%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   BRANCHING PROCESS MODEL
%      OMICRON MODEL WITH VAX BOOSTERS AND WANING IMMUNITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, clc


%_________________________ SIMULATION PARAMETERS __________________________

nReps = 20;  % Number of simulation repetitions

% Paths for dependencies
addpath('data');
addpath('dependencies');

% Folder where timeseries will be saved (make sure to create a "timeseries"
% folder, and within it a folder with the same name as savefolder
savefolder = "test";
% scen_letters = ["C1_baseline", "C1_trans-16", "C1_trans+8", "C2_baseline", "C2_trans-16", "C2_trans+8"];
% scen_letters = ["C1", "C1_-16", "C1_+8", "C2_baseline", "C2_-16", "C2_+8"];
% scen_letters = ["E", "F", "G", "H", "I", "J", "K", "L", "U", "V", "W", "X"]; 
if ~exist(append("timeseries/", savefolder), 'dir')
    mkdir(append("timeseries/", savefolder));
end

writesum = 1; % If =1, a summary table will be saved in the "summary" folder
plots = 1; % If = 1, plots will appear at the end of the simulation
saveplots = 0; % If = 1, plots will be saved in the "plots" folder

% Simulation start dates
dates = ["05JAN2022"]; %["01JAN2022", "01FEB2022", "01MAR2022", "01APR2022", "01MAY2022"];
startDate = datenum(dates);
nChange = length(startDate);

% Simulation duration (days)
itEnd = 365; % CHANGE BACK

% Number of daily border cases
borderSeeds = 50;
% borderSeedMultiplier = [0.02]; %[0.01, 0.02];

% Border cases transmission reduction
BC_transReduc = [0.2]; %[0.8, 0.25];

% Change of transmission reduction multiplier on date "changeTRdate" to
% "changeTRto". If no change required keep "changeTRto" the same as
% "transReduc"
changeTRdate = datenum("10MAR2022") - startDate;% Change to 15MAR for better fit to data using high immLevel

% Transmission level change on changeTRdate
changeTRscenario = [1, 2, 3]; % [3, 5, 6];

% Immunity level. 1 - original, 2 - low, 3 - high, 4 - vlow, 5 - vvlow
immunityLevel = [1];%, 2, 4, 5]; % Baseline = 1 (original)

% Community cases isolation effectiveness
isolEff = [0.8]; % Baseline = 0.8

% Probability of tracing contacts of confirmed cases
pTrace = [0.25]; % Baseline = 0.25

% Contacts isolation effectiveness
isolEffCT = [0.5]; % Baseline = 0.5

% Probability of detecting clinical/symptomatic cases
pTestClin = [0.3]; % Baseline = 0.3

% If =1, contact matrix gets adjusted to reflect younger age groups interacting more
cmAdjustBool = [0, 1]; % Baseline = 0
cmAdjustDate = datenum(["01JUL2022"]); % Baseline = "01JUL2022" %datenum(["01JUL2022", "15MAY2022", "01SEP2022"]);

% See google sheet for different variants specs. Variant 0 is Omicron
newVariantBool = [0];

% Change of policy resulting in a transmission multiplier of changeIPmult.
% If =1, no change
changeIPmult = [1]; % Baseline = 1 %1.05, 1.075


% Scenarios combinations
scenarios_combinations = combvec(changeTRscenario, startDate', immunityLevel, ...
    changeTRdate, borderSeeds, BC_transReduc, isolEff, ...
    pTrace, isolEffCT, pTestClin, cmAdjustBool, cmAdjustDate', ...
    newVariantBool, changeIPmult);
scenarios_combinations = scenarios_combinations(:, [1, 2, 3, 6]);
[nvar, nscenarios] = size(scenarios_combinations);

earlyReject.tData = [];
earlyReject.nCasesData = [];
earlyReject.threshold = inf;
earlyReject.rejectElimFlag = 1;


%___________________________ SCENARIOS LOOP _______________________________
parfor jj = 1:nscenarios
    
    scenarios = num2cell(scenarios_combinations);
%     scenario_letter = char(ceil(jj/(length(changeTRscenario) * size(dates, 2))) + 64);% + 4);
    scenario_letter = char(jj + 64);
