function C = adjustContactMatrix(C, contactPar)

% adjustCPar needs
% - blockOnly
% - groupIndices
% - groupMultipliers
% - doAdjust (to make it this far!)
% 'Block only' (blockOnly=True) means adjust e.g. C(2:5,2:5), otherwise
% will adjust the associated full rows and columns, i.e. C(2:5,:) and
% C(:,2:5) i.e. including interaction of other groups with this group
% 
% Typical: 
% 0-15 (indices 1:3) up by 40% (1.4)
% 15-25 (indices 4:5) up by 35% (1.35)
% 25-35 (indices 6:7) up by 5% (1.05)
% 35-60 (indices 8:12) down by 85% (0.15)
% 60-80 (indices 13:16) down by 90% (0.1)

% 'adjusting contact matrix'
%diagonalIndices = logical(eye(size(C)));
%CC = C; %copy C

%blockOnly = adjustCPar.blockOnly;
diagBlockIndices = contactPar.diagBlockIndices;
diagBlockMultipliers = contactPar.diagBlockMultipliers;
offBlockMultipliers = contactPar.offBlockMultipliers;
numDiagBlocks = contactPar.numDiagBlocks;

for i = 1:numDiagBlocks
    currentIndices = diagBlockIndices{i};
    indexMatrixDiagBlock = zeros(size(C));
    %diagonal blocks
    %'diagonal blocks'
    indexMatrixDiagBlock(currentIndices,currentIndices) = 1;
    indexMatrixDiagBlock(currentIndices,currentIndices) = 1;
    indexMatrixDiagBlock = logical(indexMatrixDiagBlock);
    C(indexMatrixDiagBlock) = diagBlockMultipliers{i}*C(indexMatrixDiagBlock); % 
    %off blocks
    if i < numDiagBlocks
        %'off blocks'
        offMultipliersArray = offBlockMultipliers{i}; %,:};
        for j = 1:length(offMultipliersArray) %note should exist for i = numDiagBlocks
            nextIndices = diagBlockIndices{i+j};
            C(currentIndices,nextIndices) = offMultipliersArray(j)*C(currentIndices,nextIndices);
            C(nextIndices,currentIndices) = offMultipliersArray(j)*C(nextIndices,currentIndices);
        end
    end
%     indexMatrixOffBlock = zeros(size(C));
%     indexMatrixOffBlock(currentIndices(end)+1:end,currentIndices) = 1;
%     indexMatrixOffBlock(currentIndices,currentIndices(end)+1:end) = 1;
%     indexMatrixOffBlock = logical(indexMatrixOffBlock);
%     C(indexMatrixOffBlock) = offBlockMultipliers{i}*C(indexMatrixOffBlock); % 
end

