-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local sNode = getDatabaseNode().getNodeName();
	DB.addHandler(sNode .. ".locked", "onUpdate", update);
	update();
end

function onClose()
	local sNode = getDatabaseNode().getNodeName();
	DB.removeHandler(sNode .. ".locked", "onUpdate", update);
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	
	if bReadOnly then
		npcweapon_iedit.setValue(0);
		npcammotypes_iedit.setValue(0);
		npcgear_iedit.setValue(0);
	end
	npcweapon_iedit.setVisible(not bReadOnly);
	npcammotypes_iedit.setVisible(not bReadOnly);
	npcgear_iedit.setVisible(not bReadOnly);

	npcweapon.setReadOnly(bReadOnly);
	for _,w in pairs(npcweapon.getWindows()) do
		w.special.setReadOnly(bReadOnly);
		w.clipsize.setReadOnly(bReadOnly);
		w.reload.setReadOnly(bReadOnly);
		w.pen.setReadOnly(bReadOnly);
		w.range.setReadOnly(bReadOnly);
		w.rof.setReadOnly(bReadOnly);
		w.damagetype.setReadOnly(bReadOnly);
		w.damagedice.setReadOnly(bReadOnly);
        w.damagebonus.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
	end
	
	npcammotypes.setReadOnly(bReadOnly);
	for _,w in pairs(npcammotypes.getWindows()) do
		w.numberofitems.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
	end
	
	npcgear.setReadOnly(bReadOnly);
	for _,w in pairs(npcgear.getWindows()) do
		w.numberofitems.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
	end
end
