function strctUnit = fnAnalyzeReverseCorrelation(strctUnit, strctKofiko, strctInterval,strctConfig,aiTrialIndices)
% Add the Face Selectivity Index Attribute
iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Passive Fixation New');

aiNoiseIndex = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(7,aiTrialIndices);
aiNoiseIndexValidTrials = aiNoiseIndex(strctUnit.m_abValidTrials);

a3fRand = load('W:\NoisePatterns\Uniform_40x40x15k.mat');

I=imread('\\192.168.50.93\StimulusSet\ReverseCorrelation\face_template_1.bmp');

aiNumSpikesPerValidTrial = sum(strctUnit.m_a2bRaster_Valid(:,300:600),2);
a2fSum = zeros(40,40);
for k=1:length(aiNumSpikesPerValidTrial)-1
    a2fSum = a2fSum + a3fRand.a3fRand(:,:, aiNoiseIndexValidTrials(k)) * aiNumSpikesPerValidTrial(k);
end;
a2fMean = mean(a3fRand.a3fRand(:,:, aiNoiseIndexValidTrials(1:end-1)),3);

a2fSumNorm = a2fSum / sum(aiNumSpikesPerValidTrial);
a2fSumMinusMean = a2fSumNorm-a2fMean;
a2fSumMinusMean = (a2fSumMinusMean - min(a2fSumMinusMean(:)))/(max(a2fSumMinusMean(:))-min(a2fSumMinusMean(:)));

a2fNoiseUpsampled=imresize(a2fSumMinusMean, [size(I,1),size(I,2)]);
a2bMask = I(:,:,1) == 255;
J = I(:,:,1);
J(a2bMask) = 255*a2fNoiseUpsampled(a2bMask);
strctUnit.m_a2fReverseCorrelationResult = J;


return;


