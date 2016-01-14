-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

launchmsg = "CoreRPG + Dark Heresy v3.0.5 ruleset for Fantasy Grounds.\rCopyright 2013 Smiteworks USA, LLC.";

-- Abilities (database names)
abilities = {
    "weapon",
    "ballistic",
    "toughness",
    "agility",
    "willpower",
	"strength",
    "intelligence",
    "perception",
    "fellowship",
	"influence",
    "toughnessbonus",
    "strengthbonus",
    "ammo",
	"agilitybonus",
	"intelligencebonus",
	"willpowerbonus",
	"fellowshipbonus",
	"influencebonus",
    "perceptionbonus",
    "gunneryskill",
    "pilotingskill",
    "technicalbase",
    "evaluation",
    "command",
    "vehicleagility"
};

abilities_label = {
    ["weapon"] = "Weapon Skill",
    ["ballistic"] = "Ballistic Skill",
	["strength"] = "Strength",
    ["toughness"] = "Toughness",
    ["agility"] = "Agility",
	["intelligence"] = "Intelligence",
    ["perception"] = "Perception",
    ["willpower"] = "Willpower",
    ["fellowship"] = "Fellowship",
    ["influence"] = "Influence",
    ["strengthbonus"] = "Strength Bonus",
    ["ammo"] = "Ammo",
    ["toughnessbonus"] = "Toughness Bonus",
    ["agilitybonus"] = "Agility Bonus",
    ["gunneryskill"] = "Gunnery Skill",
    ["pilotingskill"] = "Piloting Skill",
    ["technicalbase"] = "Technical Base",
    ["evaluation"] = "Evaluation",
    ["command"] = "Command",
    ["vehicleagility"] = "Vehicle Agility"
};

abilities_ltos = {
    ["weapon"] = "WS",
    ["ballistic"] = "BS",
    ["toughness"] = "TN",
    ["agility"] = "AG",
    ["willpower"] = "WP",
	["strength"] = "STR",
	["intelligence"] = "INT",
    ["perception"] = "PER",
    ["fellowship"] = "FEL",
    ["influence"] = "INF",
    ["toughnessbonus"] = "TNB",
    ["strengthbonus"] = "STRB",
    ["ammo"] = "AMMO",
    ["agilitybonus"] = "AGB",
	["intelligencebonus"] = "INTB",
	["willpowerbonus"] = "WPB",
	["fellowshipbonus"] = "FELB",
	["influencebonus"] = "INFB",
    ["perceptionbonus"] = "PERB",
    ["gunneryskill"] = "GS",
    ["pilotingskill"] = "PS",
    ["technicalbase"] = "TB",
    ["evaluation"] = "EV",
    ["command"] = "CMD",
    ["vehicleagility"] = "VA"
    
};

abilities_stol = {
    ["WS"] = "weapon",
    ["BS"] = "ballistic",
    ["TN"] = "toughness",
    ["AG"] = "agility",
    ["WP"] = "willpower",
	["STR"] = "strength",
	["INT"] = "intelligence",
    ["PER"] = "perception",
	["FEL"] = "fellowship",
	["INF"] = "influence",
	["TNB"] = "toughnessbonus",
    ["STRB"] = "strengthbonus",
    ["AMMO"] = "ammo",
    ["AGB"] = "agilitybonus",
	["INTB"] = "intelligencebonus",
	["WPB"] = "willpowerbonus",
	["FELB"] = "fellowshipbonus",
	["INFB"] = "influencebonus",
    ["PERB"] = "perceptionbonus",
    ["GS"] = "gunneryskill",
    ["PS"] = "pilotingskill",
    ["TB"] = "technicalbase",
    ["EV"] = "evaluation",
    ["CMD"] = "command",
    ["VA"] = "vehicleagility"
    
};


-- Conditions supported in effect conditionals and for token widgets
-- NOTE: From rules, missing dying, staggered and disabled
conditions = {
	"blinded", 
	"climbing",
	"confused",
	"cowering",
	"dazed",
    "darkness",
    "concealed",
    "fog",
    "mist",
    "shadow",
	"dazzled",
	"deafened", 
	"entangled", 
	"exhausted",
	"fascinated",
	"fatigued",
	"frightened", 
	"grappled", 
	"helpless", 
	"kneeling",
	"nauseated",
	"panicked", 
	"paralyzed",
	"pinned", 
	"prone", 
	"running",
	"shaken", 
	"sickened", 
	"sitting",
	"slowed", 
	"squeezing", 
	"stable", 
	"stunned",
    "weakened",
    "REFAC",
    "DISP",
    "CONV",
    "COVERF",
    "COVERH",
    "COVERL",
    "COVERRS",
    "COVERLS",
	"unconscious"
};

