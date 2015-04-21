function h=fnHomogeneity(afProb)
h_prime = -sum(afProb .* log(afProb));
h_max = log(length(afProb));
h = h_prime / h_max;
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