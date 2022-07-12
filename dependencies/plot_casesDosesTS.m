function [] = plot_casesDosesTS(scenario_folder, scenario_letters, transScenarios)


startDate = datetime(2022, 01, 05);

f = figure;
f.Position = [300 300 1550 370];
tiledlayout(1,4);

letters = ["A", "B", "C.1", "C.2"];

for transSc = 1:length(transScenarios)
    nexttile
    casesDosesTS = csvread(append('timeseries/', scenario_folder, '/scenario', scenario_letters(transSc), '_casesDosesTS_', transScenarios(transSc), 'Trans.csv'));
    
    [~, dailycases, ~, ~, ~] = readOmiTimeseries(scenario_folder, scenario_letters(transSc), transScenarios(transSc), 1);
    dailycases = median(dailycases);
    totcases_immtype = sum(casesDosesTS .* repmat(dailycases', 1, 16), 1);
    disp(sum(totcases_immtype(13:16)) / sum(totcases_immtype, 'all'))
    
    
    
    t = linspace(startDate, startDate + days(length(casesDosesTS) - 1), length(casesDosesTS));
    area(t, casesDosesTS)
    xlim([min(t) max(t)])
    ylim([0 1])
    xtickformat('ddMMM')
%     title(append(letters(transSc), '.2'))
    title(append(letters(transSc), ''))
%     title(append(letters(transSc), '.3'))
end
leg = legend('0', '1', '2a', '2b', '2c', '2d', '2e', '3a', '3b', '3c', '3d', '3e', 'Wa', 'Wb', 'Wc', 'Wd', 'Location', 'northeastoutside');
title(leg,'Immunity compartment')

ncolors = {'#21618C', '#5DADE2', ...
    '#873600', '#BA4A00', '#DC7633', '#E59866', '#EDBB99', ...
    '#9C640C', '#D68910', '#F5B041', '#F8C471', '#FAD7A0', ...
    '#212F3C', '#2E4053', '#566573', '#ABB2B9'};
newcolors = zeros(length(ncolors), 3);
for c=1:length(ncolors)
    %     disp(col)
    col = ncolors{c};
    newcolors(c, :) = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
end
colororder(newcolors)

saveas(f,append('plots/casesDosesTS/', scenario_folder, '_trans_casesDosesTS.png'));

end