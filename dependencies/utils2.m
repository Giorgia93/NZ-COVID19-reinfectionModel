
%% Process and combine previous and bookings

clear
close all

datelbl_administered = "2022-02-23";
datelbl_forecast = "2022-01-26";
nAgeGroups = 16;

F0 = readtable(sprintf("vaccine_bookings_%s_withage.xlsx", datelbl_forecast));
T0 = readtable(sprintf("TPM_vaccine_%s.csv", datelbl_administered));

T0.DHBOFRESIDENCE = categorical(T0.DHBOFRESIDENCE);
T0.ageBand = min(16, 1+floor(double(string(T0.AGEATVACCINATIONEVENT))/5) );
% Make sure T0 has an entry for each age band (with count = 0)
nRows = height(T0);
T0 = [T0; T0(1:nAgeGroups, :)];
T0.count = [ones(nRows, 1); zeros(nAgeGroups, 1)];
T0 = T0(T0.ageBand > 0, :);
T0.ageBand(nRows+1:nRows+nAgeGroups) = 1:nAgeGroups;
U0 = unstack(T0, 'count', 'ageBand', 'AggregationFunction', @sum, 'GroupingVariables', {'ACTIVITYDATE', 'DOSENUMBER', 'DHBOFRESIDENCE'});

F0.ageBand = min(16, 1+double(extractBefore(string(F0.AGE_BAND_5), '-'))/5);
F0.ORGANISATION_NAME = categorical(extractBefore(string(F0.ORGANISATION_NAME), " District Health Board"));
F0.DOSE_NUMBER = double(string(F0.DOSE_NUMBER));
F0 = table(F0.APPOINTMENT_DATE, F0.ORGANISATION_NAME, F0.DOSE_NUMBER, F0.count, F0.ageBand, 'VariableNames', {'ACTIVITYDATE', 'DHBOFRESIDENCE', 'DOSENUMBER', 'count', 'ageBand'});
nRows = height(F0);
F0 = [F0; F0(1:nAgeGroups, :)];
F0.count(nRows+1:nRows+nAgeGroups) = 0;
F0.ageBand(nRows+1:nRows+nAgeGroups) = 1:nAgeGroups;
W0 = unstack(F0, 'count', 'ageBand', 'AggregationFunction', @sum, 'GroupingVariables', {'ACTIVITYDATE', 'DOSENUMBER', 'DHBOFRESIDENCE'});

Uc = [U0; W0(W0.ACTIVITYDATE > max(U0.ACTIVITYDATE), :)];





st = min(Uc.ACTIVITYDATE); en = max(Uc.ACTIVITYDATE); 
dts = st:en;
writematrix(dts, "processed_for_modelling/dates.csv");

change1 = ["national"]; %["national", "akl"];

%%
for iChange1 = 1:length(change1)

    REGION = change1(iChange1)

    % Load Data
    if REGION == "akl"
        popCounts = readmatrix("agedists/agedist_auckland.xlsx");
        DHBs = categorical(["Waitemata", "Auckland", "Counties Manukau"]);
        inRegionFlag = ismember(Uc.DHBOFRESIDENCE, DHBs);
    elseif REGION == "cmdhb"
        popCounts = readmatrix("agedists/agedist_cmdhb_orion.xlsx");
        DHBs = categorical(["Counties Manukau"]);
        inRegionFlag = ismember(Uc.DHBOFRESIDENCE, DHBs);
    elseif REGION == "national"
        popCounts = readmatrix("agedists/agedist_national.xlsx");
        inRegionFlag = ones(height(Uc), 1);
    else
        error("Please choose a valid REGION");
    end

    V1plus = zeros(nAgeGroups, length(dts));
    V2plus = zeros(nAgeGroups, length(dts));
    V3 = zeros(nAgeGroups, length(dts));
    V1plus(:, 1) = nansum(table2array(Uc(inRegionFlag & Uc.ACTIVITYDATE == dts(1) & Uc.DOSENUMBER == 1, 4:end)), 1 )';
    V2plus(:, 1) = nansum(table2array(Uc(inRegionFlag & Uc.ACTIVITYDATE == dts(1) & Uc.DOSENUMBER == 2, 4:end)), 1 )';
    V3(:, 1)     = nansum(table2array(Uc(inRegionFlag & Uc.ACTIVITYDATE == dts(1) & Uc.DOSENUMBER == 3, 4:end)), 1 )';
    for ii = 2:length(dts)
        dt = dts(ii);
        V1plus(:, ii) = V1plus(:, ii-1) + nansum(table2array(Uc(inRegionFlag & Uc.ACTIVITYDATE == dts(ii) & Uc.DOSENUMBER == 1, 4:end)), 1 )';
        V2plus(:, ii) = V2plus(:, ii-1) + nansum(table2array(Uc(inRegionFlag & Uc.ACTIVITYDATE == dts(ii) & Uc.DOSENUMBER == 2, 4:end)), 1 )';
        V3(:, ii)     = V3(:, ii-1)     + nansum(table2array(Uc(inRegionFlag & Uc.ACTIVITYDATE == dts(ii) & Uc.DOSENUMBER == 3, 4:end)), 1 )';
    end

    V1 = max(V1plus-V2plus, 0);
    V2 = max(V2plus-V3, 0);

    v1 = V1./popCounts;
    v2 = V2./popCounts;
    v3 = V3./popCounts;

     figure
     subplot(2, 2, 1)
    plot(dts, v1+v2+v3); title("Proportion of Each Age Group With At Least One Dose"); xline(datetime("today"));
    subplot(2, 2, 2)
    plot(dts, v2+v3); title("Proportion of Each Age Group With At Least Two Dose"); xline(datetime("today"));   
    subplot(2, 2, 3)
    plot(dts, v3); title("Proportion of Each Age Group With Third Dose"); xline(datetime("today"));
    
     writematrix(v1, sprintf("processed_for_modelling/firstDoseProp_%s.csv", REGION));
     writematrix(v2, sprintf("processed_for_modelling/secondDoseProp_%s.csv", REGION));
     writematrix(v3, sprintf("processed_for_modelling/thirdDoseProp_%s.csv", REGION));
  %   writematrix(V1, sprintf("processed_for_modelling/firstDoseCount_%s.csv", REGION ));
  %   writematrix(V2, sprintf("processed_for_modelling/secondDoseCount_%s.csv", REGION ));
  %   writematrix(V3, sprintf("processed_for_modelling/thirdDoseCount_%s.csv", REGION ));
end



