function Ri = genRi(n, m, par)

% Generate individual Ri (relative to average) for a clinical case
% Original (v1.0) model had not heterogeneity, i.e. Ri is the same value
% for every clinical case. in which case this function just returns a matrix of ones.
% Alternative is a gamma distribution with the same mean.

if par.ssk == inf
    Ri = ones(n, m);
else
   Ri = gamrnd(par.ssk, 1/par.ssk, n ,m); 
end



