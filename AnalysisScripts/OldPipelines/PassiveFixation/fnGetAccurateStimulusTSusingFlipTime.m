function [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,bFailed] = ...
    fnGetAccurateStimulusTSusingFlipTime(strctKofiko, strctSession,iParadigmIndex)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
bFailed = false;

if ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'Trials')
    % Old synchornization method
    [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
    fnOldFlipSyncCode(strctKofiko, strctSession,iParadigmIndex);

else
    if isfield(strctKofiko.g_strctDAQParams,'StimulusServerSync')
        SyncTime = strctKofiko.g_strctDAQParams.StimulusServerSync;
    else
        SyncTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime;
    end
   
    if all(SyncTime.Buffer(:,2) == 0)
        aiStimulusIndex = [];
        afModifiedStimulusON_TS_Plexon = [];
        afModifiedStimulusOFF_TS_Plexon = [];
        bFailed = true;
        return;
    end
  
  aiTrialIndices = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.TimeStamp >= strctSession.m_fKofikoStartTS & ...
                        strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.TimeStamp <= strctSession.m_fKofikoEndTS);

  aiStimulusIndex = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(1,aiTrialIndices);
  if isempty(aiStimulusIndex)
      afModifiedStimulusON_TS_Plexon = [];
      afModifiedStimulusOFF_TS_Plexon = [];
      return;
  end
  afOnset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(2,aiTrialIndices);
  afOffset_StimServer_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.Trials.Buffer(3,aiTrialIndices);
  
  
  [afModifiedStimulusON_TS_Plexon] = fnStimulusServerTimeToPlexonTime(SyncTime,strctSession, afOnset_StimServer_TS);
  [afModifiedStimulusOFF_TS_Plexon] = fnStimulusServerTimeToPlexonTime(SyncTime,strctSession, afOffset_StimServer_TS);
  
  % Crop to ones that have a positive plexon timestamp
  abInsideSessionInterval =  (afModifiedStimulusON_TS_Plexon >= strctSession.m_fPlexonStartTS & afModifiedStimulusON_TS_Plexon <= strctSession.m_fPlexonEndTS);
  afModifiedStimulusON_TS_Plexon = afModifiedStimulusON_TS_Plexon(abInsideSessionInterval);
  afModifiedStimulusOFF_TS_Plexon = afModifiedStimulusOFF_TS_Plexon(abInsideSessionInterval);
  aiStimulusIndex = aiStimulusIndex(abInsideSessionInterval);
  
end

return


function [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
    fnOldFlipSyncCode(strctKofiko, strctSession,iParadigmIndex)


afLocalTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,1);
afRemoteTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,2);
fJitterMS = mean(1e3*strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,3));
if max(fJitterMS) == 0
    fnWorkerLog('Cannot do this time alignment? It seems like this was run on a touch screen configuration without a stimulus server?!?!?');
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
aiStimuli = squeeze(S.Buffer(iStart:iEnd));

if iEnd-iStart ~= iEnd_TS-iStart_TS
    fnWorkerLog('Detected discreprency in timing (a possible bug)...Trying to recover...');
    if iEnd-iStart ==  iEnd_TS-iStart_TS + 1
        iStartProblem = find(aiStimuli(1:end-1) ~= afOnset_ImageIndex,1,'first');
        if isempty(iStartProblem) && all(aiStimuli(1:end-1) == afOnset_ImageIndex)
            aiStimuli = aiStimuli(1:end-1);
        else
            if aiStimuli(iStartProblem) ~= 0 && aiStimuli(iStartProblem+1) ~= 0
                aiStimuli = aiStimuli([1:iStartProblem-1,iStartProblem+1:end]);
                
            end
        end
    elseif iEnd-iStart ==  iEnd_TS-iStart_TS - 1
          iStartProblem = find(aiStimuli ~= afOnset_ImageIndex(1:end-1),1,'first');
          
          if iStartProblem == 1 && all(afOnset_ImageIndex(2:end) == aiStimuli)
              aiStimuli = afOnset_ImageIndex(3:end);
              afOnset_ImageIndex = afOnset_ImageIndex(3:end);
              afOnset_StimServer_TS = afOnset_StimServer_TS(3:end);
          else
              assert(false);
          end;
        
    else
        
        assert(false);
    end

end

% These two variables hold the list of stimuli displayed and their Kofiko timestamp
if ~all(aiStimuli == afOnset_ImageIndex)
   fnWorkerLog('Detected discreprency in strobe words. Trying to recover...');
   iStartError = find(aiStimuli ~= afOnset_ImageIndex,1,'first');
   if iStartError == 1
       fnWorkerLog('*************** This is a highly risky fix... ******************');
           afOnset_ImageIndex =afOnset_ImageIndex(2:end);
           afOnset_StimServer_TS = afOnset_StimServer_TS(2:end);
           aiStimuli = afOnset_ImageIndex;
   end
   
end
%assert(all(aiStimuli == afOnset_ImageIndex));

% Convert Stimulus Server timestamps to Kofiko TS



% afTimeTrans = [afRemoteTime ones(size(afRemoteTime))] \ afLocalTime;
% afStimulusOnsetFromStimServerInKofikoTime =  afTimeTrans(1)*afOnset_StimServer_TS + afTimeTrans(2);
% afTimeRelative = afStimulusOnsetFromStimServerInKofikoTime - strctSession.m_fKofikoStartTS;
% afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%     afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%     strctSession.m_afKofikoTStoPl exonTS(1);
% 

afKofikoInPlexTime = fnStimulusServerTimeToPlexonTime(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime,...
    strctSession,afOnset_StimServer_TS);

aiStimulusIndex = aiStimuli(aiStimuli > 0);
aiTmp = find(aiStimuli > 0);
afModifiedStimulusON_TS_Plexon  = afKofikoInPlexTime(aiTmp);
if aiTmp(end)+1 > length(afKofikoInPlexTime)
    afModifiedStimulusOFF_TS_Plexon = [afKofikoInPlexTime(aiTmp(1:end-1)+1)];
else
    afModifiedStimulusOFF_TS_Plexon = afKofikoInPlexTime(aiTmp+1);
end

if length(afModifiedStimulusON_TS_Plexon) == length(afModifiedStimulusOFF_TS_Plexon) + 1
    % We pressed "Stop recording" before we got the timestamp for the last
    % image...
    % Probably make sense to take the mean off time and use it ...
    fMeanOff = mean(afModifiedStimulusOFF_TS_Plexon(1:end)-afModifiedStimulusON_TS_Plexon(1:end-1));
    afModifiedStimulusOFF_TS_Plexon(end+1) = afModifiedStimulusON_TS_Plexon(end) + fMeanOff;
end

% figure(10);
% clf;
% hold on;
% for k=1:length(afKofikoInPlexTimeOnlyImages)
%     plot([afKofikoInPlexTimeOnlyImages(k) afKofikoInPlexTimeOnlyImages(k)],[0 1],'b');
%     plot([afModifiedStimulusON_TS_Plexon(k) afModifiedStimulusON_TS_Plexon(k)],[0 0.8],'r');
% end;
% axis([0 10 0 1.1])
% figure;hist((afModifiedStimulusON_TS_Plexon-afKofikoInPlexTimeOnlyImages') * 1e3)


return;