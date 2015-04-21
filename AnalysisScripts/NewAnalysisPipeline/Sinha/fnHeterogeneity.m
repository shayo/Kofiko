function ahHetro=fnHeterogeneity(a2fProb)
% Compute Heterogeneity per time bin for a set of features...
% First, normalize the probability measure per column to have a sum of
% one....
a2fProbNorm = a2fProb ./ repmat(sum(a2fProb ,1), size(a2fProb,1),1);
a2bZeros = a2fProbNorm == 0;
a2fDot = a2fProbNorm .* log(a2fProbNorm);
a2fDot(a2bZeros) = 0; % 0 * log(0) = 0
h_prime = -sum(a2fDot,1);
h_max = log(size(a2fProb,1));
ahHetro = 1 - h_prime ./ h_max;
return;


% below is the code for 1D:
h_prime = -sum(afProb .* log(afProb));
h_max = log(length(afProb));
h = 1 - h_prime / h_max;
% 
% Heterogeneity is derived from the Shannon-Weaver diversity index
% H0 ¼ P
% k
% i¼1
% pi logðpiÞ, with k being the number of bins in the distribution
% (11 in our case) and pi being the relative number of entries in each bin.
% Homogeneity is defined as the ratio of H¢ and Hmax ¼ log(k); heterogeneity is
% defined as 1 – homogeneity. Thus, if all pi values are identical, heterogeneity is
% 0, and if all values are zero except for one, heterogeneity is 1.