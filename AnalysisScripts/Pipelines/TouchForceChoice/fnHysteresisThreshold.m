function [astrctIntervals,abBinary] = fnHysteresisThreshold(afData, fLowThres, fHighThres, iMinimumLength, iMergeDistance)
% segmentation using thresholding with hysteresis.
% Data is first thresholded with a high threshold to find reliable points.
% Low threshold data that is near by is added to the reliable points. 
% Intervals smaller than iMinimumLength are discarded as "noise"
iDataLength = length(afData);
abHigh= fnIntervalsToBinary( fnMergeIntervals( fnGetIntervals(afData > fHighThres),iMergeDistance) , iDataLength);
abLow = fnIntervalsToBinary( fnMergeIntervals( fnGetIntervals(afData > fLowThres),iMergeDistance), iDataLength);

aiLabelsHigh = bwlabeln(abHigh);
[aiLabelsLow,iNumCC] = bwlabeln(abLow);
aiCCsize = histc(aiLabelsLow,1:iNumCC);
aiSelectedLabels = setdiff(unique(aiLabelsLow(aiLabelsLow > 0 &  aiLabelsHigh > 0)), find(aiCCsize <= iMinimumLength));
abBinary = ismember(aiLabelsLow, aiSelectedLabels);
astrctIntervals = fnGetIntervals(abBinary);
return;

figure(13);
clf;
plot(afData);
hold on;
plot(abHigh*2,'g');
plot(abLow,'r');
