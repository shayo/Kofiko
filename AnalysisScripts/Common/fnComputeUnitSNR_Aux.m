function [fSNR,afSNR_Time] = fnComputeUnitSNR_Aux(a2fWaveforms, afTimestamps)
% Compute single unit Signal to noise ratio (see Kelly et al. J.
% Neuroscience 2007) Comparison of Recordings from Microelectrode Arrays and Single Electrodes in the Visual Corte
afMean = mean(a2fWaveforms,1);
fDenominator = (max(afMean(:))-min(afMean(:)));
a2fDiff = a2fWaveforms-repmat(afMean,size(a2fWaveforms,1),1);
SDe = std(a2fDiff(:));
fSNR = fDenominator / (2*SDe);

afTimeStampMinutes = (afTimestamps-afTimestamps(1))/60;
fNumberMinutes = ceil(max(afTimeStampMinutes));
aiBins = 0:fNumberMinutes;
[~,aiInd]=histc(afTimeStampMinutes, aiBins);
afSNR_Time = nans(1,1+fNumberMinutes);
for i=1:fNumberMinutes+1
    Tmp = a2fDiff(aiInd == i,:);
    if ~isempty(Tmp)
        afSNR_Time(i) = fDenominator/(2*std(Tmp(:)));
    end
end

afSNR_Time = afSNR_Time;

return
