-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function rollOutcome(rollValue, modValue, successValue)
	local desc = "";
	local value = 0;
	local lSuccessValue = tonumber(successValue);
	
	local lRollValue = rollValue;
	
	if lRollValue <= lSuccessValue then
                value = 1 + math.floor(lSuccessValue/10) - math.floor(lRollValue/10);		
		if math.floor(value) == 1 then
			desc = "1 Degree of Success";
		else
			desc = math.floor(value) .. " Degrees of Success";
		end
	else
		value = 1 + math.floor(lRollValue/10) - math.floor(lSuccessValue/10)
		if math.floor(value) == 1 then
			desc = "1 Degree of Failure";
		else
			desc = math.floor(value) .. " Degrees of Failure";
		end
	end
	return desc;
end