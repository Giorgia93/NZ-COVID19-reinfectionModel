function [dates, V1, V2a, V2b, V2c, V2d, V3a, V3b, V3c, V3d, V3e] = getSegmentedVaccineData(fNamePart, par)
% Outputs vaccine coverage data by vaccination compartment

plots = 0;

vaxDataDate = datenum("04MAY2022");     % date of most recent vaccine data download

% combine data on vaccine doses with simple model for booster and 5-11 rollout
% booster rollout model:
% boostGap = 104;  %134   % 90 days to become eligible plus 14 days (on average)
% boostProp = par.boostProp; %0.75;
% boostElig = [0 0 0 2/5 ones(1, 12)];        % Only over 18s eligible for booster

%5-11 vax model:
childGap = 10*7;                                             % gap to 2nd dose
% startDate = datenum('17JAN2022') + par.vaccImmDelay;        % start date for 5-11 vax (plus delay to dose taking effect)
% childDosesPerDay = 6000;                                    % assumed future 5-11 doses per day
% maxChildCov = 0.75;                                         % max coverage in 5-11s (unless data says higher)

% other parameters:
adultGap = 35;                                           % over 15s get their second dose by this time if they haven't already





[dates, V1, V2, V3] = getVaccineData(fNamePart, par.popCount);    % read time-dependent vaccination data
dates = dates+par.vaccImmDelay;     % shift vaccination dates to allow for delay

iDate = find(datenum(dates) == par.date0);
nPad = par.tEnd - (length(dates) - iDate);
if nPad > 0
    dates = [dates, dates(end)+1:dates(end)+nPad];
    V1 = [V1(1:end, :); repmat(V1(end, :), nPad, 1)];
    V2 = [V2(1:end, :); repmat(V2(end, :), nPad, 1)];
    V3 = [V3(1:end, :); repmat(V3(end, :), nPad, 1)];
end

V123 = V1+V2+V3;        % at least one dose
V23 = V2+V3;            % at least two doses

if plots == 1
    % Figure to sense check before/after coverage curves in some age bands
    figure
    subplot(1, 2, 1)
    plot(dates, V123(:, 2), 'b-', dates, V123(:, 3), 'r-', dates, V23(:, 2), 'b--', dates, V23(:, 3), 'r--')
    title('5-9 (red -> pink) and 10-14 (blue -> cyan)')
    hold on
    subplot(1, 2, 2)
    plot(dates, V123(:, 6), 'b-', dates, V123(:, 14), 'r-', dates, V23(:, 6), 'b--', dates, V23(:, 14), 'r--', dates, V3(:, 6), 'b:', dates, V3(:, 14), 'r:')
    title('25-29 (red -> pink) and 65-69 (blue -> cyan)')
    hold off
end

