-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


-- original code from template_char

function action(draginfo)
	local rActor = ActorManager.getActor("pc", window.getDatabaseNode());
	ActionAbility.performRoll(draginfo, rActor, stat[1]);
	return true;
end

function onDragStart(button, x, y, draginfo)
    return action(draginfo);
end				

function onDoubleClick(x,y)
    return action();
end
