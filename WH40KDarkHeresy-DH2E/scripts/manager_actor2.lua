-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function getPercentWounded(sNodeType, node)
	
	local nMaxWounds = 0;
	local nFatigueTaken = 0;
	local nMaxFatigue = 0;
    local nWounds = 0;
    local rActor = ActorManager.getActor(sNodeType, node);
    local nDying = GameSystem.getDeathThreshold(rActor);

    if sNodeType == "ct" then
		nWounds = DB.getValue(node, "damagetaken", 0);
		nMaxWounds = DB.getValue(node, "totalwounds", 0);
        nFatigueTaken = DB.getValue(node, "fatiguetaken", 0);
	elseif sNodeType == "pc" then
		nWounds = DB.getValue(node, "wounds", 0);
		nMaxWounds = DB.getValue(node, "totalwounds", 0);
        nFatigueTaken = DB.getValue(node, "fatigue", 0);
	end

	
	if nFatigueTaken > 0 then
		sStatus = "Fatigued";
	end


    local nPercentWounded = 0;
	 if nWounds > 0 then
		 nPercentWounded = nWounds / nMaxWounds;
	 end
	
    local sStatus;
	if OptionsManager.isOption("WNDC", "detailed") then
        if nWounds >= nMaxWounds +10 then
            local rActor = ActorManager.getActor(sNodeType, node);
			local nDying = GameSystem.getDeathThreshold(rActor);
            sStatus = "Dead";
        elseif nPercentWounded  > 1.25 then
            if nWounds > nDying then
                sStatus = "Dying";
            else
                sStatus = "Critically Wounded";
            end 
        elseif nPercentWounded  > 1 then
            sStatus = "Critically Wounded";
        elseif nPercentWounded  > 0.75 then
            sStatus = "Heavily Wounded";    
        elseif nPercentWounded  > 0.5 then
            sStatus = "Wounded";
        elseif nPercentWounded  > 0.25 then
            sStatus = "Lightly Wounded";
        else
                sStatus = "Able";
        end

    else
        if nPercentWounded > 1.75 then
            local rActor = ActorManager.getActor(sNodeType, node);
			local nDying = GameSystem.getDeathThreshold(rActor);
                sStatus = "Dead";
        elseif nPercentWounded > 1.4 then
            if nWounds > nDying then
				sStatus = "Dying";
            else
               sStatus = "Critically Damaged";
			end 
        elseif nPercentWounded > 1 then
			 sStatus = "Critically Damaged";
        elseif nPercentWounded > 0.75 then
			 sStatus = "Heavily Damaged";
        elseif nPercentWounded > 0.5 then
			 sStatus = "Lightly Damaged";                
        else 
			 sStatus = "Able";
        end
    end
	return sStatus, nPercentWounded; 
end

function getWoundColor(sNodeType, node)
	local sStatus, nPercentWounded = getPercentWounded(sNodeType, node);

	local sColor;
    if OptionsManager.isOption("WNDC", "detailed") then
       
        if sStatus == "Dead" then
            sColor = "666666";
        elseif sStatus == "Dying" then
            sColor = "990033"; 
        elseif sStatus == "Critically Wounded" then
            sColor = "CC0000";
        elseif sStatus == "Heavily Wounded" then
            sColor = "CC9933";
        elseif sStatus == "Wounded" then
            sColor = "996633";    
        elseif sStatus == "Lightly Wounded" then
            sColor = "006600";
        elseif sStatus == "Able" then
            sColor = "0066CC";
        end
        
    else
        if nPercentWounded >= 1.5 then
            sColor = "666666";
        elseif nPercentWounded >= 1.3 then
            sColor = "990033";
        elseif nPercentWounded >= 0.75 then
            sColor = "CC0000";
        elseif nPercentWounded >= 0.5 then
			 sColor = "996633";
        else
            sColor = "006600";
        end
    end
	return sColor, nPercentWounded, sStatus;
end


function getAbilitiesEffectsBonus(rActor, sAbilities)
	if not rActor or not sAbilities then
		return 0, 0;
	end
	
	local sAbilitiesEffect = DataCommon.abilities_ltos[sAbilities];
	if not sAbilitiesEffect then
		return 0, 0;
	end
	
	local nEffectMod, nAbilitiesEffects = EffectManager.getEffectsBonus(rActor, sAbilitiesEffect, true);

	local nAbilitiesMod = 0;
	local nAbilitiesScore = getAbilitiesScore(rActor, sAbilities);
	if nAbilitiesScore > 0 then
        local nAffectedScore = nEffectMod; --return only the mod
		nAbilitiesMod = nAffectedScore;
	end

	return nAbilitiesMod, nAbilitiesEffects;
