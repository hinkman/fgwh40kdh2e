-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYDMG = "applydmg";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDMG, handleApplyDamage);

	ActionsManager.registerModHandler("damage", modDamage);
    ActionsManager.registerPostRollHandler("damage", onDamageRoll);
    ActionsManager.registerResultHandler("damage", onDamage);
    --ActionsManager.registerResultHandler("righteousfury", onRighteousFury);
end

function handleApplyDamage(msgOOB)
	local rSource = ActorManager.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rTarget = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);
	if rTarget then
		rTarget.nOrder = msgOOB.nTargetOrder;
	end
	
	local nTotal = tonumber(msgOOB.nTotal) or 0;
	applyDamage(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sRollType, msgOOB.sDamage, nTotal);
end

function notifyApplyDamage(rSource, rTarget, bSecret, sRollType, sDesc, nTotal)
	if not rTarget then
		return;
	end
	local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
	if sTargetType ~= "pc" and sTargetType ~= "ct" then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDMG;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sRollType = sRollType;
	msgOOB.nTotal = nTotal;
	msgOOB.sDamage = sDesc;
	msgOOB.sTargetType = sTargetType;
	msgOOB.sTargetNode = sTargetNode;
	msgOOB.nTargetOrder = rTarget.nOrder;

	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	Comm.deliverOOBMessage(msgOOB, "");
end

function getRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "damage";
	rRoll.aDice = {};
	rRoll.nMod = 0;
	rRoll.sDesc = "[DAMAGE: ";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
    
    rRoll.sAbilities = rAction.stat;
    
	if rAction.range then
		rRoll.sDesc = rRoll.sDesc .. " " .. rAction.range .. "]";
        rRoll.range = rAction.range;
	end

    rRoll.sDesc = rRoll.sDesc .. " " .. rAction.label .. " -> Pen: " .. rAction.pen;
    
    local bFelling = rAction.felling;
    if tonumber(bFelling) > 0 then
        rRoll.sDesc = rRoll.sDesc .. ", Felling: " .. rAction.felling;
    else
        rRoll.sDesc = rRoll.sDesc
    end
    
    local bProven = rAction.proven;
    if tonumber(bProven) > 0 then
        ActionsManager2.encodeProven(rRoll, bProven);
    end
    if tonumber(bProven) > 0 then
        rRoll.sDesc = rRoll.sDesc .. ", Proven: " .. rAction.proven;
    else
        rRoll.sDesc = rRoll.sDesc
    end
    
    local bTearing = rAction.tearing;
    if bTearing ~= false then
        ActionsManager2.encodeAdvantage(rRoll, bTearing);
    end
    if bTearing ~= false then
        rRoll.sDesc = rRoll.sDesc .. ", Tearing";
    else
        rRoll.sDesc = rRoll.sDesc
    end
    
    if rAction.primitive == true then
        rRoll.sDesc = rRoll.sDesc .. ", Primitive";
    else
        rRoll.sDesc = rRoll.sDesc
    end
 
    rRoll.sDesc = rRoll.sDesc .. " >> Location: " .. rAction.location;
    
    if rAction.cover == true then
        rRoll.sDesc = rRoll.sDesc .. " (Covered) <<";
    else
        rRoll.sDesc = rRoll.sDesc .. " <<";
    end 
    
    	-- Save the damage clauses in the roll structure
	rRoll.clauses = rAction.clauses;
    
    	-- Add the dice and modifiers
	for _,vClause in pairs(rRoll.clauses) do
		for _,vDie in ipairs(vClause.dice) do
			table.insert(rRoll.aDice, vDie);
		end
		rRoll.nMod = rRoll.nMod + vClause.modifier;
	end
	
	-- Encode the damage types
	encodeDamageTypes(rRoll);
 
	return rRoll;
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll, true);
end
----------------------------------
function modDamage(rSource, rTarget, rRoll)
	-- Extract damage type information from roll
	decodeDamageTypes(rRoll);

	-- Set up
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	-- Build attack type filter
	local aAttackFilter = {};
	if rRoll.range == "R" then
		table.insert(aAttackFilter, "ranged");
	elseif rRoll.range == "M" then
		table.insert(aAttackFilter, "melee");
	end
	
	-- If source actor, then get modifiers
	if rSource then
		local bEffects = false;
		local aEffectDice = {};
		local nEffectMod = 0;

		-- Apply ability modifiers
		for kClause,vClause in ipairs(rRoll.clauses) do

			-- Get any stat effects bonus
			local nBonusStat, nBonusEffects = ActorManager2.getAbilitiesEffectsBonus(rSource, rRoll.sAbilities);
			if nBonusEffects > 0 then
				bEffects = true;
				
				-- Calc total stat mod
				local nTotalStatMod = nBonusStat;
				
				-- Apply bonus difference
				nEffectMod = nEffectMod + nTotalStatMod;
				vClause.modifier = vClause.modifier + nTotalStatMod;
				rRoll.nMod = rRoll.nMod + nTotalStatMod;
			end
		end
		
		-- Apply general damage modifiers
		local aEffects, nEffectCount;
		if rRoll.sType == "damage" then
			aEffects, nEffectCount = EffectManager.getEffectsBonusByType(rSource, "DMG", true, aAttackFilter, rTarget);
		end
		if nEffectCount > 0 then
			bEffects = true;

			-- For each effect, add a damage clause
			for _,v in pairs(aEffects) do
				local rClause = {};
				
				-- Add effect dice
				rClause.dice = {};
				for _,vDie in ipairs(v.dice) do
					table.insert(aEffectDice, vDie);
					table.insert(rClause.dice, vDie);
					table.insert(rRoll.aDice, "p" .. vDie:sub(2));
				end

				-- Add effect modifier
				local nCurrentMod = v.mod;
		
				nEffectMod = nEffectMod + nCurrentMod;
				rClause.modifier = nCurrentMod;
				rRoll.nMod = rRoll.nMod + nCurrentMod;
				
				-- Add effect damage types
				local aEffectDmgType = {};
				if sEffectBaseType ~= "" then
					table.insert(aEffectDmgType, sEffectBaseType);
				end
				for _,sWord in ipairs(v.remainder) do
					if StringManager.contains(DataCommon.dmgtypes, sWord) then
						table.insert(aEffectDmgType, sWord);
					end
				end
				rClause.dmgtype = table.concat(aEffectDmgType, ",");
				
				table.insert(rRoll.clauses, rClause);
			end
		end
		
		-- Apply damage type modifiers
		local aEffects = EffectManager.getEffectsByType(rSource, "DMGTYPE", {});
		local aAddTypes = {};
		for _,v in ipairs(aEffects) do
			for _,v2 in ipairs(v.remainder) do
				if StringManager.contains(DataCommon.dmgtypes, v2) then
					table.insert(aAddTypes, v2);
				end
			end
		end
		if #aAddTypes > 0 then
			for _,vClause in ipairs(rRoll.clauses) do
				local aSplitTypes = StringManager.split(vClause.dmgtype, ",", true);
				for _,v2 in ipairs(aAddTypes) do
					if not StringManager.contains(aSplitTypes, v2) then
						if vClause.dmgtype ~= "" then
							vClause.dmgtype = vClause.dmgtype .. "," .. v2;
						else
							vClause.dmgtype = v2;
						end
					end
				end
			end
		end
		
		-- Apply condition modifiers
		if rRoll.sType == "damage" then
			if EffectManager.hasEffectCondition(rSource, "Sickened") then
                if rRoll.sAbilities ~= "ammo" then
                    rRoll.nMod = rRoll.nMod - 2;
                    nEffectMod = nEffectMod -2;
                    bEffects = true;
                end
            end
        end
        
        if rRoll.sType == "damage" then
            if EffectManager.hasEffectCondition(rSource, "Weakened") then
                if rRoll.sAbilities ~= "ammo" then
                    rRoll.nMod = rRoll.nMod - 2;
                    nEffectMod = nEffectMod -2;
                    bEffects = true;
                end
            end
        end
        
        ---- Comment Out Need to figure out how to add pen from Ct
        --if EffectManager.hasEffectCondition(rSource, "PEN") then
        --    if rRoll.range == "R" then
        --       nEffectMod = rAction.pen + nEffectMod;
        --        bEffects = true;
        --    end
		--end

		-- Add note about effects
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aEffectDice, nEffectMod, true);
			if sMod ~= "" then
				sEffects = " [" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = " [" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
	end
	
	-- Add notes to roll description
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end

	-- Add damage type info to roll description
	encodeDamageTypes(rRoll);
