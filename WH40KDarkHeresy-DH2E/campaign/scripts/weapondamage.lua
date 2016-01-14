-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


function action(draginfo)
	local rActor, rDamage = CharManager.getWeaponDamageRollStructures(window.getDatabaseNode());
	
	ActionDamage.performRoll(draginfo, rActor, rDamage);
	return true;
end

function onDragStart(button, x, y, draginfo)
	return action(draginfo);
end

function onDoubleClick(x,y)
	return action();
end			