vaxDataInd = find(datenum(dates) == vaxDataDate+par.vaccImmDelay);
% 
% childFutureRolloutInd = datenum(dates') > vaxDataDate + par.vaccImmDelay & datenum(dates') <= startDate + childGap;
% V123(vaxDataInd+1:end, 2) = max(V123(vaxDataInd+1:end, 2), min(maxChildCov,                V123(vaxDataInd, 2) + 5/7*childDosesPerDay/par.popCount(2) * (datenum(dates(vaxDataInd+1:end)')-(vaxDataDate+par.vaccImmDelay)) ) );
% V123(vaxDataInd+1:end, 3) = max(V123(vaxDataInd+1:end, 3), min(2/5*maxChildCov + 3/5*0.95, V123(vaxDataInd, 3) + 2/7*childDosesPerDay/par.popCount(3) * (datenum(dates(vaxDataInd+1:end)')-(vaxDataDate+par.vaccImmDelay)) ) );


% Assume everyone single dosed gets their second dose 35 days later (over 15s) or 8 weeks later (U15s) if they
% haven't already had it
V23(vaxDataInd+1:end, 2:3) =   max(V23(vaxDataInd+1:end, 2:3),   V123(vaxDataInd+1-childGap:end-childGap, 2:3));
V23(vaxDataInd+1:end, 4:end) = max(V23(vaxDataInd+1:end, 4:end), V123(vaxDataInd+1-adultGap:end-adultGap, 4:end));

V1 = max(0, V123-V23);

% optional assume x% of adults who are double-dosed by time t are boosted by time
% (t + boostGap)
% V3(vaxDataInd+1:end, :) = max(V3(vaxDataInd+1:end, :), boostProp*V23(vaxDataInd+1-boostGap:end-boostGap, :).*boostElig);

if plots == 1
    subplot(1, 2, 1)
    plot(dates, V123(:, 2), 'c-', dates, V123(:, 3), 'm-', dates, V23(:, 2), 'c--', dates, V23(:, 3), 'm--')
    ylim([0 1])
    subplot(1, 2, 2)
    plot(dates, V123(:, 6), 'c-', dates, V123(:, 14), 'm-', dates, V23(:, 6), 'c--', dates, V23(:, 14), 'm--', dates, V3(:, 6), 'c:', dates, V3(:, 14), 'm:')
    ylim([0 1])
end

% Segment second and third dose compartments by time since last dose:

% Because data is already time shifted by 2 weeks (to allow for time for
% immune response), this segments into 2-5 weeks, 5-10 weeks, 10-15 weeks
% and 15+ weeks after dose 2, and an extra 25+ weeks for dose 3    
cutPoints = 7 .* [3, 8, 13, 23];    % cut points (days since last dose) for moving between compartments with sequentially lower vaccine effectiveness
% 7 .* [3, 8, 13, 23];
V2a = [ nan(cutPoints(1), par.nAgeGroups); V23(1+cutPoints(1):end, :) - V23(1:end-cutPoints(1), :) ];
V2b = [ nan(cutPoints(2), par.nAgeGroups); V23(1+cutPoints(2)-cutPoints(1):end-cutPoints(1), :) - V23(1:end-cutPoints(2), :) ];
V2c = [ nan(cutPoints(3), par.nAgeGroups); V23(1+cutPoints(3)-cutPoints(2):end-cutPoints(2), :) - V23(1:end-cutPoints(3), :) ];
V2d = [ nan(cutPoints(3), par.nAgeGroups); V23(1:end-cutPoints(3), :) - V3(1+cutPoints(3):end, :) ];
V3a = [ nan(cutPoints(1), par.nAgeGroups); V3(1+cutPoints(1):end, :) - V3(1:end-cutPoints(1), :) ];
V3b = [ nan(cutPoints(2), par.nAgeGroups); V3(1+cutPoints(2)-cutPoints(1):end-cutPoints(1), :) - V3(1:end-cutPoints(2), :) ];
V3c = [ nan(cutPoints(3), par.nAgeGroups); V3(1+cutPoints(3)-cutPoints(2):end-cutPoints(2), :) - V3(1:end-cutPoints(3), :) ];
V3d = [ nan(cutPoints(4), par.nAgeGroups); V3(1+cutPoints(4)-cutPoints(3):end-cutPoints(3), :) - V3(1:end-cutPoints(4), :) ];
V3e = [ nan(cutPoints(4), par.nAgeGroups); V3(1:end-cutPoints(4), :) ];

dates = dates(iDate:end);
V1 = V1(iDate:end, :);
V23 = V23(iDate:end, :);
V2a = V2a(iDate:end, :);
V2b = V2b(iDate:end, :);
V2c = V2c(iDate:end, :);
V2d = V2d(iDate:end, :);
V3 = V3(iDate:end, :);
V3a = V3a(iDate:end, :);
V3b = V3b(iDate:end, :);
V3c = V3c(iDate:end, :);
V3d = V3d(iDate:end, :);
V3e = V3e(iDate:end, :);



V1_all = sum( V1.*par.popDist', 2);
V23_all = sum( V23.*par.popDist', 2);
V2a_all = sum( V2a.*par.popDist', 2);
V2b_all = sum( V2b.*par.popDist', 2);
V2c_all = sum( V2c.*par.popDist', 2);
V2d_all = sum( V2d.*par.popDist', 2);
V3a_all = sum( V3a.*par.popDist', 2);
V3b_all = sum( V3b.*par.popDist', 2);
V3c_all = sum( V3c.*par.popDist', 2);
V3d_all = sum( V3d.*par.popDist', 2);
V3e_all = sum( V3e.*par.popDist', 2);
V3_all = sum( V3.*par.popDist', 2);

if plots == 1
    figure
    plot(dates, V1_all, ...
        dates, V2a_all, ...
        dates, V2b_all, ...
        dates, V2c_all, ...
        dates, V2d_all, ...
        dates, V3a_all, ...
        dates, V3b_all, ...
        dates, V3c_all, ...
        dates, V3d_all, ...
        dates, V3e_all, ...
        dates, V1_all+V2a_all+V2b_all+V2c_all+V2d_all+V3a_all+V3b_all+V3c_all+V3d_all+V3e_all, '--', ...
        dates, V2a_all+V2b_all+V2c_all+V2d_all+V3a_all+V3b_all+V3c_all+V3d_all+V3e_all, '--', ...
        dates, V3a_all+V3b_all+V3c_all+V3d_all+V3e_all, '--')
    legend("1", "2a", "2b", "2c", "2d", "3a", "3b", "3c", "3d", "3e", "1+", "2+", "3")
    drawnow
    
    figure
    plot(dates, V1_all+V2a_all+V2b_all+V2c_all+V2d_all+V3a_all+V3b_all+V3c_all+V3d_all+V3e_all, ...
        dates, V2a_all+V2b_all+V2c_all+V2d_all+V3a_all+V3b_all+V3c_all+V3d_all+V3e_all, ...
        dates, V3a_all+V3b_all+V3c_all+V3d_all+V3e_all)
    ylabel('proportion of total population')
    legend("1+ doses", "2+ doses", "3 doses")
    drawnow
end

end
