%
%PAL_AMPM_setupPM  Creates structure which contains settings for and 
%   results of psi method adaptive method.
%   
%   syntax: PM = PAL_AMPM_setupPM({optional arguments})
%
%   PM = PAL_AMPM_setupPM creates and returns a structure containing 
%       settings for the psi method adaptive method using default settings.
%
%   Default settings may be changed by providing pairwise arguments, where
%   the first entry of the pair is a string indicating the field to be
%   changed and the second entry provides the new value of the field.
%   Modifiable fields and settings (default values in curly brackets):
%   
%   'priorAlphaRange'     vector  {[-2:.05:2]}
%       Vector containing values of threshold to be considered in posterior
%       distribution.
%   
%   'priorBetaRange'      vector  {[-1:.05:1]}
%       Vector containing log (base 10) transformed values of slope to be 
%       considered in posterior distribution.
%
%   'stimRange'           vector  {[-1:.1:1]}
%       Stimulus values to be considered on each trial.
%
%   'prior'               matrix {uniform across priorAlphaRange x 
%                       priorBetaRange}
%       Prior distribution.
%
%   'gamma'               scalar in range [0-1] {.5}
%       Guess rate to be used in fits.
%
%   'lambda'              scalar in range [0-1] {.02}
%       Lapse rate to be used in fits.
%
%   'PF'                  inline function {@PAL_Gumbel}
%       Form of psychometric function to be assumed by Psi method.
%
%   'numTrials'           positive integer {50}
%       Length of run in terms of number of trials
%
%   Example: PM = PAL_AMPM_setupPM('numTrials',100, 'lambda', .01) creates
%   a new structure using default settings for all fields except numTrials
%   and lambda which are set to 100 and .01 respectively.
%
%   In order to change settings in an existing structure, pass the existing
%   structure as the first argument. For example, given an existing
%   structure 'PM' the call:
%       PM = PAL_AMPM_setupPM(PM, 'gamma',.25)
%   changes the field gamma in the existing structure 'PM' to .25 without
%   affecting other settings in existing structure 'PM.'.
%
%   PM's result storage fields:
%
%   'PM.x' stores stimulus intensities for all trials
%   'PM.response' stores responses for all trials (positive (correct,
%       'greater than'): 1, negative: 0)
%   'PM.pdf' stores posterior distribution
%   'PM.threshold' stores threshold estimates after each trial (marginal 
%       expected value of alpha in posterior)
%   'PM.slope' stores log slope estimates after each trial (marginal 
%       expected value of log beta in posterior)
%   'PM.seThreshold' stores standard error of threshold estimate (marginal 
%       standard deviation of alpha in posterior).
%   'PM.seSlope' stores standard error of log slope estimate (marginal 
%       standard deviation of log beta in posterior).
%   'PM.thresholdUniformPrior', 'PM.slopeUniformPrior', 
%       'PM.seThresholdUniformPrior', and 'PM.seSlopeUniformPrior' ignore 
%       user-defined prior and use rectangular prior instead.
%   'PM.stop' is used as termination flag. While stop criterion has not 
%       been reached, 'PM.stop' will equal 0, when criterion is reached, 
%       'PM.stop' will be set to 1.
%
% Introduced: Palamedes version 1.0.0 (NP)
% Modified: Palamedes version 1.1.1 (NP): Included previously omitted 
%   lines:
%   PM.numTrials = 50;
%   PM.response = [];
%
%   Made explicit in the help section that log values used are log base 10.
%
% Modified: Palamedes version 1.2.0 (NP): Fixed some stylistic nasties
%   (failing to pre-allocate arrays, etc.)
% Modified: Palamedes version 1.4.0 (NP): Fixed some stylistic nasties
%   ('Matlab style short circuit operator')


function PM = PAL_AMPM_setupPM(varargin)

NumOpts = length(varargin);

if mod(NumOpts,2) == 0

    PM.priorAlphaRange = -2:.05:2;
    PM.priorBetaRange = -1:.05:1;
    PM.stimRange = -1:.1:1;
    PM.gamma = 0.5;
    PM.lambda = 0.02;
    [PM.priorAlphas PM.priorBetas] = meshgrid(PM.priorAlphaRange,PM.priorBetaRange);
    PM.PF = @PAL_Gumbel;
    PM.LUT = PAL_AMPM_CreateLUT(PM.priorAlphaRange, PM.priorBetaRange, PM.stimRange, PM.gamma, PM.lambda, PM.PF);

    PM.prior = ones(size(PM.priorAlphas));
    PM.prior = PM.prior./sum(sum(PM.prior));
    PM.pdf = PM.prior;

    pSuccessGivenx = PAL_AMPM_pSuccessGivenx(PM.LUT, PM.pdf);
    [PM.posteriorTplus1givenSuccess PM.posteriorTplus1givenFailure] = PAL_AMPM_PosteriorTplus1(PM.pdf, PM.LUT); 
    ExpectedEntropy = PAL_Entropy(PM.posteriorTplus1givenSuccess).*pSuccessGivenx + PAL_Entropy(PM.posteriorTplus1givenFailure).*(1-pSuccessGivenx);
    [MinEntropy PM.I] = min(squeeze(ExpectedEntropy));
    PM.xCurrent = PM.stimRange(PM.I);
    PM.x = PM.xCurrent;
    PM.numTrials = 50;
    PM.response = [];
    PM.stop = 0;
