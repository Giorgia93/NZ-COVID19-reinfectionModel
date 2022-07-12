function [dates, V1, V2, V3] = getVaccineData(fNamePart, popCount)

fNameDates = "dates.csv";
fName1 = "firstDoseCount" + fNamePart + ".csv";
fName2 = "secondDoseCount" + fNamePart + ".csv";
fName3 = "thirdDoseCount" + fNamePart + ".csv";

% fprintf('   Loading vaccination data:    %s\n                                %s\n                                %s\n', fNameDates, fName1, fName2)
dates = readmatrix(fNameDates, 'OutputType', 'datetime');
V1 = readmatrix(fName1).';
V2 = readmatrix(fName2).';
V3 = readmatrix(fName3).';

V1 = V1./popCount';
V2 = V2./popCount';
V3 = V3./popCount';

end


