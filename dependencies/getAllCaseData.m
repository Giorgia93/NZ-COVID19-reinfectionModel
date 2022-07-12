function cases = getAllCaseData(fName,date0,date1)

% date0 is when to start from? date1 is when to stop. Only use if not
% 'None'

% fprintf('   Loading EpiSurv data:    %s\n', fName)
cases = importEpiSurv(fName);
%load(fName);

% cases.LabDateMerged = cases.LABCONFDATE;
% ind = isnat(cases.LabDateMerged);
% cases.LabDateMerged(ind) = cases.REPORTDATE(ind);
                                                                                                           %\/ travel case \/
casesToExclude = ["20-386576-HN", "20-386680-HN", "20-386674-HN", "20-386678-HN", "20-386668-HN", "20-386682-HN", "21-405012-AK"];
statusCats = categorical({'Confirmed', 'Probable'});
if strcmp(date1,'None')
    keepFlag = datenum(cases.LabDateMerged) >= date0 & ismember(cases.STATUS, statusCats) & cases.Overseas ~= 'Yes' & ~ismember(cases.EpiSurvNumber, casesToExclude) & cases.Historical ~= "Yes"  ;
else
    keepFlag = datenum(cases.LabDateMerged) >= date0 & datenum(cases.LabDateMerged) <= date1 & ismember(cases.STATUS, statusCats) & cases.Overseas ~= 'Yes' & ~ismember(cases.EpiSurvNumber, casesToExclude) & cases.Historical ~= "Yes"  ;
end
cases = cases(keepFlag, :);
[nRows, ~] = size(cases);

end