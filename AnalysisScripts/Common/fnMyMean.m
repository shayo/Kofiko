function [fMean,fStd,fStdErr] = fnMyMean(afValues)
afValues = afValues(~isnan(afValues));
if ~isempty(afValues)
    fMean = mean(afValues);
    fStd = std(afValues);
    fStdErr = fStd/sqrt(length(afValues));
else
    fMean = NaN;
    fStd = NaN;
    fStdErr = NaN;
end;