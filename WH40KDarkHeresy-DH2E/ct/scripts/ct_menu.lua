-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if User.isHost() then
		registerMenuItem("Initiative", "turn", 7);
		registerMenuItem("Roll All Initiatives", "shuffle", 7, 8);
		registerMenuItem("Roll NPC Initiatives", "mask", 7, 7);
		registerMenuItem("Roll PC Initiatives", "portrait", 7, 6);
		registerMenuItem("Reset Initiatives", "pointer_circle", 7, 4);
        
        registerMenuItem(Interface.getString("menu_rest"), "lockvisibilityon", 8);
		registerMenuItem(Interface.getString("menu_restovernight"), "pointer_circle", 8, 6);

		registerMenuItem("Delete From Tracker", "delete", 3);
		registerMenuItem("Delete All Non-Friendly", "delete", 3, 1);
		registerMenuItem("Delete Only Foes", "delete", 3, 3);

		registerMenuItem("Effects", "hand", 5);
		registerMenuItem("Clear All Effects", "pointer_circle", 5, 7);

	end
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if button == 1 then
		Interface.openRadialMenu();
		return true;
	end
end

function onMenuSelection(selection, subselection, subsubselection)
	if User.isHost() then
		if selection == 7 then
			if subselection == 4 then
				CombatManager.resetInit();
			elseif subselection == 6 then
				CombatManager2.rollInit("PC");
			elseif subselection == 7 then
				CombatManager2.rollInit("NPC");
			elseif subselection == 8 then
				CombatManager2.rollInit("All")
			end
		end
        if selection == 8 then
			if subselection == 6 then
				ChatManager.Message(Interface.getString("ct_message_restovernight"), true);
				CombatManager2.rest();
			end
		end
		if selection == 5 then
			if subselection == 7 then
				CombatManager2.resetEffects();
			end
		end
		if selection == 3 then
			if subselection == 1 then
				clearNPCs();
			elseif subselection == 3 then
				clearNPCs(true);
			end
		end
	end
end

function clearNPCs(bDeleteOnlyFoe)
	for _, vChild in pairs(window.list.getWindows()) do
		local sFaction = vChild.friendfoe.getStringValue();
		if bDeleteOnlyFoe then
			if sFaction == "foe" then
				vChild.delete();
			end
		else
			if sFaction ~= "friend" then
				vChild.delete();
			end
		end
	end
end
