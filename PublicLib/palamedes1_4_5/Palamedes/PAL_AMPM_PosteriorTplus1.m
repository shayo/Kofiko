%
%PAL_AMPM_PosteriorTplus1  Derives posterior distributions for combinations
%   of stimulus intensity and response on trial T + 1 in psi method 
%   adaptive procedure.
%   
%   syntax: [PosteriorTplus1givenSuccess PosteriorTplus1givenFailure] = ...
%       PAL_AMPM_PosteriorTplus1(pdf, PFLookUpTable)
%
%   Internal function
%
%Introduced: Palamedes version 1.0.0 (NP)

function [PosteriorTplus1givenSuccess PosteriorTplus1givenFailure] = PAL_AMPM_PosteriorTplus1(pdf, PFLookUpTable)

pdf3D = repmat(pdf, [1 1 size(PFLookUpTable,3)]);

Denominator = squeeze(squeeze(sum(sum(pdf3D.*PFLookUpTable))));
Denominator = repmat(Denominator, [1 size(pdf3D,1) size(pdf3D,2)]);
Denominator = permute(Denominator, [2 3 1]);

PosteriorTplus1givenSuccess = (pdf3D.*PFLookUpTable)./Denominator;

Denominator = squeeze(squeeze(sum(sum(pdf3D.*(1-PFLookUpTable)))));
Denominator = repmat(Denominator, [1 size(pdf3D,1) size(pdf3D,2)]);
Denominator = permute(Denominator, [2 3 1]);

PosteriorTplus1givenFailure = (pdf3D.*(1-PFLookUpTable))./Denominator;