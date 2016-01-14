-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
	update();
end

function VisDataCleared()
	update();
end

function InvisDataAdded()
	update();
end

function updateControl(sControl, bReadOnly, bID)
	if not self[sControl] then
		return false;
	end
		
	if not bID then
		return self[sControl].update(bReadOnly, true);
	end
	
	return self[sControl].update(bReadOnly);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID, bOptionID = ItemManager.getIDState(nodeRecord);
	local bHost = User.isHost();
	
    local bSection1 = false;
	if bOptionID and bHost then
		if updateControl("nonid_name", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonid_name", bReadOnly, false);
	end
	if bOptionID and (bHost or not bID) then
		if updateControl("nonid_notes", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonid_notes", bReadOnly, false);
	end
	
	type.setVisible(bID);
	type.setReadOnly(bReadOnly);
	local sType = type.getValue();

	
	local bAmmo = (sType == "Ammunition");
	local bArmor = (sType == "Armor");
	local bGear = (sType == "Clothes/Personal Item" or sType == "Drug/Consumable" or sType == "Tool");
	local bRangedWeapon = (sType == "Ranged Weapon");
	local bMeleeWeapon = (sType == "Melee Weapon");
	
	updateControl("subtype", true);
	updateControl("cost", true);
	updateControl("availability", true);
	updateControl("weight", true);
	updateControl("usedwith", true);
	updateControl("protects", true);
	updateControl("ap", true);
	updateControl("class", true);
	updateControl("damagedice", true);
    updateControl("damagebonus", true);
	updateControl("damagetype", true);
	updateControl("pen", true);
	updateControl("special", true);
	updateControl("clipsize", true);
	updateControl("range", true);
	updateControl("reload", true);
	updateControl("rof", true);
	
    local bSection2 = false;
	if updateControl("subtype", bReadOnly, bID) then bSection2 = true; end;
	if updateControl("cost", bReadOnly, bID) then bSection2 = true; end;
	if updateControl("availability", bReadOnly, bID) then bSection2 = true; end;
	if updateControl("weight", bReadOnly, bID) then bSection2 = true; end;
	if updateControl("usedwith", bReadOnly, bID and bAmmo) then bSection2 = true; end;
	if updateControl("protects", bReadOnly, bID and bArmor)then bSection2 = true; end;
	if updateControl("ap", bReadOnly, bID and bArmor) then bSection2 = true; end;
	if updateControl("class", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end;
	if updateControl("damagedice", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end;
    if updateControl("damagebonus", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end;
	if updateControl("damagetype", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon))then bSection2 = true; end;
	if updateControl("pen", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon))then bSection2 = true; end;
	if updateControl("special", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end;
	if updateControl("clipsize", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end; --bRangedWeapon);
	if updateControl("range", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end;
	if updateControl("reload", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end; --bRangedWeapon);
	if updateControl("rof", bReadOnly, bID and (bRangedWeapon or bMeleeWeapon)) then bSection2 = true; end; --bRangedWeapon);

    local bSection3 = bID;
	description.setVisible(bID);
	description.setReadOnly(bReadOnly);
	
	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible((bSection1 or bSection2) and bSection3);
	
	--divider.setVisible(bOptionID and bHost);
	--divider2.setVisible(bID);
end
