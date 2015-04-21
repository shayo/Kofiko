%
%PAL_AMPM_CreateLUT  Look-up Table (LUT) of Psychometric Function values
%
%   syntax: PFLookUpTable = PAL_AMPM_CreateLUT(priorAlphaValues, ...
%       priorBetaValues, StimLevels, gamma, lambda, PF)
%
%   Creates a 3-D (alpha x beta x stimulus intensity) array of PF values.
%
%Internal function
%
%Introduced: Palamedes version 1.0.0 (NP)
%Modified: Palamedes version 1.2.0 (NP). Corrected error in function name.

function PFLookUpTable = PAL_AMPM_CreateLUT(priorAlphaValues, priorBetaValues, StimLevels, gamma, lambda, PF)
    
[a b x] = meshgrid(priorAlphaValues, priorBetaValues, StimLevels);
params.alpha = a;
params.beta = 10.^b;
params.gamma = gamma;
params.lambda = lambda;
PFLookUpTable = PF(params, x);