-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onDrop(x, y, draginfo)
	local sDragType = draginfo.getType();
	if sDragType ~= "shortcut" then
		return false;
	end
	
	local sDropClass, sDropNodeName = draginfo.getShortcutData();
	if not StringManager.contains({"item", "referencerangedweapons", "referencemeleeweapons", "referenceequipment", "referenceammo", "referencearmor"}, sDropClass) then
		return true;
	end
	
	local nodeSource = draginfo.getDatabaseNode();
	local nodeTarget = window.getDatabaseNode();
		
	local sSourceType = DB.getValue(nodeSource, "type", "");
	local sTargetType = DB.getValue(nodeTarget, "type", "");
	
	local sSourceName = DB.getValue(nodeSource, "name", "");
	sSourceName = string.gsub(sSourceName, " %(" .. sSourceType .. "%)", "");
	local sTargetName = DB.getValue(nodeTarget, "name", "");
	sTargetName = string.gsub(sTargetName, " %(" .. sTargetType .. "%)", "");
	
	if sSourceType == sTargetType then
		
		if sSourceName ~= "" then
			local sName = sSourceName .. " (" .. DB.getValue(nodeTarget, "name", "") .. ")";
			DB.setValue(nodeTarget, "name", "string", sName);
		end
		
		local sCost = StringManager.combine(" ", DB.getValue(nodeSource, "cost", ""), DB.getValue(nodeTarget, "cost", ""));
		DB.setValue(nodeTarget, "cost", "string", sCost);
		
		DB.setValue(nodeTarget, "weight", "number", DB.getValue(nodeSource, "weight", 0));
		DB.setValue(nodeTarget, "cost", "string", DB.getValue(nodeSource, "cost", ""));
		DB.setValue(nodeTarget, "availability", "string", DB.getValue(nodeSource, "availability", ""));
		DB.setValue(nodeTarget, "type", "string", DB.getValue(nodeSource, "type", ""));
		
		if sSourceType == "referencearmor" then		
			DB.setValue(nodeTarget, "protects", "string", DB.getValue(nodeSource, "protects", ""));
			DB.setValue(nodeTarget, "ap", "string", DB.getValue(nodeSource, "ap", ""));
			DB.setValue(nodeTarget, "subtype", "string", DB.getValue(nodeSource, "subtype", ""));	
		elseif sSourceType == "referencerangedweapons" or sSourceType == "referencemeleeweapons" then
			DB.setValue(nodeTarget, "damagedice", "string", DB.getValue(nodeSource, "damagedice", ""));
            DB.setValue(nodeTarget, "damagebonus", "string", DB.getValue(nodeSource, "damagebonus", ""));
			DB.setValue(nodeTarget, "damagetype", "string", DB.getValue(nodeSource, "damagetype", ""));
			DB.setValue(nodeTarget, "pen", "string", DB.getValue(nodeSource, "pen", ""));
			DB.setValue(nodeTarget, "special", "string", DB.getValue(nodeSource, "special", ""));
		
			if sSourceType == "referencerangedweapons" then
				DB.setValue(nodeTarget, "class", "string", DB.getValue(nodeSource, "class", ""));
				DB.setValue(nodeTarget, "range", "string", DB.getValue(nodeSource, "range", ""));
				DB.setValue(nodeTarget, "rof", "string", DB.getValue(nodeSource, "rof", ""));
				DB.setValue(nodeTarget, "clipsize", "string", DB.getValue(nodeSource, "clipsize", ""));
				DB.setValue(nodeTarget, "reload", "string", DB.getValue(nodeSource, "reload", ""));
			end
		elseif sSourceType == "referenceammo" then
			DB.setValue(nodeTarget, "usedwith", "string", DB.getValue(nodeSource, "usedwith", ""));
		end
	end

	return true;
end
