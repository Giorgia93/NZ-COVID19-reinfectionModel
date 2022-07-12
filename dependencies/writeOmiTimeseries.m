function [] = writeOmiTimeseries(savefolder, scenario_letter, daily_inf, daily_cases, daily_hosp, cdeaths, hosp_beds, transSc)

% Example output filename = dailyinf_lowTrans_70boost1Jan.csv

filename_dailyinf = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyinf_', transSc, 'Trans.csv');
writematrix(daily_inf, filename_dailyinf)

filename_dailycases = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases_', transSc, 'Trans.csv');
writematrix(daily_cases, filename_dailycases)

filename_dailyhosp = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp_', transSc, 'Trans.csv');
writematrix(daily_hosp, filename_dailyhosp)

filename_cdeaths = append('timeseries/', savefolder, '/scenario', scenario_letter, '_cumuldeaths_', transSc, 'Trans.csv');
writematrix(cdeaths, filename_cdeaths)

filename_hospbeds = append('timeseries/', savefolder, '/scenario', scenario_letter, '_hospbeds_', transSc, 'Trans.csv');
writematrix(hosp_beds, filename_hospbeds)


if ~exist(append("timeseries/", savefolder, "/tidy"), 'dir')
    mkdir(append("timeseries/", savefolder, "/tidy"));
end

startDate = datetime(2022, 01, 05);
dates = linspace(startDate, startDate + size(daily_cases, 2), size(daily_cases, 2));
rownames = append("rep", string(1:size(daily_cases, 1)));


filename_dailyinf = append('timeseries/', savefolder, '/tidy/scenario', scenario_letter, '_dailyinf.csv');
T = array2table(daily_inf','VariableNames',rownames,'RowNames',cellstr(dates));
T.Properties.DimensionNames(1) = {'date'};
writetable(T, filename_dailyinf,'WriteRowNames',true)

filename_dailycases = append('timeseries/', savefolder, '/tidy/scenario', scenario_letter, '_dailycases.csv');
T = array2table(daily_cases','VariableNames',rownames,'RowNames',cellstr(dates));
T.Properties.DimensionNames(1) = {'date'};
writetable(T, filename_dailycases,'WriteRowNames',true)

filename_dailyhosp = append('timeseries/', savefolder, '/tidy/scenario', scenario_letter, '_dailyhosp.csv');
T = array2table(daily_hosp','VariableNames',rownames,'RowNames',cellstr(dates));
T.Properties.DimensionNames(1) = {'date'};
writetable(T, filename_dailyhosp,'WriteRowNames',true)

filename_cdeaths = append('timeseries/', savefolder, '/tidy/scenario', scenario_letter, '_cumuldeaths.csv');
T = array2table(cdeaths','VariableNames',rownames,'RowNames',cellstr(dates));
T.Properties.DimensionNames(1) = {'date'};
writetable(T, filename_cdeaths,'WriteRowNames',true)

filename_hospbeds = append('timeseries/', savefolder, '/tidy/scenario', scenario_letter, '_hospbeds.csv');
T = array2table(hosp_beds','VariableNames',rownames,'RowNames',cellstr(dates));
T.Properties.DimensionNames(1) = {'date'};
writetable(T, filename_hospbeds,'WriteRowNames',true)


end