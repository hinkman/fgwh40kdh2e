-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInit);
    
    ActionsManager.registerModHandler("init", modRoll);
	ActionsManager.registerResultHandler("init", onResolve);
end

function handleApplyInit(msgOOB)
	local nTotal = tonumber(msgOOB.nTotal) or 0;

	DB.setValue(msgOOB.sSourceCTNode .. ".initresult", "number", nTotal);
end

function notifyApplyInit(rSource, nTotal)
	if not rSource then
		return;
	end
	
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYINIT;
	
	msgOOB.nTotal = nTotal;
	msgOOB.sSourceCTNode = rSource.sCTNode;

	Comm.deliverOOBMessage(msgOOB, "");
end

function onResolve(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);
	
	local nTotal = ActionsManager.total(rRoll);
	notifyApplyInit(rSource, nTotal);
end

function performRoll(draginfo, rActor, bSecretRoll, nAgilityValue, nMiscValue, nTempValue, sStat)
	local rRoll = getRoll(rActor, bSecretRoll, nAgilityValue, nMiscValue, nTempValue, sStat);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, bSecretRoll, nAgilityValue, nMiscValue, nTempValue, sStat)
	local rRoll = {};
	rRoll.sType = "init";
	rRoll.aDice = { "d10" };
	rRoll.nMod = 0;
    rRoll.sStat = sStat;
	rRoll.bSecret = bSecretRoll;

	local nAgilValue = math.floor(nAgilityValue/10);
	rRoll.nMod = nAgilValue + nMiscValue + nTempValue;
    
    rRoll.sDesc = "[INITIATIVE] ";
    
    rRoll.sDesc = rRoll.sDesc .. string.format("[%+d Ag, %+d Misc", nAgilValue, nMiscValue);
    
    if nTempValue == 0 then   
        rRoll.sDesc = rRoll.sDesc .. "]";
    elseif nTempValue > 0 then
        rRoll.sDesc = rRoll.sDesc .. ", +" .. nTempValue .. " Temp]";
    elseif nTempValue < 0 then
        rRoll.sDesc = rRoll.sDesc .. ", " .. nTempValue .. " Temp]";    
    end

	return rRoll;
end

function modRoll(rSource, rTarget, rRoll)
	if rSource then
		local bEffects = false;

		-- DETERMINE STAT IF ANY
		local sActionStat = rRoll.sStat;
	
		
		-- DETERMINE EFFECTS
		local aAddDice, nAddMod, nEffectCount = EffectManager.getEffectsBonus(rSource, {"INIT"});
		if nEffectCount > 0 then
			bEffects = true;
			for _,vDie in ipairs(aAddDice) do
				table.insert(rRoll.aDice, "p" .. string.sub(vDie, 2));
			end
		end
		
		-- Get condition modifiers
		if EffectManager.hasEffectCondition(rSource, "Deafened") then
			bEffects = true;
			rRoll.nMod = rRoll.nMod - 2;
        elseif EffectManager.hasEffectCondition(rSource, "Dazzled") then
            bEffects = true;
            nAddMod = nAddMod - 2;
		end
		
		-- GET STAT MODIFIERS
		local nBonusStat, nBonusEffects = ActorManager2.getAbilitiesEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			bEffects = true;
            nBonusStat = nBonusStat/10;
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
			rRoll.sDesc = rRoll.sDesc .. " " .. sEffects;
		end
        rRoll.nMod = rRoll.nMod + nAddMod;
	end
end
