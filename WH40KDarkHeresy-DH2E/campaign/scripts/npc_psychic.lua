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
	
	npcpowerlevel.setReadOnly(bReadOnly);
	
	if bReadOnly then
		npcpsychic_iedit.setValue(0);
	end
	npcpsychic_iedit.setVisible(not bReadOnly);

	npcpsychic.setReadOnly(bReadOnly);
	for _,w in pairs(npcpsychic.getWindows()) do
		w.overbleed.setReadOnly(bReadOnly);
		w.sustain.setReadOnly(bReadOnly);
		w.range.setReadOnly(bReadOnly);
		w.focustime.setReadOnly(bReadOnly);
		w.threshold.setReadOnly(bReadOnly);
		w.name.setReadOnly(bReadOnly);
	end
end