end
----------------------------
function onDamageRoll(rSource, rRoll)
    ActionsManager2.decodeAdvantage(rRoll);
    ActionsManager2.decodeProven(rRoll);
    
	-- Decode damage types
	decodeDamageTypes(rRoll);
    
    --CHECK FOR RIGHTEOUS FURY (works, but how to handle the confirming roll? not added to damage calcs, just throws a d10)
        --local nResult = rRoll.aDice[1].result;
        --if nResult == 10 then
        --    local rRighteousFuryRoll = { sType = "righteousfury", sDesc = "Righteous Fury Check", aDice = {"d100", "d10"}, nMod = 0 };
        --    ActionsManager.roll(rSource, rTarget, rRighteousFuryRoll);
        --end
	
	-- Encode the dadmage results for damage application and readability
	encodeDamageText(rRoll);
end
-----------------------------
function onDamage(rSource, rTarget, rRoll)
	if #(rRoll.aDice) == 0 then
		decodeDamageTypes(rRoll);
		encodeDamageText(rRoll);
	end
	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.text = string.gsub(rMessage.text, " %[MOD:[^]]*%]", "");

	local nTotal = ActionsManager.total(rRoll);
	
	-- Send the chat message
	local bShowMsg = true;
	if rTarget and rTarget.nOrder and rTarget.nOrder ~= 1 then
		bShowMsg = false;
	end
	if bShowMsg then
		Comm.deliverChatMessage(rMessage);
	end

	-- Apply damage to the PC or CT entry referenced
	notifyApplyDamage(rSource, rTarget, rMessage.secret, rRoll.sType, rMessage.text, nTotal);
