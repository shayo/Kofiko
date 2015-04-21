function [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
    fnGetAccurateStimulusTSusingPhotodiode(strctKofiko, strctPlexon, strctSession,iParadigmIndex)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
if ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'Trials')
    [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
        fnPhotodiodeFlipOldCode(strctKofiko, strctPlexon, strctSession,iParadigmIndex);
else
    
    % Get data using Kofiko data structures
    aiTrialIndices = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.TimeStamp >= strctSession.m_fKofikoStartTS & ...
        strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.TimeStamp <= strctSession.m_fKofikoEndTS);
    
    aiStimulusIndexKofiko = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(1,aiTrialIndices);
    afMsgSent_Kofiko_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(4,aiTrialIndices);
    afOnset_Kofiko_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(5,aiTrialIndices);
    
    afPlexon_Before_Rise_TS = fnKofikoTimeToPlexonTime(strctSession, afMsgSent_Kofiko_TS);
    %Note, the first entry may be negative, if we started recording after
    %trial started...
    
    
    iSelectedFrame = find(strctPlexon.m_strctPhotodiode.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');
    iStart = strctPlexon.m_strctPhotodiode.m_aiStart(iSelectedFrame);
    iEnd = strctPlexon.m_strctPhotodiode.m_aiEnd(iSelectedFrame);
    fTTLThreshold = 1000;
    [astrctStimulusONIntervals,aiStartIndicesON] = fnGetIntervals(strctPlexon.m_strctPhotodiode.m_afData(iStart:iEnd) > fTTLThreshold);
    afPhotodiodeON_TS_Plexon = strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame) + (aiStartIndicesON-1) / strctPlexon.m_strctPhotodiode.m_fFreq;
    
    
    %   % We can also extract this information from the plexon strobe word data structure
    iStart = find(strctPlexon.m_strctStrobeWord.m_afTimestamp >= strctSession.m_fPlexonStartTS,1,'first');
    iEnd = find(strctPlexon.m_strctStrobeWord.m_afTimestamp <= strctSession.m_fPlexonEndTS,1,'last');
 
    aiWords = strctPlexon.m_strctStrobeWord.m_aiWords(iStart:iEnd);
    aiStimuliIndexPlexon = aiWords(aiWords<30000);
    aiStimuliTSPlexon = strctPlexon.m_strctStrobeWord.m_afTimestamp(aiWords<30000);
    
    % Notice that aiStimulusIndex may not be the same as
    % aiStimuliIndexPlexon
    % because some trials may have been omitted due to a pause/monkey
    % stopping working, etc....
    % But we can try to match this using sub-strings approach....
    aiKofikoToPlexonIndexMatching = fnSubStringMatching(aiStimulusIndexKofiko, aiStimuliIndexPlexon);
    aiTrialIndicesWithBothPlexonAndKofikoInfo = find(aiKofikoToPlexonIndexMatching > 0);
    
    aiStimuliIndicesCropped = aiStimulusIndexKofiko(aiKofikoToPlexonIndexMatching > 0);
    afPlexon_Before_Rise_TS_Cropped = afPlexon_Before_Rise_TS(aiTrialIndicesWithBothPlexonAndKofikoInfo);
    
    
    aiStimulusIndex = aiStimuliIndicesCropped;
    % Search for the rise of the photodiode TTL pulse, just after stimulus strobe
      
    % for each stimulus presentation, find the nearest rise of photodiode
    % signal:
    iNumStimuliDisplayed = length(aiStimuliIndicesCropped);
    
    afModifiedStimulusON_TS_Plexon = zeros(1, iNumStimuliDisplayed);
    afModifiedStimulusOFF_TS_Plexon = zeros(1, iNumStimuliDisplayed);
    for iStimulusIter=1:iNumStimuliDisplayed
        iIndexON = find(afPhotodiodeON_TS_Plexon >= afPlexon_Before_Rise_TS_Cropped(iStimulusIter),1,'first');
        afModifiedStimulusON_TS_Plexon(iStimulusIter) = afPhotodiodeON_TS_Plexon(iIndexON);
        
        % Note, the OFF is probably not accurate because the photodiode
        % amplifiler elongates the TTL pulse by a fixed amount, which depend on
        % the threshold setting. In my rig, the TTL pulse will remain high for
        % ~ 11 ms after photodiode signal goes high.
        afModifiedStimulusOFF_TS_Plexon(iStimulusIter) = afPhotodiodeON_TS_Plexon(iIndexON) + ...
            astrctStimulusONIntervals(iIndexON).m_iLength / strctPlexon.m_strctPhotodiode.m_fFreq;
    end;
    
    
    
    
