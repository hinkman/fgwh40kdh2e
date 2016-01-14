-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


function onInit()
    local sNode = getDatabaseNode().getNodeName();
    DB.addHandler(sNode .. ".locked", "onUpdate", onLockChanged);
    onLockChanged();
end
			
function onClose()
    local sNode = getDatabaseNode().getNodeName();
    DB.removeHandler(sNode .. ".locked", "onUpdate", onLockChanged);
end

function onLockChanged()
    if header.subwindow then
        header.subwindow.update();
    end
    if main.subwindow then
        main.subwindow.update();
    end
    if skills.subwindow then
        skills.subwindow.update();
    end
    if gear.subwindow then
        gear.subwindow.update();
    end
    if psychic.subwindow then
        psychic.subwindow.update();
    end
    if notes.subwindow then
        notes.subwindow.update();
    end
    if notes.subwindow then
        vehicle.subwindow.update();
    end
    local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
    notes.setReadOnly(bReadOnly);		
end

