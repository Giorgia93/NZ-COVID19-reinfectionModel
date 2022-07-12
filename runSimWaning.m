function [cases, dist, relTransCurrentAL, ReffEmp, Rvt, casesDosesTS] = runSimWaning(par, earlyReject, newVariantType)

% transmission process will stop if this many people have been infected
maxCases = 15000000;

% Set up time array
t = par.date0 + (0:1:par.tEnd);
nSteps = length(t)-1;

% Set the relative transmission rate due to alert level settings, as a function of time
% (this is the base setting and can be later modified by dynamic control rules)
relTransCurrentAL = par.relTransBaseAL;

% calculate the area under the curve of the generation time distribution in 1-day time
% steps - this gives the relative amount of transmitting each person does
% on each day of their infection
tArr = 0:1:par.maxInfectTime+1;
C = wblcdf(tArr, par.genA, par.genB);
auc = diff(C).';
auc = auc/sum(auc); % Renormalise auc so that it definitely sums to 1 :)


% initialise variables for the case table
caseID = (1:maxCases).';
parentID = nan(maxCases, 1);
gen = nan(maxCases, 1);
nOff = zeros(maxCases, 1);
ageGroup = nan(maxCases, 1);
Rimult = genRi(maxCases, 1, par);   % pre generate each individual's values of Yi
subclinFlag = nan(maxCases, 1);
vaccDoses = zeros(maxCases, 1);
tInfect = nan(maxCases, 1);
tOnset = genOnsetDelay(maxCases, 1, par);   % pre-generate each individuals incubation period
tIsol = nan(maxCases, 1);   % testing and isolation times assumed simulteneous
tQuar = nan(maxCases, 1);   % testing and isolation times assumed simulteneous
tHosp = nan(maxCases, 1);
tDisc = nan(maxCases, 1);
icuFlag = zeros(maxCases, 1);
diedFlag = zeros(maxCases, 1);

tWane = nan(maxCases, 1);
postInfVaccTime = nan(maxCases, 1);
reinfectFlag = zeros(maxCases, 1);

% initialise case table
cases = table(caseID, parentID, gen, nOff, ageGroup, Rimult, subclinFlag, ...
    vaccDoses, tInfect, tOnset, tQuar, tIsol, tHosp, tDisc, icuFlag, diedFlag, ...
    tWane, postInfVaccTime, reinfectFlag);

nSeed0 = poissrnd(par.meanSeedsPerDay*par.seedPeriod);

% Draw total number of border seed cases over the simulated phase
nBorderCases = poissrnd(par.borderSeedsPerDay .* par.borderSeedPeriod);

% Total number of seed cases is the existing seed cases in first 7 days +
% border cases arriving during simulated period
nSeedCases = nSeed0 + sum(nBorderCases);

% Set parentID of all seed cases to 0
cases.parentID(1:nSeedCases) = 0;

% Set generation of seed cases to 1
cases.gen(1:nSeedCases) = 1;

% Set ages of seed cases to be distributed the same as the overall popn
% cases.ageGroup(1:nSeedCases) = discRand2(par.popDist, nSeedCases, 1);

% Use new 'seedPopDist' parameter
cases.ageGroup(1:nSeedCases) = discRand2(par.seedPopDist, nSeedCases, 1);    % ages of seed cases

% Reduce infectiousness of seed cases by multiplying Rimult by
% relInfSeedCases <1, to represent home isolation of seed cases
cases.Rimult(1:nSeed0) = par.relInfSeedCases * cases.Rimult(1:nSeed0);
cases.Rimult(nSeed0+1:nSeedCases) = par.relInfBorderCases * cases.Rimult(nSeed0+1:nSeedCases);

% Set vaccination status of seed cases
cases.vaccDoses(1:nSeedCases) = par.genSeedVaxStatus(cases, nSeedCases, par);

% Set subclinical status for seed cases from probability of being
% subclinical for each age group
cases.subclinFlag(1:nSeedCases) = rand(nSeedCases, 1) < par.VEs(1+cases.vaccDoses(1:nSeedCases)) + (1-par.VEs(1+cases.vaccDoses(1:nSeedCases))).*par.pSub(cases.ageGroup(1:nSeedCases));

