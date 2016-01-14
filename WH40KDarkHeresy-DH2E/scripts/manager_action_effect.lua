-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--	
--	DATA STRUCTURES
--
-- rEffect
--		sName = ""
--		nDuration = #
--		sUnits = ""
-- 		nInit = #
--		sSource = ""
--		nGMOnly = 0, 1
--		sApply = "", "action", "roll", "single"
--

function onInit()
	Interface.onHotkeyDrop = onHotkeyDrop;

	ActionsManager.registerResultHandler("effect", onEffect);
end

function onHotkeyDrop(draginfo)
	local rEffect = decodeEffectFromDrag(draginfo);
	if rEffect then
		rEffect.nInit = nil;

		draginfo.setSlot(1);
		draginfo.setStringData(encodeEffectAsText(rEffect));
	end
end

function getRoll(draginfo, rActor, rAction)
	local rRoll = encodeEffect(rAction);
	if rRoll.sDesc == "" then
		return nil;
	end
	
	if draginfo and Input.isShiftPressed() then
		local aTargetNodes = {};
		local aTargets;
		if rRoll.bSelfTarget then
			aTargets = { rActor };
		else
			aTargets = TargetingManager.getFullTargets(rActor);
		end
		for _,v in ipairs(aTargets) do
			local sCTNode = ActorManager.getCTNodeName(v);
			if sCTNode ~= "" then
				table.insert(aTargetNodes, sCTNode);
			end
		end
		
		if #aTargetNodes > 0 then
			rRoll.aTargets = table.concat(aTargetNodes, "|");
		end
	end

	return rRoll;
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(draginfo, rActor, rAction);
	if not rRoll then
		return false;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
	return true;
end

function onEffect(rSource, rTarget, rRoll)
	-- Decode effect from roll
	local rEffect = decodeEffect(rRoll);
	if not rEffect then
		ChatManager.SystemMessage(Interface.getString("ct_error_effectdecodefail"));
		return;
	end
	
	-- If no target, then report to chat window and exit
	if not rTarget then
		-- Clear source and init for effect
		rEffect.sSource = nil;
		rEffect.nInit = nil;
		rRoll.sDesc = encodeEffectAsText(rEffect);
		rRoll.nMod = rEffect.nDuration or 0;

		-- Report effect to chat window
		local rMessage = ActionsManager.createActionMessage(nil, rRoll);
		rMessage.icon = "roll_effect";
		Comm.deliverChatMessage(rMessage);
		
		return;
	end
	
	-- If target not in combat tracker, then we're done
	local sTargetCT = ActorManager.getCTNodeName(rTarget);
	if sTargetCT == "" then
		ChatManager.SystemMessage(Interface.getString("ct_error_effectdroptargetnotinct"));
		return;
	end

	-- If effect is not a CT effect drag, then figure out source and init
	if rEffect.nInit == 0 and rEffect.sSource == "" then
		local sSourceCT = "";
		
		if ActorManager.getType(rSource) == "pc" then
			sSourceCT = ActorManager.getCTNodeName(rSource);
		end
		
		if sSourceCT == "" then
			local nodeTempCT = nil;
			if User.isHost() then
				nodeTempCT = CombatManager.getActiveCT();
			else
				nodeTempCT = CombatManager.getCTFromNode("charsheet." .. User.getCurrentIdentity());
			end
			if nodeTempCT then
				sSourceCT = nodeTempCT.getNodeName();
			end
		end
		
		if sSourceCT ~= "" then
			rEffect.sSource = sSourceCT;
			rEffect.nInit = DB.getValue(DB.findNode(sSourceCT), "initresult", 0);
		end
	end
	
	-- If source is same as target, then don't specify a source
	if rEffect.sSource == sTargetCT then
		rEffect.sSource = "";
	end
	
	-- If target is NPC and source is not PC, then effect should be GM only
	local sTargetType = ActorManager.getType(rTarget);
	if sTargetType == "npc" then
		if rSource then
			local sSourceType = ActorManager.getType(rSource);
			if sSourceType ~= "pc" then
				rEffect.nGMOnly = 1;
			end
		else
			rEffect.nGMOnly = 1;
		end
	end
	
	-- Resolve
	-- If shift-dragging, then apply to the source actor targets, then target the effect to the drop target
	if rRoll.aTargets then
		local aTargets = StringManager.split(rRoll.aTargets, "|");
		for _,v in ipairs(aTargets) do
			EffectManager.notifyApply(rEffect, v, sTargetCT);
		end
	
	-- Otherwise, just apply effect to target normally
	else
		EffectManager.notifyApply(rEffect, sTargetCT);
	end
