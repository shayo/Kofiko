%
%PAL_AMPM_updatePM  Updates structure which contains settings for and 
%   results of psi method adaptive method.
%   
%   syntax: PM = PAL_AMPM_updatePM(PM,response)
%
%After having created a structure 'PM' using PAL_AMPM_setupPM, use 
%   something akin to the following loop to control stimulus intensity
%   during experimental run:
%
%   while ~PM.stop
%       
%       %Present trial here at stimulus magnitude in 'PM.xCurrent'
%       %and collect response (1: correct/greater than, 0: incorrect/
%       %smaller than)
%
%       PM = PAL_AMPM_updatePM(PM, response); %update PM structure based 
%                                             %on response                                    
%    
%    end
%
%Introduced: Palamedes version 1.0.0 (NP)

function PM = PAL_AMPM_updatePM(PM,response)

trial = length(PM.x);
PM.response(trial) = response;

if response == 1
    PM.pdf = PM.posteriorTplus1givenSuccess(:,:,find(PM.stimRange == PM.xCurrent));
else
    PM.pdf = PM.posteriorTplus1givenFailure(:,:,find(PM.stimRange == PM.xCurrent));
end
PM.pdf = PM.pdf./sum(sum(PM.pdf));

pSuccessGivenx = PAL_AMPM_pSuccessGivenx(PM.LUT, PM.pdf);
[PM.posteriorTplus1givenSuccess PM.posteriorTplus1givenFailure] = PAL_AMPM_PosteriorTplus1(PM.pdf, PM.LUT);
ExpectedEntropy = PAL_Entropy(PM.posteriorTplus1givenSuccess).*pSuccessGivenx + PAL_Entropy(PM.posteriorTplus1givenFailure).*(1-pSuccessGivenx);
[MinEntropy PM.I] = min(squeeze(ExpectedEntropy));
PM.xCurrent = PM.stimRange(PM.I);
PM.x(trial+1) = PM.xCurrent;

PM.threshold(trial) = sum(sum(PM.priorAlphas.*PM.pdf));
PM.slope(trial) = sum(sum(PM.priorBetas.*PM.pdf));
PM.seThreshold(trial) = sqrt(sum(sum(((PM.priorAlphas-PM.threshold(trial)).^2).*PM.pdf)));
PM.seSlope(trial) = sqrt(sum(sum(((PM.priorBetas-PM.slope(trial)).^2).*PM.pdf)));

PM.thresholdUniformPrior(trial) = sum(sum(PM.priorAlphas.*PM.pdf./PM.prior))./sum(sum(PM.pdf./PM.prior));
PM.slopeUniformPrior(trial) = sum(sum(PM.priorBetas.*PM.pdf./PM.prior))./sum(sum(PM.pdf./PM.prior));
PM.seThresholdUniformPrior(trial) = sqrt(sum(sum(((PM.priorAlphas-PM.thresholdUniformPrior(trial)).^2).*PM.pdf./PM.prior))./sum(sum(PM.pdf./PM.prior)));
PM.seSlopeUniformPrior(trial) = sqrt(sum(sum(((PM.priorBetas-PM.slopeUniformPrior(trial)).^2).*PM.pdf./PM.prior))./sum(sum(PM.pdf./PM.prior)));

if trial == PM.numTrials
    PM.stop = 1;
end