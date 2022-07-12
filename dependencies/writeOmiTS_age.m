function [] = writeOmiTS_age(savefolder, scenario_letter, transSc, dailyinfTS_age, dailycasesTS_age, dailyhospTS_age, cdeathsTS_age, ...
    hospbedsTS_age, dailyhospTS_byInfDate_age, dailydeathsTS_byInfDate_age)

% Example output filename = dailyinf_lowTrans_70boost1Jan.csv

filename_dailyinfTS_age = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyinf_age_', transSc, 'Trans.csv');
writematrix(dailyinfTS_age, filename_dailyinfTS_age)

filename_dailycasesTS_age = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases_age_', transSc, 'Trans.csv');
writematrix(dailycasesTS_age, filename_dailycasesTS_age)

filename_dailyhospTS_age = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp_age_', transSc, 'Trans.csv');
writematrix(dailyhospTS_age, filename_dailyhospTS_age)

filename_cdeathsTS_age = append('timeseries/', savefolder, '/scenario', scenario_letter, '_cumuldeaths_age_', transSc, 'Trans.csv');
writematrix(cdeathsTS_age, filename_cdeathsTS_age)

filename_hospbedsTS_age = append('timeseries/', savefolder, '/scenario', scenario_letter, '_hospbeds_age_', transSc, 'Trans.csv');
writematrix(hospbedsTS_age, filename_hospbedsTS_age)

filename_dailyhospTS_byInfDate_age = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp_byInfDate_age_', transSc, 'Trans.csv');
writematrix(dailyhospTS_byInfDate_age, filename_dailyhospTS_byInfDate_age)

filename_dailydeathsTS_byInfDate_age = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailydeaths_byInfDate_age_', transSc, 'Trans.csv');
writematrix(dailydeathsTS_byInfDate_age, filename_dailydeathsTS_byInfDate_age)

end