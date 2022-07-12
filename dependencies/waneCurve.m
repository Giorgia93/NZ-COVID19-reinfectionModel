
nweeks = [10, 15, 15];
mult = [1, 1.5, 1/1.5];
ic = [1; 0; 0; 0];
tSpan = [30 360];

%       [baseline; fast; slow]
VEi = [0.89 0.80 0.66 0.50; 0.89 0.80 0.55 0.05; 0.93 0.88 0.66 0.1];
VEd = [0.9989	0.9960	0.9830	0.9400;	0.9989	0.9960	0.9775	0.8860;	0.9993	0.9976	0.9830	0.8920];
VEm = [0.9989	0.9960	0.9830	0.9400;	0.9989	0.9960	0.9775	0.8860;	0.9993	0.9976	0.9830	0.8920];


imm_type = ["Omicron Infection","Pfizer vaccine dose 1 + Omicron infection",  ...
                "Pfizer vaccine dose 2 + Omicron infection", "mRNA booster + Omicron infection"];
immunity_against = ["acquisition", "hospitalisation", "death"];
immunity_against_labels = ["(a) re-infection", "(b) hospitalisation or death"];

f = figure;
f.Position = [300 300 1000 300];
tiledlayout(1,2)

for i = 1:2
    imm_against = immunity_against(i);
    imm_against_labels = immunity_against_labels(i);
    nexttile
    hold on
    for j = 1:size(VEi, 1)
        
        w = mult(j) * 1/(7*nweeks(j));
        myRHS = @(t, y)( [-w*y(1); w*(y(1)-y(2)); w*(y(2)-y(3)); w*y(3)] );
        [t, Y] = ode23(myRHS, tSpan, ic);
        
        immLevels = [VEi(j, :); VEd(j, :); VEm(j, :)];
        avgImm = sum(Y .* immLevels(i, :), 2);
        plot(t ./ 7, 100*avgImm, 'LineWidth', 2)
    end
%     yline(immLevels(i, 1), 'k:', 'HandleVisibility', 'off');
%     yline(immLevels(i, 2), 'k:', 'HandleVisibility', 'off');
%     yline(immLevels(i, 3), 'k:', 'HandleVisibility', 'off');
%     yline(immLevels(i, 4), 'k:', 'HandleVisibility', 'off');
    % for j = 4:nweeks:4 + 3 * nweeks
    %     xline(j, 'k--', 'HandleVisibility', 'off');
    % end
    
    T = readtable("ve_waning_predictions_omicron.csv");
    T.immunity_type(string(T.immunity_type) == "Infection (Omicron)") = {'Omicron Infection'};
    
    
    for iti = imm_type
        
        it = string(iti);
        inf_immunity = T.ve_predict_mean(T.outcome == imm_against & T.immunity_type == it);
        
        time = (1:length(inf_immunity))./7;
        plot(time, 100*inf_immunity)
    end
    hold off
    
    xlim([0 365/7])
    ylim([0 100])
    title(imm_against_labels)
    xlabel("time since Omicron infection (weeks)")
    ylabel("immunity")
    ytickformat('percentage')
    
end

l = legend(["MODEL (baseline)", "MODEL (fast waning)", "MODEL (slow waning)", ...
    "Golding et al. (infection)", "Golding et al. (infection + 1dose)", "Golding et al. (infection + 2doses)", ...
    "Golding et al. (infection + 3doses)"], "Location", "northeastoutside");
title(l, "Immunity type")