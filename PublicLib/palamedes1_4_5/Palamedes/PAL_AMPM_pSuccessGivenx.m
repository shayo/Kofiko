%
%PAL_AMPM_pSuccessGivenx  Derives probability of a positive response for 
%   all potential stimulus intensities that may be used on trial T + 1. 
%   Probability is calculated as the expected value of the probability of 
%   a positive response calculated across the posterior distribution.
%   
%   syntax: pSuccessGivenx = PAL_AMPM_pSuccessGivenx(PFLookUpTable, ...
%       pdf)
%
%   Internal function
%
%Introduced: Palamedes version 1.0.0 (NP)


function pSuccessGivenx = PAL_AMPM_pSuccessGivenx(PFLookUpTable, pdf)

pdf3D = repmat(pdf, [1 1 size(PFLookUpTable,3)]);
pSuccessGivenx = sum(sum(pdf3D.*PFLookUpTable));