end
-----------------------------
--
-- UTILITY FUNCTIONS
--
-----------------------------
function encodeDamageTypes(rRoll)
	for _,vClause in ipairs(rRoll.clauses) do
		local sDice = StringManager.convertDiceToString(vClause.dice, vClause.modifier);
		rRoll.sDesc = rRoll.sDesc .. string.format(" [Type: %s (%s) (%s)]", vClause.dmgtype, sDice, vClause.stat or "");
	end
end

function decodeDamageTypes(rRoll)
	-- Process each type clause in the damage description as encoded previously
	local nMainDieIndex = 0;
	rRoll.clauses = {};
	for sDmgType, sDmgDice, sDmgStat in string.gmatch(rRoll.sDesc, "%[Type: ([^(]*) %(([^)]*)%) %(([^)]*)%)%]") do
		local rClause = {};
		rClause.dmgtype = StringManager.trim(sDmgType);
		rClause.dice, rClause.modifier = StringManager.convertStringToDice(sDmgDice);
		rClause.stat = sDmgStat;
		
		rClause.nTotal = rClause.modifier;
		for _,vDie in ipairs(rClause.dice) do
			nMainDieIndex = nMainDieIndex + 1;
			rClause.nTotal = rClause.nTotal + (rRoll.aDice[nMainDieIndex].result or 0);
		end
		
		table.insert(rRoll.clauses, rClause);
	end
	
	-- Handle rolls that went straight to roll without going through whole system (i.e. ongoing damage, regen, fast heal, etc.)
	if #(rRoll.clauses) == 0 then
		local sDmgType = string.match(rRoll.sDesc, "%[Type: ([^(%]]*)%]");
		if sDmgType then
			local rClause = {};
			rClause.dmgtype = StringManager.trim(sDmgType);
			rClause.dice = {};
			for _,vDie in ipairs(rRoll.aDice) do
				table.insert(rClause.dice, vDie.type);
			end
			rClause.modifier = rRoll.nMod;
			rClause.stat = "";
			rClause.nTotal = ActionsManager.total(rRoll);
		
			table.insert(rRoll.clauses, rClause);
		end
	end
	
	-- Remove damage type information from roll description
	rRoll.sDesc = string.gsub(rRoll.sDesc, " %[Type:[^]]*%]", "");
end
-------------------------------
function getDamageTypesFromString(sDamageTypes)
	local sLower = string.lower(sDamageTypes);
	local aSplit = StringManager.split(sLower, ",", true);
	
	local aDamageTypes = {};
	for k, v in ipairs(aSplit) do
		if StringManager.contains(DataCommon.dmgtypes, v) then
			table.insert(aDamageTypes, v);
		end
	end
	
	return aDamageTypes;
end

--
-- DAMAGE APPLICATION
--
function getParenDepth(sText, nIndex)
	local nDepth = 0;
	
	local cStart = string.byte("(");
	local cEnd = string.byte(")");
	
	for i = 1, nIndex do
		local cText = string.byte(sText, i);
		if cText == cStart then
			nDepth = nDepth + 1;
		elseif cText == cEnd then
			nDepth = nDepth - 1;
		end
	end
	
	return nDepth;
end

function decodeAndOrClauses(sText)
	local nIndexOR;
	local nStartOR, nEndOR, nStartAND, nEndAND;
	local nStartOR2, nEndOR2;
	local nParen;
	local sPhraseOR;

	local aClausesOR = {};
	local aSkipOR = {};
	local nIndexOR = 1;
	while nIndexOR < #sText do
		local nTempIndex = nIndexOR;
		repeat
			nParen = 0;
			nStartOR, nEndOR = string.find(sText, "%s+or%s+", nTempIndex);
			nStartOR2, nEndOR2 = string.find(sText, "%s*;%s*", nTempIndex);
			
			if nStartOR2 and (not nStartOR or nStartOR > nStartOR2) then
				nStartOR = nStartOR2;
				nEndOR = nEndOR2;
			end
			
			if nStartOR then
				nParen = getParenDepth(sText, nStartOR);
				if nParen ~= 0 then
					nTempIndex = nEndOR + 1;
				end
			end
		until not nStartOR or nParen == 0;
		
		if nStartOR then
			sPhraseOR = string.sub(sText, nIndexOR, nStartOR - 1);
		else
			sPhraseOR = string.sub(sText, nIndexOR);
		end

		local aClausesAND = {};
		local aSkipAND = {};
		local nIndexAND = 1;
		while nIndexAND < #sPhraseOR do
			nTempIndex = nIndexAND;
			repeat
				nParen = 0;
				nStartAND, nEndAND = string.find(sPhraseOR, "%s+and%s+", nTempIndex);
				
				if nStartAND then
					nParen = getParenDepth(sText, nIndexOR + nStartAND);
					if nParen ~= 0 then
						nTempIndex = nEndAND + 1;
					end
				end
			until not nStartAND or nParen == 0;
			
			if nStartAND then
				table.insert(aClausesAND, string.sub(sPhraseOR, nIndexAND, nStartAND - 1));
				nIndexAND = nEndAND + 1;
				table.insert(aSkipAND, nEndAND - nStartAND + 1);
			else
				table.insert(aClausesAND, string.sub(sPhraseOR, nIndexAND));
				nIndexAND = #sPhraseOR;
				if nStartOR then
					table.insert(aSkipAND, nEndOR - nStartOR + 1);
				else
					table.insert(aSkipAND, 0);
				end
			end
		end
		
		if nStartOR then
			nIndexOR = nEndOR + 1;
		else
			nIndexOR = #sText;
		end

		table.insert(aClausesOR, aClausesAND);
		table.insert(aSkipOR, aSkipAND);
	end
	
	return aClausesOR, aSkipOR;
