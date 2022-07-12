function [] = writeOmiSummary_vaxage(scenarioname, scenarios)

nscenarios = size(scenarios, 2);

agebands = {'0-4', '5-9', '10-14', '15-19', '20-24', '25-29', '30-34', ...
    '35-39', '40-44', '45-49', '50-54', '55-59', '60-64', '65-69', '70-74', '75+'};

% % Summary matrix initialissation
% [nCases0d, nCases1d, nCases2d, nCases3d, ...
%     nHosp0d, nHosp1d, nHosp2d, nHosp3d] = deal(zeros(length(agebands), 1));
% summary = table(agebands', nCases0d, nCases1d, nCases2d, nCases3d, nHosp0d, nHosp1d, nHosp2d, nHosp3d);

for jj = 1:nscenarios
    
    transSc = ["high", "med", "low"];

    ichangeTRscenario = scenarios(1, jj);
    
    
    [dailycases0d, dailycases1d, dailycases2d, dailycases3d, ...
    dailyhosp0d, dailyhosp1d, dailyhosp2d, dailyhosp3d] = readOmiTS_vaxage(scenarioname, transSc(ichangeTRscenario), 1);
    
    
    summary = table(agebands', ...
        sum(dailycases0d, 1)', sum(dailycases1d, 1)', sum(dailycases2d, 1)', sum(dailycases3d, 1)', ...
        sum(dailyhosp0d, 1)', sum(dailyhosp1d, 1)', sum(dailyhosp2d, 1)', sum(dailyhosp3d, 1)', ...
        'VariableNames', {'ageband', 'nCases0d', 'nCases1d', 'nCases2d', 'nCases3d', 'nHosp0d', 'nHosp1d', 'nHosp2d', 'nHosp3d'});
    writetable(summary, append("summaries/", scenarioname, "_summary_", ...
        transSc(igenScGI), 'Trans_', int2str(100*iboostProp) ,'boost', ...
        datestr(idate0, "ddmmm"), ".csv"))
end

end