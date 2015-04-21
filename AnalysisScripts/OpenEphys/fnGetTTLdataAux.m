function [astrctIntervals,acTTLchannelNames] = fnGetTTLdataAux(allXMLfields, strctDataFromEvents, TTLchannelsPrefix,  strTTLchannelName)
% finds the TTL channel according to XML settings, then build intervals
% array with hardware timestamps
acTTLchannelNames = cell(0);
counter = 1;
for k=1:length(allXMLfields)
    if strncmpi(allXMLfields{k},TTLchannelsPrefix,length(TTLchannelsPrefix))
        acTTLchannelNames{counter} = allXMLfields{k}(length(TTLchannelsPrefix)+1:end);
        counter=counter+1;
    end
end
TTLchannel = find(ismember(acTTLchannelNames,strTTLchannelName));
if isempty(TTLchannel)
    fprintf('Cannot find ttl channel %s. !\n',strTTLchannelName);
    astrctIntervals = [];
    return;
end;
aiEventInd = find(strctDataFromEvents.TTLs(:,1) == TTLchannel-1);
if isempty(aiEventInd)
     fprintf('No TTLs found for channel %s.!\n',strTTLchannelName);
     astrctIntervals = [];
     return;
end

% abRiseUnsorted = strctDataFromEvents.TTLs(aiEventInd,2);
afEventsTSunSorted = strctDataFromEvents.TTLs(aiEventInd,4);

% Get rid of duplicated events....
[~,aiUniqueTimestampInd]=unique(afEventsTSunSorted);

abRiseUnsorted_unique = strctDataFromEvents.TTLs(aiEventInd(aiUniqueTimestampInd),2);
afEventsTSunSorted_unique = strctDataFromEvents.TTLs(aiEventInd(aiUniqueTimestampInd),4);


[afEventsTS,sortInd] = sort(afEventsTSunSorted_unique);
abRise = abRiseUnsorted_unique(sortInd);



% Verify information make sense (?)
if ~(all(abRise(1:2:end)==0) || all(abRise(1:2:end)==1))
    fprintf('Critical error. Weird ttl signal (should always flip between 0 and 1). Aborting.!\n');
    astrctIntervals = [];
    return;
end


iIndex = find(abRise == 1,1,'first');
aiRiseInd = iIndex:2:length(abRise);
if aiRiseInd(end) == length(abRise)
    aiRiseInd=aiRiseInd(1:end-1);
end
aiStartTime = afEventsTS(aiRiseInd);
aiEndTime = afEventsTS(aiRiseInd+1);
aiDuration = aiEndTime-aiStartTime;

clear astrctIntervals;
for k=1:length(aiStartTime)
    astrctIntervals(k).m_iStart = aiStartTime(k);
    astrctIntervals(k).m_iEnd = aiEndTime(k);
    astrctIntervals(k).m_iLength = aiDuration(k);
end

return