end



function getAbilitiesScore(rActor, sAbilities)
	if not sAbilities then
		return -1;
	end
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if not nodeActor then
		return -1;
	end
	local sShort = string.sub(string.lower(sAbilities), 1, 3);  
	local nStatScore = -1;
  	if sActorType == "pc" then 
        local sShort = string.sub(string.lower(sAbilities), 1, 2);    
        if sShort == "we" then
                nStatScore = DB.getValue(nodeActor, "abilities.weapon", 0); 
        elseif sShort == "ba" then
                nStatScore = DB.getValue(nodeActor, "abilities.ballistic", 0); 
        elseif sShort == "to" then
                nStatScore = DB.getValue(nodeActor, "abilities.toughness", 0); 
        elseif sShort == "ag" then
                nStatScore = DB.getValue(nodeActor, "abilities.agility", 0);
        elseif sShort == "wi" then
                nStatScore = DB.getValue(nodeActor, "abilities.willpower", 0); 
        else
            local sShort = string.sub(string.lower(sAbilities), 1, 3);
            if sShort == "str" then
                nStatScore = DB.getValue(nodeActor, "abilities.strength", 0);
            elseif sShort == "int" then
                nStatScore = DB.getValue(nodeActor, "abilities.intelligence", 0);
            elseif sShort == "per" then
                nStatScore = DB.getValue(nodeActor, "abilities.perception", 0);
            elseif sShort == "fel" then
                nStatScore = DB.getValue(nodeActor, "abilities.fellowship", 0);
            elseif sShort == "gun" then
                nStatScore = DB.getValue(nodeActor, "abilities.gunneryskill", 0);
            elseif sShort == "pil" then
                nStatScore = DB.getValue(nodeActor, "abilities.pilotingskill", 0);
            elseif sShort == "com" then
                nStatScore = DB.getValue(nodeActor, "abilities.command", 0);
            elseif sShort == "eva" then
                nStatScore = DB.getValue(nodeActor, "abilities.evaluation", 0);
            elseif sShort == "tec" then
                nStatScore = DB.getValue(nodeActor, "abilities.technicalbase", 0);
            elseif sShort == "vec" then
                nStatScore = DB.getValue(nodeActor, "abilities.vehicleagility", 0);
            else
                local sShort = string.sub(string.lower(sAbilities), 1, 4);
                if sShort == "stre" then
                    nStatScore = DB.getValue(nodeActor, "abilities.strengthbonus", 0);
                elseif sShort == "ammo" then
                    nStatScore = DB.getValue(nodeActor, "abilities.ammo", 0); 
                end
            end
        end
      
	else
    	local sShort = string.sub(string.lower(sAbilities), 1, 3); 
		if sShort == "wea" then
			nStatScore = DB.getValue(nodeActor, "weapon", 0);
		elseif sShort == "bal" then
			nStatScore = DB.getValue(nodeActor, "ballistic", 0);
		elseif sShort == "str" then
			nStatScore = DB.getValue(nodeActor, "strength", 0);
		elseif sShort == "tou" then
			nStatScore = DB.getValue(nodeActor, "toughness", 0);
        elseif sShort == "agi" then
			nStatScore = DB.getValue(nodeActor, "agility", 0);
		elseif sShort == "int" then
			nStatScore = DB.getValue(nodeActor, "intelligence", 0);
        elseif sShort == "per" then
			nStatScore = DB.getValue(nodeActor, "perception", 0);
		elseif sShort == "wil" then
			nStatScore = DB.getValue(nodeActor, "willpower", 0);
		elseif sShort == "fel" then
			nStatScore = DB.getValue(nodeActor, "fellowship", 0);
        elseif sShort == "gun" then
			nStatScore = DB.getValue(nodeActor, "gunneryskill", 0);
        elseif sShort == "pil" then
			nStatScore = DB.getValue(nodeActor, "pilotingskill", 0);
        elseif sShort == "com" then
			nStatScore = DB.getValue(nodeActor, "command", 0);
        elseif sShort == "eva" then
			nStatScore = DB.getValue(nodeActor, "evaluation", 0);
        elseif sShort == "tec" then
			nStatScore = DB.getValue(nodeActor, "technicalbase", 0);
        elseif sShort == "vec" then
			nStatScore = DB.getValue(nodeActor, "vehicleagility", 0);            
        else
            local sShort = string.sub(string.lower(sAbilities), 1, 4);
            if sShort == "stre" then
                nStatScore = DB.getValue(nodeActor, "strengthbonus", 0);
            elseif sShort == "ammo" then
                nStatScore = DB.getValue(nodeActor, "ammo", 0);
            elseif sShort == "skil" then
                nStatScore = DB.getValue(nodeActor, "skill", 0); 
            end
		end
	end
	
	return nStatScore;