%     scenario_letter = scen_letters(jj);
    
    
    TRscenario = ["low", "med", "high", "high", "high", "high"]; % For summary writing
    
    immLevel = ["original", "low", "high", "vlow", "vvlow"];
    
    % Parameter combination initialisation:
    [ichangeTRscenario, idate0, iimmLevel, ichangeTRdate, iborderSeeds, ...
       iborderTransRed, iisolEff, ipTrace, iisolEffCT, ipTestClin, ...
       icmAdjustBool, icmAdjustDate, inewVariantBool, ichangeIPmult] = scenarios{:, jj};
    
    % Timeseries matrices initialisation
    [dailyinfTS, dailycasesTS, dailyhospTS, cdeathsTS, hospbedsTS, ReffEmpTS] = ...
        deal(zeros(nReps, itEnd));
    
    [dailyinfTS_waned, dailycasesTS_0d, dailycasesTS_1d, dailycasesTS_2d, dailycasesTS_3d, dailycasesTS_waned, ...
        dailyhospTS_0d, dailyhospTS_1d, dailyhospTS_2d, dailyhospTS_3d, dailyhospTS_waned,...
        dailyinfTS_age, dailycasesTS_age, dailyhospTS_age, cdeathsTS_age, ...
        hospbedsTS_age, casesDosesTSall, dailyhospTS_byInfDate_age, ...
        dailydeathsTS_byInfDate_age] = deal(zeros(itEnd, 16, nReps));
    
    % Get sim parameters
    par = getParOmiWane(idate0, ichangeTRdate, ichangeTRscenario, ...
        immLevel(iimmLevel), itEnd, iborderSeeds, iborderTransRed, ...
        iisolEff, ipTrace, iisolEffCT, ipTestClin, icmAdjustBool, ...
        icmAdjustDate, ichangeIPmult);
    
    
    % Sim reps loop:
    for iRep = 1:nReps
        fprintf("Combination %i of %i, Sim %i of %i\n", jj, nscenarios, iRep, nReps)
        % Run simulation
        [cases, ~, ~, ReffEmp, ~, casesDosesTS] = runSimWaning(par, earlyReject, inewVariantBool);
        % Process cases data
        [nInfected, nIsol, reinf, cases_0dose, cases_1dose, cases_2dose, cases_3dose, cases_waned, ...
            nHosp, dailyHosp_0dose, dailyHosp_1dose, dailyHosp_2dose, dailyHosp_3dose, dailyHosp_waned, ...
            nDisc, nICUIn, nICUOut, nDeaths, nHosp_byInfDate, nDeaths_byInfDate] = postProcess(cases, par);
        
        dailyinfTS(iRep, :) = sum(nInfected(1:par.tEnd, :), 2);
        dailycasesTS(iRep, :) = sum(nIsol(1:par.tEnd, :), 2);
        dailyhospTS(iRep, :) = sum(nHosp(1:par.tEnd, :), 2);
        cdeathsTS(iRep, :) = cumsum(sum(nDeaths(1:par.tEnd, :), 2), 1);
        hospbedsTS(iRep, :) = cumsum(sum(nHosp(1:par.tEnd, :)-nDisc(1:par.tEnd, :), 2), 1);
        ReffEmpTS(iRep, :) = ReffEmp(1:end -1);
        
        dailyinfTS_waned(:, :, iRep) = reinf(1:par.tEnd, :);
        
        dailycasesTS_0d(:, :, iRep) = cases_0dose(1:par.tEnd, :);
        dailycasesTS_1d(:, :, iRep) = cases_1dose(1:par.tEnd, :);
        dailycasesTS_2d(:, :, iRep) = cases_2dose(1:par.tEnd, :);
        dailycasesTS_3d(:, :, iRep) = cases_3dose(1:par.tEnd, :);
        dailycasesTS_waned(:, :, iRep) = cases_waned(1:par.tEnd, :);
        dailyhospTS_0d(:, :, iRep) = dailyHosp_0dose(1:par.tEnd, :);
        dailyhospTS_1d(:, :, iRep) = dailyHosp_1dose(1:par.tEnd, :);
        dailyhospTS_2d(:, :, iRep) = dailyHosp_2dose(1:par.tEnd, :);
        dailyhospTS_3d(:, :, iRep) = dailyHosp_3dose(1:par.tEnd, :);
        dailyhospTS_waned(:, :, iRep) = dailyHosp_waned(1:par.tEnd, :);
        casesDosesTSall(:, :, iRep) = casesDosesTS;
        
        dailyinfTS_age(:, :, iRep) = nInfected(1:par.tEnd, :);
        dailycasesTS_age(:, :, iRep) = nIsol(1:par.tEnd, :);
        dailyhospTS_age(:, :, iRep) = nHosp(1:par.tEnd, :);
        cdeathsTS_age(:, :, iRep) = cumsum(nDeaths(1:par.tEnd, :), 1);
        hospbedsTS_age(:, :, iRep) = cumsum(nHosp(1:par.tEnd, :)-nDisc(1:par.tEnd, :), 1);
        dailyhospTS_byInfDate_age(:, :, iRep) = nHosp_byInfDate(1:par.tEnd, :);
        dailydeathsTS_byInfDate_age(:, :, iRep) = nDeaths_byInfDate(1:par.tEnd, :);
    end
    
    
    
    % Export casesDosesTS for geology plots
    writematrix(mean(casesDosesTSall, 3), append('timeseries/', savefolder, '/scenario', scenario_letter, '_casesDosesTS_', TRscenario(ichangeTRscenario), 'Trans.csv'))
    
    % Export reinf TS
    writematrix(mean(dailyinfTS_waned, 3), append('timeseries/', savefolder, '/scenario', scenario_letter, '_reinfTS_', TRscenario(ichangeTRscenario), 'Trans.csv'))
    
    % Export ReffEmp timeseries to calculate growth rate
    writematrix(mean(ReffEmpTS, 1), append('timeseries/', savefolder, '/scenario', scenario_letter, '_ReffEmpTS_', TRscenario(ichangeTRscenario), 'Trans.csv'));
    
    %     Write timeseries results, one line per repetition:
    writeOmiTimeseries(savefolder, scenario_letter, dailyinfTS, dailycasesTS, dailyhospTS, cdeathsTS, ...
        hospbedsTS, TRscenario(ichangeTRscenario))
    
    %     Write timeseries results, divided by age band and vax status, averaged over repetitions:
    writeOmiTS_vaxage(savefolder, scenario_letter, ...
        mean(dailycasesTS_0d, 3), mean(dailycasesTS_1d, 3), mean(dailycasesTS_2d, 3), mean(dailycasesTS_3d, 3), mean(dailycasesTS_waned, 3), ...
        mean(dailyhospTS_0d, 3), mean(dailyhospTS_1d, 3), mean(dailyhospTS_2d, 3), mean(dailyhospTS_3d, 3), mean(dailyhospTS_waned, 3), ...
        TRscenario(ichangeTRscenario));
    
    writeOmiTS_age(savefolder, scenario_letter, TRscenario(ichangeTRscenario), ...
        mean(dailyinfTS_age, 3), mean(dailycasesTS_age, 3), ...
        mean(dailyhospTS_age, 3), mean(cdeathsTS_age, 3), ...
        mean(hospbedsTS_age, 3), mean(dailyhospTS_byInfDate_age, 3),...
        mean(dailydeathsTS_byInfDate_age, 3));
    