end

--
-- UTILITY FUNCTIONS
--

function decodeEffectFromDrag(draginfo)
	local rEffect = nil;
	
	local sDragType = draginfo.getType();
	local sDragDesc = "";

	local bEffectDrag = false;
	if sDragType == "effect" then
		bEffectDrag = true;
		sDragDesc = draginfo.getStringData();
	elseif sDragType == "number" then
		if string.match(sDragDesc, "%[EFFECT") then
			bEffectDrag = true;
			sDragDesc = draginfo.getDescription();
		end
	end
	
	if bEffectDrag then
		rEffect = decodeEffectFromText(sDragDesc, draginfo.getSecret());
		if rEffect then
			rEffect.nDuration = draginfo.getNumberData();
		end
	end
	
	return rEffect;
end

function encodeEffect(rAction)
	local rRoll = {};
	rRoll.sType = "effect";
	rRoll.sDesc = encodeEffectAsText(rAction);
	rRoll.aDice = rAction.aDice or {};
	rRoll.nMod = rAction.nDuration or 0;
	if rAction.nGMOnly then
		rRoll.bSecret = (rAction.nGMOnly ~= 0);
	end
	if rAction.sTargeting and rAction.sTargeting == "self" then
		rRoll.bSelfTarget = true;
	end
	
	return rRoll;
end

function decodeEffect(rRoll)
	local rEffect = decodeEffectFromText(rRoll.sDesc, rRoll.bSecret);
	if rEffect then
		rEffect.aDice = rRoll.aDice;
		rEffect.nMod = rRoll.nMod;
		rEffect.nDuration = ActionsManager.total(rRoll);
	end
	
	return rEffect;
end

function encodeEffectAsText(rEffect)
	local aMessage = {};
	
	if rEffect then
		table.insert(aMessage, "[EFFECT] " .. rEffect.sName);

		if rEffect.nInit and rEffect.nInit ~= 0 then
			table.insert(aMessage, "[INIT " .. rEffect.nInit .. "]");
		end

		if rEffect.sUnits and rEffect.sUnits ~= "" then
			local sOutputUnits = nil;
			if rEffect.sUnits == "minute" then
				sOutputUnits = "MIN";
			elseif rEffect.sUnits == "hour" then
				sOutputUnits = "HR";
			elseif rEffect.sUnits == "day" then
				sOutputUnits = "DAY";
			end

			if sOutputUnits then
				table.insert(aMessage, "[UNITS " .. sOutputUnits .. "]");
			end
		end

		if rEffect.sTargeting and rEffect.sTargeting ~= "" then
			table.insert(aMessage, "[" .. string.upper(rEffect.sTargeting) .. "]");
		end
		
		if rEffect.sApply and rEffect.sApply ~= "" then
			table.insert(aMessage, "[" .. string.upper(rEffect.sApply) .. "]");
		end
		
		if rEffect.sSource and rEffect.sSource ~= "" then
			table.insert(aMessage, "[by " .. rEffect.sSource .. "]");
		end
	end
	
	return table.concat(aMessage, " ");
end

function decodeEffectFromText(sEffect, bSecret)
	local rEffect = nil;

	local sEffectName = string.match(sEffect, "%[EFFECT%] ([^[]+)");
	if sEffectName then
		rEffect = {};
		
		if bSecret then
			rEffect.nGMOnly = 1;
		else
			rEffect.nGMOnly = 0;
		end

		rEffect.sName = StringManager.trim(sEffectName);
		
		rEffect.sSource = string.match(sEffect, "%[by ([^]]+)%]") or "";
		
		local sEffectInit = string.match(sEffect, "%[INIT (%d+)%]");
		rEffect.nInit = tonumber(sEffectInit) or 0;

		rEffect.sTargeting = "";
		if string.match(sEffect, "%[SELF%]") then
			rEffect.sTargeting = "self";
		end
		
		rEffect.sApply = "";
		if string.match(sEffect, "%[ACTION%]") then
			rEffect.sApply = "action";
		elseif string.match(sEffect, "%[ROLL%]") then
			rEffect.sApply = "roll";
		elseif string.match(sEffect, "%[SINGLE%]") then
			rEffect.sApply = "single";
		end
		
		rEffect.sUnits = "";
		local sUnits = string.match(sEffect, "%[UNITS ([^]]+)]");
		if sUnits then
			if sUnits == "MIN" then
				rEffect.sUnits = "minute";
			elseif sUnits == "HR" then
				rEffect.sUnits = "hour";
			elseif sUnits == "DAY" then
				rEffect.sUnits = "day";
			end
		end
	end
	
	return rEffect;
end
