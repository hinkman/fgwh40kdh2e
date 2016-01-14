-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerModHandler("abilities", modRoll);
	ActionsManager.registerResultHandler("abilities", onRoll);
end

function getRoll(rActor, sAbilities, bSecretRoll)
	local rRoll = {};
	rRoll.sType = "abilities";
	rRoll.aDice = { "d100", "d10" };
	rRoll.nMod = 0;
	rRoll.bSecret = bSecretRoll;

	rRoll.sDesc = string.format("[Trait: %s]", DataCommon.abilities_label[sAbilities]);
	rRoll.sAbilities = sAbilities;
	rRoll.nTarget = DB.getValue(ActorManager.getCreatureNode(rActor), "abilities." .. rRoll.sAbilities, 0);
	
	return rRoll;
end

function performRoll(draginfo, rActor, sAbilities, bSecretRoll)
	local rRoll = getRoll(rActor, sAbilities, bSecretRoll);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function modRoll(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	if rSource then
		local bEffects = false;

		-- GET ACTION MODIFIERS
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager.getEffectsBonus(rSource, {"ABIL"}, false, {rRoll.sAbilities});
		if (nEffectCount > 0) then
			bEffects = true;
		end
		
		-- GET CONDITION MODIFIERS
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
            if rRoll.sAbilities == "weapon" then
                bEffects = true;
                nAddMod = nAddMod - 20;
            end
		end
        if EffectManager.hasEffect(rSource, "Darkness") then
            if rRoll.sAbilities == "ballistic" then
                bEffects = true;
                nAddMod = nAddMod - 30;
            end
		end
		if EffectManager.hasEffectCondition(rSource, "Dazzled") then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
		if EffectManager.hasEffectCondition(rSource, "Slowed") then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
		if EffectManager.hasEffectCondition(rSource, "Entangled") then
			bEffects = true;
			nAddMod = nAddMod - 20;
		end
		if rRoll.sType == "abilities" and 
				(EffectManager.hasEffectCondition(rSource, "Pinned") or
				EffectManager.hasEffectCondition(rSource, "Grappled")) then
			bEffects = true;
			nAddMod = nAddMod - 10;
		end
		if EffectManager.hasEffectCondition(rSource, "Prone") then
			if rRoll.sAbilities == "weapon" then
				bEffects = true;
				nAddMod = nAddMod - 10;
			end
		end

		-- GET STAT MODIFIERS
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
	rRoll.nTarget = rRoll.nTarget + nAddMod;
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

