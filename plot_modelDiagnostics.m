% =========================================================================
%                       PLOT MODEL DIAGNOSTICS
% Script to plot comparison between model and data, split by age group
% =========================================================================



% ------------------------ DEFINE PLOT DATES ------------------------------
firstDay = "05JAN2022";
lastDay_toplot = "12MAY2022";
startDate = datetime(firstDay, 'InputFormat', 'ddMMMyyyy');


% ------------------------ DEFINE AGE GORUPS ------------------------------
ag_type = "10-year";
caseDataRaw = readtable("data/epidata_by_age_and_vax_28-May-2022.xlsx");
caseDataRawNR = readtable("data/epidata_by_age_and_vax_NR_28-May-2022.xlsx");

if ag_type == "5-year"
    age_groups = {'0-4', '5-9', '10-14', '15-19', '20-24', '25-29', '30-34' ...
        '35-39', '40-44', '45-49', '50-54', '55-59', '60-64', '65-69', '70-75', '75+'};
elseif ag_type == "10-year"
    age_groups = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70+'};
end
n_age_groups = length(age_groups);


% ------------------------ IMPORT CASE DATA -------------------------------

[casesAge, deathsAge, casesAgeNR, hospAgeNR] = deal(zeros(size(caseDataRaw, 1), n_age_groups));

for ag = 1:n_age_groups
    casesAge(:, ag) = sum(table2array(caseDataRaw(:, ag+1:n_age_groups:n_age_groups*4+1)), 2);
    deathsAge(:, ag) = sum(table2array(caseDataRaw(:, ag+97:n_age_groups:129)), 2);
    casesAgeNR(:, ag) = sum(table2array(caseDataRawNR(:, ag+1:n_age_groups:33)), 2);
    hospAgeNR(:, ag) = sum(table2array(caseDataRawNR(:, ag+33:n_age_groups:65)), 2);
end
cases_rollingave = smoothdata(casesAge, 'movmean', 7);
casesNR_rollingave = smoothdata(casesAgeNR, 'movmean', 7);
bedsNR_rollingave = smoothdata(hospAgeNR, 'movmean', 7);
deaths_rollingave = smoothdata(deathsAge, 'movmean', 14);
dates = datetime(caseDataRaw.date);


% ----------------------- IMPORT MODEL DATA -------------------------------

scenario_folder = "baseline_lowhighWimm3";
to_plot = 3;
model_scenarios = ["A", "B", "C", "D"];
model_scenarios2 = ["A", "B", "C.1", "C.2"];
model_translevs = ["low", "med", "high", "high"];

[~, dailycases_age, dailyhosp_age, dailydeaths_age, ~] = readOmiTimeseries(scenario_folder, ...
    model_scenarios(to_plot), model_translevs(to_plot), 3);
dailycases_age = smoothdata(dailycases_age, 'movmean', 7);
dailyhosp_age = smoothdata(dailyhosp_age, 'movmean', 7);
dailydeaths_age = smoothdata(dailydeaths_age, 'movmean', 14);

dailycases_waned = readmatrix(append("timeseries/", scenario_folder, ...
    "/scenario", model_scenarios(to_plot), "_dailycases_waned_", model_translevs(to_plot), "Trans.csv"));
reinf_props = max(0, dailycases_waned ./ dailycases_age);

t = linspace(startDate, startDate + days(length(dailycases_age) - 1), length(dailycases_age));


% ---------------------- IMPORT POP DIST ----------------------------------
nAgeGroups = 8;
fs = 'popnSizeData.xlsx';
popSizeData = readtable(fs); % Load NZ population structure from data folder

popCount = zeros(nAgeGroups, 1); % Create popDist vector
popCountNR = zeros(nAgeGroups, 1); % Create popDist vector
for ag = 1:nAgeGroups-1
    popCount(ag) = sum(popSizeData.National(ag*2-1:ag*2));
    popCountNR(ag) = sum(popSizeData.Auckland(ag*2-1:ag*2)) + ...
        sum(popSizeData.CountiesManukau(ag*2-1:ag*2)) + ...
        sum(popSizeData.Waitemata(ag*2-1:ag*2)) + ...
        sum(popSizeData.Northland(ag*2-1:ag*2));
