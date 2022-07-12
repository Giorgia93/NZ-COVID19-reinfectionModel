function [NGM, NGMclin] = getNGM(par)

%------------- Load Contact Matrix and Define NGM --------------
fs = 'nzcontmatrix.xlsx';
% fprintf('   Loading contact matrix:    %s\n', fs)
C = readmatrix(fs); % Get Prem et al contact matrix from data folder

if par.contactPar.adjustContacts
%     'warning ad hoc adjustment to contact matrix'
    C = adjustContactMatrix(C, par.contactPar);
end
% 
% fs = 'popnSizeData.xlsx';      % This should *ALWAYS* be the national population distribution 'nzpopdist.xlsx'
% % fprintf('   Loading benchmark population distribution for contact matrix:    %s\n', fs)
% tmp = readmatrix(fs); % Load NZ population structure from data folder
% popDistBench = [tmp(1:par.nAgeGroups-1, 2); sum( tmp(par.nAgeGroups:end, 2))];
% popDistBench = popDistBench/sum(popDistBench);
popDistBench = par.popDist;

C_detBal = zeros(par.nAgeGroups, par.nAgeGroups); % Create our contact matrix
for ii = 1:par.nAgeGroups
    for jj = 1:par.nAgeGroups
        C_detBal(ii,jj) = 0.5*(C(ii,jj) + (popDistBench(jj)/popDistBench(ii)) * C(jj,ii)); % Force detailed balance condition
    end
end

NGM0 = diag(par.ui)*C_detBal'*diag(par.IDR + par.cSub*(1-par.IDR)); % Construct "first guess at the NGM"
u = par.R0/max(abs(eig(NGM0))); % Choose u to give desired R0


% Re-adjust for actual population distribution being modelling as per Prem
% et al
C_popAdj = (par.popDist./popDistBench).' .* C_detBal;
NGM =     u * diag(par.ui) * C_popAdj' * diag(par.IDR + par.cSub*(1-par.IDR));    % Set final NGM
NGMclin = u * diag(par.ui) * C_popAdj';                                           % NGM for clinical individuals (as used in BPM)





