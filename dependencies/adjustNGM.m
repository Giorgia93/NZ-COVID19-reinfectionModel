function [adjustedNGM, adjustedNGMclin] = adjustNGM(par, highlow)

% Typical adjustments to contact matrix:
% 0-15 (indices 1:3) up by 40% (1.4)
% 15-25 (indices 4:5) up by 35% (1.35)
% 25-35 (indices 6:7) up by 5% (1.05)
% 35-60 (indices 8:12) down by 85% (0.15)
% 60-80 (indices 13:16) down by 90% (0.1)

if highlow == "lowContacts" % "Omicron" (low) mixing with older age groups
    % New sent by Olie on 8th April "new-new" CM
    par.contactPar.adjustContacts = 1;
    par.contactPar.diagBlockIndices = {[1:3], [4:5], [6:7], [8:12], [13:16]};
    par.contactPar.numDiagBlocks = length(par.contactPar.diagBlockIndices);
    par.contactPar.diagBlockMultipliers = {1.1, 1.2, 1.1, 0.15, 0.15};
    par.contactPar.offBlockMultipliers = {[0.7,0.55,0.45,0.5]; [0.7,0.5,0.3]; [0.5,0.5]; [0.45]};
    [adjustedNGM, adjustedNGMclin] = getNGM(par);
    
elseif highlow == "highContacts" % Higher mixing with older age groups
    % "in-between" CM
    par.contactPar.adjustContacts = 1;
    par.contactPar.diagBlockIndices = {[1:3], [4:5], [6:7], [8:10], [11:12], [13:16]};
    par.contactPar.numDiagBlocks = length(par.contactPar.diagBlockIndices);
    par.contactPar.diagBlockMultipliers = {1.1, 1.1, 1.2, 0.5, 0.3, 0.9};
    par.contactPar.offBlockMultipliers = {[0.7,0.6,0.6,0.5,0.6]; [0.7,0.6,0.5,0.6]; [0.6,0.5,0.6]; [0.5,0.6]; [0.6]};
    [adjustedNGM, adjustedNGMclin] = getNGM(par);
end

end
