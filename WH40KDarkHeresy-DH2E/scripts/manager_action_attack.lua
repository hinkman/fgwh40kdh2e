-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYATK = "applyatk";


function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATK, handleApplyAttack);
    
    ActionsManager.registerTargetingHandler("attack", onTargeting);
	ActionsManager.registerModHandler("attack", modAttack);
	ActionsManager.registerResultHandler("attack", onAttack);
	ActionsManager.registerResultHandler("misschance", onMissChance);
	
end

function handleApplyAttack(msgOOB)
	local rSource = ActorManager.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rTarget = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);
	
	local nTotal = tonumber(msgOOB.nTotal) or 0;
	applyAttack(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sAttackType, msgOOB.sDesc, nTotal, msgOOB.sResults);
end
function notifyApplyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	if not rTarget then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYATK;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sAttackType = sAttackType;
	msgOOB.nTotal = nTotal;
	msgOOB.sDesc = sDesc;
	msgOOB.sResults = sResults;
    

	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
	msgOOB.sTargetType = sTargetType;
	msgOOB.sTargetNode = sTargetNode;

	Comm.deliverOOBMessage(msgOOB, "");
end

function onTargeting(rSource, aTargeting, rRolls)
	if OptionsManager.isOption("RMMT", "multi") then
		local aTargets = {};
		for _,vTargetGroup in ipairs(aTargeting) do
			for _,vTarget in ipairs(vTargetGroup) do
				table.insert(aTargets, vTarget);
			end
		end
		if #aTargets > 1 then
			for _,vRoll in ipairs(rRolls) do
				if not string.match(vRoll.sDesc, "%[FULL%]") then
					vRoll.bRemoveOnMiss = "true";
				end
			end
		end
	end
	return aTargeting;
end

