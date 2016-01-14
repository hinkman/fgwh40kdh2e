-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local effectson = false;

function onInit()
	-- Set the displays to what should be shown
    setTargetingVisible();
    setDefensiveVisible();
    setSpacingVisible();
	setEffectsVisible();

	-- Acquire token reference, if any
	linkToken();
	
	-- Set up the PC links
	onLinkChanged();
	
	-- Update the displays
	onFactionChanged();
	onHealthChanged();
	
	-- Register the deletion menu item for the host
	registerMenuItem("Delete Item", "delete", 6);
	registerMenuItem("Confirm Delete", "delete", 6, 7);
end

function isPC()
	local sClass,_ = link.getValue();
	return (sClass == "charsheet");
end

function updateDisplay()
	local sFaction = friendfoe.getStringValue();

	if DB.getValue(getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end

function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		delete();
	end
end

function delete()
	local node = getDatabaseNode();
	if not node then
		close();
		return;
	end
	
	-- Remember node name
	local sNode = node.getNodeName();
	
	-- Clear any effects and wounds first, so that saves aren't triggered when initiative advanced
	effects.reset(false);
	
	-- Move to the next actor, if this CT entry is active
	if DB.getValue(node, "active", 0) == 1 then
		CombatManager.nextActor();
	end

	-- Delete the database node and close the window
	node.delete();

	-- Update list information (global subsection toggles)
	windowlist.onVisibilityToggle();
	windowlist.onEntrySectionToggle();
end

--[[function onLinkChanged()
	local sClass, sRecord = link.getValue();
	if sClass == "charsheet" then
		linkPCFields();
		name.setLine(false);
	end
end --]]

function onLinkChanged()
	-- If a PC, then set up the links to the char sheet
	local bPC = isPC();
	--if bPC then
		linkPCFields();
	--end
	
	-- Show the correct fields depending on if this is a PC or NPC
	name.setLine(not bPC);

end

function onHealthChanged()
	local sColor, nPercentWounded, sStatus = ActorManager2.getWoundColor("ct", getDatabaseNode());
	
	damagetaken.setColor(sColor);
	status.setValue(sStatus);
	
	if not isPC() then
		idelete.setVisibility((nPercentWounded >= 1.5));
	end
end

function onFactionChanged()
	-- Update the entry frame
	updateDisplay();

	-- If not a friend, then show visibility toggle
	if friendfoe.getStringValue() == "friend" then
		tokenvis.setVisible(false);
	else
		tokenvis.setVisible(true);
	end
end

function onVisibilityChanged()
	TokenManager.updateVisibility(getDatabaseNode());
	windowlist.onVisibilityToggle();
end

function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		fatiguetaken.setLink(nodeChar.createChild("fatigue", "number"));
		damagetaken.setLink(nodeChar.createChild("wounds", "number"));
		totalwounds.setLink(nodeChar.createChild("totalwounds", "number"));
		criticalwoundstaken.setLink(nodeChar.createChild("attributes.critwounds", "number"));
		halfmove.setLink(nodeChar.createChild("attributes.halfmove", "number"), true);
		fullmove.setLink(nodeChar.createChild("attributes.fullmove", "number"), true);
		charge.setLink(nodeChar.createChild("attributes.charge", "number"), true);
		run.setLink(nodeChar.createChild("attributes.run", "number"), true);	
		init.setLink(nodeChar.createChild("init_total", "number"));
        tnb.setLink(nodeChar.createChild("abilities.toughnessbonus", "number"));
        toughnessct.setLink(nodeChar.createChild("abilities.toughness", "number"));
        tnuc.setLink(nodeChar.createChild("abilities.tnmult", "number"));
        avhead.setLink(nodeChar.createChild("armor.head", "number"));
        avra.setLink(nodeChar.createChild("armor.ra", "number"));
        avla.setLink(nodeChar.createChild("armor.la", "number"));
        avbody.setLink(nodeChar.createChild("armor.body", "number"));
        avrl.setLink(nodeChar.createChild("armor.rl", "number"));
        avll.setLink(nodeChar.createChild("armor.ll", "number"));
        cover.setLink(nodeChar.createChild("cover", "number"))
	end
end

--
-- SECTION VISIBILITY FUNCTIONS
--
function setTargetingVisible()
	local v = false;
	if activatetargeting.getValue() == 1 then
		v = true;
	end

	targetingicon.setVisible(v);
	
	sub_targeting.setVisible(v);
	
	frame_targeting.setVisible(v);

	target_summary.onTargetsChanged();
end

function setDefensiveVisible()
	local v = false;
	if activatedefensive.getValue() == 1 then
		v = true;
	end
	
	defensiveicon.setVisible(v);
    
    l_tnuc.setVisible(v);
    l_tnb.setVisible(v);
    l_avhead.setVisible(v);
	l_avra.setVisible(v);
	l_avla.setVisible(v);
	l_avbody.setVisible(v);
	l_avrl.setVisible(v);
	l_avll.setVisible(v);
    l_cover.setVisible(v);
    tnuc.setVisible(v);
    tnb.setVisible(v);
	avhead.setVisible(v);
	avra.setVisible(v);
	avla.setVisible(v);
	avbody.setVisible(v);
	avrl.setVisible(v);
	avll.setVisible(v);
    cover.setVisible(v);
	
	frame_defensive.setVisible(v);
end

function setSpacingVisible()
	local v = false;
	if activatespacing.getValue() == 1 then
		v = true;
	end

	spacingicon.setVisible(v);
	
	halfmovelabel.setVisible(v);
	halfmove.setVisible(v);

	frame_spacing.setVisible(v);
end

function setEffectsVisible()
	local v = false;
	if activateeffects.getValue() == 1 then
		v = true;
	end
	
	effectson = v;
	effecticon.setVisible(v);
	
	effects.setVisible(v);
	effects_iadd.setVisible(v);

	frame_effects.setVisible(v);

	effect_summary.onEffectsChanged();
end