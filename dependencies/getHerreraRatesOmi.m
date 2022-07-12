function [IHR, pICU, IFR] = getHerreraRatesOmi()

IHR = [0.0042	0.0042	0.0018	0.0027	0.0039	0.0056	0.0082	0.012	0.017	0.025	0.037	0.052	0.075	0.105	0.146	0.257447829].';
ICR = [0.00024	0.00024	0.00019	0.0003	0.0005	0.00081	0.0013	0.0022	0.0036	0.0059	0.0096	0.016	0.026	0.041	0.066	0.154738379].';
IFR = [0.000014	0.000014	0.000014	0.000026	0.000051	0.0001	0.0002	0.00038	0.00075	0.0015	0.0029	0.0056	0.011	0.021	0.04	0.135399134].';

% Apply Delta hazard ratios from Twohig et al & Fisman et al
HR_Hosp_Delta = 2.26;
OR_Death_Delta = 1;    %OR_Death_Delta = 2.32;
IHR = 1 - (1-IHR).^HR_Hosp_Delta;
ICR = 1 - (1-ICR).^HR_Hosp_Delta;
IFR = OR_Death_Delta*IFR./(1-IFR+OR_Death_Delta*IFR);

% Omicron adjustments
HR_Hosp_Omi = 0.33;
HR_ICU_Omi = 0.3;
HR_Death_Omi = 0.3;
IHR = 1 - (1-IHR).^HR_Hosp_Omi;
ICR = 1 - (1-ICR).^HR_ICU_Omi;
IFR = 1 - (1-IFR).^HR_Death_Omi;

pICU = ICR./IHR;

end