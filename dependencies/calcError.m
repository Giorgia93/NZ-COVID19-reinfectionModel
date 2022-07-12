function dist = calcError(tData, nCasesData, tSim, nCasesSim)

ind1 = ismember(tSim, tData);
ind2 = ismember(tData, tSim);

%dist = sum((nCasesSim(ind1)-nCasesData(ind2)).^2);
dist = sum((sqrt(nCasesSim(ind1))-sqrt(nCasesData(ind2))).^2);
end

