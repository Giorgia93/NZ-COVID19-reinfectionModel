% close all

savefolder = "baseline4";
transScen = ["low", "med", "high"];
rako_startDate = datetime(2022, 02, 01);
model_startDate = datetime(2022, 01, 11);

figure
hold on
for iTrans = 1:length(transScen)
    [dailyinfTS, ~, ~, ~, ~] = ...
        readOmiTimeseries(savefolder, "B", transScen(iTrans), "199", "90", "11Jan");
    prevTS = median(movsum(dailyinfTS, [0, 9], 2)) ./ 5112280;
    tmodel = linspace(model_startDate + days(12), model_startDate + days(200 - 1) + days(12), 200);
    plot(tmodel(1:100), 100.*prevTS(1:100))
end
rakoPrev = readtable("rako_prev.csv");
trako = linspace(rako_startDate, rako_startDate + days(length(rakoPrev.date) - 1), length(rakoPrev.date));
plot(trako, 100.*rakoPrev.prev, 'ko')

hold off
leg = legend([transScen, "rako data"], 'Location', 'northeast');
title(leg,'Trans. scenario')
ytickformat('percentage')
xlabel("date")
ylabel("infection prevalence")