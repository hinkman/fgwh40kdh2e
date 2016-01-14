-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ItemManager.setCustomCharAdd(onCharItemAdd);
end
                

function updateEncumbrance(nodeChar)
	local nEncTotal = 0;

	local nCount, nWeight;
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if DB.getValue(vNode, "carried", 0) == 1 then
			nCount = DB.getValue(vNode, "count", 0);
			if nCount < 1 then
				nCount = 1;
			end
			nWeight = DB.getValue(vNode, "weight", 0);
			
			nEncTotal = nEncTotal + (nCount * nWeight);
		end
	end

	DB.setValue(nodeChar, "encumbrance.load", "number", nEncTotal);
end

function onCharItemAdd(nodeItem)
	DB.setValue(nodeItem, "carried", "number", 1);
end

function getWeaponDamageStats(nodeWeapon, nodeChar)
	local sDamageStat;

	local bRanged = DB.getValue(nodeWeapon, "class", "");
       if string.lower(DB.getValue(nodeWeapon, "class", "")) == "pistol" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "basic" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "heavy" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "launched" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "grenade" then
        bRanged = true;
    else
        bRanged = false;
    end 
    
	if bRanged == false then
		sDamageStat = tostring(DB.getValue(nodeChar, "abilities.strengthbonus", ""));
        if sDamageStat == "" then
            sDamageStat = "strengthbonus";
        end
    else
        sDamageStat = tostring(DB.getValue(nodeChar, "abilities.ammo", ""));
        if sDamageStat == "" then
            sDamageStat = "ammo";
        end
	end
    
	return sDamageStat;
end

function getWeaponDamageRollStructures(nodeWeapon, nodeChar)
	if not nodeWeapon or nodeChar then
		return;
	end
	
	local nodeChar = nodeWeapon.getChild("...");
	local rActor = ActorManager.getActor("pc", nodeChar);
    
    local bRanged = DB.getValue(nodeWeapon, "class", "");
    if string.lower(DB.getValue(nodeWeapon, "class", "")) == "pistol" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "basic" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "heavy" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "launched" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "thrown" then
        bRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "grenade" then
        bRanged = true;
    else
        bRanged = false;
    end
    
    local bPrimitive = DB.getValue(nodeWeapon, "primitive", 0);
        if bPrimitive == 1 then
            bPrimitive = true;
        else
            bPrimitive = false;
        end
    
    local bCover = DB.getValue(nodeWeapon, "cover", 0);
        if bCover == 1 then
            bCover = true;
        else
            bCover = false;
        end  

    local pen = DB.getValue(nodeWeapon, "pen", 0);
    local PenOne = DB.getValue(nodeWeapon, "ammoonepen", 0);
    local PenTwo = DB.getValue(nodeWeapon, "ammotwopen", 0);
    local AmOp1 = DB.getValue(nodeWeapon, "ammoone", 0);
    local AmOp2 = DB.getValue(nodeWeapon, "ammotwo", 0);
    local Mono = DB.getValue(nodeWeapon, "mono", 0);
    local Force = DB.getValue(nodeWeapon, "force", 0);
    local ForceCheck = DB.getValue(nodeWeapon, "forcecheck", 0);
    
    if bRanged ~= false then
        if AmOp1 == 1 and AmOp2 ~= 1 then
            pen = pen + PenOne;
        elseif AmOp2 == 1 and AmOp1 ~= 1 then
            pen = pen + PenTwo;
        else
            pen = pen;
        end
    end
    
    if bRanged ~= true then
        if Mono == 1 and ForceCheck ~=1 then
            pen = pen + 2;
        else
            pen = pen;
        end
    end
    
    if bRanged ~= true then
        if ForceCheck == 1 and Mono ~= 1 then
            pen = pen + Force;
        else
            pen = pen;
        end
    end
   
   local bTearing = DB.getValue(nodeWeapon, "tearing", 0);
        if bTearing == 1 then
            bTearing = true;
        else
            bTearing = false;
        end

	local rDamage = {};
	rDamage.type = "damage";
	rDamage.label = DB.getValue(nodeWeapon, "name", "");
    rDamage.pen = pen;
    rDamage.felling = DB.getValue(nodeWeapon, "felling", "");
    rDamage.location = DB.getValue(nodeWeapon, "location", "");
    rDamage.primitive = bPrimitive;
    rDamage.cover = bCover;
    rDamage.tearing = bTearing;
    rDamage.proven = DB.getValue(nodeWeapon, "proven", 0);
    
    if bRanged == true then
		rDamage.range = "R";
	else
		rDamage.range = "M";
	end
 
	rDamage.stat = getWeaponDamageStats(nodeWeapon);
	
	rDamage.clauses = {};
    
    local aDamageTypes = ActionDamage.getDamageTypesFromString(DB.getValue(nodeWeapon, "damagetype", ""));
    local bForce = "f";
    local ForceCheck = DB.getValue(nodeWeapon, "forcecheck", 0);
    local DmgOne = DB.getValue(nodeWeapon, "ammoonedmgtype", 0);
    local bDmgOne = DmgOne;
    local DmgTwo = DB.getValue(nodeWeapon, "ammotwodmgtype", 0);
    local bDmgTwo = DmgTwo;
    local AmOp1 = DB.getValue(nodeWeapon, "ammoone", 0);
    local AmOp2 = DB.getValue(nodeWeapon, "ammotwo", 0);
    local Holy = DB.getValue(nodeWeapon, "holy", 0);
    local bHoly = "h";
    local Sanc = DB.getValue(nodeWeapon, "sanc", 0);
    local bSanc = "s";
    
    if bRanged ~= false then
        if AmOp1 == 1 and AmOp2 ~= 1 then
            table.insert(aDamageTypes, bDmgOne);
        else
            aDamageTypes = aDamageTypes;
        end
    end
   
   if bRanged ~= false then
        if AmOp2 == 1 and AmOp1 ~= 1 then
            table.insert(aDamageTypes, bDmgTwo);
        else
            aDamageTypes = aDamageTypes;
        end
    end
    
    if Holy == 1  and bRanged ~= true then
        table.insert(aDamageTypes, bHoly);
    else
         aDamageTypes = aDamageTypes;
    end
    
    if Sanc == 1 and bRanged ~= true then
        table.insert(aDamageTypes, bSanc);
    else
         aDamageTypes = aDamageTypes;
    end
    
    if ForceCheck == 1 and bRanged ~= true then
        table.insert(aDamageTypes, bForce);
    else
        aDamageTypes = aDamageTypes;
    end
    
    local aDice = StringManager.convertStringToDice(DB.getValue(nodeWeapon, "damagedice", ""));
    local nMod = addStrMod(nodeWeapon, nodeChar);
    
    local rWeaponClause = {};
    rWeaponClause.dice = aDice;
	rWeaponClause.modifier = nMod;
	rWeaponClause.dmgtype = table.concat(aDamageTypes, ",");
    table.insert(rDamage.clauses, rWeaponClause);

	return rActor, rDamage;
