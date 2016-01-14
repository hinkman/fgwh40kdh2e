-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function encodeAdvantage(rRoll, bTearing)    
    
    if bTearing then
        bADV = true;
    else
        bADV = false;
    end

	if bADV then
        table.insert (rRoll.aDice, 2, "d10");
	end
end

function decodeAdvantage(rRoll)
	local bADV = string.match(rRoll.sDesc, "Tearing");

	if bADV then
		if #(rRoll.aDice) > 2 then
            local D1 = rRoll.aDice[1].result;
            local D2 = rRoll.aDice[2].result;
            local D3 = rRoll.aDice[3].result;
            local DR1;
            local DR2;
            if bADV then
                DR1 = math.max(D1, D2);
                DR2 = math.max(D2, D3);
                    
                if DR2 == D2 then
                    if DR1 ~= D2 then
                        DR2 = D2
                    else
                        if D3 > D1 then
                            DR2 = D3;
                        else
                            DR2 = D1;
                        end
                    end
                end
            end

            rRoll.aDice[1].result = DR1;
            rRoll.aDice[2].result = DR2;
            
            table.remove(rRoll.aDice, 3);
        else
			local nDecodeDie;
			if bADV then
				nDecodeDie = math.max(rRoll.aDice[1].result, rRoll.aDice[2].result);
			end

			rRoll.aDice[1].result = nDecodeDie;

			table.remove(rRoll.aDice, 2);
            
		end
	end	
end

function encodeProven(rRoll, bProven)    
	if tonumber(bProven) > 0 then
		bADV = true;
    else
        bADV = false;
	end

end

function decodeProven (rRoll)
    local bADV = string.match(rRoll.sDesc, "Proven:%s");
    local sP = string.match(rRoll.sDesc, "Proven:%s(%d+)");
    local nP = tonumber(sP);
    if bADV then
        if #(rRoll.aDice) > 1 then
            local D1 = rRoll.aDice[1].result;
            local D2 = rRoll.aDice[2].result;
            local DR1;
            local DR2;
            if bADV then
                if D1 < nP then
                    DR1 = nP;
                else
                    DR1 = D1;
                end
                if D2 < nP then
                    DR2 = nP;
                else
                    DR2 = D2;
                end
            end
            rRoll.aDice[1].result = DR1;
            rRoll.aDice[2].result = DR2;
            
        else
            local nDieRoll = rRoll.aDice[1].result;
            local nDecodeDie;
            if bADV then
                if nDieRoll < nP then
                    nDecodeDie = nP;
                else
                    nDecodeDie = nDieRoll;
                end
            end
            rRoll.aDice[1].result = nDecodeDie;
        end
    end
end
              