function [] = writeOmiTS_vaxage(savefolder, scenario_letter, dailycases0d, dailycases1d, dailycases2d, dailycases3d, dailycases_waned, ...
    dailyhosp0d, dailyhosp1d, dailyhosp2d, dailyhosp3d, dailyhosp_waned, transSc)

% Example output filename = dailyinf_lowTrans_70boost1Jan.csv

filename_dailycases0d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases0d_', transSc, 'Trans.csv');
writematrix(dailycases0d, filename_dailycases0d)
filename_dailycases1d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases1d_', transSc, 'Trans.csv');
writematrix(dailycases1d, filename_dailycases1d)
filename_dailycases2d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases2d_', transSc, 'Trans.csv');
writematrix(dailycases2d, filename_dailycases2d)
filename_dailycases3d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases3d_', transSc, 'Trans.csv');
writematrix(dailycases3d, filename_dailycases3d)
filename_dailycases_waned = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailycases_waned_', transSc, 'Trans.csv');
writematrix(dailycases_waned, filename_dailycases_waned)

filename_dailyhosp0d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp0d_', transSc, 'Trans.csv');
writematrix(dailyhosp0d, filename_dailyhosp0d)
filename_dailyhosp1d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp1d_', transSc, 'Trans.csv');
writematrix(dailyhosp1d, filename_dailyhosp1d)
filename_dailyhosp2d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp2d_', transSc, 'Trans.csv');
writematrix(dailyhosp2d, filename_dailyhosp2d)
filename_dailyhosp3d = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp3d_', transSc, 'Trans.csv');
writematrix(dailyhosp3d, filename_dailyhosp3d)
filename_dailyhosp_waned = append('timeseries/', savefolder, '/scenario', scenario_letter, '_dailyhosp_waned_', transSc, 'Trans.csv');
writematrix(dailyhosp_waned, filename_dailyhosp_waned)


end