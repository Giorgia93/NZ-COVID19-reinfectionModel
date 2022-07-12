function tbl = importEpiSurv(fName)

opts = detectImportOptions(fName);
opts = setvartype(opts, {'STATUS', 'SEX', 'ETHNICITYPRIORITISEDMPAMEU', 'DHB', 'PHS', 'DIED', 'HOSP', 'EPICONT', 'HLTHSTAT', 'ICU', 'OVERSEAS', 'SOURCE', 'LABCONF', 'FLAGDIEDFROMDISEASE', 'ISOLATIONTYPE', 'HOWDISCOV', 'HISTORICAL', 'VENTREQD'}, {'categorical'});
opts = setvartype(opts, {'REPORTDATE', 'DIEDDT', 'EARLIESTDATE', 'HOSPDT', 'ONSETDT', 'MODIFIEDDATETIME', 'DTARRIVED', 'LASTDTDEPARTED', 'LASTDTENTERED', 'SECDTDEPARTED', 'SECDTENTERED', 'THIRDDTDEPARTED', 'THIRDDTENTERED', 'LABCONFDATE', 'ISOLATIONFROMDATE','ISOLATIONTODATE', 'QUARANTDT', 'DISCHDT'}, {'datetime'});
opts = setvartype(opts, {'AGEINYEARS'}, {'double'});
%opts = setvartype(opts, {'DIEDDT'}, {'string'});

tbl = readtable(fName, opts);

%tbl.DIEDDT = datetime(tbl.DIEDDT, 'Inputformat', "yyyy-MM-dd");


tbl.OnsetMerged = tbl.ONSETDT;
% ind = isnat(cases.OnsetMerged);
% cases.OnsetMerged(ind) = cases.DevSymptDt(ind);

tbl.LabDateMerged = tbl.LABCONFDATE;
ind = isnat(tbl.LabDateMerged);
tbl.LabDateMerged(ind) = tbl.REPORTDATE(ind);

tbl.Properties.VariableNames(1) = {'EpiSurvNumber'};
tbl.Properties.VariableNames(3) = {'ReportDate'};
tbl.Properties.VariableNames(5) = {'Age'};
tbl.Properties.VariableNames(10) = {'Died'};
tbl.Properties.VariableNames(11) = {'DiedDt'};
tbl.Properties.VariableNames(13) = {'Hosp'};
tbl.Properties.VariableNames(15) = {'HospDt'};
tbl.Properties.VariableNames(35) = {'Overseas'};
tbl.Properties.VariableNames(47) = {'DiedFromDisease'};
tbl.Properties.VariableNames(65) = {'Historical'};
tbl.Properties.VariableNames(67) = {'DischDt'};



