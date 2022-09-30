function [] = plotOmiTS_scenarios(scenario, transScen, scenario_letter, legendEntries, saveplot, plotTitle, plotCMdateLine, scenInd)

startDate = datetime(2022, 01, 05);
plot_curdata = 1;

plotDateLine = 0;
plotDate = datenum("22JUN2022") - datenum(datetime(2022, 01, 05));

% plotCMdateLine = 0;
CMdate = datenum("01JUL2022") - datenum(datetime(2022, 01, 05));

keepScale = 0;

casesData = readtable("data/omi2022_outbreak_press.xlsx");
casesData.Date = datetime(casesData.Date, 'InputFormat', 'dd/mm/yyyy');
pastDataDate = datenum("11APR2022") - datenum("22JAN2022"); %79
casesData1 = casesData(1:pastDataDate-1, :);
casesData2 = casesData(pastDataDate:end, :);


% Change colors
ncolors = {'#000000', '#009E73', '#E69F00', '#D55E00', '#56B4E9'}; % TTIQ sensitivity
% ncolors = {'#009E73', '#000000', '#E69F00', '#E69F00', '#D55E00', '#56B4E9'}; % waning
% ncolors = {'#f59402', '#ba0600', '#008f32'}; % Uncomment for TL colors
newcolors = zeros(length(ncolors), 3);
for c=1:length(ncolors)
    col = ncolors{c};
    newcolors(c, :) = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
end

lineTypes = ["-", "-", "-", "-", "-"]; %["-", "-", "-", "--", "-"];%
plotlabels = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)", "(g)", "(h)", "(i)"];
%plotlabels = plotlabels(3*scenInd-2:3*scenInd);


f = figure;
f.Position = [100 300 1600 250];
t = tiledlayout(1,4);
title(t, plotTitle)

%%%% Plot daily infections
nexttile
title(plotlabels(1) + " Daily infections")
hold on


for i = 1:length(transScen)
    [dailyinf, ~, ~, ~, ~] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
    t = linspace(startDate, startDate + days(length(dailyinf) - 1), length(dailyinf));
    plot(t, median(dailyinf, 1), 'Linestyle', lineTypes(i), 'Color', newcolors(i, :))
end
if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
if plotDateLine == 1; xline(t(plotDate), 'r--'); end
hold off
xtickformat('ddMMM')
xlabel("date")
% ylabel("daily infections")



%%%% Plot daily reported cases
nexttile
title(plotlabels(2) + " Daily reported cases")
hold on

if plot_curdata == 1
    plot(casesData1.Date, smoothdata(max(0, casesData1.nCasesTot), 'movmean', 7), 'k-', 'LineWidth', 2)
%     plot(casesData2.Date, smoothdata(max(0, casesData2.nCasesTot), 'movmean', 7), 'b-', 'LineWidth', 2)
    %     plot(casesData.Date, max(0, smoothdata(casesData.Cases, 'movmean', 7)), 'b-', 'Linewidth', 2)
end
for i = 1:length(transScen)
    [~, dailycases, ~, ~, ~] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
    t = linspace(startDate, startDate + days(length(dailycases) - 1), length(dailycases));
    plot(t, median(dailycases, 1), 'Linestyle', lineTypes(i), 'Color', newcolors(i, :))
end
if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
if plotDateLine == 1; xline(t(plotDate), 'r--'); end
hold off
xtickformat('ddMMM')
xlabel("date")
% ylabel("daily reported cases")
if keepScale == 1; ylim([0 25000]); end


%%%% Plot hospital beds occupied
nexttile
title(plotlabels(3) + " Hospital beds occupied")
hold on

if plot_curdata == 1
    plot(casesData1.Date, max(0, casesData1.In_Hosp_Press), 'k.')
%     plot(casesData2.Date, max(0, casesData2.In_Hosp_Press), 'b.')
    %     plot(casesData.Date, max(0, smoothdata(casesData.In_Hosp_Press, 'movmean', 7)), 'b-', 'Linewidth', 2)
end
for i = 1:length(transScen)
    [~, ~, ~, ~, hospbeds] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
    t = linspace(startDate, startDate + days(length(hospbeds) - 1), length(hospbeds));
    plot(t, median(hospbeds, 1), 'Linestyle', lineTypes(i), 'Color', newcolors(i, :))
end
if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
if plotDateLine == 1; xline(t(plotDate), 'r--'); end
hold off
xtickformat('ddMMM')
xlabel("date")
% ylabel("hospital beds occupied")
if keepScale == 1; ylim([0 1500]); end


%%%% Plot daily deaths
% nexttile
% title(plotlabels(3))
% hold on
% 
% 
% if plot_curdata == 1
%     plot(casesData.Date, max(0, casesData.Deaths), 'ko')
%     plot(casesData.Date, max(0, smoothdata(casesData.Deaths, 'movmean', 14)), 'b-', 'Linewidth', 2)
% end
% for i = 1:length(transScen)
%     [~, ~, ~, cdeaths, ~] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
%     t = linspace(startDate, startDate + days(length(cdeaths) - 1), length(cdeaths));
%     plot(t, [0, smoothdata(median(cdeaths(:, 2:end), 1) - median(cdeaths(:, 1:end-1), 1), 'movmean', 14)], ...
%         'Linestyle', lineTypes(i), 'Linewidth', 2, 'Color', newcolors(i, :))
% end
% if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
% if plotDateLine == 1; xline(t(plotDate), 'r--'); end
% hold off
% xtickformat('ddMMM')
% xlabel("date")
% ylabel("daily deaths")
% if keepScale == 1; ylim([0 4500]); end


%%%% Plot cumulative deaths
nexttile
title(plotlabels(4) + " Cumulative deaths")
hold on


if plot_curdata == 1
    plot(casesData1.Date, cumsum(max(0, casesData1.DeathsTot)), 'k.')
    cd2 = cumsum(max(0, casesData.DeathsTot));
%     plot(casesData2.Date, cd2(pastDataDate:end), 'b.')
end
for i = 1:length(transScen)
    [~, ~, ~, cdeaths, ~] = readOmiTimeseries(scenario, scenario_letter(i), transScen(i), 1);
    t = linspace(startDate, startDate + days(length(cdeaths) - 1), length(cdeaths));
    plot(t, median(cdeaths, 1), 'Linestyle', lineTypes(i), 'Color', newcolors(i, :))
end
if plotCMdateLine == 1; xline(t(CMdate), 'k:'); end
if plotDateLine == 1; xline(t(plotDate), 'r--'); end
hold off
xtickformat('ddMMM')
xlabel("date")
% ylabel("cumulative deaths")
if keepScale == 1; ylim([0 4500]); end


% Add legend
% leg = legend(legendEntries, 'Location', 'northeastoutside');
% title(leg,'Scenario')




% Save plots
if saveplot == 1
    saveas(f,append('plots/', scenario, scenario_letter(i), '_', transScen(i), '.png'));
end


end