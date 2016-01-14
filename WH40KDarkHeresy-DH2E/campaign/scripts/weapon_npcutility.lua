-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
	update();
    setWS();
    setBS();
    setPRNPC();
end    
 
function setWS()
    local node = getDatabaseNode();
    local nWS = DB.getValue(node, "...abilities.weapon", 0);
    meleeattack.setValue(nWS);
end

function setBS()
    local node = getDatabaseNode();
    local nBS = DB.getValue(node, "...abilities.ballistic", 0);
    rangedattack.setValue(nBS);
end

function setPRNPC()    
    local node = getDatabaseNode();
	local nWS = DB.getValue(node, "...abilities.weapon", 0);
    local npcskillsnode = node.getChild("...npcskills");

	weaponlistparry.setValue(nWS);
	
	if (npcskillsnode ~= nil) then
		for k, childnode in pairs (npcskillsnode.getChildren()) do
			if childnode.getChild("name").getValue() == "Parry" then
				nPR = childnode.getChild("skill_total").getValue();		
				weaponlistparry.setValue(nPR);
				break;
			end
		end
	end
end

function update()
    local nodeRecord = getDatabaseNode();
	local sType = DB.getValue(nodeRecord, "class", "");
	local bMeleeWeapon = (sType == "Primitive" or sType == "Chain" or sType == "Power" or sType == "Shock" or sType == "Melee");
    local bRangedWeapon = (sType == "Pistol" or sType == "Basic" or sType == "Heavy" or sType == "Grenade" or sType == "Thrown" or sType == "Ranged");
	
    setWS();
    setBS();
    setPRNPC();
    
    if bMeleeWeapon or bRangedWeapon then
	class.setVisible(true);
	damagedice.setVisible(true);
    damagebonus.setVisible(true);
	damagetype.setVisible(true);
	pen.setVisible(true);
	special.setVisible(true);
    location.setVisible(false);
    location_label.setVisible(true);
    locationcheck.setVisible(true);
    cover.setVisible(true);
    l_cover.setVisible(true);
    felling_label.setVisible(true);
    felling.setVisible(true);
    quality_label.setVisible(true);
    best_label.setVisible(true);
    bestcheck.setVisible(true);
    good_label.setVisible(true);
    goodcheck.setVisible(true);
    poor_label.setVisible(true);
    poorcheck.setVisible(true);
    other_label.setVisible(true);
    primitive_label.setVisible(true);
    primitive.setVisible(true);
    attack_label.setVisible(true);
    tearing_label.setVisible(true);
    tearing.setVisible(true);
    divider_label.setVisible(true);
    proven_label.setVisible(true);
    proven.setVisible(true);
    end

    if bRangedWeapon then
    clipsize.setVisible(true);
    reload.setVisible(true);
    range.setVisible(true);
    rof.setVisible(true);
    l_fireselector.setVisible(true);
    l_ammoone.setVisible(true);
    ammoone.setVisible(true);
    ammoonedam.setVisible(true);
    ammotwopen.setVisible(true);
    ammoonedmgtype.setVisible(true);
    l_ammotwo.setVisible(true);
    ammotwo.setVisible(true);
    ammotwodam.setVisible(true);
    ammotwopen.setVisible(true);
    ammotwodmgtype.setVisible(true);
    sights_label.setVisible(true);
    sights.setVisible(true);
    range_label.setVisible(true);
    rangedattackroll.setVisible(true);
    rangedattack.setVisible(false);
    attack_rangedtotal.setVisible(false);
    mightyshot_label.setVisible(true);
    mightyshot.setVisible(true);
    else
    clipsize.setVisible(false);
    reload.setVisible(false);
    range.setVisible(false);
    rof.setVisible(false);
    l_fireselector.setVisible(false);
    l_ammoone.setVisible(false);
    ammoone.setVisible(false);
    ammoonedam.setVisible(false);
    ammotwopen.setVisible(false);
    ammoonedmgtype.setVisible(false);
    l_ammotwo.setVisible(false);
    ammotwo.setVisible(false);
    ammotwodam.setVisible(false);
    ammotwopen.setVisible(false);
    ammotwodmgtype.setVisible(false);
    sights_label.setVisible(false);
    sights.setVisible(false);
    range_label.setVisible(false);
    rangedattackroll.setVisible(false);
    rangedattack.setVisible(false);
    attack_rangedtotal.setVisible(false);
    mightyshot_label.setVisible(false);
    mightyshot.setVisible(false);
    end
 
    if bMeleeWeapon then
    balanced_label.setVisible(true);
    balancedcheck.setVisible(true);
    unbalanced_label.setVisible(true);
    unbalanced.setVisible(true);
    mono_label.setVisible(true);
    mono.setVisible(true);
    force_label.setVisible(true);
    forcecheck.setVisible(true);
    force.setVisible(true);
    holy_label.setVisible(true);
    holy.setVisible(true);
    sanc_label.setVisible(true);
    sanc.setVisible(true);
    melee_label.setVisible(true);
    meleeattack.setVisible(false);
    meleeattackroll.setVisible(true);
    attack_meleetotal.setVisible(false);
    parry_label.setVisible(true);
    weaponlistparry.setVisible(false);
    parryroll.setVisible(true);
    crushingblow_label.setVisible(true);
    crushingblow.setVisible(true);
    else
    balanced_label.setVisible(false);
    balancedcheck.setVisible(false);
    unbalanced_label.setVisible(false);
    unbalanced.setVisible(false);
    mono_label.setVisible(false);
    mono.setVisible(false);
    force_label.setVisible(false);
    forcecheck.setVisible(false);
    force.setVisible(false);
    holy_label.setVisible(false);
    holy.setVisible(false);
    sanc_label.setVisible(false);
    sanc.setVisible(false);
    melee_label.setVisible(false);
    meleeattack.setVisible(false);
    meleeattackroll.setVisible(false);
    attack_meleetotal.setVisible(false);
    parry_label.setVisible(false);
    weaponlistparry.setVisible(false);
    parryroll.setVisible(false);
    crushingblow_label.setVisible(false);
    crushingblow.setVisible(false);
    end

end
