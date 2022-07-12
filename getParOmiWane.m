function par = getParOmiWane(istartDate, ichangeTRdate, changeTRscenario, ...
    iimmLevel, itEnd, iborderSeeds, iborderTransRed, iisolEff, ipTrace, ...
    iisolEffCT, ipTestClin, icmAdjustBool, icmAdjustDate, ichangeIPmult)


%------------- Seed and control Parameters --------------


par.tEnd = itEnd; % 365
par.date0 = istartDate;
par.borderOpenDate = max(par.date0 + 1, datenum("01APR2022"));


changeBackAfter = inf; % Number of days after ichangeTRdate when we change back to original Ct
relTrans = 0.7;% BL - 0.75;
% changeTRby = [0.35, 0.5, 0.65]; % These were used for the fit of the high immLevel to first wave
changeTRby = [0.1, 0.3, 0.5, 0.5, 0.5, 0.5];
changeTRto = relTrans + changeTRby(changeTRscenario); %[1.15, 0.95, 0.75];
par.relTransBaseAL = relTrans*ones(1, par.tEnd+1);

% % Sudden change on one date
% par.relTransBaseAL(1, ichangeTRdate:min(ichangeTRdate + max(changeBackAfter, 0), par.tEnd+1)) = changeTRto;

% Gradual change
% gradual = relTrans + linspace(changeTRby(changeTRscenario)/30, changeTRby(changeTRscenario), 30);
gradualSpeed = 0.01; % Change to 0.015 to better fit using high immLevel
gradual = relTrans + (gradualSpeed:gradualSpeed:changeTRby(changeTRscenario));
par.relTransBaseAL(1, ichangeTRdate:min(ichangeTRdate + max(changeBackAfter, 0), par.tEnd+1)) = ...
    [gradual, changeTRto .* ones(1, par.tEnd + 2 - ichangeTRdate - length(gradual))];

% Change of policy on day ...
changeIPday = datenum("15OCT2022") - par.date0;
changeIPback = length(par.relTransBaseAL); %datenum("15OCT2022") - par.date0;
par.relTransBaseAL(changeIPday:changeIPback) = par.relTransBaseAL(changeIPday:changeIPback) .* ichangeIPmult;

% Extra scenarios for sensitivity analysis
if changeTRscenario == 4                            % two-step increase in transmission
    changeDate = datenum("01JUL2022") - istartDate;
    gradual = 1.05:0.01:1.25;
    par.relTransBaseAL(1, changeDate:par.tEnd+1) = ...
    [gradual, 1.25 .* ones(1, par.tEnd + 2 - changeDate - length(gradual))];

elseif changeTRscenario == 5                        % move to red
    changeDate = datenum("22JUN2022") - istartDate;
    gradual = changeTRto:-0.01:changeTRto - 0.2;
    par.relTransBaseAL(1, changeDate:par.tEnd+1) = ...
    [gradual, (changeTRto - 0.2) .* ones(1, par.tEnd + 2 - changeDate - length(gradual))];

elseif changeTRscenario == 6                        % move to green
    changeDate = datenum("22JUN2022") - istartDate;
    gradual = changeTRto:0.01:changeTRto + 0.1;
    par.relTransBaseAL(1, changeDate:par.tEnd+1) = ...
    [gradual, (changeTRto+0.1) .* ones(1, par.tEnd + 2 - changeDate - length(gradual))];
end

% genScenario stays constant at 2. Other values for R0 are not used.
genScenario = 2;
R0 = [4.3, 3.3, 2.7];
par.R0 = R0(genScenario);

par.minDetectTime = 0;    % time of outbreak detection
par.followUpTime = 7;    % cases with an isolation time prior to detection are distributed over this time period post-detection

% Seed infections parameters
par.meanSeedsPerDay = 500/7; % Community seeds
par.seedPeriod = 7; % Initial number of days where community seeds appear
par.borderSeedsPerDay = iborderSeeds; % Border seeds
par.borderSeedPeriod = par.tEnd - (par.borderOpenDate - par.date0);

par.relInfSeedCases = 1;
par.relInfBorderCases = 1 - iborderTransRed;
par.genSeedVaxStatus = @genSeedVaxStatus_cat2d;

%   % Used for border sensitivity analysis request with different number of arrivals every month
% month_lengths = [30, 31, 30, 31, 31, 30, 31, 30, 31];
% par.borderSeedPeriod = month_lengths;
% par.borderSeedsPerDay = iborderSeeds/7;
% par.borderSeedsPerDay = iborderSeeds .* [82710	97150	117605	...
%                                 168058	171778	192584	...
%                                 243543	257599	326518] ./ month_lengths;
    