end


return;


function [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
    fnPhotodiodeFlipOldCode(strctKofiko, strctPlexon, strctSession,iParadigmIndex)

if 0
    afLocalTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,1);
    afRemoteTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,2);
    fJitterMS = mean(1e3*strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,3));
    if max(fJitterMS) == 0
        fnWorkerLog('Cannot do this time alignment? It seems like this was run on a touch screen configuration without a stimulus server?!?!?\n');
        assert(false);
    end
    
    StimulusServerFlipTS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.TimeStamp;
    iStart_TS = find(StimulusServerFlipTS >= strctSession.m_fKofikoStartTS,1,'first');
    iEnd_TS = find(StimulusServerFlipTS <= strctSession.m_fKofikoEndTS,1,'last');
    
    afOnset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.Buffer(iStart_TS:iEnd_TS,1);
    afOnset_ImageIndex = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.Buffer(iStart_TS:iEnd_TS,2);
    
    
    % First thing first, identify when stimulus was displayed using the photodiode sensor
    S = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.CurrStimulusIndex;
    iStart = find(S.TimeStamp >= strctSession.m_fKofikoStartTS,1,'first');
    iEnd = find(S.TimeStamp <= strctSession.m_fKofikoEndTS,1,'last');
    
    assert(iEnd-iStart == iEnd_TS-iStart_TS);
    
    % These two variables hold the list of stimuli displayed and their Kofiko timestamp
    aiStimuli = squeeze(S.Buffer(iStart:iEnd));
    assert(all(aiStimuli == afOnset_ImageIndex));
    
    % Convert Stimulus Server timestamps to Kofiko TS
    
    
    
    afTimeTrans = [afRemoteTime ones(size(afRemoteTime))] \ afLocalTime;
    
    afStimulusOnsetFromStimServerInKofikoTime =  afTimeTrans(1)*afOnset_StimServer_TS + afTimeTrans(2);
    
%     afTimeRelative = afStimulusOnsetFromStimServerInKofikoTime - strctSession.m_fKofikoStartTS;
%     
%     afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%         afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%         strctSession.m_afKofikoTStoPlexonTS(1);
%     
%     afKofikoInPlexTimeOnlyImages = afKofikoInPlexTime(aiStimuli > 0);
    % figure(10);
    % clf;
    % hold on;
    % for k=1:length(afKofikoInPlexTimeOnlyImages)
    %     plot([afKofikoInPlexTimeOnlyImages(k) afKofikoInPlexTimeOnlyImages(k)],[0 1],'b');
    %     plot([afModifiedStimulusON_TS_Plexon(k) afModifiedStimulusON_TS_Plexon(k)],[0 0.8],'r');
    % end;
    % axis([0 10 0 1.1])
    % figure;hist((afModifiedStimulusON_TS_Plexon-afKofikoInPlexTimeOnlyImages') * 1e3)
end


% First thing first, identify when stimulus was displayed using the photodiode sensor
S = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.CurrStimulusIndex;
iStart = find(S.TimeStamp >= strctSession.m_fKofikoStartTS,1,'first');
iEnd = find(S.TimeStamp <= strctSession.m_fKofikoEndTS,1,'last');

%iEnd-iStart

% These two variables hold the list of stimuli displayed and their Kofiko timestamp
aiStimuli = squeeze(S.Buffer(iStart:iEnd));
afStimuli_TS_Kofiko = S.TimeStamp(iStart:iEnd);

% We can also extract this information from the plexon strobe word data structure
iStart = find(strctPlexon.m_strctStrobeWord.m_afTimestamp >= strctSession.m_fPlexonStartTS,1,'first');
iEnd = find(strctPlexon.m_strctStrobeWord.m_afTimestamp <= strctSession.m_fPlexonEndTS,1,'last');
% This is also represented as:  strctSession.m_aiPlexonStrobeInterval


% These two variables hold the list of stimuli displayed and their Kofiko timestamp
% Assume maximum of 30,000 stimulus types...
aiIndices = find(strctPlexon.m_strctStrobeWord.m_aiWords(iStart:iEnd) < 30000);
aiStimuli_Plexon = strctPlexon.m_strctStrobeWord.m_aiWords(iStart+aiIndices-1);
afStimuli_TS_Plexon = strctPlexon.m_strctStrobeWord.m_afTimestamp(iStart+aiIndices-1);
assert( all(aiStimuli_Plexon == aiStimuli));

% Now, restrict analysis to the ON events:
aiStimulusIndex = aiStimuli_Plexon(aiStimuli_Plexon>0);
afStimuliON_TS_Plexon = afStimuli_TS_Plexon(aiStimuli_Plexon>0);

% Search for the rise of the photodiode TTL pulse, just after stimulus strobe

iSelectedFrame = find(strctPlexon.m_strctPhotodiode.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');

iStart = strctPlexon.m_strctPhotodiode.m_aiStart(iSelectedFrame);
iEnd = strctPlexon.m_strctPhotodiode.m_aiEnd(iSelectedFrame);

fTTLThreshold = 1000;
[astrctStimulusONIntervals,aiStartIndicesON] = fnGetIntervals(strctPlexon.m_strctPhotodiode.m_afData(iStart:iEnd) > fTTLThreshold);

if 0
    % This will show stimulus on time, as recv by plexon strobe word, and
    % the rise of the photo diode (after image was painted on screen)
    afTime = strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame):1/strctPlexon.m_strctPhotodiode.m_fFreq:...
        strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame)+(iEnd-iStart) * 1/strctPlexon.m_strctPhotodiode.m_fFreq;
    figure(1);
    clf;
    plot(afStimuliON_TS_Plexon, aiStimulusIndex,'b.');
    hold on;
    plot(afTime, strctPlexon.m_strctPhotodiode.m_afData(iStart:iEnd) ,'r');
    plot(afTime, strctPlexon.m_strctPhotodiode.m_afData(iStart:iEnd) ,'r.');
    axis([afTime(1) afTime(1)+2 0 2500]);
end

afPhotodiodeON_TS_Plexon = strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame) + (aiStartIndicesON-1) / strctPlexon.m_strctPhotodiode.m_fFreq;

