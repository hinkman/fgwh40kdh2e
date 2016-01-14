-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
    CombatManager.setCustomDrop(onDrop);
	CombatManager.setCustomAddNPC(addNPC);
	CombatManager.setCustomSort(sortfunc);
	CombatManager.setCustomCombatReset(resetInit);
end


function sortfunc(node1, node2)
	local nValue1 = DB.getValue(node1, "initresult", 0);
	local nValue2 = DB.getValue(node2, "initresult", 0);
	if nValue1 ~= nValue2 then
		return nValue1 > nValue2;
	end
	
	nValue1 = DB.getValue(node1, "init", 0);
	nValue2 = DB.getValue(node2, "init", 0);
	if nValue1 ~= nValue2 then
		return nValue1 > nValue2;
	end
	
	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return node1.getNodeName() < node2.getNodeName();
end

-- DROP HANDLING
--

function onDrop(rSource, rTarget, draginfo)
	local sDragType = draginfo.getType();

	-- Effect targeting
	if sDragType == "effect_targeting" then
		if User.isHost() then
			onEffectTargetingDrop(rSource, rTarget, draginfo);
			return true;
		end
	end
end

function onEffectTargetingDrop(rSource, rTarget, draginfo)
	local sTargetCT = ActorManager.getCTNodeName(rTarget);
	if sTargetCT ~= "" then
		local sRefClass, sEffectNode = draginfo.getShortcutData();
		if sRefClass and sEffectNode then
			if sRefClass == "ct_effect" then
				EffectManager.addEffectTarget(sEffectNode, sTargetCT);
			end
		end
	end
end

--
-- ADD FUNCTIONS
--

function addNPC(sClass, nodeNPC, sName)
	local nodeEntry, nodeLastMatch = CombatManager.addNPCHelper(nodeNPC, sName);

	-- Combat properties
	local sDamage = DB.getValue(nodeNPC, "damage", "");
	DB.setValue(nodeEntry, "damage", "number", tonumber(string.match(sDamage, "(%d+)")) or 0);
    
	-- Roll initiative and sort
	local nBaseInit = DB.getValue(nodeEntry, "level", 0) * 3;
	local sOptINITNPC = OptionsManager.getOption("INITNPC");
	if sOptINITNPC == "group" then
		local nMaxInit = nBaseInit;
		for _,v in pairs(DB.getChildren(CombatManager.CT_LIST)) do
			local sClass, _ = DB.getValue(v, "link", "", "");
			if sClass ~= "charsheet" then
				nMaxInit = math.max(nMaxInit, DB.getValue(v, "initresult", 0));
			end
		end
		for _,v in pairs(DB.getChildren(CombatManager.CT_LIST)) do
			local sClass, _ = DB.getValue(v, "link", "", "");
			if sClass ~= "charsheet" then
				DB.setValue(v, "initresult", "number", nMaxInit);
			end
		end
	else
		DB.setValue(nodeEntry, "initresult", "number", nBaseInit);
	end

	return nodeEntry;
end

--
-- RESET FUNCTIONS
--

function resetEffects()
	for _, vChild in pairs(DB.getChildren(CombatManager.CT_LIST)) do
		local nodeEffects = vChild.getChild("effects");
		if nodeEffects then
			for _, vEffect in pairs(nodeEffects.getChildren()) do
				vEffect.delete();
			end
		end
	end
end

function rollInit(sCharType)
	local nMaxInitPC = 0;
	local nMaxInitNPC = 0;
	for _, v in pairs(DB.getChildren(CombatManager.CT_LIST)) do
		local sClass, _ = DB.getValue(v, "link", "", "");
		if (sClass == "charsheet" and sCharType == "PC") or (sClass ~= "charsheet" and sCharType == "NPC") or sCharType == "All" then
			local nInit = math.random(10) + DB.getValue(v, "init", 0);
			DB.setValue(v, "initresult", "number", nInit);
			
			if sClass == "charsheet" then 
				nMaxInitPC = math.max(nMaxInitPC, nInit);
			else
				nMaxInitNPC = math.max(nMaxInitNPC, nInit);
			end
		end
	end
	
	if OptionsManager.getOption("INITPC") == "group" and (sCharType == "All" or sCharType == "PC") then
		for _, v in pairs(DB.getChildren(CombatManager.CT_LIST)) do
			local sClass, _ = DB.getValue(v, "link", "", "");
			if sClass == "charsheet" then
				DB.setValue(v, "initresult", "number", nMaxInitPC);
			end
		end
	end
	
	if OptionsManager.getOption("INITNPC") == "group" and (sCharType == "All" or sCharType == "NPC")  then
		for _, v in pairs(DB.getChildren(CombatManager.CT_LIST)) do
			local sClass, _ = DB.getValue(v, "link", "", "");
			if sClass ~= "charsheet" then
				DB.setValue(v, "initresult", "number", nMaxInitNPC);
			end
		end
	end
end

function resetInit()
	local nMaxInit = 0;
	for _, v in pairs(DB.getChildren(CombatManager.CT_LIST)) do
		local sClass, _ = DB.getValue(v, "link", "", "");
		if sClass == "charsheet" then
			DB.setValue(v, "initresult", "number", 0);
		else
			local nBaseInit = DB.getValue(v, "level", 0) * 3;
			DB.setValue(v, "initresult", "number", nBaseInit);
			nMaxInit = math.max(nMaxInit, nBaseInit);
		end
	end

	if OptionsManager.getOption("INITNPC") == "group" then
		for _, v in pairs(DB.getChildren(CombatManager.CT_LIST)) do
			local sClass, _ = DB.getValue(v, "link", "", "");
			if sClass ~= "charsheet" then
				DB.setValue(v, "initresult", "number", nMaxInit);
			end
		end
	end
end

function rest(nodeChar)
	resetHealth(nodeChar);
end

function resetHealth(nodeChar)
	-- Clear fatigue
	DB.setValue(nodeChar, "fatigue", "number", 0);
	
	-- Heal 1 wound
	local nWounds = DB.getValue(nodeChar, "wounds", 0);
    local nMaxWounds = DB.getValue(nodeChar, "totalwounds", 0);
	nWounds = nWounds - 1;
	if nWounds < 0 then
		nWounds = 0;
	end
	DB.setValue(nodeChar, "wounds", "number", nWounds);
	
    --Heal 1 Crit
	local nCrit = DB.getValue(nodeChar, "attributes.critwounds", 0);
	nCrit = nCrit - 1;
	if nCrit < 0 then
		nCrit = 0;
	end
	DB.setValue(nodeChar, "attributes.critwounds", "number", nCrit);
	
end

