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
	DB.addHandler(sNode .. ".wounds", "onUpdate", onWoundsChanged);
	onWoundsChanged();
	
	maxwoundnode = window.getDatabaseNode().createChild("totalwounds", "number");
	maxwoundnode.onUpdate = updateSlots;
	window.numberOfWounds_label.setValue(getRemainingWounds());
	registerMenuItem("Clear", "erase", 4);
end

function onClose()
	local sNode = window.getDatabaseNode().getNodeName();
	DB.removeHandler(sNode .. ".wounds", "onUpdate", onWoundsChanged);

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
		window.numberOfWounds_label.setValue(getRemainingWounds());
	end
end

function onWoundsChanged()
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
	
	local toughnessValue = window.getDatabaseNode().getChild("abilities.toughness").getValue();
	local lightwoundedThreshold = math.floor(toughnessValue/10)*2;
	local criticalWounds = window.getDatabaseNode().getChild("attributes.critwounds").getValue()
	local maxWounds = window.maxwoundvalue.getValue();
	local currentWoundValue = maxWounds - c;
	
	local healthState = "UNHARMED";
	local label_fontcolor = "0000CC00";
	if criticalWounds > 0 then 
		healthState = "CRITICALLY DAMAGED";
		label_fontcolor = "00980000";
	elseif c > lightwoundedThreshold then 
		healthState = "HEAVILY DAMAGED";
		label_fontcolor = "00FF3300";
	elseif c > 0 then 
		healthState = "LIGHTLY DAMAGED";
		label_fontcolor = "00FF9900";
	end
    

	window.healthstate_label.setValue(healthState);
	window.healthstate_label.setColor(label_fontcolor);
	window.numberOfWounds_label.setValue(getRemainingWounds());
 
	
end

function adjustCounter(nAdj)
	local m = getMaxValue();
	local c = getCurrentValue() + nAdj;
	
	--if c > m then
		--setCurrentValue(m);
	--elseif c < 0 then
		--setCurrentValue(0);
	--else
		setCurrentValue(c);
	--end
    if c > m then
        window.criticalwounds.setValue(c-m);
    else
        window.criticalwounds.setValue(0);
    end
    updateSlots();
end

--function checkBounds()
	--local m = getMaxValue();
	--local c = getCurrentValue();
	
--	if c > m then
	--	setCurrentValue(m);
	--elseif c < 0 then
	--	setCurrentValue(0);
--	end
--end

					

function getMaxValue()
	return DB.getValue(window.getDatabaseNode(), "totalwounds", 0);
end

function getCurrentValue()
	return DB.getValue(window.getDatabaseNode(), "wounds", 0);
end

function getRemainingWounds()
	return getMaxValue() - getCurrentValue();
end

function setCurrentValue(nCount)
	DB.setValue(window.getDatabaseNode(), "wounds", "number", nCount);
end
    
    
