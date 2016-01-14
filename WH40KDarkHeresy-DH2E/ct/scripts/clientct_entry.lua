-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onFactionChanged();
	onHealthChanged();
end

function updateDisplay()
	if active.getValue() == 1 then
		name.setFont("sheetlabel");

		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		local sFaction = friendfoe.getStringValue();
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
		
		windowlist.scrollToWindow(self);
	else
		name.setFont("sheettext");

		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		local sFaction = friendfoe.getStringValue();
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

function onActiveChanged()
	updateDisplay();
end

function onFactionChanged()
	updateHealthDisplay();
	updateDisplay();
end

function onLinkChanged()
	updateHealthDisplay();
end

function onHealthChanged()
	local sColor, nPercentWounded, sStatus = ActorManager2.getWoundColor("ct", getDatabaseNode());
	
	damagetaken.setColor(sColor);
    status.setValue(sStatus);

end

function updateHealthDisplay()
	local sOption = OptionsManager.getOption("SHPH");
	
	local bShowHealth = false;
	if sOption == "all" then
		bShowHealth = true;
	elseif sOption == "pc" then
		if friendfoe.getStringValue() == "friend" then
			bShowHealth = true;
		end
	end
	
	if bShowHealth then
		local sClass,_ = link.getValue();
		local bPC = (sClass == "charsheet");

		totalwounds.setVisible(true);
		damagetaken.setVisible(true);
		criticalwoundstaken.setVisible(true);
		fatiguetaken.setVisible(true);
        status.setVisible(false);
	else
		totalwounds.setVisible(false);
		damagetaken.setVisible(false);
		criticalwoundstaken.setVisible(false);
		fatiguetaken.setVisible(false);
        status.setVisible(true);
	end
end
