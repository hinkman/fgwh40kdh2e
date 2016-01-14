-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

slots = {};
local nMaxSlotRow = 20;
local nDefaultSpacing = 10;
local nSpacing = nDefaultSpacing;

function onInit()
	local sNode = window.getDatabaseNode().getNodeName();
	DB.addHandler(sNode .. ".crew", "onUpdate", onCrewChanged);
	onCrewChanged();
	
	maxcrewnode = window.getDatabaseNode().createChild("totalcrew", "number");
	maxcrewnode.onUpdate = updateSlots;
	window.numberOfCrew_label.setValue(getRemainingCrew());
	registerMenuItem("Clear", "erase", 4);
end

function onClose()
	local sNode = window.getDatabaseNode().getNodeName();
	DB.removeHandler(sNode .. ".crew", "onUpdate", onCrewChanged);

	if spacing then
		nSpacing = tonumber(spacing[1]) or nDefaultSpacing;
	end
	setAnchoredHeight(nSpacing);
	setAnchoredWidth(nSpacing);

	updateSlots();

end

function onMenuSelection(selection)
	if selection == 4 then
		setCurrentValue(0);
		window.numberOfCrew_label.setValue(getRemainingCrew());
	end
end

function onCrewChanged()
	updateSlots();
end

function onWheel(notches)
	if not isReadOnly() then
		if not OptionsManager.isMouseWheelEditEnabled() then
			return false;
		end

		adjustCounter(notches);
		return true;
	end
end

function onClickDown(button, x, y)
	if not isReadOnly() then
		return true;
	end
end

function onClickRelease(button, x, y)
	if not isReadOnly() then
		local m = getMaxValue();
		local c = getCurrentValue();

		local nClickH = math.floor(x / nSpacing) + 1;
		local nClickV;
		if m > nMaxSlotRow then
			nClickV	= math.floor(y / nSpacing);
		else
			nClickV = 0;
		end
		local nClick = (nClickV * nMaxSlotRow) + nClickH;

		if nClick > c then
			adjustCounter(1);
		else
			adjustCounter(-1);
		end

		return true;
	end
end

function updateSlots()
	local m = getMaxValue();
	local c = getCurrentValue();
	
	if #slots ~= m then
		-- Clear
		for _,v in ipairs(slots) do
			v.destroy();
		end
		slots = {};

		-- Build slots
		for i = 1, m do
			local widget = nil;

			if i > c then
				widget = addBitmapWidget(stateicons[1].off[1]);
			else
				widget = addBitmapWidget(stateicons[1].on[1]);
			end

			local nW = (i - 1) % nMaxSlotRow;
			local nH = math.floor((i - 1) / nMaxSlotRow);
			local nX = (nSpacing * nW) + math.floor(nSpacing / 2);
			local nY;
			if m > nMaxSlotRow then
				nY = (nSpacing * nH) + math.floor(nSpacing / 2);
			else
				nY = (nSpacing * nH) + nSpacing;
			end
			widget.setPosition("topleft", nX, nY);

			slots[i] = widget;
		end
		
		if m > nMaxSlotRow then
			setAnchoredWidth(nMaxSlotRow * nSpacing);
			setAnchoredHeight((math.floor((m - 1) / nMaxSlotRow) + 1) * nSpacing);
		else
			setAnchoredWidth(m * nSpacing);
			setAnchoredHeight(nSpacing * 2);
		end
	else
		for i = 1, m do
			if i > c then
				slots[i].setBitmap(stateicons[1].off[1]);
			else
				slots[i].setBitmap(stateicons[1].on[1]);
			end
		end
	end
end

function adjustCounter(nAdj)
	local m = getMaxValue();
	local c = getCurrentValue() + nAdj;
	
	if c > m then
		setCurrentValue(m);
	elseif c < 0 then
		setCurrentValue(0);
	else
		setCurrentValue(c);
	end
	window.numberOfCrew_label.setValue(getRemainingCrew());
end

function checkBounds()
	local m = getMaxValue();
	local c = getCurrentValue();
	
	if c > m then
		setCurrentValue(m);
	elseif c < 0 then
		setCurrentValue(0);
	end
end

function getMaxValue()
	return DB.getValue(window.getDatabaseNode(), "totalcrew", 0);
end

function getCurrentValue()
	return DB.getValue(window.getDatabaseNode(), "crew", 0);
end

function getRemainingCrew()
	return getMaxValue() - getCurrentValue();
end

function setCurrentValue(nCount)
	DB.setValue(window.getDatabaseNode(), "crew", "number", nCount);
end