end

function matchAndOrClauses(aClausesOR, aMatchWords)
	for kClauseOR, aClausesAND in ipairs(aClausesOR) do
		local bMatchAND = true;
		local nMatchAND = 0;

		for kClauseAND, sClause in ipairs(aClausesAND) do
			nMatchAND = nMatchAND + 1;

			if not StringManager.contains(aMatchWords, sClause) then
				bMatchAND = false;
				break;
			end
		end
		
		if bMatchAND and nMatchAND > 0 then
			return true;
		end
	end
		
	return false;
end

function getDamageAdjust(rSource, rTarget, nDamage, rDamageOutput)
	-- SETUP
	local nDamageAdjust = 0;
	local bVulnerable = false;
	local bResist = false;
	local aWords;
	
	-- GET THE DAMAGE ADJUSTMENT EFFECTS
	local aImmune = EffectManager.getEffectsBonusByType(rTarget, "IMMUNE", false, {}, rSource);
	local aVuln = EffectManager.getEffectsBonusByType(rTarget, "VULN", false, {}, rSource);
	local aResist = EffectManager.getEffectsBonusByType(rTarget, "RESIST", false, {}, rSource);
    local aDR = EffectManager.getEffectsByType(rTarget, "DR", {}, rSource);
	
	-- IF IMMUNE ALL, THEN JUST HANDLE IT NOW
	if aImmune["all"] then
		nDamageAdjust = 0 - nDamage;
		bResist = true;
		return nDamageAdjust, bVulnerable, bResist;
	end
	
	-- HANDLE REGENERATION
	local aRegen = EffectManager.getEffectsBonusByType(rTarget, "REGEN", false, {});
	local nRegen = 0;
	for _, _ in pairs(aRegen) do
		nRegen = nRegen + 1;
	end
	if nRegen > 0 then
		local aRemap = {};
		for k,v in pairs(rDamageOutput.aDamageTypes) do
			local bCheckRegen = true;
			
			local aSrcDmgClauseTypes = {};
			local aTemp = StringManager.split(k, ",", true);
			for i = 1, #aTemp do
				if aTemp[i] == "nonlethal" then
					bCheckRegen = false;
					break;
				end    
				if aTemp[i] ~= "untyped" and aTemp[i] ~= "" then
					table.insert(aSrcDmgClauseTypes, aTemp[i]);
				end
			end

			if bCheckRegen then
				local bMatchAND, nMatchAND, bMatchDMG, aClausesOR;
				local bApplyRegen;
				for kRegen, vRegen in pairs(aRegen) do
					bApplyRegen = true;
					
					local sRegen = table.concat(vRegen.remainder, " ");
					
					aClausesOR = decodeAndOrClauses(sRegen);
					if matchAndOrClauses(aClausesOR, aSrcDmgClauseTypes) then
						bApplyRegen = false;
					end
					
					if bApplyRegen then
						local kNew = table.concat(aSrcDmgClauseTypes, ",");
						if kNew ~= "nonlethal" then
							kNew = kNew .. ", ";
						else
							kNew = " ";
						end
						aRemap[k] = kNew;
					end
				end
			end
		end
		for k,v in pairs(aRemap) do
			rDamageOutput.aDamageTypes[v] = rDamageOutput.aDamageTypes[k];
			rDamageOutput.aDamageTypes[k] = nil;
		end
	end
	
	-- ITERATE THROUGH EACH DAMAGE TYPE ENTRY
	local nVulnApplied = 0;
	for k, v in pairs(rDamageOutput.aDamageTypes) do
		-- GET THE INDIVIDUAL DAMAGE TYPES FOR THIS ENTRY (EXCLUDING UNTYPED DAMAGE TYPE)
		local aSrcDmgClauseTypes = {};
		local bHasEnergyType = false;
		local aTemp = StringManager.split(k, ",", true);
		for i = 1, #aTemp do
			if aTemp[i] ~= "untyped" and aTemp[i] ~= "" then
				table.insert(aSrcDmgClauseTypes, aTemp[i]);
				if not bHasEnergyType and (StringManager.contains(DataCommon.energytypes, aTemp[i])) then
					bHasEnergyType = true;
				end
			end
		end

		-- HANDLE IMMUNITY, VULNERABILITY AND RESISTANCE
		local nLocalDamageAdjust = 0;
		if #aSrcDmgClauseTypes > 0 then
			-- CHECK VULN TO DAMAGE TYPES
			for keyDmgType, sDmgType in pairs(aSrcDmgClauseTypes) do
				if not aImmune[sDmgType] and aVuln[sDmgType] and not aVuln[sDmgType].nApplied then
					nLocalDamageAdjust = nLocalDamageAdjust + math.floor(v / 2);
					aVuln[sDmgType].nApplied = v;
					bVulnerable = true;
				end
			end
			
			-- CHECK EACH DAMAGE TYPE
			for keyDmgType, sDmgType in pairs(aSrcDmgClauseTypes) do
				-- IF IMMUNE, THEN DISCOUNT ALL OF THIS DAMAGE
				if aImmune[sDmgType] then
					nLocalDamageAdjust = nLocalDamageAdjust - v;
					bResist = true;
				else
					-- CHECK RESISTANCE
					if aResist[sDmgType] then
						local nApplied = aResist[sDmgType].nApplied or 0;
						if nApplied < aResist[sDmgType].mod then
							local nChange = math.min((aResist[sDmgType].mod - nApplied), v + nLocalDamageAdjust);
							aResist[sDmgType].nApplied = nApplied + nChange;
							nLocalDamageAdjust = nLocalDamageAdjust - nChange;
							bResist = true;
						end
					end
				end
			end
		end
		
		-- HANDLE DR  (FORM: <type> and <type> or <type> and <type>)
		if not bHasEnergyType and (v + nLocalDamageAdjust) > 0 then
			local bMatchAND, nMatchAND, bMatchDMG, aClausesOR;
			
			local bApplyDR;
			for _,vDR in pairs(aDR) do
				local kDR = table.concat(vDR.remainder, " ");
				
				if kDR == "" or kDR == "-" or kDR == "all" then
					bApplyDR = true;
				else
					bApplyDR = true;
					aClausesOR = decodeAndOrClauses(kDR);
					if matchAndOrClauses(aClausesOR, aSrcDmgClauseTypes) then
						bApplyDR = false;
					end
				end

				if bApplyDR then
					local nApplied = vDR.nApplied or 0;
					if nApplied < vDR.mod then
						local nChange = math.min((vDR.mod - nApplied), v + nLocalDamageAdjust);
						vDR.nApplied = nApplied + nChange;
						nLocalDamageAdjust = nLocalDamageAdjust - nChange;
						bResist = true;
					end
				end
			end
		end
        
		-- APPLY DAMAGE ADJUSTMENT FROM THIS DAMAGE CLAUSE TO OVERALL DAMAGE ADJUSTMENT
		nDamageAdjust = nDamageAdjust + nLocalDamageAdjust;
	end
	
	-- RESULTS
	return nDamageAdjust, bVulnerable, bResist;