% Set time of appearance of each seed case, randomly drawn from the
% simulated time period
cases.tInfect(1:nSeed0) = t(1) + floor(par.seedPeriod*rand(nSeed0, 1));

prevBC = nSeed0;
prevPeriod = 0;
for mon = 1:length(par.borderSeedPeriod)
    curmon_cases = nBorderCases(mon);
    cases.tInfect(prevBC+1:prevBC+curmon_cases) = t(par.borderOpenDate - par.date0 + prevPeriod) + ...
        floor(par.borderSeedPeriod(mon) * rand(curmon_cases, 1));
    prevBC = prevBC + curmon_cases;
    prevPeriod = sum(par.borderSeedPeriod(1:mon), 2);
end

% Set wait till symptom onset period of seed cases from randomly drawn inc periods
cases.tOnset(1:nSeedCases) = cases.tOnset(1:nSeedCases) + cases.tInfect(1:nSeedCases);

% Set probability that seed cases go into isolation from the probabilities
% of symptomatic and subclinical cases getting tested
pIsol = par.pTestClin*(cases.subclinFlag(1:nSeedCases) == 0 ) + par.pTestSub*(cases.subclinFlag(1:nSeedCases) == 1 );

% Set isolation status of seed cases
isolFlag = rand(nSeedCases, 1) < pIsol;
nIsol = sum(isolFlag);

% Set time when seed cases went into isolation
tIsol = cases.tOnset(isolFlag) + genIsolDelay(nIsol, 1, par);

% Find which seed cases started isolating before the minimum detection time
ind = tIsol < t(1)+par.minDetectTime;
% Make sure all seed cases start isolating after min detection time
tIsol(ind) = t(1)+par.minDetectTime + rand(sum(ind), 1)*par.followUpTime;
cases.tIsol(isolFlag) = tIsol;

% Initialise susceptible compartments - 16 susceptible compartments x 16 age groups:
M = [par.cov1(1, :); par.cov2a(1, :); par.cov2b(1, :); par.cov2c(1, :); par.cov2d(1, :); ...
    zeros(1, par.nAgeGroups); ...
    par.cov3a(1, :); par.cov3b(1, :); par.cov3c(1, :); par.cov3d(1, :); par.cov3e(1, :); ...
    zeros(4, par.nAgeGroups)];
susFrac = [1-sum(M, 1); M];
susFracTS = zeros(nSteps, 16);
casesDosesTS = zeros(nSteps, 16);

% Relative transmisison rates as a result of vaccination and
% quarantine/isolation
relTransIsol = [1; par.cQuar; par.cIsol];