%------------- Branching Process Parameters --------------

par.cSub = 0.5; % Relative infectiousness of subclinicals
par.ssk = 0.5; % Overdispersion/superspreading parameter k
par.maxInfectTime = 14; % Maximum infectious perod (for computational efficiency)

if genScenario == 1 % long GI scenario, high transmission
    par.genA = 5.665; par.genB = 2.826; % Generation time distribution parameters
    par.incA = 5.8; par.incB = 0.95; % Exposure to Onset distribution parameters
elseif genScenario == 2 % baseline GI scenario, medium transmission
    par.genA = 3.7016; par.genB = 2.826; % Generation time distribution parameters
    par.incA = 5.8; par.incB = 0.62; % Exposure to Onset distribution parameters
elseif genScenario == 3 % short GI scenario, low transmission
    par.genA = 3; par.genB = 2.826; % Generation time distribution parameters
    par.incA = 5.8; par.incB = 0.5; % Exposure to Onset distribution parameters
end

par.isolA = 1; par.isolB = 4; % Onset to isolation distribution parameters
par.traceA = 3; par.traceB = 3/3; % Parent isolation to quarantine distribution parameters
par.hospA = 1; par.hospB = 5; % Onset to hospitalisation distribution parameters
par.losA = 1; par.losB = 4; % Hospital LOS distribution parameters

par.pTestClin = ipTestClin; % 0.3; % Probability of detecting symptomatic cases
par.pTestSub = 0;  % Probability of detecting subclinical cases
par.pTrace = ipTrace; %0.25; % Probability of detecting a case by contact tracing
par.traceCapacity = inf;        % 1000/10   (now tracing capacity for average daily cases over last 7 days)

par.cIsol = 1 - iisolEff; %0.2;
par.cQuar = 1 - iisolEffCT; %0.5;


%------------- Disease Rate Data --------------
par.IDR = [0.5440, 0.5550, 0.5770, 0.5985, 0.6195, 0.6395, 0.6585, 0.6770, 0.6950, 0.7117, 0.7272, 0.7418, 0.7552, 0.7680, 0.7800, 0.8008]'; % Fraser group
par.ui = [0.4000, 0.3950, 0.3850, 0.4825, 0.6875, 0.8075, 0.8425, 0.8450, 0.8150, 0.8050, 0.8150, 0.8350, 0.8650, 0.8450, 0.7750, 0.7400];    % Davies relative suscewptibility
par.pSub = 1 - par.IDR;

[par.IHR, par.pICU, par.IFR] = getHerreraRatesOmi();
par.IFR(16) = par.IFR(16) * 1.6; % Adjustment to calibrate to NZ deaths data

% fprintf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", par.IFR)
% fprintf("%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", par.ui./par.ui(13))


%------------- Specify Population Structure --------------
par.nAgeGroups = 16;
fs = 'popnSizeData.xlsx';
popSizeData = readtable(fs); % Load NZ population structure from data folder

par.popCount = zeros(par.nAgeGroups, 1); % Create popDist vector
par.popCount(1:par.nAgeGroups-1) = popSizeData.National(1:par.nAgeGroups-1); % Fill entries with population distribution
par.popCount(par.nAgeGroups) = sum(popSizeData.National(par.nAgeGroups:end)); % Aggregate 75+ age-groups
par.totalPopSize = sum(par.popCount);
par.popDist = par.popCount/sum(par.popCount);

par.age = (2.5:5:77.5)'; % Define final age groups (matching contact matrix)


%------------- Get next generation matrix ---------

% NGM = readmatrix('data/NGM.xlsx');
% NGMclin_original = readmatrix('data/NGMclin.xlsx');
% NGM_adjusted = readmatrix('data/NGM_adjusted.xlsx');
% NGMclin1 = readmatrix('data/NGMclin1.xlsx');

% [NGM0_1] = adjustNGM(par.popDist, par.nAgeGroups, par.ui, par.IDR, par.cSub, "lowContacts");
% [NGM0_2] = adjustNGM(par.popDist, par.nAgeGroups, par.ui, par.IDR, par.cSub, "highContacts");


[~, NGMclin1] = adjustNGM(par, "lowContacts");
[~, NGMclin2] = adjustNGM(par, "highContacts");


par.CMadjustDate = icmAdjustDate;
par.CMadjustBool = icmAdjustBool;

if par.CMadjustBool == 1 % switch to NGM2 at icmAdjustDate
    par.NGMclin = cat(3, NGMclin1 .* ones(16, 16, par.CMadjustDate - par.date0), ...
        NGMclin2 .* ones(16, 16, par.tEnd - (par.CMadjustDate - par.date0)));