end
----------------------------------------------
-- Collapse damage clauses by damage type (in the original order, if possible)
function getDamageStrings(clauses)
	local aOrderedTypes = {};
	local aDmgTypes = {};
	for _,vClause in ipairs(clauses) do
		local rDmgType = aDmgTypes[vClause.dmgtype];
		if not rDmgType then
			rDmgType = {};
			rDmgType.aDice = {};
			rDmgType.nMod = 0;
			rDmgType.nTotal = 0;
			rDmgType.sType = vClause.dmgtype;
			aDmgTypes[vClause.dmgtype] = rDmgType;
			table.insert(aOrderedTypes, rDmgType);
		end

		for _,vDie in ipairs(vClause.dice) do
			table.insert(rDmgType.aDice, vDie);
		end
		rDmgType.nMod = rDmgType.nMod + vClause.modifier;
		rDmgType.nTotal = rDmgType.nTotal + (vClause.nTotal or 0);
	end
	
	return aOrderedTypes;
end

function encodeDamageText(rRoll)
	local aDamage = getDamageStrings(rRoll.clauses);
	for _, rDamage in ipairs(aDamage) do
		local sDmgTypeOutput = rDamage.sType;
		if sDmgTypeOutput == "" then
			sDmgTypeOutput = "untyped";
		end
		
		if #rDamage.aDice == 0 then
            rRoll.sDesc = rRoll.sDesc .. string.format(" [Type: %s]", sDmgTypeOutput);
		else
			local sDice = StringManager.convertDiceToString(rDamage.aDice, rDamage.nMod);
            rRoll.sDesc = rRoll.sDesc .. string.format(" [Type: %s]", sDmgTypeOutput);
		end
	end
end

