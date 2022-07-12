function [] = plotOmiTS_AgeSplit(scenario, transScen, scenario_letter, saveplot)

startDate = datetime(2022, 01, 05);
plot_curdata = 1;
plot_dateline = 0;
keep_scale = 0;

change_date = 1;

lastDay = "01/05/2022";

casesData = readtable("data/omi2022_outbreak_press.xlsx");
casesData.Date = datetime(casesData.Date, 'InputFormat', 'dd/mm/yyyy');
casesData = casesData(1:111, :);

newcolors = [0 0.4470 0.7410; 0.4660 0.6740 0.1880; 0.9290 0.6940 0.1250; 0.8500 0.3250 0.0980; 0.9 0 0.9];
ncolors = {'#000000', '#009E73', '#E69F00','#D55E00',  '#56B4E9'};
for c=1:5
    %     disp(col)
    col = ncolors{c};
    newcolors(c, :) = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
end


f = figure;
f.Position = [300 300 800 500];
f.Position = [300 300 1200 250];
tiledlayout(1,3);
% title(tl, append("Baseline scenario"))

%%%% Plot daily reported cases
nexttile
title("(a)")
hold on

[~, dailycases, ~, ~, ~] = readOmiTimeseries(scenario, scenario_letter, transScen, 1);
[~, dailycases_age, ~, ~, ~] = readOmiTimeseries(scenario, scenario_letter, transScen, 2);
t = linspace(startDate, startDate + days(length(dailycases) - 1), length(dailycases));
plot(t, median(dailycases, 1), 'k')
for ageg = [1, 7, 13]; plot(t, sum(dailycases_age(:, ageg:min(ageg+5, 16)), 2)); end
% if plot_curdata == 1; plot(casesData.Date, casesData.Cases, 'ko'); end
if plot_dateline == 1; xline(t(change_date), '--r'); end
hold off
xtickformat('ddMMM')
xlabel("date")

ylabel("daily reported cases")
if keep_scale == 1; ylim([0, 25000]); end


%%%% Plot hospital beds occupied
nexttile
title("(b)")
hold on

[~, ~, ~, ~, hospbeds] = readOmiTimeseries(scenario, scenario_letter, transScen, 1);
[~, ~, ~, ~, hospbeds_age] = readOmiTimeseries(scenario, scenario_letter, transScen, 2);
t = linspace(startDate, startDate + days(length(hospbeds) - 1), length(hospbeds));
plot(t, median(hospbeds, 1), t, sum(hospbeds_age(:, 1:6), 2), t, sum(hospbeds_age(:, 7:12), 2), t, sum(hospbeds_age(:, 13:end), 2))
if plot_curdata == 1; plot(casesData.Date, max(0, casesData.In_Hosp_Press), 'ko'); end
if plot_dateline == 1; xline(t(change_date), '--r'); end
hold off
xtickformat('ddMMM')
xlabel("date")
ylabel("hospital beds occupied")


%%%% Plot cumulative deaths
nexttile
title("(c)")
hold on

[~, ~, ~, cdeaths, ~] = readOmiTimeseries(scenario, scenario_letter, transScen, 1);
[~, ~, ~, cdeaths_age, ~] = readOmiTimeseries(scenario, scenario_letter, transScen, 2);
t = linspace(startDate, startDate + days(length(cdeaths) - 1), length(cdeaths));
plot(t, median(cdeaths, 1), t, sum(cdeaths_age(:, 1:6), 2), t, sum(cdeaths_age(:, 7:12), 2), t, sum(cdeaths_age(:, 13:end), 2))
if plot_curdata == 1; plot(casesData.Date, cumsum(casesData.Deaths), 'ko'); end
if plot_dateline == 1; xline(t(change_date), '--r'); end
hold off
xtickformat('ddMMM')
xlabel("date")
ylabel("cumulative deaths")
if keep_scale == 1; ylim([0, 400]); end


leg = legend({'all', '0-29 yo', '30-59 yo', '60+ yo'}, 'Location', 'northeastoutside');
title(leg,'Age')



colororder(newcolors)

if saveplot == 1
    saveas(f,append('plots/', scenario, scenario_letter, '_', transScen(1), 'Trans.png'));
end


transSc = ["low", "med", "high", "high"];
scenario_letters = ["A", "B", "C", "D"];
dailycases_age_all = zeros(length(scenario_letters)+1, 16);
for i = 1:length(scenario_letters)
    [~, dailycases_age, ~, ~, ~] = readOmiTimeseries(scenario, scenario_letters(i), transSc(i), 2);
    dailycases_age_all(i, :) = 100.*sum(dailycases_age, 1)./sum(dailycases_age, 'all');
end
data = [47384 72443 83075 92560 98621 94918 93813 83042 74569 65576 55306 41799 33051 22020 15068 20729];
dailycases_age_all(length(scenario_letters)+1, :) = 100 .* data ./ sum(data);

age_groups = categorical({'0-4', '5-9', '10-14', '15-19', '20-24', '25-29', '30-34' ...
    '35-39', '40-44', '45-49', '50-54', '55-59', '60-64', '65-69', '70-75', '75+'});
age_groups = reordercats(age_groups,{'0-4', '5-9', '10-14', '15-19', '20-24', '25-29', '30-34' ...
    '35-39', '40-44', '45-49', '50-54', '55-59', '60-64', '65-69', '70-75', '75+'});

figure
hold on
bar(age_groups, dailycases_age_all(1:length(scenario_letters), :))
plot(age_groups, 100 .* data ./ sum(data), 'o-')
hold off
xlabel("age group (yrs)")
ylabel("proportion of total cases")
ytickformat('percentage')
l = legend(["A", "B", "C.1", "C.2", "data"]);
title(l, "Scenario")

colororder(newcolors([2, 1, 3, 4, 5], :))

end