end

function addStrMod(nodeWeapon, nodeChar)

    local nNoAddMod = tonumber(DB.getValue(nodeWeapon, "damagebonus", 0));
    local nAddMod = DB.getValue(nodeChar, "abilities.strengthbonus", 0);
    local bAddRanged = DB.getValue(nodeWeapon, "class", "");
    local AmmoOne = DB.getValue(nodeWeapon, "ammoonedam", 0);
    local AmmoTwo = DB.getValue(nodeWeapon, "ammotwodam", 0);
    local AmOp1 = DB.getValue(nodeWeapon, "ammoone", 0);
    local AmOp2 = DB.getValue(nodeWeapon, "ammotwo", 0);
    local Best  = DB.getValue(nodeWeapon, "bestcheck", 0);
    local Force = DB.getValue(nodeWeapon, "force", 0);
    local ForceCheck = DB.getValue(nodeWeapon, "forcecheck", 0);
    local Mono = DB.getValue(nodeWeapon, "mono", 0);
    local Crushing = DB.getValue(nodeWeapon, "crushingblow", 0);
    local Mighty = DB.getValue(nodeWeapon, "mightyshot", 0);
    local tMod = 0;
    
    if string.lower(DB.getValue(nodeWeapon, "class", "")) == "pistol" then
        bAddRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "basic" then
        bAddRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "heavy" then
        bAddRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "launched" then
        bAddRanged = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "grenade" then
        bAddRanged = true;
    else
        bAddRanged = false;
    end 
    
    if bAddRanged == true then
        tMod = nNoAddMod;
    else
        tMod = nAddMod + nNoAddMod; 
    end
    
    if bAddRanged ~= true then
        if Crushing == 1 then
            tMod = tMod + 2;
        end
    end
    
    if bAddRanged ~= false then
        if Mighty == 1 then
            tMod = tMod + 2;
        end
    end
    
    if bAddRanged ~= true then
        if Best == 1 then
            tMod = tMod + 1;
        end
    end
    
    if bAddRanged ~= true then
        if ForceCheck == 1  and Mono ~= 1 then
            tMod = tMod + Force;
        end
    end
    
    if bAddRanged ~= false then
        if AmOp1 == 1 and AmOp2 ~= 1 then
            tMod = tMod + AmmoOne;
        else
            tMod = tMod;
        end
        if AmOp2 == 1 and AmOp1 ~= 1 then
            tMod = tMod + AmmoTwo;
        else
            tMod = tMod;
        end
    end
    return tMod;

end 

function getWeaponAttackRollStructures(nodeWeapon, nodeChar)
	if not nodeWeapon or nodeChar then
		return;
	end
	
	local nodeChar = nodeWeapon.getChild("...");
	local rActor = ActorManager.getActor("pc", nodeChar);

	local rAttack = {};
	rAttack.type = "attack";
	rAttack.label = DB.getValue(nodeWeapon, "name", "");
	
    local sRange = DB.getValue(nodeWeapon, "class", "");
    if string.lower(DB.getValue(nodeWeapon, "class", "")) == "pistol" then
        sRange = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "basic" then
        sRange = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "heavy" then
        sRange = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "launched" then
        sRange = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "thrown" then
        sRange = true;
    elseif string.lower(DB.getValue(nodeWeapon, "class", "")) == "grenade" then
        sRange = true;
    else
        sRange = false;
    end 
    
    if sRange == true then
		rAttack.range = "R";
        rAttack.stat = "ballistic";
		rAttack.target = DB.getValue(nodeWeapon, "attack.ballistic", 0);
        rAttack.temp = DB.getValue(nodeWeapon, ".attack_rangedtemp", 0);
	else
		rAttack.range = "M";
        rAttack.stat = "weapon";
        rAttack.target = DB.getValue(nodeWeapon, "attack.weapon", 0);
        rAttack.temp = DB.getValue(nodeWeapon, ".attack_meleetemp", 0);
	end
    
	return rActor, rAttack;
end 