function decodeDamageText(nDamage, sDamageDesc)
	local rDamageOutput = {};
	
	if string.match(sDamageDesc, "%[FHEAL") then
		rDamageOutput.sType = "fheal";
		rDamageOutput.sTypeOutput = "Fast healing";
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

	elseif string.match(sDamageDesc, "%[REGEN") then
        rDamageOutput.sType = "regen";
        rDamageOutput.sTypeOutput = "Regeneration";
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

	elseif nDamage < 0 then
		rDamageOutput.sType = "heal";
		rDamageOutput.sTypeOutput = "Heal";
		rDamageOutput.sVal = string.format("%01d", (0 - nDamage));
		rDamageOutput.nVal = 0 - nDamage;

	else
		rDamageOutput.sType = "damage";
		rDamageOutput.sTypeOutput = "Damage";
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

		-- Determine range
		rDamageOutput.sRange = string.match(sDamageDesc, "%[DAMAGE %((%w)%)%]") or "";
		rDamageOutput.aDamageFilter = {};
		if rDamageOutput.sRange == "M" then
			table.insert(rDamageOutput.aDamageFilter, "melee");
		elseif rDamageOutput.sRange == "R" then
			table.insert(rDamageOutput.aDamageFilter, "ranged");
		end

		-- Determine damage energy types
		rDamageOutput.aDamageTypes = {};
		local nDamageRemaining = nDamage;
		for sDamageType in sDamageDesc:gmatch("%[Type: ([^%]]+)%]") do
			local sDmgType = StringManager.trim(sDamageType:match("^([^(%]]+)"));

			local sTotal = sDamageType:match("%((%d+)%)");
    
			local nDmgTypeTotal = tonumber(sTotal) or nDamageRemaining;

			if rDamageOutput.aDamageTypes[sDmgType] then
				rDamageOutput.aDamageTypes[sDmgType] = rDamageOutput.aDamageTypes[sDmgType] + nDmgTypeTotal;
			else
				rDamageOutput.aDamageTypes[sDmgType] = nDmgTypeTotal;
			end
			if not rDamageOutput.sFirstDamageType then
				rDamageOutput.sFirstDamageType = sDmgType;
			end

			nDamageRemaining = nDamageRemaining - nDmgTypeTotal;
		end
		if nDamageRemaining > 0 then
			rDamageOutput.aDamageTypes[""] = nDamageRemaining;
		elseif nDamageRemaining < 0 then
			ChatManager.SystemMessage("Total mismatch in damage type totals");
		end
		
	end
	
	return rDamageOutput;
