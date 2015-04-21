function filteredData = fnFilterAndDiscard(subdata_timestamps,subdata_uV_raw, b,a, astrctFastSettleEvents,nSamplesDiscardBefore,nSamplesDiscardAfter)
filteredData = filtfilt(b,a,subdata_uV_raw);
return;

if isempty(astrctFastSettleEvents)
    % easy way out
    filteredData = filtfilt(b,a,subdata_uV_raw);
    return;
end
filteredData = ones(size(subdata_uV_raw))*NaN;
% Crop out fast settle intervals and filter in between.
% Then fill in the blanks with NaNs.
% This will reduce artifacts outside the ROI....

for k=1:length(astrctFastSettleEvents)
    if (k == 1)
        % special case
        iStartInd = 1;
        iEndInd = find(subdata_timestamps == astrctFastSettleEvents(k).m_iStart,1,'first')-nSamplesDiscardBefore;
    else
        % normal case
        iStartInd = find(subdata_timestamps == astrctFastSettleEvents(k-1).m_iEnd,1,'first')+nSamplesDiscardAfter;
        iEndInd = find(subdata_timestamps == astrctFastSettleEvents(k).m_iStart,1,'first')-nSamplesDiscardBefore;
    end
    filteredData(iStartInd:iEndInd) = filtfilt(b,a,subdata_uV_raw(iStartInd:iEndInd));
end
% special case
iStartInd = find(subdata_timestamps == astrctFastSettleEvents(end).m_iEnd,1,'first')+nSamplesDiscardAfter;
iEndInd = length(subdata_timestamps);
filteredData(iStartInd:iEndInd) = filtfilt(b,a,subdata_uV_raw(iStartInd:iEndInd));

return;

