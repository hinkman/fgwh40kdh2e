-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();

end

function updateControl(sControl, bReadOnly, bForceHide)
	if not self[sControl] then
		return false;
	end
	
	return self[sControl].update(bReadOnly, bForceHide);
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());

	weapon.setReadOnly(bReadOnly);
	ballistic.setReadOnly(bReadOnly);
	strength.setReadOnly(bReadOnly);
	toughness.setReadOnly(bReadOnly);
	agility.setReadOnly(bReadOnly);
	intelligence.setReadOnly(bReadOnly);
	perception.setReadOnly(bReadOnly);
	willpower.setReadOnly(bReadOnly);
	fellowship.setReadOnly(bReadOnly);
	init_misc.setReadOnly(bReadOnly);
	totalwounds.setReadOnly(bReadOnly);
	headhitnumber.setReadOnly(bReadOnly);
	rightarmhitnumber.setReadOnly(bReadOnly);
	leftarmhitnumber.setReadOnly(bReadOnly);
	bodyhitnumber.setReadOnly(bReadOnly);
	rightleghitnumber.setReadOnly(bReadOnly);
	leftleghitnumber.setReadOnly(bReadOnly);
	halfmoveoverride.setReadOnly(bReadOnly);
	fullmoveoverride.setReadOnly(bReadOnly);
	chargeoverride.setReadOnly(bReadOnly);
	runoverride.setReadOnly(bReadOnly);
	baseleapoverride.setReadOnly(bReadOnly);
	basejumpoverride.setReadOnly(bReadOnly);
	handedness.setReadOnly(bReadOnly);
    ucstrength.setReadOnly(bReadOnly);
    uctoughness.setReadOnly(bReadOnly);
	if bReadOnly then
		overridemovementvalues.setValue(0);
		halfmoveoverride.setVisible(false);
		fullmoveoverride.setVisible(false);
		chargeoverride.setVisible(false);
		runoverride.setVisible(false);
		baseleapoverride.setVisible(false);
		basejumpoverride.setVisible(false);
	end
	overridemovementvalues.setVisible(not bReadOnly);
end