if 0
    [C,H]=hist(cat(1,astrctStimulusONIntervals.m_iLength)/strctPlexon.m_strctPhotodiode.m_fFreq*1e3);
    [C(C>0)./sum(C)*100;H(C>0)]
    % First row is the percentage of stimulus presentations, second row is timing in ms
end;



% for each stimulus presentation, find the nearest rise of photodiode
% signal:
iNumStimuliDisplayed = length(aiStimulusIndex);
afModifiedStimulusON_TS_Plexon = zeros(1, iNumStimuliDisplayed);
afModifiedStimulusOFF_TS_Plexon = zeros(1, iNumStimuliDisplayed);
for iStimulusIter=1:iNumStimuliDisplayed
    iIndexON = find(afPhotodiodeON_TS_Plexon >= afStimuliON_TS_Plexon(iStimulusIter),1,'first');
    afModifiedStimulusON_TS_Plexon(iStimulusIter) = afPhotodiodeON_TS_Plexon(iIndexON);
    
    % Note, the OFF is probably not accurate because the photodiode
    % amplifiler elongates the TTL pulse by a fixed amount, which depend on
    % the threshold setting. In my rig, the TTL pulse will remain high for
    % ~ 11 ms after photodiode signal goes high.
    afModifiedStimulusOFF_TS_Plexon(iStimulusIter) = afPhotodiodeON_TS_Plexon(iIndexON) + ...
        astrctStimulusONIntervals(iIndexON).m_iLength / strctPlexon.m_strctPhotodiode.m_fFreq;
end;

%fprintf('Max time to next photodiode TTL (should be quite small) : %.2f\n',max((afModifiedStimulusON_TS_Plexon'-afStimuliON_TS_Plexon)*1e3));
%%% If we ever want to convert a timestamp from Kofiko to plexon, here is
%%% what needs to be done:
if 0
%     afTimeRelative = afStimuli_TS_Kofiko - strctSession.m_fKofikoStartTS;
%     afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%         afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%         strctSession.m_afKofikoTStoPlexonTS(1);
%     
%     afTime = strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame):1/strctPlexon.m_strctPhotodiode.m_fFreq:...
%         strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame)+...
%         (strctPlexon.m_strctPhotodiode.m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/strctPlexon.m_strctPhotodiode.m_fFreq;
%     
%     figure(2);
%     clf;
%     hold on;
%     plot(afTime, strctPlexon.m_strctPhotodiode.m_afData(strctPlexon.m_strctPhotodiode.m_aiStart(iSelectedFrame):strctPlexon.m_strctPhotodiode.m_aiEnd(iSelectedFrame)));
%     for k=1:length(afStimuli_TS_Plexon)
%         plot([afStimuli_TS_Plexon(k),afStimuli_TS_Plexon(k)],[0 1000],'g');
%         plot([afKofikoInPlexTime(k), afKofikoInPlexTime(k)],[0 500],'r');
%     end;
%     
end;


return;