-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function action(draginfo)
	rActor, rAttack = CharManager.getWeaponAttackRollStructures(window.getDatabaseNode());
   
   	ActionAttack.performRoll(draginfo, rActor, rAttack);
	return true;
end

function onDragStart(button, x, y, draginfo)
	return action(draginfo);
end

function onDoubleClick(x,y)
	return action();
end			
