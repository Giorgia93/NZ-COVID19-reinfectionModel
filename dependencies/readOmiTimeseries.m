function [dailyinf, dailycases, dailyhosp, cdeaths, hospbeds] = readOmiTimeseries(savefolder, scenario_letter, transSc, filename_type)

% Example filename type 1 = timeseries/test/scenarioA_dailycases_medTrans.csv
% Example filename type 2 = timeseries/test/scenarioA_dailycases_medTrans.csv

if filename_type == 1
    filename_dailyinf = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyinf_', transSc, 'Trans.csv');
    dailyinf = csvread(filename_dailyinf);
    
    filename_dailycases = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases_', transSc, 'Trans.csv');
    dailycases = csvread(filename_dailycases);
    
    filename_dailyhosp = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp_', transSc, 'Trans.csv');
    dailyhosp = csvread(filename_dailyhosp);
    
    filename_cdeaths = append('timeseries/', savefolder, '/scenario', scenario_letter, '_cumuldeaths_', transSc, 'Trans.csv');
    cdeaths = csvread(filename_cdeaths);
    
    filename_hospbeds = append('timeseries/', savefolder, '/scenario', scenario_letter, '_hospbeds_', transSc, 'Trans.csv');
    hospbeds = csvread(filename_hospbeds);
    
elseif filename_type == 2
    filename_dailyinf = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyinf_age_', transSc, 'Trans.csv');
    dailyinf = csvread(filename_dailyinf);
    
    filename_dailycases = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases_age_', transSc, 'Trans.csv');
    dailycases = csvread(filename_dailycases);
    
    filename_dailyhosp = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp_age_', transSc, 'Trans.csv');
    dailyhosp = csvread(filename_dailyhosp);
    
    filename_cdeaths = append('timeseries/', savefolder, '/scenario', scenario_letter, '_cumuldeaths_age_', transSc, 'Trans.csv');
    cdeaths = csvread(filename_cdeaths);
    
    filename_hospbeds = append('timeseries/', savefolder, '/scenario', scenario_letter, '_hospbeds_age_', transSc, 'Trans.csv');
    hospbeds = csvread(filename_hospbeds);
    
elseif filename_type == 3
    
    
    filename_dailyinf = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyinf_age_', transSc, 'Trans.csv');
    dailyinf = csvread(filename_dailyinf);
    filename_dailycases = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases_age_', transSc, 'Trans.csv');
    dailycases = csvread(filename_dailycases);
    filename_hospbeds = append('timeseries/', savefolder, '/scenario', scenario_letter, '_hospbeds_age_', transSc, 'Trans.csv');
    hospbeds = csvread(filename_hospbeds);
    
    filename_dailyhospTS_byInfDate = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp_byInfDate_age_', transSc, 'Trans.csv');
    dailyhosp = csvread(filename_dailyhospTS_byInfDate);
    
    filename_dailydeathsTS_byInfDate = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailydeaths_byInfDate_age_', transSc, 'Trans.csv');
    cdeaths = csvread(filename_dailydeathsTS_byInfDate); % NOT CUMULATIVE DEATHS
    
end



end