-- Bonus/penalty effect types for token widgets
bonuscomps = {
	"INIT",
	"ABIL",
	"AC",
	"ATK",
	"CMB",
	"CMD",
	"DMG",
	"DMGS",
	"HEAL",
	"SAVE",
	"SKILL",
	"STR",
	"TN",
    "AMMO",
	"AG",
	"INT",
	"WP",
	"FEL",
	"INF",
    "WS",
    "BS",
    "PER",
    "TNB",
    "WPB",
    "AGB",
    "STRB",
    "PERB",
    "INTB",
    "FELB",
    "INFB"
};

-- Condition effect types for token widgets
condcomps = {
	["blinded"] = "cond_blinded",
	["confused"] = "cond_confused",
	["cowering"] = "cond_cowering",
	["dazed"] = "cond_dazed",
	["dazzled"] = "cond_dazzled",
    ["darkness"] = "cond_darkness",
    ["concealed"] = "cond_concealed",
    ["fog"] = "cond_fog",
    ["mist"] = "cond_mist",
    ["shadow"] = "cond_shadow",
	["deafened"] = "cond_deafened",
	["entangled"] = "cond_entangled",
	["exhausted"] = "cond_exhausted",
	["fascinated"] = "cond_fascinated",
	["fatigued"] = "cond_fatigued",
	["frightened"] = "cond_frightened",
	["grappled"] = "cond_grappled",
	["helpless"] = "cond_helpless",
	["nauseated"] = "cond_nauseated",
	["panicked"] = "cond_panicked",
	["paralyzed"] = "cond_paralyzed",
	["pinned"] = "cond_pinned",
	["prone"] = "cond_prone",
	["shaken"] = "cond_shaken",
	["sickened"] = "cond_sickened",
	["slowed"] = "cond_slowed",
    ["REFAC"] = "cond_refac",
    ["DISP"] = "cond_disp",
    ["CONV"] = "cond_conv",
    ["COVERF"] = "cond_coverfull",
	["COVERL"] = "cond_coverlower",
    ["COVERH"] = "cond_coverhigh",
    ["COVERLS"] = "cond_coverleft",
    ["COVERRS"] = "cond_coverright",
    ["weakened"] = "cond_weakened",
	["stunned"] = "cond_stunned",
	["unconscious"] = "cond_unconscious"
};

-- Other visible effect types for token widgets
othercomps = {
    ["REFAC"] = "cond_refac",
    ["DISP"] = "cond_disp",
    ["CONV"] = "cond_conv",
	["COVERF"] = "cond_coverfull",
	["COVERL"] = "cond_coverlower",
    ["COVERH"] = "cond_coverhigh",
    ["COVERLS"] = "cond_coverleft",
    ["COVERRS"] = "cond_coverright",
	["IMMUNE"] = "cond_immune",
	["RESIST"] = "cond_resist",
	["VULN"] = "cond_vuln",
	["REGEN"] = "cond_regen",
	["FHEAL"] = "cond_fheal",
	["DMGO"] = "cond_ongoing"
};

-- Effect components which can be targeted
targetableeffectcomps = {
	"COVERF",
	"COVERH",
    "COVERL",
    "COVERLS",
    "COVERRS",
    "REFAC",
    "DISP",
    "CONV",
	"ATK",
	"DMG",
    "DR",
	"IMMUNE",
	"VULN",
	"RESIST"
};

connectors = {
	"and",
	"or"
};

-- Range types supported
rangetypes = {
	"melee",
	"ranged"
};

-- Damage types supported
energytypes = {
    "negative",
    "positive"

};

immunetypes = {
    "warpfire",
    "force channeled",
    "flames",
    "fire",
    "toxin",
    "acid",
    "cold",
    "electricity",
	"holy",
    "sanctified",
    "warp",
    "force",
	"energy",
	"impact",  		
	"rending",
    "explosive",
    "h",
    "s",
    "f",
    "w",
    "e",
    "i",
    "x",
    "t",
    "ex",
    "r"
};