end
popCount(nAgeGroups) = sum(popSizeData.National(ag*2+1:end));
popCountNR(nAgeGroups) = sum(popSizeData.Auckland(ag*2+1:end)) + ...
        sum(popSizeData.CountiesManukau(ag*2+1:end)) + ...
        sum(popSizeData.Waitemata(ag*2+1:end)) + ...
        sum(popSizeData.Northland(ag*2+1:end));


% ------------------------- PLOT FIGURES ----------------------------------
f = figure(90);
f.Position = [50 0 1800 800];
tiledlayout(5,9)

% %%%% Plot proportion of cases that are re-rinfections
% for ag = 0:length(age_groups)
%     nexttile
%     hold on
%     if ag == 0
%         title("ALL AGES")
%         plot(t, sum(dailycases_waned, 2) ./ sum(dailycases_age, 2))
%     else
%         title(append(age_groups(ag), " years"))
%         plot(t, reinf_props(:, ag))
%     end
%     hold off
%     xtickformat('ddMMM')
%     xlabel("date")
%     ylabel("reinfections prop.")
%     xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
%     ylim([0 1])
% %     if ag > 0; ylim([0, 5900]); end
%     if ag == 8; legend([append("model " , model_scenarios2(to_plot)), "data"], 'Location', 'northeastoutside'); end
% end

%%%% Plot daily reported cases
for ag = 0:length(age_groups)
    nexttile
    hold on
    if ag == 0
        title("ALL AGES")
        plot(t, sum(dailycases_age, 2))
        plot(dates, sum(cases_rollingave, 2))
    else
        title(append(age_groups(ag), " years"))
        plot(t, sum(dailycases_age(:, ag * 2 - 1:ag * 2), 2))
        plot(dates, cases_rollingave(:, ag))
    end
    hold off
    xtickformat('ddMMM')
    xlabel("date")
    ylabel("daily reported cases")
    xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
%     if ag > 0; ylim([0, 5900]); end
    if ag == 8; legend([append("model " , model_scenarios2(to_plot)), "data"], 'Location', 'northeastoutside'); end
end

%%%% Plot daily hospital beds
for ag = 0:length(age_groups)
    nexttile
    hold on
    if ag == 0
        title("ALL AGES")
        plot(t, 100000 .* sum(dailyhosp_age, 2) ./ sum(popCount))
        plot(dates(1:end - 14), 100000 .* sum(bedsNR_rollingave(1:end - 14, :), 2) ./ sum(popCountNR))
    else
        title(append(age_groups(ag), " years"))
        plot(t, 100000 .* sum(dailyhosp_age(:, ag * 2 - 1:ag * 2), 2) ./ popCount(ag))
        plot(dates(1:end - 14), 100000 .* bedsNR_rollingave(1:end - 14, ag) ./ popCountNR(ag))
    end
    hold off
    xtickformat('ddMMM')
    xlabel("date")
    ylabel("daily hosp per 100K pop")
    xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
%     if ag > 0; ylim([0, 60]); end
end


%%%% Plot deaths
for ag = 0:length(age_groups)
    nexttile
    hold on
    if ag == 0
        title("ALL AGES")
        plot(t, 100000 .* sum(dailydeaths_age, 2) ./ sum(popCount))
        plot(dates(1:end - 14), 100000 .* sum(deaths_rollingave(1:end - 14, :), 2) ./ sum(popCount))
    else
        title(append(age_groups(ag), " years"))
        plot(t, 100000 .* sum(dailydeaths_age(:, ag * 2 - 1:ag * 2), 2) ./ popCount(ag))
        plot(dates(1:end - 14), 100000 .* deaths_rollingave(1:end - 14, ag) ./ popCount(ag))
    end
    hold off
    xtickformat('ddMMM')
    xlabel("date")
    ylabel("daily deaths per 100K pop")
    xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
