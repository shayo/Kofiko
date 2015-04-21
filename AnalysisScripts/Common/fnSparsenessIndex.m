function SI=fnSparsenessIndex(A)
% Assume A is NxM, where N is the number of cells and M are the responses
% see K. Vonderschen 2011, or Rolls 1995
n=size(A,2);
I = (sum(A/n,2)).^2 ./ sum( A.^2/n,2);
SI = (1-I) ./ (1-1/n);
return;