end
---------------------------------
function applyDamage(rSource, rTarget, bSecret, sRollType, sDamage, nTotal)
	-- SETUP
    local nMaxWds = 0;
	local nWounds = 0;

	local aNotifications = {};
    
	-- GET HEALTH FIELDS
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	if sTargetType ~="pc" and sTargetType ~= "ct" then
		return;
	end
	
	if sTargetType == "pc" then
        nMaxWds = DB.getValue(nodeTarget, "totalwounds", 0);
		nWounds = DB.getValue(nodeTarget, "wounds", 0);
        nCover = DB.getValue(nodeTarget, "cover", 0);
	else
        nMaxWds = DB.getValue(nodeTarget, "totalwounds", 0);
		nWounds = DB.getValue(nodeTarget, "wounds", 0);
        nCover = DB.getValue(nodeTarget, "cover", 0);
	end

	-- DECODE DAMAGE DESCRIPTION
	local rDamageOutput = decodeDamageText(nTotal, sDamage);
	
	-- HEALING
	if rDamageOutput.sType == "heal" or rDamageOutput.sType == "fheal" then
		-- CHECK COST
		if nWounds <= 0 then
			table.insert(aNotifications, "[NOT WOUNDED]");
		else
			-- CALCULATE HEAL AMOUNTS
			local nHealAmount = rDamageOutput.nVal;
			
			if rDamageOutput.sType == "fheal" then
				nHealAmount = nHealAmount;
			end

			local nOriginalWounds = nWounds;
			
			local nWoundHealAmount = math.min(nHealAmount, nWounds);
			nWounds = nWounds - nWoundHealAmount;
			
			-- IF WE HEALED FROM NEGATIVE TO ZERO OR HIGHER, THEN REMOVE STABLE EFFECT
			if (nOriginalWounds > nWounds) and (nWounds <= nMaxWds) then
				EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
			end
			
			-- SET THE ACTUAL HEAL AMOUNT FOR DISPLAY
			rDamageOutput.nVal = nWoundHealAmount;
			if nWoundHealAmount > 0 then
				rDamageOutput.sVal = "Healed " .. nWoundHealAmount;
			else
				rDamageOutput.sVal = "0";
			end
		end

	-- Working REGENERATION
	elseif rDamageOutput.sType == "regen" then
		if nWounds <= 0 then
			table.insert(aNotifications, "No Damage");
		else
            local nHealAmount = rDamageOutput.nVal;
            
            local nOriginalWounds = nWounds;
            
			local nWoundHealAmount = math.min(nHealAmount, nWounds);
            nWounds = nOriginalWounds - nWoundHealAmount;
		
            rDamageOutput.nVal = nWoundHealAmount;
            if nWoundHealAmount > 0 then
				rDamageOutput.sVal = "" .. nWoundHealAmount;
			else
				rDamageOutput.sVal = "0";
			end

		end

	else
	
		-- APPLY ANY TARGETED DAMAGE EFFECTS
		-- NOTE: DICE ARE RANDOMLY DETERMINED BY COMPUTER, INSTEAD OF ROLLED
		if rSource and rTarget and rTarget.nOrder then
			local aTargetedDamage;
			if sRollType == "damage" then
				aTargetedDamage = EffectManager.getEffectsBonusByType(rSource, {"DMG"}, true, rDamageOutput.aDamageFilter, rTarget, true);
			end

			local nDamageEffectTotal = 0;
			local nDamageEffectCount = 0;
			for k, v in pairs(aTargetedDamage) do
				local nSubTotal = StringManager.evalDice(v.dice, v.mod);
				
				local sDamageType = rDamageOutput.sFirstDamageType;
				if sDamageType then
					sDamageType = sDamageType .. "," .. k;
				else
					sDamageType = k;
				end

				rDamageOutput.aDamageTypes[sDamageType] = (rDamageOutput.aDamageTypes[sDamageType] or 0) + nSubTotal;
				
				nDamageEffectTotal = nDamageEffectTotal + nSubTotal;
				nDamageEffectCount = nDamageEffectCount + 1;
			end
			nTotal = nTotal + nDamageEffectTotal;

			if nDamageEffectCount > 0 then
				if nDamageEffectTotal ~= 0 then
					local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]";
					table.insert(aNotifications, string.format(sFormat, nDamageEffectTotal));
				else
					table.insert(aNotifications, "[" .. Interface.getString("effects_tag") .. "]");
				end
			end
		end
		
		-- APPLY ANY DAMAGE TYPE ADJUSTMENT EFFECTS
		local nDamageAdjust, bVulnerable, bResist = getDamageAdjust(rSource, rTarget, nTotal, rDamageOutput);

		-- ADDITIONAL DAMAGE ADJUSTMENTS NOT RELATED TO DAMAGE TYPE
		local nAdjustedDamage = nTotal + nDamageAdjust;
		if nAdjustedDamage < 0 then
			nAdjustedDamage = 0;
		end
		if bResist then
			if nAdjustedDamage <= 0 then
				table.insert(aNotifications, "[Resist]");
			else
				table.insert(aNotifications, "[Partial Resist]");
			end
		end
		if bVulnerable then
			table.insert(aNotifications, "[VULNERABLE]");
		end
		
        --
        --Armor vs. Pen
        --
        if sRollType == "damage" then
            local sLocation = string.match(sDamage, "Location:%s(%w+)");
            if sLocation == "HD" then
                aAR = DB.getValue(nodeTarget, "armor.head", 0);
            elseif sLocation == "RA" then
                aAR = DB.getValue(nodeTarget, "armor.ra", 0);
            elseif sLocation == "LA" then
                aAR = DB.getValue(nodeTarget, "armor.la", 0);
            elseif sLocation == "BD" then
                aAR = DB.getValue(nodeTarget, "armor.body", 0);
            elseif sLocation == "RL" then
                aAR = DB.getValue(nodeTarget, "armor.rl", 0);
            elseif sLocation == "LL" then
                aAR = DB.getValue(nodeTarget, "armor.ll", 0);
            elseif sLocation == "NA" then
                aAR = 0;
            end
        
            local isPrimitive = string.match(sDamage, "Primitive");
            if  isPrimitive then
                aAR = aAR * 2;
            else
                aAR = aAR;
            end
        
            local isCover = string.match(sDamage, "%(Covered%)");
            if isCover then
                aAR = aAR + nCover;
            else
                aAR = aAR;
            end
        
            local aTnb = 0;  -- recalculate the toughness bonus here so we can use the weapon effects
            local aTn = DB.getValue(nodeTarget, "abilities.toughness", 0);
            local aUC = DB.getValue(nodeTarget, "abilities.tnmult", 0);
            local aTTn = 0;
            local isFelling = string.match(sDamage, "Felling:%s(%d+)");
            local aFelling = tonumber(isFelling);
            local isPen = string.match(sDamage, "Pen:%s(%d+)");
            local aPen =   tonumber(isPen); 
            local nSoak = 0;
            --long descriptors for effect types
            local islTox = string.match(sDamage, "%[Type:%stoxin") or string.match(sDamage, "%[Type:%s%w+,toxin");
            local islWarp = string.match(sDamage, "%[Type:%swarp") or string.match(sDamage, "%[Type:%s%w+,warp");
            local islWarpfire = string.match(sDamage, "%[Type:%swarpfire") or string.match(sDamage, "%[Type:%s%w+,warpfire");
            local islHoly = string.match(sDamage, "%[Type:%sholy") or string.match(sDamage, "%[Type:%s%w+,holy");
            local islForce = string.match(sDamage, "%[Type:%sforce") or string.match(sDamage, "%[Type:%s%w+,force");
            local islForceC = string.match(sDamage, "%[Type:%sforce%schannled") or string.match(sDamage, "%[Type:%s%w+,force%schannled");
            local islSanctified = string.match(sDamage, "%[Type:%ssanctified") or string.match(sDamage, "%[Type:%s%w+,sanctified");
            --short descriptors for weapons from inventory
            local isWarp = string.match(sDamage, "%[Type:%sw") or string.match(sDamage, "%[Type:%s%w+,w");
            local isHoly = string.match(sDamage, "%[Type:%sh") or string.match(sDamage, "%[Type:%s%w+,h");
            local isForce = string.match(sDamage, "%[Type:%sf") or string.match(sDamage, "%[Type:%s%w+,f");
            local isSanctified = string.match(sDamage, "%[Type:%ss") or string.match(sDamage, "%[Type:%s%w+,s");
 
            if isFelling then -- finds the felling type weapons so we can discount Unnatural Characteristics
                if aFelling <=0 then 
                    aUC = aUC;
                else
                    aUC = aUC - aFelling;
                    if aUC <=0 then
                        aUC = 1;
                    end
                end    
            end    
        
            aTnb = math.floor(aTn/10); -- gives base toughness bonus so force, holy, sanctified types work properly
        
            aTTn = aTnb * aUC;  -- total toughness bonus to use in soak calcs
        
            if islWarpfire or islForceC then  -- these types pass thru armor and toughness
                nSoak = 0;
                
            elseif islTox or islWarp or isWarp then  -- these types pass thru armor **note: the tag "toxin" should only be used as an effect not weapon damaage type**
                nSoak = aTTn; 
                
            elseif islSanctified or islForce or islHoly or isSanctified or isForce or isHoly then  --these types allow only base toughness bonus/armor vs. damage/pen    
                if aPen > aAR then
                    aAR = 0;
                elseif aPen == aAR then
                    aAR = 0;
                elseif aPen < aAR then
                    aAR = aAR - aPen;
                end
                nSoak = aAR + aTnb;
                
            elseif nAdjustedDamage > 0 then -- these use the standard damage/pen vs. toughness bonus/armor
                if aPen > aAR then
                        aAR = 0;
                elseif aPen == aAR then
                        aAR = 0;
                elseif aPen < aAR then
                    aAR = aAR - aPen;
                end
                nSoak = aAR + aTTn;    
            end
            nAdjustedDamage = nAdjustedDamage - nSoak;
            if nAdjustedDamage <= 0 then
                nAdjustedDamage = 0;
            else
                nAdjustedDamage = nAdjustedDamage;
            end
        		-- Update the damage output variable to reflect adjustments
            rDamageOutput.nVal = nAdjustedDamage;
            if nAdjustedDamage > 0 then
                rDamageOutput.sVal = "" .. nAdjustedDamage .. "] [" .. "DR: " .. nSoak;
            else
                rDamageOutput.sVal = "0" .. "] [" .. "DR: " .. nSoak;
            end
        end

		-- APPLY REMAINING DAMAGE
        local nOriginalWounds = nWounds;
        nWounds = nOriginalWounds + nAdjustedDamage;
        if nWounds < 0 then
            nWounds = 0;
        end
        
        if nCover > 0 then
            if nAdjustedDamage > nCover then
                nCover = nCover - 1;
            end
            if nCover < 0 then
                nCover = 0;
            end
        end
        
    end

	-- SET HEALTH FIELDS
	if sTargetType == "pc" then
		DB.setValue(nodeTarget, "wounds", "number", nWounds);
        DB.setValue(nodeTarget, "cover", "number", nCover);
	else
		DB.setValue(nodeTarget, "damagetaken", "number", nWounds);
        DB.setValue(nodeTarget, "cover", "number", nCover);
	end
	
	-- OUTPUT RESULTS
	messageDamage(rSource, rTarget, bSecret, rDamageOutput.sTypeOutput, sDamage, rDamageOutput.sVal, table.concat(aNotifications, " "));
end

function messageDamage(rSource, rTarget, bSecret, sDamageType, sDamageDesc, sTotal, sExtraResult)
	if not (rTarget or sExtraResult ~= "") then
		return;
	end
	
	local msgShort = {font = "reportfont"};
	local msgLong = {font = "reportfont"};

	if sDamageType == "Heal" or sDamageType == "fHeal" then
		msgShort.icon = "roll_heal";
		msgLong.icon = "roll_heal";
	else
		msgShort.icon = "roll_damage";
		msgLong.icon = "roll_damage";
	end

	msgShort.text = sDamageType .. " ->";
	msgLong.text = sDamageType .. " [" .. sTotal .. "] ->";
	if rTarget then
		msgShort.text = msgShort.text .. " [to " .. rTarget.sName .. "]";
		msgLong.text = msgLong.text .. " [to " .. rTarget.sName .. "]";
	end
	
	if sExtraResult and sExtraResult ~= "" then
		msgLong.text = msgLong.text .. " " .. sExtraResult;
	end
	
	ActionsManager.messageResult(bSecret, rSource, rTarget, msgLong, msgShort);
end