function getRoll(draginfo, rActor, rAction)
	local rRoll = {};
    rRoll.sType = "attack";
    rRoll.sDesc = "[ATTACK: ";
	rRoll.aDice = { "d100", "d10" };
	rRoll.nMod = 0;
    rRoll.nTarget = rAction.target;
    rRoll.sAbilities = rAction.stat;
    rRoll.sRange = rAction.range;
    rRoll.nTemp = rAction.temp;
    
    if rRoll.sRange then
        rRoll.sDesc = rRoll.sDesc .. rAction.range .. "]";
    end
    
    rRoll.sDesc = rRoll.sDesc .. " " .. rAction.label;
    
    if rRoll.nTemp == 0 then
        rRoll.sDesc = rRoll.sDesc
    elseif rRoll.nTemp > 0 then
        rRoll.sDesc = rRoll.sDesc .. " [Temp: " .. "+" .. rRoll.nTemp .. "]";
    elseif rRoll.nTemp < 0 then
        rRoll.sDesc = rRoll.sDesc .. " [Temp: " .. rRoll.nTemp .. "]";
    end    

    return rRoll;
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(draginfo, rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function modAttack(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
        
	if rSource then
    
        -- Build attack filter
		local aAttackFilter = {};
		if rRoll.sRange == "R" then
			table.insert(aAttackFilter, "ranged");
		else
			table.insert(aAttackFilter, "melee");
		end
		
		-- Get attack effect modifiers
		local bEffects = false;
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager.getEffectsBonus(rSource, {"ATK"}, false, aAttackFilter, rTarget);
		if (nEffectCount > 0) then
			bEffects = true;
		end
		
		-- Get condition modifiers
		if EffectManager.hasEffectCondition(rSource, "Frightened") or 
				EffectManager.hasEffectCondition(rSource, "Panicked") or
				EffectManager.hasEffectCondition(rSource, "Shaken") then
			nAddMod = nAddMod - 10;
			bEffects = true;
		end
		if EffectManager.hasEffectCondition(rSource, "Sickened") then
			nAddMod = nAddMod - 10;
			bEffects = true;
		end
        
        if EffectManager.hasEffectCondition(rSource, "Fatigued") then
			nAddMod = nAddMod - 10;
			bEffects = true;
		end
        
        		-- Get attack related condition modifiers
		if EffectManager.hasEffect(rSource, "Blinded") then
			bEffects = true;
            nAddMod = nAddMod - 30;
		end
        if EffectManager.hasEffect(rSource, "Darkness") then
            if rRoll.sRange == "M" then
                bEffects = true;
                nAddMod = nAddMod - 20;
            end
		end
        if EffectManager.hasEffect(rSource, "Darkness") then
            if rRoll.sRange == "R" then
                bEffects = true;
                nAddMod = nAddMod - 30;
            end
		end
		if EffectManager.hasEffectCondition(rSource, "Dazzled") then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
        if EffectManager.hasEffectCondition(rSource, "Running") then
			bEffects = true;
			nAddMod = nAddMod - 20;
		end
		if EffectManager.hasEffectCondition(rSource, "Slowed") then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
		if EffectManager.hasEffectCondition(rSource, "Entangled") then
			bEffects = true;
			nAddMod = nAddMod - 20;
		end
		if EffectManager.hasEffectCondition(rSource, "Prone") then
			if rRoll.sRange == "M" then
				bEffects = true;
				nAddMod = nAddMod - 10;
			end
		end
		
		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager2.getAbilitiesEffectsBonus(rSource, rRoll.sAbilities);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end

		-- If effects, then add them
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = " [" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = " [" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
	end
	
	-- Add modifier stack to target number
	local sStackDesc, nStackMod = ModifierStack.getStack(true);
	ModifierStack.reset();
	if sStackDesc ~= "" then
		table.insert(aAddDesc, " [" .. sStackDesc .. "]");
	end
	nAddMod = nAddMod + nStackMod;
    
	-- Add modifiers
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	for _,vDie in ipairs(aAddDice) do
		table.insert(rRoll.aDice, "p" .. string.sub(vDie, 2));
	end
    
    if rSource then
        rRoll.nTarget = rRoll.nTarget + rRoll.nMod + nAddMod; 
        rRoll.sDesc = rRoll.sDesc .. " [TN: " .. rRoll.nTarget .. "]";
    end
end

function onAttack(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll, rTarget);
	local nTotal = ActionsManager.total(rRoll);

    local rAction = {};
	rAction.nTotal = ActionsManager.total(rRoll);
    rAction.range = rRoll.sRange;
	rAction.aMessages = {};
	
	-- If we have a target, then calculate the defense we need to compare
	local nDefenseVal, nDefEffectsBonus, nMissChance, sCoverType, bCovered = ActorManager2.getDefenseValue(rSource, rTarget, rRoll);
	if nDefEffectsBonus ~= 0 then
		local sFormat = "[" .. Interface.getString("effects_def_tag") .. " %+d]"
		table.insert(rAction.aMessages, string.format(sFormat, nDefEffectsBonus));
	end
    
    local sResult;
	if nDefenseVal then
        local nDefenseTotal = tonumber(nDefenseVal);
		if nTotal <= nDefenseTotal then
			if nTotal >= 96 then
				sResult = "miss";
				if rRoll.sRange ~= "M" then
					table.insert(rAction.aMessages, "\r[Auto MISS] >>> Check for Weapon Jams <<<");
				else
					table.insert(rAction.aMessages, "\r[Auto MISS]");
				end
			else
				sResult = "hit";
				table.insert(rAction.aMessages, "\r[HIT]" .. " Roll: " .. nTotal .. " vs. " .. nDefenseTotal);
			end
        elseif nTotal > nDefenseTotal then
			sResult = "miss";
			if nTotal >= 96 then
				if rRoll.sRange ~= "M" then
					table.insert(rAction.aMessages, "\r[Auto MISS] >>> Check for Weapon Jams/Overheating <<<");
				else
					table.insert(rAction.aMessages, "\r[Auto MISS]");
				end
			else
				table.insert(rAction.aMessages, "\r[MISS]"  ..  " Roll: " .. nTotal .. " vs. " .. nDefenseTotal);
			end
		end
	end

    local sHitLoc = "";
    local HitDesc = "";
    if sResult ~="miss" then
        local nCheck = nTotal;
        if nCheck < 0 then
            nCheck = math.abs(nCheck);
        end
        if nCheck > 100 then
            nCheck = math.floor(nCheck / 10);
        end
        if nCheck == 0 then
            nCheck = 01;
        end
        if nCheck == 100 then
            nCheck = 99;
        end
        
        if nCheck == 9 then
            nCheck = 09;
        elseif nCheck == 8 then
            nCheck = 08;
        elseif nCheck == 7 then
            nCheck = 07;
        elseif nCheck == 6 then
            nCheck = 06;
        elseif nCheck == 5 then
            nCheck = 05;
        elseif nCheck == 4 then
            nCheck = 04;
        elseif nCheck == 3 then
            nCheck = 03;
        elseif nCheck == 2 then
            nCheck = 02;
        end
        
        local sVal = tostring(nCheck);
        local sValRev = string.reverse(sVal);
        local sHit = tonumber(sValRev);
        
        if sHit <= 10 then
            sHitLoc = "Head";
        end
        if sHit >= 11 and sHit <= 20 then
            sHitLoc = "Right Arm";
        end
        if sHit >= 21 and sHit <= 30 then
            sHitLoc = "Left Arm";
        end        
        if sHit >= 31 and sHit <= 70 then
            sHitLoc = "Body";
        end        
        if sHit >= 71 and sHit <= 85 then
            sHitLoc = "Right Leg";
        end        
        if sHit >= 86 and sHit <= 100 then
            sHitLoc = "Left Leg";
        end 
        sHitloc = sHitLoc;
        HitDesc = " --> Location: " .. sHitLoc;
        table.insert(rAction.aMessages, " " .. HitDesc);
    end
    
    local hasCover = "";
    if sResult ~="miss" then
        if sHitLoc == "Head" and bCovered == true then
            if sCoverType == "Cover Full" or
                sCoverType == "Cover High" then
                    hasCover = "\r>> Covered <<";
            end
        end
        if sHitLoc == "Right Arm" and bCovered == true then
            if sCoverType == "Cover Full" or
                sCoverType == "Cover High"  or 
                sCoverType == "Cover Right" then
                    hasCover = "\r>> Covered <<";
            end
        end
        if sHitLoc == "Left Arm" and bCovered == true then
            if sCoverType == "Cover Full" or
                sCoverType == "Cover High"  or 
                sCoverType == "Cover Left" then
                    hasCover = "\r>> Covered <<";
            end
        end
        if bCovered ~= false and sHitLoc == "Body" then
            if sCoverType == "Cover Full" or
                sCoverType == "Cover High"  or
                sCoverType == "Cover Right"  or             
                sCoverType == "Cover Left" then
                    hasCover = "\r >> Covered <<";
            end
        end
        if sHitLoc == "Right Leg" and bCovered == true then
            if sCoverType == "Cover Full" or
                sCoverType == "Cover Low"  or
                sCoverType == "Cover Right"  or             
                sCoverType == "Cover Left" then
                    hasCover = "\r>> Covered <<";
            end
        end
        if sHitLoc == "Left Leg" and bCovered == true then
            if sCoverType == "Cover Full" or
                sCoverType == "Cover Low"  or
                sCoverType == "Cover Right"  or             
                sCoverType == "Cover Left" then
                    hasCover = "\r>> Covered <<";
            end
        end
        hasCover = hasCover;
        table.insert(rAction.aMessages, " " .. hasCover);
    end
 
    if sResult ~= "miss" and nMissChance > 0 then
		table.insert(rAction.aMessages, "\r[FIELD " .. nMissChance .. "%]");
	end
    
	Comm.deliverChatMessage(rMessage);

    if (nMissChance > 0) and (sResult ~= "miss") then
        local rMissChanceRoll = { sType = "misschance", sDesc = "Field Check" .. " [FIELD " .. nMissChance .. "%]", aDice = { "d100", "d10" }, nMod = 0 };
        ActionsManager.roll(rSource, rTarget, rMissChanceRoll);
    end

	if rTarget then
		notifyApplyAttack(rSource, rTarget, rMessage.secret, rRoll.sType, rRoll.sDesc, rAction.nTotal, table.concat(rAction.aMessages, " "));
		-- REMOVE TARGET ON MISS OPTION
		if sResult == "miss" and not string.match(rRoll.sDesc, "%[FULL%]") then
			local bRemoveTarget = false;
			if OptionsManager.isOption("RMMT", "on") then
				bRemoveTarget = true;
			elseif rRoll.bRemoveOnMiss then
				bRemoveTarget = true;
			end
			
			if bRemoveTarget then
				TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
			end
		end
	end

end

function onMissChance(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local nTotal = ActionsManager.total(rRoll);
	local nMissChance = tonumber(string.match(rMessage.text, "%[FIELD%s(%d+)%%%]")) or 0;
	if nTotal <= nMissChance then
		rMessage.text = rMessage.text .. "[MISS]";
		if rTarget then
			rMessage.icon = "roll_attack_miss";
		else
			rMessage.icon = "roll_attack";
		end
	else
		rMessage.text = rMessage.text .. "[HIT]";
		if rTarget then
			rMessage.icon = "roll_attack_hit";
		else
			rMessage.icon = "roll_attack";
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end

function applyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	local msgShort = {font = "reportfont"};
	local msgLong = {font = "reportfont"};
	
	if sAttackType == "attack" then
		msgShort.text = "Attack ->";
		msgLong.text = "Attack ->";
	end
	if rTarget then
		msgShort.text = msgShort.text .. " [at " .. rTarget.sName .. "]";
		msgLong.text = msgLong.text .. " [at " .. rTarget.sName .. "]";
	end
	if sResults ~= "" then
		msgLong.text = msgLong.text .. " " .. sResults;
	end
    
    if string.match(sResults, "vs.%s") then
        local nDefenseTarget = string.match(sResults, "vs.%s(%d+)");
        local nRollTotal = string.match(sResults, "Roll:%s(%d+)");
        local sOutcome = rollOutcome(nRollTotal, nDefenseTarget);
        msgShort.text = msgShort.text .. "\r-->>> Outcome: " .. sOutcome;
        msgLong.text = msgLong.text .. "\r-->>> Outcome: " .. sOutcome;
    end
    
	msgShort.icon = "roll_attack";
	if string.match(sResults, "HIT%]") then
		msgLong.icon = "roll_attack_hit";
	elseif string.match(sResults, "MISS%]") then
		msgLong.icon = "roll_attack_miss";
	else
		msgLong.icon = "roll_attack";
	end
		
	ActionsManager.messageResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

function rollOutcome(rollValue, successValue, rTarget)
	local desc = "";
	local value = 0;
	local lSuccessValue = tonumber(successValue);
	
	local lRollValue = tonumber(rollValue);
	
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