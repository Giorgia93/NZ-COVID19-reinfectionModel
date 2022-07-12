
% close all

vax_assumptions = ["Baseline vaccination assumptions"];%, "Low vaccination assumptions"];



T = readtable("ve_waning_predictions_omicron.csv");
T.immunity_type(string(T.immunity_type) == "Infection (Omicron)") = {'Omicron Infection'};


% Change colors
ncolors = {'#009E73', '#000000', '#E69F00', '#E69F00', '#D55E00', '#56B4E9'};
% ncolors = {'#f59402', '#ba0600', '#008f32'}; % Uncomment for TL colors
newcolors = zeros(length(ncolors), 3);
for c=1:length(ncolors)
    col = ncolors{c};
    newcolors(c, :) = sscanf(col(2:end),'%2x%2x%2x',[1 3])/255;
end

% Get average VEi from Nic"s 2nd dose + infection
startday = 30;
ndays_cats = 15*7;
ncats = 4;
VElow_13_16 = zeros(1, 4);
imm_against = "acquisition";
imm_against = "hospitalisation";
% imm_against = "death";
for i = 1:ncats
    VElow_13_16(i) = mean(T.ve_predict_mean(T.outcome == imm_against ...
        & T.immunity_type == "Pfizer vaccine dose 1 + Omicron infection" ...
        & T.days >= startday + ndays_cats * (i - 1) ...
        & T.days < startday + ndays_cats * i));
end
disp(VElow_13_16)

% Get average VEi from Nic"s 2nd dose + infection
startday = 30;
ndays_cats = 15*7;
ncats = 4;
VEhigh_13_16 = zeros(1, 4);
imm_against = "acquisition";
% imm_against = "hospitalisation";
% imm_against = "death";

imm_ag = ["acquisition", "hospitalisation", "death"];
titles = ["(a) infection", "(b) hospitalisation", "(c) death"];

f = figure;
f.Position = [300 300 1000 300];
tiledlayout(1,3)

for ia = 1:length(imm_ag)
    imm_against = imm_ag(ia);
    for i = 1:ncats
        VEhigh_13_16(i) = mean(T.ve_predict_mean(T.outcome == imm_against ...
            & T.immunity_type == "Pfizer vaccine dose 2 + Omicron infection" ...
            & T.days >= startday + ndays_cats * (i - 1) ...
            & T.days < startday + ndays_cats * i));
    end
    disp(VEhigh_13_16)


    for i = vax_assumptions
        nexttile
        title(titles(ia))
        hold on
        imm_type = ["Pfizer vaccine dose 1", "Pfizer vaccine dose 2", "mRNA booster"];%, ...
    %         "Omicron Infection", ...
    %         "Pfizer vaccine dose 1 + Omicron infection", "Pfizer vaccine dose 2 + Omicron infection", ...
    %         "mRNA booster + Omicron infection"];

        for iti = 1:length(imm_type)

            it = string(imm_type(iti));
            inf_immunity = T.ve_predict_mean(T.outcome == imm_against & T.immunity_type == it);

            time = (1:length(inf_immunity))./7;
    %         plot(time, inf_immunity)
        end

        if string(i) == "Baseline vaccination assumptions"
    %         VEi = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    VEhigh_13_16];
            VEi = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    0.89 0.80 0.66 0.50]'; % old baseline
            VEd = [0    0    0.8290 0.8020 0.7480 0.7192 0.6295    0.9208 0.8796 0.8304 0.7900 0.6850    0.9989 0.9960 0.9830 0.9400];
            VEm = [0    0    0.9164 0.9010 0.8740 0.8632 0.8195    0.9604 0.9398 0.9152 0.8980 0.8470    0.9989 0.9960 0.9830 0.9400];
else
            VEi = [0    0    0.62 0.55 0.4 0.28 0.05    0.64 0.57 0.47 0.4 0.1    VElow_13_16];
            VEm = [0    0    0.78 0.78 0.79 0.81 0.81   0.89 0.86 0.84 0.83 0.83  VElow_13_16];
        end


        ax = gca; ax.ColorOrderIndex = 1;
        for iti = 1:length(imm_type)
            if imm_against == "acquisition" 
                VE = VEi; 
            elseif imm_against == "hospitalisation"
                VE = VEd;
            else
                VE = VEm;
            end
            time = 3:52;
%             if iti == 1; plot(time, zeros(50, 1), "o"); end
            if iti == 2; plot(time, 100 .* repelem(VE(3:7), [3, 5, 5, 10, 50 - 23]), "o", 'Color', newcolors(5, :)); end
            if iti == 3; plot(time, 100 .* repelem(VE(8:12), [3, 5, 5, 10, 50 - 23]), "o", 'Color', newcolors(3, :)); end
            if iti == 7; plot(1:52, 100 .* [1, 1, 1, 1, repelem(VE(13:end), [15, 15, 15, 48 - 45])], "ko"); end
        end

    %     legend([imm_type, "assumed VE 0-1d", "assumed VE 2d", "assumed VE 3d", "assumed VE inf."], "Location", "northeastoutside")
        if imm_against == "death"
            leg = legend(["S2(a-e)", "S3(a-d)", "assumed VE inf."], "Location", "northeastoutside");
            title(leg,'Compartment')
        end
        hold off
        xlabel("time since vaccination (weeks)")
        ylabel("immunity")
        ytickformat('percentage')
        xlim([0, 52])
        ylim([0, 100])
    end
end

% Get average VEi from Nic"s 2nd dose + infection
startday = 30;
ndays_cats = 10*7;
ncats = 4;
toPrint = nan(1, 4);
for i = 1:ncats
    toPrint(i) = mean(T.ve_predict_mean(T.outcome == "acquisition" ...
        & T.immunity_type == "Pfizer vaccine dose 1 + Omicron infection" ...
        & T.days >= startday + ndays_cats * (i - 1) ...
        & T.days < startday + ndays_cats * i));
end
disp(toPrint)

% Get average VEi from Nic"s 2nd dose + infection
startday = 30;
ndays_cats = 10*7;
ncats = 4;
toPrint = nan(1, 4);
for i = 1:ncats
    toPrint(i) = mean(T.ve_predict_mean(T.outcome == "hospitalisation" ...
        & T.immunity_type == "Pfizer vaccine dose 2 + Omicron infection" ...
        & T.days >= startday + ndays_cats * (i - 1) ...
        & T.days < startday + ndays_cats * i));
end
disp(toPrint)

% Get average VEi from Nic"s 2nd dose + infection
startday = 30;
ndays_cats = 10*7;
ncats = 4;
toPrint = nan(1, 4);
for i = 1:ncats
    toPrint(i) = mean(T.ve_predict_mean(T.outcome == "death" ...
        & T.immunity_type == "Pfizer vaccine dose 2 + Omicron infection" ...
        & T.days >= startday + ndays_cats * (i - 1) ...
        & T.days < startday + ndays_cats * i));
end
disp(toPrint)