else % keep NGM1 all along
    par.NGMclin = NGMclin1 .* ones(16, 16, par.tEnd);
end

%-------------- Olie's code to adjust seed cases age dist -----------------
% % data to use
% dataName = 'covid_allcases_nhcc_2022-02-13.xlsx';
% % update seeding dist based on actual data
% date0 = istartDate; %starting date for data to consider
% date1 = 'None'; %fin date for data to consider
% 
% actualCasesTable = getAllCaseData(dataName, date0, date1);
% 
% modelAgeCentres = (2.5:5:77.5)'; % Define final age groups (matching contact matrix)
% ageEdges = [modelAgeCentres-min(modelAgeCentres); 120];
% 
% caseBinCounts = histcounts(actualCasesTable.Age,ageEdges);
% pCaseByAgeActual = caseBinCounts/sum(caseBinCounts);
% 
% % 'Seeding by actual case age dist'
% par.seedPopDist = pCaseByAgeActual';

% Seed cases age distribution to match observed cases up until 13 Feb 2022
par.seedPopDist = [0.0544 0.0755 0.0687 0.1092 0.1038 0.1163 0.1036 0.0759...
    0.0659 0.0633 0.0511 0.0455 0.0277 0.0159 0.0120 0.0113]';

  

%'Seeding by population age dist'
%par.seedPopDist = par.popDist; % general population


%------------- Define time-dependent vaccine coverage ---------

% Vaccine Effectiveness Parameters 
% after 0, 1, 2a, ... doses
par.VEs = [0    0    0 0 0 0 0                  0 0 0 0 0 0               0 0 0 0 0 0]';
par.VEt = [0    0    0 0 0 0 0                  0 0 0 0 0 0               0 0 0 0 0 0]';
% par.VEd = [0    0    0.55 0.56 0.58 0.61 0.61   0.78 0.72 0.68 0.65 0.65 0.99 0.98 0.95 0.88]'; % old baseline (conditional)
% par.VEm = [0    0    0.78 0.78 0.79 0.81 0.81   0.89 0.86 0.84 0.83 0.83  0.99 0.98 0.95 0.88]'; % old baseline (conditional)

if iimmLevel == "original"
    nweeksBtwWaneComp = 10;
    waneRateMult = 1;
    VEi_absolute = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    0.89 0.80 0.66 0.50]'; % old baseline
    VEd_absolute = [0    0    0.8290 0.8020 0.7480 0.7192 0.6295    0.9208 0.8796 0.8304 0.7900 0.6850    0.9989 0.9960 0.9830 0.9400]';
    VEm_absolute = [0    0    0.9164 0.9010 0.8740 0.8632 0.8195    0.9604 0.9398 0.9152 0.8980 0.8470    0.9989 0.9960 0.9830 0.9400]';
elseif iimmLevel == "low"
    nweeksBtwWaneComp = 15;
    waneRateMult = 1.5;
    VEi_absolute = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    0.89 0.80 0.55 0.05]';
    VEd_absolute = [0    0    0.8290 0.8020 0.7480 0.7192 0.6295    0.9208 0.8796 0.8304 0.7900 0.6850    0.9989 0.9960 0.9775 0.8860]';
    VEm_absolute = [0    0    0.9164 0.9010 0.8740 0.8632 0.8195    0.9604 0.9398 0.9152 0.8980 0.8470    0.9989 0.9960 0.9775 0.8860]';
elseif iimmLevel == "high"
    nweeksBtwWaneComp = 15;
    waneRateMult = 1/1.5;
    VEi_absolute = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    0.93 0.88 0.66 0.1]';
    VEd_absolute = [0    0    0.8290 0.8020 0.7480 0.7192 0.6295    0.9208 0.8796 0.8304 0.7900 0.6850    0.9993 0.9976 0.9830 0.8920]';
    VEm_absolute = [0    0    0.9164 0.9010 0.8740 0.8632 0.8195    0.9604 0.9398 0.9152 0.8980 0.8470    0.9993 0.9976 0.9830 0.8920]';
elseif iimmLevel == "vlow"
    nweeksBtwWaneComp = 15;
    waneRateMult = 1.5;
    VEi_absolute = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    0.89 0.80 0.55 0.05]';
    VEd_absolute = [0    0    0.8290 0.8020 0.7480 0.7192 0.6295    0.9208 0.8796 0.8304 0.7900 0.6850    0.9989 0.9960 0.9775 0.85]';
    VEm_absolute = [0    0    0.9164 0.9010 0.8740 0.8632 0.8195    0.9604 0.9398 0.9152 0.8980 0.8470    0.9989 0.9960 0.9775 0.85]';