end


%__________________________ Summary writing _______________________________
if writesum == 1
%     savefolder = "baseline_lowhighWimm2";
    scen_letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", ...
        "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X"];
    writeOmiSummary(savefolder, scenarios_combinations, scen_letters(1:size(scenarios_combinations, 2)))
%     writeOmiSummaryIsoPolicy(savefolder, scenarios_combinations, scen_letters)
end


% _______________________________ Plots ___________________________________
if plots == 1
%     savefolder = "baseline_lowhighWimm2";
    plot_casesDosesTS(savefolder, ["A", "B", "C", "D"], ["low", "med", "high", "high"])
end



if plots == 1
    plot_scenario = savefolder;
%     plot_scenario = "baseline_lowhighWimm2";
    titles = ["Baseline scenarios", "Fast waning of post-infection immunity scenarios", ...
        "Slow waning of post-infection immunity scenarios", ""];
    for i = 1:length(titles)
        trans_sc_toplot = ["low", "med", "high", "high"];
        scenario_letter = num2cell(char([1:length(trans_sc_toplot)] + 64 + (i - 1) * length(trans_sc_toplot)));% ,
        %         scenario_letter = ["A", "B", "C", "D"];% ,
        legendEntries = ["A", "B", "C.1", "C.2", "data"];%
        plotTitle = titles(i);
        plotOmiTS_NEW(plot_scenario, trans_sc_toplot, scenario_letter, legendEntries, saveplots, plotTitle, 0)
    end
end

% if plots == 1
%     plot_scenario = savefolder;
% %     plot_scenario = "TLsensitivityScenariosC_25MayChange";
% %     scenario_letter = ["A", "B", "C"];% ,
% %     scenario_letter = num2cell(char([1:3] + 64 + 3));% 
%     trans_sc_toplot = ["high", "high", "high"];%["low", "med", "high", "high"];
%     legendEntries = ["No change", "-16% transmission", "+8% transmission","data", "Transmission change date", "Contacts change date"];%
% %     legendEntries = ["No change", "-19% transmission", "+10% transmission","data", "Transmission change date", "Contacts change date"];%
%     plotTitle = "Scenarios C.2";
%         plotOmiTS_NEW(plot_scenario, trans_sc_toplot, scen_letters(4:6), legendEntries, saveplots, plotTitle, 1)
% end

% scenario_letter = "B";
% if plots == 1
%     plot_scenario = savefolder;
% %         plot_scenario = "baseline_lowhighWimm3";
%     trans_sc_toplot = ["low", "med", "high"];
%     plotOmiTS_AgeSplit(plot_scenario, scenario_letter, trans_sc_toplot, saveplots)
% end

% % iso policy plots
% if plots == 1
%     savefolder = "isoPolicyScenarios_15JulChange";
% %     savefolder = "isoPolicyScenarios_15JulChange15OctBack";
%     scenario_letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", ...
%         "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X"];
%     scenatio_letters = scen_letters;
%     trans_sc_toplot = ["low", "med", "high", "high"];
%     plotOmiTS_isoPolicy(savefolder, trans_sc_toplot, scenario_letters, saveplots)
% end