end

function getAbilitiesBonus(rActor, sAbilities)
	if not sAbilities then
		return 0;
	end
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if not nodeActor then
		return 0;
	end
	
	-- SETUP
	local sStat = sAbilities;
	local nStatVal = 0;

	-- GET ABILITY VALUE
	local nStatScore = getAbilitiesScore(rActor, sStat);
	if nStatScore < 0 then
		return 0;
	end
    
    if StringManager.contains(DataCommon.abilities, sStat) then
        nStatVal = nStatScore - nStatScore;  -- changes here so the stat comes back 0 and doesn't add the stat score into the calcs.
	end
	
    nStatVal = nStatVal;
	
    -- RESULTS
	return nStatVal;
end

-----
-- Defensive Evaluations
-----

function getDefenseValue(rAttacker, rDefender, rRoll)
	-- VALIDATE
	if not rDefender or not rRoll then
		return nil, 0, 0, 0;
	end
	
	local sAttack = rRoll.sDesc;
	
	-- DETERMINE ATTACK TYPE AND DEFENSE
	local sAttackType = string.match(sAttack, "%[ATTACK:%s(%w+)");

	local bCoverf = string.match(sAttack, "%[Cover%sFull]");
    local bCoverh = string.match(sAttack, "%[Cover%sHigh]");
    local bCoverl = string.match(sAttack, "%[Cover%sLow]");
    local bCoverrs = string.match(sAttack, "%[Cover%sRight]");
    local bCoverls = string.match(sAttack, "%[Cover%sLeft]");
	local bRefactor = string.match(sAttack, "%[Refactor%]");
	local bConversion = string.match(sAttack, "%[Conversion%]");
	local bDisplacer = string.match(sAttack, "%[Displacer%]");

	local sDefenderType, nodeDefender = ActorManager.getTypeAndNode(rDefender);
	if not nodeDefender then
		return nil, 0, 0, 0;
	end

	-- Determine the defense database node name
	local nDefense = 0;
	if (sDefenderType == "pc") or (sDefenderType == "ct") then
        nDefense = string.match(sAttack, "%[TN:%s(%d+)");
	end
	
	-- EFFECT MODIFIERS
	local nDefenseEffectMod = 0;
	local nMissChance = 0;
    local bCovered = false;
    local sCoverType = "No Cover";
	if ActorManager.hasCT(rDefender) then
		-- SETUP
		local nBonusSituational = 0;
		
		-- BUILD ATTACK FILTER 
		local aAttackFilter = {};
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		end
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - GENERAL

		if EffectManager.hasEffect(rDefender, "Blinded") then
			nBonusSituational = nBonusSituational - 10;
		end
        if EffectManager.hasEffect(rDefender, "Fog") then
			nBonusSituational = nBonusSituational - 20;
		end
        if EffectManager.hasEffect(rDefender, "Mist") then
			nBonusSituational = nBonusSituational - 20;
		end
        if EffectManager.hasEffect(rDefender, "Shadow") then
			nBonusSituational = nBonusSituational - 20;
		end
        if EffectManager.hasEffect(rDefender, "Concealed") then
			nBonusSituational = nBonusSituational - 30;
		end
		if EffectManager.hasEffect(rDefender, "Slowed") then
			nBonusSituational = nBonusSituational + 10;
		end
		if EffectManager.hasEffect(rDefender, "Climbing") then
                nBonusSituational = nBonusSituational + 10;
		end
        if EffectManager.hasEffect(rDefender, "Running") then
                nBonusSituational = nBonusSituational - 20;
		end
		if EffectManager.hasEffect(rDefender, "Pinned") or
				EffectManager.hasEffect(rDefender, "Grappled") then
					nBonusSituational = nBonusSituational + 10;
        end
		if EffectManager.hasEffect(rDefender, "Helpless") or 
				EffectManager.hasEffect(rDefender, "Unconscious") then
				nBonusSituational = nBonusSituational + 20;
		end
		if EffectManager.hasEffect(rDefender, "Prone") then
			if sAttackType == "R" then
				nBonusSituational = nBonusSituational - 10;
            end
        end
        if EffectManager.hasEffect(rDefender, "Prone") then
			if sAttackType == "M" then
				nBonusSituational = nBonusSituational + 10;
			end
		end
		if EffectManager.hasEffect(rDefender, "Stunned") then
			nBonusSituational = nBonusSituational + 20;
		end
        if EffectManager.hasEffect(rDefender, "Entangled") then
			nBonusSituational = nBonusSituational + 20;
		end

		if EffectManager.hasEffect(rDefender, "REFAC", rAttacker) then
			bRefactor = true;
		end
        if EffectManager.hasEffect(rDefender, "CONV", rAttacker) then
			bConversion = true;
		end
        if EffectManager.hasEffect(rDefender, "DISP", rAttacker) then
			bDisplacer = true;
		end
        
        
        if EffectManager.hasEffect(rDefender, "COVERF", rAttacker) then
			bCoverf = true;
		end
        if EffectManager.hasEffect(rDefender, "COVERH", rAttacker) then
			bCoverh = true;
		end
        if EffectManager.hasEffect(rDefender, "COVERL", rAttacker) then
			bCoverl = true;
		end
        if EffectManager.hasEffect(rDefender, "COVERRS", rAttacker) then
			bCoverrs = true;
		end
        if EffectManager.hasEffect(rDefender, "COVERLS", rAttacker) then
			bCoverls = true;
		end
        
        
        -- GET DEFENDER MODIFIERS - COVER
        
        if EffectManager.hasEffect(rDefender, "COVERF") or bCoverf then
			bCovered = true;
            sCoverType = "Cover Full";
		end
        if EffectManager.hasEffect(rDefender, "COVERH") or bCoverh then
			bCovered = true;
            sCoverType = "Cover High";
		end
        if EffectManager.hasEffect(rDefender, "COVERL") or bCoverl then
			bCovered = true;
            sCoverType = "Cover Low";
		end
        if EffectManager.hasEffect(rDefender, "COVERRS") or bCoverrs then
			bCovered = true;
            sCoverType = "Cover Right";
		end
        if EffectManager.hasEffect(rDefender, "COVERLS") or bCoverls then
			bCovered = true;
            sCoverType = "Cover Left";
		end
		
		-- GET DEFENDER SITUATIONAL MODIFIERS - CONCEALMENT
		local aRefac = EffectManager.getEffectsByType(rDefender, "REFAC", aAttackFilter, rAttacker);
		if #aRefac > 0 or EffectManager.hasEffect(rDefender, "REFAC", rAttacker) or bRefactor  then
			nMissChance = 30;
		end
        local aConv = EffectManager.getEffectsByType(rDefender, "CONV", aAttackFilter, rAttacker);
        if #aConv > 0 or EffectManager.hasEffect(rDefender, "CONV", rAttacker) or bConversion then
            nMissChance = 40;
        end
        local aDisp = EffectManager.getEffectsByType(rDefender, "DISP", aAttackFilter, rAttacker);
        if #aDisp > 0 or EffectManager.hasEffect(rDefender, "DISP", rAttacker) or bDisplacer then
            nMissChance = 50;
        end

		-- ADD IN EFFECT MODIFIERS
		nDefenseEffectMod = nBonusSituational;
        nDefense = nDefense + nDefenseEffectMod;
	
	-- NO DEFENDER SPECIFIED, SO JUST LOOK AT THE ATTACK ROLL MODIFIERS
	else
		if bRefactor then
			nMissChance = 30;
		elseif bConversion then
			nMissChance = 40;
        elseif bDisplacer then
			nMissChance = 50;
        end
        if bCoverf then
            bCovered = true;
            sCoverType = "Cover Full";
        elseif bCoverh then
            bCovered = true;
            sCoverType = "Cover High";
        elseif bCoverl then
            bCovered = true;
            sCoverType = "Cover Low";
        elseif bCoverrs then
            bCovered = true;
            sCoverType = "Cover Right";
        elseif bCoverls then
            bCovered = true;
            sCoverType = "Cover Left";            
		end
		
	end
	
	-- Return the final defense value
	return nDefense, nDefenseEffectMod, nMissChance, sCoverType, bCovered;
end