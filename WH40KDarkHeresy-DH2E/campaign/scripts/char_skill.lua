-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--



function onInit()
    local nodeChar = getDatabaseNode().getParent();
	local sChar = nodeChar.getNodeName();
    DB.addHandler(sChar ..  ".abilities", "onChildUpdate", onStatUpdate);
    onStatUpdate();
end

function onClose()
	local nodeChar = getDatabaseNode().getParent();
	local sChar = nodeChar.getNodeName();
	DB.removeHandler(sChar ..  ".abilities", "onChildUpdate", onStatUpdate);
end



function onStatUpdate()
	stat.update(statname.getStringValue());
end






