%
%PAL_Entropy  Shannon entropy of probability density function
%
%   syntax: Entropy = PAL_Entropy(pdf)
%
%   Entropy = PAL_Entropy(pdf) returns the Shannon entropy (in 'nats') of 
%   the (discrete) probability density function in the vector or matrix 
%   'pdf'.
%
%   Example:
%
%   y = PAL_Entropy([.5 .5]) returns:
%
%   y = 
%       0.6931
%
%   y = log2(exp(PAL_Entropy([.5 .5]))) returns entropy in units of bits:
%
%   y = 
%       1
% 
%   y = log10(exp(PAL_Entropy([.5 .5]))) returns entropy in units of bans:
%
%   y = 
%       0.3010
%
%Introduced: Palamedes version 1.0.0 (NP)
%Modified: Palamedes version 1.1.0 (NP): upon completion returns all 
%   warning states to prior settings.

function Entropy = PAL_Entropy(pdf)

warningstates = warning('query','all');
warning off MATLAB:log:logOfZero

temp = pdf.*log(pdf);
temp(isnan(temp)) = 0;          %effectively defines 0.*log(0) to equal 0.
Entropy = -sum(sum(temp));

warning(warningstates)