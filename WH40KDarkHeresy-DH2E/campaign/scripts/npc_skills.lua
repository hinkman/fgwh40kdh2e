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
		npcskills_iedit.setValue(0);
		npctalents_iedit.setValue(0);
	end
	npcskills_iedit.setVisible(not bReadOnly);
	npctalents_iedit.setVisible(not bReadOnly);

	npcskills.setReadOnly(bReadOnly);
	for _,w in pairs(npcskills.getWindows()) do
		w.skill_total.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
	end
	
	npctalents.setReadOnly(bReadOnly);
	for _,w in pairs(npctalents.getWindows()) do
		w.name.setReadOnly(bReadOnly);
	end
end

