-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerModHandler("skill", modSkill);
	ActionsManager.registerResultHandler("skill", onRoll);
end

function performSRoll(draginfo, rActor, nodeWin)
	local sSkillName = DB.getValue(nodeWin, "name", "");
    local nSkillMod = 0;
    local sSkillStat = DB.getValue(nodeWin, "statname", "");
    local nSkillTemp = DB.getValue(nodeWin, ".skill_temp", 0);
	local nSkillTarget = DB.getValue(nodeWin, "skillroll", 0);   
	
	performRoll(draginfo, rActor, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget);
end

function performPRoll(draginfo, rActor, nodeWin, sSkillName, sSkillStat, nSkillTemp, nSkillTarget)
	local sSkillName = "Parry";
    local nSkillMod = 0;
    local sSkillStat = "weapon";
    local nSkillTemp = DB.getValue(nodeWin, ".skill_temp", 0);
	local nSkillTarget = DB.getValue(nodeWin, "parryroll", 0);  
	
	performRoll(draginfo, rActor, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget);
end

function getRoll(rActor, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget, bSecretRoll)
	local rRoll = {};
	rRoll.sType = "skill";
	rRoll.aDice = { "d100" , "d10" };
    rRoll.sDesc = "[SKILL: " .. sSkillName .. "]";
    rRoll.nMod = 0;
    rRoll.sAbilities = sSkillStat;
	rRoll.nTarget = nSkillTarget;
	rRoll.bSecret = bSecretRoll;
    
    rRoll.nTemp = nSkillTemp;

    local sAbilitiesEffect = DataCommon.abilities_ltos[sSkillStat];
    if sAbilitiesEffect then
        rRoll.sDesc = rRoll.sDesc .. " [Trait: " .. sAbilitiesEffect .. "]";
    end
    
    if nSkillTemp == 0 then
        rRoll.sDesc = rRoll.sDesc;
    elseif nSkillTemp > 0 then
        rRoll.sDesc = rRoll.sDesc .. " [Temp: " .. "+" .. nSkillTemp .. "]";
    elseif nSkillTemp < 0 then
        rRoll.sDesc = rRoll.sDesc .. " [Temp: " .. nSkillTemp .. "]";
    end
	
	return rRoll;
end

function performRoll(draginfo, rActor, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget, bSecretRoll)
	local rRoll = getRoll(rActor, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget, bSecretRoll);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function modSkill(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	if rSource then

		-- Determine skill used
		local sSkillLower = "";
		local sSkill = string.match(rRoll.sDesc, "%[SKILL:%s(%w+)");
		if sSkill then
			sSkillLower = string.lower(StringManager.trim(sSkill));
		end 

		-- Build effect filter for this skill
		local aSkillFilter = { rRoll.sAbilities };
		local aSkillNameFilter = {};
		local aSkillWordsLower = StringManager.parseWords(sSkillLower);
		if #aSkillWordsLower > 0 then
			table.insert(aSkillFilter, table.concat(aSkillWordsLower, " "));
		end

		-- Get effects
        local bEffects = false;
        local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager.getEffectsBonus(rSource, {"SKILL"}, false, aSkillFilter);
		if (nEffectCount > 0) then
			bEffects = true;
		end
        		
		-- Get condition modifiers
		if EffectManager.hasEffectCondition(rSource, "Frightened") or 
				EffectManager.hasEffectCondition(rSource, "Panicked") or
				EffectManager.hasEffectCondition(rSource, "Shaken") then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
		if EffectManager.hasEffectCondition(rSource, "Sickened") then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
        if EffectManager.hasEffectCondition(rSource, "Entangled") then
			bEffects = true;
			nAddMod = nAddMod - 20;
		end
		if EffectManager.hasEffectCondition(rSource, "Fatigued") then
            if DataCommon.abilities_label[rRoll.sAbilities] then
				bEffects = true;
				nAddMod = nAddMod - 10;
			end
        end
        if EffectManager.hasEffectCondition(rSource, "Slowed") then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
        if (EffectManager.hasEffectCondition(rSource, "Pinned") or
				EffectManager.hasEffectCondition(rSource, "Grappled")) then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
		if EffectManager.hasEffectCondition(rSource, "Blinded") then
			if sSkillLower == "search" or sSkillLower == "scrutiny" then
				bEffects = true;
				nAddMod = nAddMod - 30;
			end
		elseif EffectManager.hasEffectCondition(rSource, "Dazzled") then
			if sSkillLower == "scrutiny" or sSkillLower == "search"  then
				bEffects = true;
				nAddMod = nAddMod - 10;
			end
		end
        if EffectManager.hasEffectCondition(rSource, "Prone") then
			if sSkillLower == "dodge" then
				bEffects = true;
				nAddMod = nAddMod - 20;
			end
        end

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager2.getAbilitiesEffectsBonus(rSource, rRoll.sAbilities);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
        
		-- IF EFFECTS HAPPENED, THEN ADD NOTE
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
	end
	
	-- Add modifier stack to target number
	local sStackDesc, nStackMod = ModifierStack.getStack(true);
	ModifierStack.reset();
	if sStackDesc ~= "" then
		table.insert(aAddDesc, "[" .. sStackDesc .. "]");
	end
    nAddMod = nAddMod + nStackMod;
    
    -- Add modifiers
    if #aAddDesc > 0 then
        rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
    end
    for _,vDie in ipairs(aAddDice) do
        table.insert(rRoll.aDice, "p" .. string.sub(vDie, 2));
    end

    rRoll.nTarget = rRoll.nTarget + rRoll.nMod + nAddMod;
end

function onRoll(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nTotal = ActionsManager.total(rRoll);
	
	rMessage.text = rMessage.text .. " vs. " .. rRoll.nTarget .. "\r -->>> Outcome: " .. rollOutcome(nTotal, rRoll.nTarget);
	Comm.deliverChatMessage(rMessage);
end

function rollOutcome(rollValue, successValue)
	local desc = "";
	local value = 0;
	local lSuccessValue = tonumber(successValue);
	
	local lRollValue = rollValue;
	
	if lRollValue <= lSuccessValue then
                value = 1 + math.floor(lSuccessValue/10) - math.floor(lRollValue/10);		
		if math.floor(value) == 1 then
			desc = "1 Degree of Success";
		else
			desc = math.floor(value) .. " Degrees of Success";
		end
	else
		value = 1 + math.floor(lRollValue/10) - math.floor(lSuccessValue/10)
		if math.floor(value) == 1 then
			desc = "1 Degree of Failure";
		else
			desc = math.floor(value) .. " Degrees of Failure";
		end
	end
	return desc;
end