function x = discRand2(v, nRows, mCols)

% Generate random numbers from an arbitrary discrete probability
% distribution with probability mass function described by the vector v on
% [1, 2, 3, ...]
%
% USAGE: x = discRand(v, nRows, mCols)
%
% INPUTS: v - n x 1 vector of probability weights (these do NOT need to sum
% to 1 as this normalisation is done within the fucntion) of the random
% variable taking values [1, 2, ..., n]
%         nRows - number of rows in the output matrix
%    	  mCols - number of columns in the output matirx
%
% OUTPUTS: x - matrix of random numbers generated in [1, 2, ..., n]

c = [0; cumsum(v)];
c = c/c(end);
[~, ~, x] = histcounts( rand(nRows, mCols), c);


% f = mnrnd(nElements, v/sum(v)).';
% xValues = repelem(1:length(v), f);
% si = randperm(nElements);
% x = reshape(xValues(si), nRows, mCols);



