
folder = 'adjusted_CM_inipop';
trans_sc = 'med';

cases_0dose = readmatrix(append('timeseries/', folder, '/dailycases0d_', trans_sc, 'Trans_90boost11Jan'));
cases_1dose = readmatrix(append('timeseries/', folder, '/dailycases1d_', trans_sc, 'Trans_90boost11Jan'));
cases_2dose = readmatrix(append('timeseries/', folder, '/dailycases2d_', trans_sc, 'Trans_90boost11Jan'));
cases_3dose = readmatrix(append('timeseries/', folder, '/dailycases3d_', trans_sc, 'Trans_90boost11Jan'));

cases_alldoses = cases_0dose + cases_1dose + cases_2dose + cases_3dose;

days_toplot = [30, 60, 90];
X = categorical({'0-4','5-9','10-14','15-19', '20-24', '25-29', '30-34', '35-39', '40-44', '45-49', '50-54', '55-59', '60-64', '65-69', '70-74', '75+'});
X = reordercats(X,{'0-4','5-9','10-14','15-19', '20-24', '25-29', '30-34', '35-39', '40-44', '45-49', '50-54', '55-59', '60-64', '65-69', '70-74', '75+'});

figure(99)
bar(X, (cases_alldoses(days_toplot, :)./sum(cases_alldoses(days_toplot, :), 2))')
xlabel('age group')
ylabel('proportion of cases')
legend(append('day ', string(days_toplot(1)), ' - ', string(round(sum(cases_alldoses(days_toplot(1), :)))), ' cases'), ...
    append('day ', string(days_toplot(2)), ' - ', string(round(sum(cases_alldoses(days_toplot(2), :)))), ' cases'), ...
    append('day ', string(days_toplot(3)), ' - ', string(round(sum(cases_alldoses(days_toplot(3), :)))), ' cases'))

newcolors = zeros(5, 3);
ncolors = {'#D0ebf9', '#34b7ea', '#0074a0', '#E69F00', '#56B4E9'};
for c=1:5
    %     disp(col)
    col = ncolors{c};
    newcolors(c, :) = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
end
colororder(newcolors)