elseif iimmLevel == "vvlow"
    nweeksBtwWaneComp = 15;
    waneRateMult = 1.5;
    VEi_absolute = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    0.89 0.80 0.55 0.05]';
    VEd_absolute = [0    0    0.8290 0.8020 0.7480 0.7192 0.6295    0.9208 0.8796 0.8304 0.7900 0.6850    0.9989 0.9960 0.9775 0.8]';
    VEm_absolute = [0    0    0.9164 0.9010 0.8740 0.8632 0.8195    0.9604 0.9398 0.9152 0.8980 0.8470    0.9989 0.9960 0.9775 0.8]';
end

par.VEi = VEi_absolute;
par.VEd = 1 - (1 - VEd_absolute) ./ (1 - VEi_absolute);
par.VEm = 1 - (1 - VEm_absolute) ./ (1 - VEi_absolute);


% fprintf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", VEi_absolute)
% fprintf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", VEd_absolute)
% fprintf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n", VEm_absolute)
% 
% fprintf("%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", par.VEi)
% fprintf("%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", par.VEd)
% fprintf("%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n", par.VEm)

% Creates matrices for 1st and 2nd dose coverage by time and age group, starting
% on date0
% If the simulation runs longer than the number of rows in these matrices, the
% coverage on the last defined time date will be used for the remainder of
% the simulation
par.vaccImmDelay = 14;     % delay from vaccination to immunity
fNamePart = "_national";
[~, par.cov1, par.cov2a, par.cov2b, par.cov2c, par.cov2d, par.cov3a, par.cov3b, par.cov3c, par.cov3d, par.cov3e] = getSegmentedVaccineData(fNamePart, par);

par.waneA = 30; par.waneB = 1;  % Parameter for gamma distributed waning time

nCats = 16; % Number of compartments (0d, 1d, 5x2d, 5x3d, 4xInfWane)

par.finalTwoDoseWaneRate = 1 / (7 * 10);  % average 10 weeks to move from 2d to 2e
par.prevInfWaneRate = waneRateMult * 1 / (7 * nweeksBtwWaneComp); % average 15 weeks to move between post-infection waning compartments

covMat = zeros(11, par.nAgeGroups, par.tEnd-1); % Proportions having exactly 0, 1, 2a... doses
cumCovMat = zeros(11, par.nAgeGroups, par.tEnd-1); % Proportions having at least 0, 1, 2a... doses
par.Q = zeros(nCats, par.nAgeGroups, par.tEnd); % fractions moving btw compartments at each time step
par.QQ = zeros(nCats, par.nAgeGroups, par.tEnd); % fractions moving btw compartments at each time step (2e fork)

for t = 1:par.tEnd
    % 10 x 16 (one dose, 4 x two dose cats, 5 x three dose cats):
    M = [par.cov1(t, :);  par.cov2a(t, :); par.cov2b(t, :); par.cov2c(t, :); par.cov2d(t, :); ...
        par.cov3a(t, :); par.cov3b(t, :); par.cov3c(t, :); par.cov3d(t, :); par.cov3e(t, :)];
    
    
    % 11 x 16 (includes first row for 0 doses):
    covMat(:, :, t) = [1-sum(M, 1); M];         % Proportions having exactly 0, 1, 2a... doses
    cumCovMat(:, :, t)= cumsum(covMat(:, :, t), 1, 'reverse');  % Proportions having at least 0, 1, 2a... doses
    
    if t > 1
        % 10 x 16 flow from 0->1, 1->2a, 2a->2b, 2b->2c, 2c->2d, 2d->3a, 3a->3b ... 3d->3e:
        Qpart = min(1, max(0, (cumCovMat(2:end, :, t) - cumCovMat(2:end, :, t-1)) ./ covMat(1:end-1, :, t-1)));
        
        % 16 x 16 flow from cat i -> i+1 (i=1.. 16)
        par.Q(:, :, t-1) = [Qpart(1:5, :); min(1 - Qpart(6, :), par.finalTwoDoseWaneRate*ones(1, nCats)); ...
            Qpart(6:end, :); zeros(1, par.nAgeGroups); ...
            par.prevInfWaneRate*ones(3, par.nAgeGroups); zeros(1, par.nAgeGroups)];
        
        % 16 x 16 flow from cat i -> i+1 (i=1..16) - only for 6 -> 8
        par.QQ(6, :, t-1) = Qpart(6, :);
        
    end
end
end