% Make an array (propList) whose coluumns are the possible combinations of: (1) age group of
% offspring, (2) dose category of offspring
% ageGroupList = repmat((1:par.nAgeGroups)', 10, 1);
% vaxCatList = [zeros(par.nAgeGroups, 1); ones(par.nAgeGroups, 1); 2*ones(par.nAgeGroups, 1); 3*ones(par.nAgeGroups, 1); 4*ones(par.nAgeGroups, 1); 5*ones(par.nAgeGroups, 1); 6*ones(par.nAgeGroups, 1); 7*ones(par.nAgeGroups, 1); 8*ones(par.nAgeGroups, 1); 9*ones(par.nAgeGroups, 1)] ;
% To get ordering right, do combinations in differnet order
ageGroupList = repelem((1:par.nAgeGroups)', size(susFrac, 1));
vaxCatList = repmat( (0:size(susFrac, 1)-1)', par.nAgeGroups, 1);

nCases0 = histcounts(cases.ageGroup(1:nSeedCases), 1:par.nAgeGroups+1);
nCases = nCases0;
ReffEmp = zeros(size(t));
Rvt = zeros(size(t));
dailyAvg = 0;
nActive = 0;
nFuture = nSeedCases;
iStep = 1;
dist = 0;
while iStep < nSteps && sum(nCases) < maxCases && (nActive + nFuture > 0 || relTransCurrentAL(iStep+1) < 1) && dist < earlyReject.threshold
    %     fprintf("%s\n", datestr(t(iStep), "ddmmmyyyy"))
    
    % Change to RATs on 23Feb
    if iStep == datenum("23FEB2022") - par.date0
        par.isolB = 1.5;
        par.pTestClin = 0.5;
        par.pTrace = 0.25;
        par.cIsol = 0.5;
        par.cQuar = 0.5;
        relTransIsol = [1; par.cQuar; par.cIsol];
    end
    
    %     Change to new variant on day ...
    if newVariantType > 0 && iStep == datenum("01JUL2022") - par.date0
        if newVariantType <= 2 || newVariantType == 5 || newVariantType == 6
            % Everyone in Wa, Wb, Wc gets put into Wc
            cases.vaccDoses(cases.vaccDoses > 11 & cases.vaccDoses < 14) = 14;
            susFrac(15, :) = sum(susFrac(13:15, :), 1);
            susFrac(13:14, :) = 0;
            % Lower VE
            par.VEi(1:12) = par.VEi(1:12) .* 0.6;
            par.VEd(1:12) = par.VEd(1:12) .* 0.9;
            par.VEm(1:12) = par.VEm(1:12) .* 0.9;
            
        elseif newVariantType >= 9
            % Everyone in Wa, Wb, Wc gets put into Wd
            cases.vaccDoses(cases.vaccDoses > 11 & cases.vaccDoses < 15) = 15;
            susFrac(16, :) = sum(susFrac(13:16, :), 1);
            susFrac(13:15, :) = 0;
            if newVariantType <=10
                % Lower VE
                par.VEi(1:12) = par.VEi(1:12) .* 0.6;
                par.VEd(1:12) = par.VEd(1:12) .* 0.9;
                par.VEm(1:12) = par.VEm(1:12) .* 0.9;
            end
        end
        
        % Change to high severity
        if mod(newVariantType, 2) == 1
            % Change of virulence to Delta-similar
            [par.IHR, par.pICU, par.IFR] = getHerreraRatesDelta();
        end
        
        % Change to high intrinsic transmissibility
        if newVariantType >= 5 && newVariantType <= 8
            par.R0 = par.R0 * 1.5;
        end
    end
    
    
    iStep = iStep+1;
    
    % number of seed cases whose infeciotn time is still in the future:
    nFuture = sum( t(iStep) <= cases.tInfect );
    
    % Get IDs of active cases at current time step:
    activeID = cases.caseID(t(iStep) > cases.tInfect & t(iStep) <= cases.tInfect+par.maxInfectTime);
    nActive = length(activeID);
    
    if nActive > 0
        % Simulate new secondary cases on day i from each currently active
        % case:
        
        % Area under the curve of the transmission rate for each active case at current time step
        auci = auc(t(iStep)-cases.tInfect(activeID));
        
        % isolation status of active cases (0 for nothing, 1 for
        % quarantined, 2 for isolated)
        isolStatus = (t(iStep) > cases.tQuar(activeID) & ~(t(iStep) > cases.tIsol(activeID))) + 2*(t(iStep) > cases.tIsol(activeID));
        
        % Seasonality multiplier, goes from 0.9 to 1.1
        seasonality_mult = 1 - 0.1 * cos(iStep*pi./(365/2));
        
        % Calculate the expected number of offspring in each age group during the current
        % time step from each active case, assuming a fully susceptible population.
        % This defines a matrix expOff whose i,j element is the expected number of
        % offspring from parent case i in age group j
        % This is the product of the following factors for each case:
        % - relative transmission due to current alert level                            relTransCurrentAL
        % - relative transmission due to vaccination status of active case              1-par.VEt
        % - relative reproduction number (typically gamma distributed) of case i        cases.Rimult
        % - relative transmission rate for clinical/subclinical status of case i        1 - (1-par.cSub)*cases.subclinFlag
        % - relative transmission due to isolation/quarantine status of case i          relTransIsol
        % - time-dependent transmission rate for the parent case i                      auci
        % - jth column of the NGM for an unvaccinated clinical individual               par.NGMclin
        % - jth column of the NGM for an unvaccinated clinical individual               
        %   in the age group of the parent case
        expOff = relTransCurrentAL(iStep) * ...
            (1-par.VEt(1+cases.vaccDoses(activeID))) .* ...
            relTransIsol(1+isolStatus) .* ...
            cases.Rimult(activeID) .* ...
            (1 - (1-par.cSub)*cases.subclinFlag(activeID)) .* ...
            auci .* ...
            (par.NGMclin(:, cases.ageGroup(activeID), iStep)).';% .* ...
        %             seasonality_mult; %% UNCOMMENT this if seasonality effect wanted (we decided the effect was small enough to ignore it)
        
        
        % Split expOff into expected offspring who have had 0, 1 or 2 doses
        % Dim1      rows        individual cases
        % Dim2      columns     age groups
        % Dim3      matrices    vax compartment
        expOffVaxAge = zeros(size(expOff, 1), size(expOff, 2), size(susFrac, 1));
        for vaxCat = 1:size(susFrac, 1)
            expOffVaxAge(:, :, vaxCat) = (1-par.VEi(vaxCat)) .* expOff .* susFrac(vaxCat, :);
        end
        
        % Sum expected offspring over all vaccine compartments
        expOff_withImmunity = sum(expOffVaxAge, 3);
        ReffEmp(iStep) = sum(expOffVaxAge, 'all') / sum(auci);
        
        % Generate expOff total number of offspring per vax compartment and
        % age group, and nOff actual number of offspring
        % Dim1      rows        vax compartment
        % Dim2      columns     age groups
        expOff_allParents_byDoseCat = permute(sum(expOffVaxAge, 1), [3, 2, 1]);
        nOff_byDoseCat = poissrnd(expOff_allParents_byDoseCat);
        
        % Total offspring in each age group, all vax compartment together
        nOffAll = sum(nOff_byDoseCat, 1);
        
        % Total number of offspring summed across all parent cases and all
        % age groups:
        nOffTot = sum(nOffAll);
        
        if nOffTot > 0
            
            secIDs = (sum(nCases)+1:sum(nCases)+nOffTot).';       % IDs for today's newly infected cases
            
            % assign age groups, parent ID, clinical status and vaccination status for new
            % cases based on nOff matrices
            
            % The frequency (number of cases with each age gorup, parent ID
            % and dose combination) of each row of propList is given by
            % the elements in the nOff matrices. Generate a sample X whose
            % columns are the values of these three properties for each
            % secondary case:
            % NOTE: transpose (original version) if propList is [1  0]
            %                                                   [2  0]
            %                                                   [.  .]
            %                                                   [1  1]
            %                                                   ,etc.
            % Don't transpose if it is [1 0]
            %                          [1 1], etc.
            %freqMat = [nOff0; nOff1; nOff2a; nOff2b; nOff2c; nOff2d; nOff3a; nOff3b; nOff3c; nOff3d]';
            %freqMat = [nOff0; nOff1; nOff2a; nOff2b; nOff2c; nOff2d; nOff3a; nOff3b; nOff3c; nOff3d];
            
            X = repelem( [ageGroupList, vaxCatList], nOff_byDoseCat(:) , 1);
            
            % Note cases by secIDs are in age group order - important for
            % efficiently assigning parent cases below
            cases.ageGroup(secIDs) = X(:, 1);
            cases.vaccDoses(secIDs) = X(:, 2);
            
            % If cases were in one of the waning compartments at time of
            % infection, flag them as reinfections
            cases.reinfectFlag(secIDs) = cases.vaccDoses(secIDs) >= 13;
            
            % Choosing parent ID %
            % Probability of being parent of new case by age group
            pParentByOffspringAge = expOff_withImmunity ./ sum(expOff_withImmunity);
            xm = mnrnd(nOffAll', pParentByOffspringAge')';
            parentList = repmat(1:nActive, par.nAgeGroups, 1)';
            % Parent IDs are also in order of the age group of the
            % offspring to match with the ordering of offspring (see above)
            pid = repelem( parentList(:), xm(:));
            cases.parentID(secIDs) = activeID(pid);
            parentIsolFlag = ~isnan(cases.tIsol(cases.parentID(secIDs)));
            cases.gen(secIDs) = cases.gen(cases.parentID(secIDs))+1;    % Generation of each new cases is generation of parent + 1
            
            pOffSubclin = par.VEs(1+cases.vaccDoses(secIDs)) + (1-par.VEs(1+cases.vaccDoses(secIDs))).*par.pSub(cases.ageGroup(secIDs));
            cases.subclinFlag(secIDs) = rand(nOffTot, 1) < pOffSubclin;
            cases.tInfect(secIDs) = t(iStep);                           % Infection time for each new cases is today
            cases.tOnset(secIDs) = t(iStep) + cases.tOnset(secIDs);     % For efficiency infection to onset delay is pre-stored in cases.tOnset
            cases.nOff(activeID) = cases.nOff(activeID)+sum(nOffAll, 2);
            
            % Gamma distributed waning time after infection (or just tWane = 30 days)
            cases.tWane(secIDs) = t(iStep) + 30; %gamrnd(par.waneA, par.waneB);
            
            % simulate case testing and isolation effects for new cases
            pIsol = par.pTestClin*(cases.subclinFlag(secIDs) == 0 ) + par.pTestSub*(cases.subclinFlag(secIDs) == 1 ) ;
            isolFlag = rand(nOffTot, 1) < pIsol;
            nIsol = sum(isolFlag);
            tIsol = cases.tOnset(secIDs(isolFlag)) + genIsolDelay(nIsol, 1, par);
            ind = tIsol < t(1)+par.minDetectTime;
            tIsol(ind) = t(1)+par.minDetectTime + rand(sum(ind), 1)*par.followUpTime;
            cases.tIsol(secIDs(isolFlag)) = tIsol;
            
            % simulate contact tracing effects for new cases
            pTrace = par.pTrace * (~(dailyAvg > par.traceCapacity)) * parentIsolFlag;
            traceFlag = rand(nOffTot, 1) < pTrace;
            nTrace = sum(traceFlag);
            cases.tQuar(secIDs(traceFlag)) = cases.tIsol(cases.parentID(secIDs(traceFlag))) + genTraceDelay(nTrace, 1, par);
            % optional: individuals traced prior to onset go into full isolation (as opposed to quarantine) on symptom onset:
            % this is applied to all individuals including subclinical on
            % assumption that asymtoma%tic contacts get tested. This allows
            % offspring of subclinicals to be traced
            cases.tIsol(secIDs(traceFlag)) = min(cases.tIsol(secIDs(traceFlag)), max(cases.tQuar(secIDs(traceFlag)), cases.tOnset(secIDs(traceFlag))));
            
            % simulate clinical outcomes (hsopitalisation, ICU and death) for new cases
            pHospClin = (1-par.VEd(1+cases.vaccDoses(secIDs)))./(1-par.VEs(1+cases.vaccDoses(secIDs))).* par.IHR(cases.ageGroup(secIDs))./par.IDR(cases.ageGroup(secIDs));
            hospFlag = (cases.subclinFlag(secIDs) == 0) & (rand(nOffTot, 1) < pHospClin);
            cases.tHosp(secIDs(hospFlag)) = cases.tOnset(secIDs(hospFlag)) + genHospDelay(sum(hospFlag), 1, par);
            cases.tDisc(secIDs(hospFlag)) = cases.tHosp(secIDs(hospFlag)) + genHospLOS(sum(hospFlag), 1, par);
            % cases are detected and isolated once hospitalised
            cases.tIsol(secIDs(hospFlag)) = min(cases.tIsol(secIDs(hospFlag)), cases.tHosp(secIDs(hospFlag)));
            
            % Update cumulative infections to date (in each age group)
            nCases = nCases+sum(nOffAll, 1);
            %toc
            casesDosesTS(iStep - 1, :) = histcounts(cases.vaccDoses(secIDs), 0:16)./length(secIDs);
        end
    else
        nOff_byDoseCat = zeros(size(susFrac, 2), par.nAgeGroups);
    end
    
    susFracTS(iStep - 1, :) = sum(susFrac .* par.popDist', 2);
    
    [~, nCols] = size(susFrac);
    % Depletion of susceptible fractions in each dose compartment and age
    % group with new infections
    susFrac = max(0,  susFrac - (nOff_byDoseCat ./ par.popCount.'));
    % Susceptible fractions in each dose compartment (line) and each age
    % group (column) are updated using flow matrices Q and QQ pre-defined
    % in getParOmiWane
    susFrac = max(0, susFrac .* (1 - par.Q(:, :, iStep) - par.QQ(:, :, iStep) ) + ...
        [zeros(1, nCols); susFrac(1:end-1, :) .* par.Q(1:end-1, :, iStep)] + ...
        [zeros(2, nCols); susFrac(1:end-2, :) .* par.QQ(1:end-2, :, iStep)]) ;
    
    % First post-infection waning compartment gets filled by cases who had
    % at least one dose at time of infection, cases who got vaccinated
    % after infection, and people getting re-infected
    headedToW1Flag = cases.vaccDoses > 0 | cases.postInfVaccTime <= t(iStep) | cases.reinfectFlag == 1;
    
    susFrac(13, :) = susFrac(13, :) + histcounts(cases.ageGroup(cases.tWane == t(iStep) & headedToW1Flag ), 1:1:17)./par.popCount.';
    % Second post-infection waning compartment gets filled by cases with
    % waning time t and either no vaccination time or vaccination time > t
    susFrac(14, :) = susFrac(14, :) + histcounts(cases.ageGroup(cases.tWane == t(iStep) & ~headedToW1Flag ), 1:1:17)./par.popCount.';
    susFrac = max(0, min(1, susFrac));
    
    %     % Uncomment for live plots of susFrac:
    %     figure(50)
    %     plot(1:16, susFrac.', '-', 1:16, sum(susFrac, 1), '--')
    %     legend('0', '1', '2a', '2b', '2c', '2d', '2e', '3a', '3b', '3c', '3d', '3e', 'W1', 'W2', 'W3', 'W4', 'all')
    %     title(sprintf('day %i, new cases = %i', iStep, nOffTot))
    %     drawnow
    %
    
    
    % Check triggers and update current alert level accordingly (Traffic Lights system)
    dailyAvg = sum( t(iStep) > min(cases.tIsol, cases.tQuar) & t(iStep) <= min(cases.tIsol, cases.tQuar)+7 )/7;
    nIsolTemp = histcounts(cases.tIsol, [t(1):t(iStep)+1] );
    dist = calcError(earlyReject.tData, earlyReject.nCasesData, t(1):t(iStep), nIsolTemp);
    %toc
    %fprintf('\n')
end

if iStep < nSteps
    dist = 2*earlyReject.threshold;
end

totCases = sum(nCases);
cases = cases(1:totCases, :);
cases.icuFlag = ~isnan(cases.tHosp) & rand(totCases, 1) < par.pICU(cases.ageGroup)  ;
cases.diedFlag = ~isnan(cases.tHosp) & rand(totCases, 1) <  (1-par.VEm(1+cases.vaccDoses))./(1-par.VEd(1+cases.vaccDoses)) .* par.IFR(cases.ageGroup)./par.IHR(cases.ageGroup);


%     figure
%
%     t = linspace(par.date0, par.date0 + par.tEnd, par.tEnd);
%     area(datetime(t,'ConvertFrom','datenum'), susFracTS)
%     leg = legend('0', '1', '2a', '2b', '2c', '2d', '2e', '3a', '3b', '3c', '3d', '3e', 'Wa', 'Wb', 'Wc', 'Wd', 'Location', 'northeastoutside');
%     title(leg,'Immunity compartment')
%     xtickformat('ddMMM')
%     ylabel("")
%     title("susFrac * par.popDist")
%
%     ncolors = {'#21618C', '#5DADE2', ...
%         '#873600', '#BA4A00', '#DC7633', '#E59866', '#EDBB99', ...
%         '#9C640C', '#D68910', '#F5B041', '#F8C471', '#FAD7A0', ...
%         '#212F3C', '#2E4053', '#566573', '#ABB2B9'};
%     newcolors = zeros(length(ncolors), 3);
%     for c=1:length(ncolors)
%         col = ncolors{c};
%         newcolors(c, :) = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
%     end
%     colororder(newcolors)
end