%     if ag > 0; ylim([0, 15]); end
end

% %%%% Plot daily hospital beds
% for ag = 0:length(age_groups)
%     nexttile
%     hold on
%     if ag == 0
%         title("ALL AGES")
%         plot(t, sum(dailyhosp_age, 2))
%         plot(dates(1:end - 14), sum(bedsNR_rollingave(1:end - 14, :), 2))
%     else
%         title(append(age_groups(ag), " years"))
%         plot(t, sum(dailyhosp_age(:, ag * 2 - 1:ag * 2), 2))
%         plot(dates(1:end - 14), bedsNR_rollingave(1:end - 14, ag))
%     end
%     hold off
%     xtickformat('ddMMM')
%     xlabel("date")
%     ylabel("daily hosp")
%     xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
% %     if ag > 0; ylim([0, 60]); end
% end

% 
% %%%% Plot deaths
% for ag = 0:length(age_groups)
%     nexttile
%     hold on
%     if ag == 0
%         title("ALL AGES")
%         plot(t, sum(dailydeaths_age, 2))
%         plot(dates(1:end - 14), sum(deaths_rollingave(1:end - 14, :), 2))
%     else
%         title(append(age_groups(ag), " years"))
%         plot(t, sum(dailydeaths_age(:, ag * 2 - 1:ag * 2), 2))
%         plot(dates(1:end - 14), deaths_rollingave(1:end - 14, ag))
%     end
%     hold off
%     xtickformat('ddMMM')
%     xlabel("date")
%     ylabel("daily deaths")
%     xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
% %     if ag > 0; ylim([0, 15]); end
% end


%%%% Plot daily hospitalisations / daily cases
for ag = 0:length(age_groups)
    nexttile
    hold on
    if ag == 0
        title("ALL AGES")
        plot(t(20:end), 1000 .* sum(dailyhosp_age(20:end, :), 2) ./ sum(dailycases_age(20:end, :), 2))
        plot(dates(1:end - 14), 1000 .* sum(bedsNR_rollingave(1:end - 14, :), 2) ./  sum(casesNR_rollingave(1:end - 14, :), 2))
    else
        title(append(age_groups(ag), " years"))
        plot(t(20:end), 1000 .* sum(dailyhosp_age(20:end, ag * 2 - 1:ag * 2), 2) ./  sum(dailycases_age(20:end, ag * 2 - 1:ag * 2), 2))
        plot(dates(1:end - 14), 1000 .* bedsNR_rollingave(1:end - 14, ag) ./  casesNR_rollingave(1:end - 14, ag))
    end
    hold off
    xtickformat('ddMMM')
    xlabel("date")
    ylabel("daily hosp per 1K cases")
    xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
%     ylim([0, 0.6])
end


%%%% Plot deaths/cases
for ag = 0:length(age_groups)
    nexttile
    hold on
    if ag == 0
        title("ALL AGES")
        plot(t(20:end), 1000 .* sum(dailydeaths_age(20:end, :), 2) ./  sum(dailycases_age(20:end, :), 2))
        plot(dates(1:end - 14), 1000 .* sum(deaths_rollingave(1:end - 14, :), 2) ./ sum(cases_rollingave(1:end - 14, :), 2))
    else
        title(append(age_groups(ag), " years"))
        plot(t(20:end), 1000 .* sum(dailydeaths_age(20:end, ag * 2 - 1:ag * 2), 2) ./ sum(dailycases_age(20:end, ag * 2 - 1:ag * 2), 2))
        plot(dates(1:end - 14), 1000 .* deaths_rollingave(1:end - 14, ag) ./ cases_rollingave(1:end - 14, ag))
    end
    hold off
    xtickformat('ddMMM')
    xlabel("date")
    ylabel("daily deaths per 1K cases")
    xlim([t(1), t(datenum(lastDay_toplot) - datenum(firstDay))])
    if ag == 5; ylim([0, 2]); end
%     if ag > 0; ylim([0, 0.05]); end
end