dmgtypes = {
	"warpfire",
    "force channeled",
    "flames",
    "fire",
    "toxin",
    "acid",
    "cold",
    "electricity",
	"holy",
    "sanctified",
    "warp",
    "force",
	"energy",
	"impact",  		
	"rending",
    "explosive",
    "h",
    "s",
    "f",
    "w",
    "e",
    "ex",
    "i",
    "x",
    "t",
    "r"
};


-- Bonus types supported in power descriptions
bonustypes = {
	"gear",
	"armor",
	"circumstance",
	"sanctified",
	"drugs",
	"dodge",
	"bionics",
    "daemonic",
	"insight",
	"luck",
	"morale",
	"natural",
	"warp",
	"racial",
	"resistance",
	"holy",
	"shield",
	"size"
};

stackablebonustypes = {
	"gear",
	"armor",
	"circumstance",
	"sanctified",
	"drugs",
	"dodge",
	"bionics",
    "daemonic",
	"insight",
	"luck",
	"morale",
	"natural",
	"warp",
	"racial",
	"resistance",
	"holy",
	"shield",
	"size"
};

-- Spell effects supported in spell descriptions
spelleffects = {
	"blinded",
	"confused",
	"cowering",
	"dazed",
	"dazzled",
	"deafened",
	"entangled",
	"exhausted",
	"fascinated",
	"frightened",
	"helpless",
	"panicked",
	"shaken",
	"sickened",
	"slowed",
	"stunned",
	"unconscious"
};

-- Coin labels
currency = { "T" };

--Skills

skilldata = {
	["Awareness"] = {
            stat = "perception"
		},
	["Barter"] = {
            stat = "fellowship"
		},
	["Carouse"] = {
            stat = "toughness"
		},
	["Charm"] = {
            stat = "fellowship"
		},
	["Climb"] = {
            stat = "strength"
		},
	["Command"] = {
            stat = "fellowship"
		},
	["Concealment"] = {
            stat = "agility"
		},
	["Contortionist"] = {
            stat = "agility"
		},
	["Deceive"] = {
            stat = "fellowship"
		},
	["Disguise"] = {
            stat = "fellowship"
		},
	["Dodge"] = {
            stat = "agility"
		},
	["Evaluate"] = {
            stat = "intelligence"
		},
	["Gamble"] = {
            stat = "intelligence"
		},
	["Inquiry"] = {
            stat = "fellowship"
		},
	["Intimidate"] = {
            stat = "strength"
		},
	["Logic"] = {
            stat = "intelligence"
		},
	["Scrutiny"] = {
            stat = "perception"
		},
	["Search"] = {
            stat = "perception"
		},
	["Silent Move"] = {
            stat = "agility"
        },
	["Swim"] = {
            stat = "strength"
		},
	["Acrobatics"] = {
            stat = "agility"
		},
	["Blather"] = {
            stat = "fellowship"
		},
	["Chem Use"] = {
            stat = "intelligence"
		},
	["Ciphers"] = {
            stat = "intelligence"
		},
	["Common Lore"] = {
            stat = "intelligence"
		},
	["Demolition"] = {
            stat = "intelligence"
		},
	["Drive"] = {
            stat = "agility"   
		},
	["Forbidden Lore"] = {
            stat = "intelligence"
		},
	["Interrogation"] = {
            stat = "willpower"
		},
	["Invocation"] = {
            stat = "willpower"
		},
	["Lip Reading"] = {
            stat = "perception"
		},
	["Literacy"] = {
            stat = "intelligence"
        },
	["Medicae"] = {
            stat = "intelligence"
		},
	["Navigation"] = {
            stat = "intelligence"
		},
	["Parry"] = {
            stat = "weapon"
		},
    ["Performer"] = {
            stat = "fellowship"
		},
    ["Pilot"] = {
            stat = "agility"
		},
    ["Psyniscience"] = {
            stat = "perception"
		},
    ["Scholastic Lore"] = {
            stat = "intelligence"
		},
    ["Secret Tongue"] = {
            stat = "intelligence"
		},
    ["Security"] = {
            stat = "agility"
		},
    ["Shadowing"] = {
            stat = "agility"
		}, 
    ["Sleight of Hand"] = {
            stat = "agility"
		},
    ["Speak Language"] = {
            stat = "intelligence"
		},
    ["Survival"] = {
            stat = "intelligence"
		},
    ["Tech Use"] = {
            stat = "intelligence"
		},
    ["Tracking"] = {
            stat = "intelligence"
		},
    ["Trade"] = {
            stat = "intelligence"
		},
    ["Wrangling"] = {
            stat = "intelligence"
		}        
}