else 
    PM = varargin{1};
end

PM.firstsession = length(PM.x) == 1;

if NumOpts > 1
    opts(1) = cellstr('priorAlphaRange');
    opts(2) = cellstr('priorBetaRange');
    opts(3) = cellstr('stimRange');
    opts(4) = cellstr('prior');
    opts(5) = cellstr('gamma');
    opts(6) = cellstr('lambda');
    opts(7) = cellstr('PF');
    opts(8) = cellstr('numTrials');
    supplied = logical(false(size(opts)));
    for opt = 1:length(opts)
        for n = 1:2:NumOpts-mod(NumOpts,2)
            n = n+mod(NumOpts,2);
            valid = 0;
            if strncmpi(varargin{n}, opts(1),6)            
                PM.priorAlphaRange = varargin{n+1};                
                valid = 1;
                supplied(1) = true;
            end
            if strncmpi(varargin{n}, opts(2),6)            
                PM.priorBetaRange = varargin{n+1};
                valid = 1;
                supplied(2) = true;
            end
            if strncmpi(varargin{n}, opts(3),4)            
                PM.stimRange = varargin{n+1};
                valid = 1;
                supplied(3) = true;
            end
            if strcmpi(varargin{n}, opts(4))            
                PM.prior = varargin{n+1};
                PM.prior = PM.prior./sum(sum(PM.prior));
                PM.pdf = PM.prior;
                valid = 1;
                supplied(4) = true;
            end
            if strncmpi(varargin{n}, opts(5),4)            
                PM.gamma = varargin{n+1};
                valid = 1;
                supplied(5) = true;
            end
            if strncmpi(varargin{n}, opts(6),4)
                PM.lambda = varargin{n+1};
                valid = 1;
                supplied(6) = true;
            end
            if strcmpi(varargin{n}, opts(7))
                PM.PF = varargin{n+1};
                valid = 1;
                supplied(7) = true;
            end            
            if strncmpi(varargin{n}, opts(8),4)
                PM.numTrials = varargin{n+1};
                valid = 1;
                supplied(8) = true;
            end
            if valid == 0
                message = [varargin{n} ' is not a valid option. Ignored.'];
                warning(message);
            end        
        end            
    end
    if supplied(1) || supplied(2)
        [PM.priorAlphas PM.priorBetas] = meshgrid(PM.priorAlphaRange,PM.priorBetaRange);
        if ~supplied(4)
            PM.prior = ones(size(PM.priorAlphas));
            PM.prior = PM.prior./sum(sum(PM.prior));
            if PM.firstsession == 1    %First session. Otherwise keep going with existing PM.pdf
                PM.pdf = PM.prior;
            end
        end
    end
    if supplied(1) || supplied(2) || supplied(3) || supplied(5) || supplied(6) || supplied(7) 
        PM.LUT = PAL_AMPM_CreateLUT(PM.priorAlphaRange, PM.priorBetaRange, PM.stimRange, PM.gamma, PM.lambda, PM.PF);
        pSuccessGivenx = PAL_AMPM_pSuccessGivenx(PM.LUT, PM.pdf);
        [PM.posteriorTplus1givenSuccess PM.posteriorTplus1givenFailure] = PAL_AMPM_PosteriorTplus1(PM.pdf, PM.LUT);
        ExpectedEntropy = PAL_Entropy(PM.posteriorTplus1givenSuccess).*pSuccessGivenx + PAL_Entropy(PM.posteriorTplus1givenFailure).*(1-pSuccessGivenx);
        [MinEntropy PM.I] = min(squeeze(ExpectedEntropy));
        PM.xCurrent = PM.stimRange(PM.I);
    end
    if PM.firstsession == 1
        PM.x(1) = PM.xCurrent;
    end
end

if PM.firstsession == 1
    PM.threshold = []; 
    PM.slope = [];
    PM.seThreshold = [];
    PM.seSlope = [];

    PM.thresholdUniformPrior = [];
    PM.slopeUniformPrior = [];
    PM.seThresholdUniformPrior = [];
    PM.seSlopeUniformPrior = [];
end