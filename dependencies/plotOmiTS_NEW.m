function [] = plotOmiTS_NEW(scenario, transScen, scenario_letter, legendEntries, saveplot, plotTitle, plotCMdateLine)

startDate = datetime(2022, 01, 05);
plot_curdata = 1;

plotDateLine = 0;
plotDate = datenum("22JUN2022") - datenum(datetime(2022, 01, 05));

% plotCMdateLine = 0;
CMdate = datenum("01JUL2022") - datenum(datetime(2022, 01, 05));

keepScale = 1;

casesData = readtable("data/omi2022_outbreak_press.xlsx");
casesData.Date = datetime(casesData.Date, 'InputFormat', 'dd/mm/yyyy');
casesData = casesData(1:111, :);

% Change colors
ncolors = {'#009E73', '#000000', '#E69F00', '#E69F00', '#D55E00', '#56B4E9'};
% ncolors = {'#f59402', '#ba0600', '#008f32'}; % Uncomment for TL colors
newcolors = zeros(length(ncolors), 3);
for c=1:length(ncolors)
    col = ncolors{c};
    newcolors(c, :) = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
end

lineTypes = ["-", "-", "-", "--", "-"];
plotlabels = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)", "(g)", "(h)", "(i)"];
plotlabels = plotlabels(1:3);


f = figure;
f.Position = [300 300 1200 250];
t = tiledlayout(1,3);
title(t, plotTitle)

%%%% Plot daily reported cases
nexttile
title(plotlabels(1))
hold on

for i = 1:length(transScen)
    [~, dailycases, ~, ~, ~] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
    t = linspace(startDate, startDate + days(length(dailycases) - 1), length(dailycases));
    plot(t, median(dailycases, 1), 'Linestyle', lineTypes(i), 'Color', newcolors(i, :))
end
if plot_curdata == 1; plot(casesData.Date, max(0, casesData.Cases), 'ko'); end
if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
if plotDateLine == 1; xline(t(plotDate), 'r--'); end
hold off
xtickformat('ddMMM')
xlabel("date")
ylabel("daily reported cases")
if keepScale == 1; ylim([0 25000]); end


%%%% Plot hospital beds occupied
nexttile
title(plotlabels(2))
hold on

for i = 1:length(transScen)
    [~, ~, ~, ~, hospbeds] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
    t = linspace(startDate, startDate + days(length(hospbeds) - 1), length(hospbeds));
    plot(t, median(hospbeds, 1), 'Linestyle', lineTypes(i), 'Color', newcolors(i, :))
end
if plot_curdata == 1; plot(casesData.Date, max(0, casesData.In_Hosp_Press), 'ko'); end
if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
if plotDateLine == 1; xline(t(plotDate), 'r--'); end
hold off
xtickformat('ddMMM')
xlabel("date")
ylabel("hospital beds occupied")
if keepScale == 1; ylim([0 1500]); end


%%%% Plot cumulative deaths
nexttile
title(plotlabels(3))
hold on


for i = 1:length(transScen)
    [~, ~, ~, cdeaths, ~] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
    t = linspace(startDate, startDate + days(length(cdeaths) - 1), length(cdeaths));
    plot(t, median(cdeaths, 1), 'Linestyle', lineTypes(i), 'Color', newcolors(i, :))
end
if plot_curdata == 1; plot(casesData.Date, cumsum(max(0, casesData.Deaths)), 'ko'); end
if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
if plotDateLine == 1; xline(t(plotDate), 'r--'); end
hold off
xtickformat('ddMMM')
xlabel("date")
ylabel("cumulative deaths")
if keepScale == 1; ylim([0 4500]); end


% Add legend
leg = legend(legendEntries, 'Location', 'northeastoutside');
title(leg,'Scenario')




% Save plots
if saveplot == 1
    saveas(f,append('plots/', scenario, scenario_letter(i), '_', transScen(i), '.png'));
end


end