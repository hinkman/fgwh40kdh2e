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

	gunneryskill.setReadOnly(bReadOnly);
	pilotingskill.setReadOnly(bReadOnly);
	technicalbase.setReadOnly(bReadOnly);
	evaluation.setReadOnly(bReadOnly);
	command.setReadOnly(bReadOnly);
	
	init_shipmisc.setReadOnly(bReadOnly);
    vehicleagility.setReadOnly(bReadOnly);
	totalhull.setReadOnly(bReadOnly);


end

