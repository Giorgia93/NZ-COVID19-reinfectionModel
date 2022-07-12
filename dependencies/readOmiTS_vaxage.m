function [dailycases0d, dailycases1d, dailycases2d, dailycases3d, ...
    dailyhosp0d, dailyhosp1d, dailyhosp2d, dailyhosp3d] = readOmiTS_vaxage(savefolder, transSc)


filename_dailycases0d = append('timeseries/', savefolder, '/dailycases0d_', transSc, 'Trans.csv');
dailycases0d = csvread(filename_dailycases0d);
filename_dailycases1d = append('timeseries/', savefolder, '/dailycases1d_', transSc, 'Trans.csv');
dailycases1d = csvread(filename_dailycases1d);
filename_dailycases2d = append('timeseries/', savefolder, '/dailycases2d_', transSc, 'Trans.csv');
dailycases2d = csvread(filename_dailycases2d);
filename_dailycases3d = append('timeseries/', savefolder, '/dailycases3d_', transSc, 'Trans.csv');
dailycases3d = csvread(filename_dailycases3d);

filename_dailyhosp0d = append('timeseries/', savefolder, '/dailyhosp0d_', transSc, 'Trans.csv');
dailyhosp0d = csvread(filename_dailyhosp0d);
filename_dailyhosp1d = append('timeseries/', savefolder, '/dailyhosp1d_', transSc, 'Trans.csv');
dailyhosp1d = csvread(filename_dailyhosp1d);
filename_dailyhosp2d = append('timeseries/', savefolder, '/dailyhosp2d_', transSc, 'Trans.csv');
dailyhosp2d = csvread(filename_dailyhosp2d);
filename_dailyhosp3d = append('timeseries/', savefolder, '/dailyhosp3d_', transSc, 'Trans.csv');
dailyhosp3d = csvread(filename_dailyhosp3d);

end