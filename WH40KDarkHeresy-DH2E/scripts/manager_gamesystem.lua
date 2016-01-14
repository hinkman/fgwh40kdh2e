--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = "true" },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	["init"] = { bUseModStack = "true" },
	["attack"] = { sIcon = "action_attack", sTargeting = "each" },
	["damage"] = { sIcon = "action_damage", sTargeting = "each", bUseModStack = "true" },
    ["heal"] = { sIcon = "action_heal", sTargeting = "all", bUseModStack = "true" },
	["skill"] = { bUseModStack = "true" },
	["abilities"] = { bUseModStack = "true" },
	["psypowerroll"] = { bUseModStack = "true" },
    ["righteousfury"] = { },
    ["misschance"] = { }
};

targetactions = {
	"attack",
	"damage",
    "heal",
	"effect"
};

function getCharSelectDetailHost(nodeChar)
	local sValue = DB.getValue(nodeChar, "background", "");
	return sValue;
end

function requestCharSelectDetailClient()
	return "name,background,role";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails[1], vDetails[2] .. " " .. vDetails[3];
end

function getCharSelectDetailLocal(nodeLocal)
	local vDetails = {};
	table.insert(vDetails, DB.getValue(nodeLocal, "name", ""));
	table.insert(vDetails, DB.getValue(nodeLocal, "background", ""));
	table.insert(vDetails, DB.getValue(nodeLocal, "role", ""));
	return receiveCharSelectDetailClient(vDetails);
end

function getDistanceUnitsPerGrid()
	return 1;
end


currencies = { "Thrones"};
currencyDefault = "Thrones";


function getDeathThreshold(rActor)
	local nDying = 0;
    local nMaxWounds = DB.getValue(nodeActor, "totalwounds", 0);
        nDying = nMaxWounds + 6;

	return nDying;
end


