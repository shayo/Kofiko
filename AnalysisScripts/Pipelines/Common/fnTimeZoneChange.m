function afNewTS = fnTimeZoneChange(afTS, strctSync, strZoneFrom, strZoneTo)
switch lower(strZoneFrom)
    case 'kofiko'
        switch lower(strZoneTo)
            case 'plexon'
                % Kofiko To Plexon
                afNewTS = fnApplyTransform(afTS, strctSync.m_strctKofikoToPlexon);
            case 'statserver'
                % Kofiko To Stat Server
                afNewTS = fnApplyInvTransform(afTS, strctSync.m_strctStatServerToKofiko);
            case 'stimulusserver'
                % Kofiko To Stimulus Server
                afNewTS = fnApplyInvTransform(afTS, strctSync.m_strctStimulusServerToKofiko);
            case 'kofiko'
                afNewTS = afTS;
        end
    case 'plexon'
        switch lower(strZoneTo)
            case 'kofiko'
                % Plexon To Kofiko
                afNewTS = fnApplyInvTransform(afTS, strctSync.m_strctKofikoToPlexon);
            case 'statserver'
                % Plexon To Stat Server
                afTS_Kofiko = fnTimeZoneChange(afTS, strctSync, 'Plexon', 'Kofiko');
                afNewTS = fnTimeZoneChange(afTS_Kofiko, strctSync, 'Kofiko', 'StatServer');
            case 'stimulusserver'
                % Plexon To Stimulus Server
                afTS_Kofiko = fnTimeZoneChange(afTS, strctSync, 'Plexon', 'Kofiko');
                afNewTS = fnTimeZoneChange(afTS_Kofiko, strctSync, 'Kofiko', 'StimulusServer');
            case 'plexon'
                afNewTS = afTS;
        end        
    case 'statserver'
        switch lower(strZoneTo)
            case 'plexon'
                % Stat Server To Plexon
                afTS_Kofiko = fnTimeZoneChange(afTS, strctSync, 'StatServer', 'Kofiko');
                afNewTS = fnTimeZoneChange(afTS_Kofiko, strctSync, 'Kofiko', 'Plexon');
            case 'kofiko'
                % Stat Server To Kofiko
                afNewTS = fnApplyTransform(afTS, strctSync.m_strctStatServerToKofiko);
            case 'stimulusserver'
                % Stat Server To Stimulus Server
                afTS_Kofiko = fnTimeZoneChange(afTS, strctSync, 'StatServer', 'Kofiko');
                afNewTS = fnTimeZoneChange(afTS_Kofiko, strctSync, 'Kofiko', 'StimulusServer');
            case 'statserver'
                afNewTS = afTS;
        end        
    case 'stimulusserver'
        switch lower(strZoneTo)
            case 'plexon'
                % Stimulus Server To Plexon
                afTS_Kofiko = fnTimeZoneChange(afTS, strctSync, 'StimulusServer', 'Kofiko');
                afNewTS = fnTimeZoneChange(afTS_Kofiko, strctSync, 'Kofiko', 'Plexon');
            case 'statserver'
                % Stimulus Server To Stat Server
                afTS_Kofiko = fnTimeZoneChange(afTS, strctSync, 'StimulusServer', 'Kofiko');
                afNewTS = fnTimeZoneChange(afTS_Kofiko, strctSync, 'Kofiko', 'StatServer');
            case 'kofiko'
                % Stimulus Server To Kofiko
                afNewTS = fnApplyTransform(afTS, strctSync.m_strctStimulusServerToKofiko);
            case 'stimulusserver'
                afNewTS = afTS;
        end        
end

return;

function afTransTS = fnApplyTransform(afTS, strctSync)
if isfield(strctSync,'m_afOffset')
    % This involves conversion between kofiko and plexon.
    % since plexon can pause time, we need to take into effect the frame
    % issue...
    % for each time stamp, we need to find which frame it belongs to....
    % and apply the correct offset and scale.
    
     % From Kofiko To Plexon.
     % TS is given in kofiko.
     
    iNumFrames = length(strctSync.m_afStartFrameTS_Kofiko);
    % Find for each frame all the time stamps that belong to it.
    iNumTimePoints = length(afTS);
    afTransTS = NaN*ones(1,iNumTimePoints);
    for iFrameIter=1:iNumFrames
        if iFrameIter == 1
            abRelevantTS = afTS <= strctSync.m_afEndFrameTS_Kofiko(iFrameIter);
        elseif iFrameIter == iNumFrames
            abRelevantTS =afTS >= strctSync.m_afStartFrameTS_Kofiko(iFrameIter) ;
        else
            abRelevantTS = afTS >= strctSync.m_afStartFrameTS_Kofiko(iFrameIter) & afTS <= strctSync.m_afEndFrameTS_Kofiko(iFrameIter);
        end
        afTransTS(abRelevantTS) =strctSync.m_afOffset(iFrameIter) + strctSync.m_afScale(iFrameIter) * afTS(abRelevantTS);
    end
    % Fix the ones that are outside the frames by doing extrapolation using
    % the first / last frames...
    if sum(isnan(afTransTS)) > 0
        aiProblematicTS = find(isnan(afTransTS));
        for iIter=1:length(aiProblematicTS)
            [fDummy, iSelectedFramemin]  = min(min(abs(strctSync.m_afEndFrameTS_Kofiko-afTS(aiProblematicTS(iIter))),abs(strctSync.m_afStartFrameTS_Kofiko-afTS(aiProblematicTS(iIter)))));
                afTransTS(aiProblematicTS(iIter)) = strctSync.m_afOffset(iSelectedFramemin) + strctSync.m_afScale(iSelectedFramemin) * afTS(aiProblematicTS(iIter));
        end
        % 
%         fprintf('Warning, some time stamps may not have been transformed properly (sampling between plexon frames)\n');
    end;
    
else
    afTransTS = strctSync.m_fOffset + strctSync.m_fScale * afTS;
    
end
return;

function afTransTS = fnApplyInvTransform(afTS, strctSync)
if isfield(strctSync,'m_afOffset')
    % This involves conversion between kofiko and plexon.
    % since plexon can pause time, we need to take into effect the frame
    % issue...
    % for each time stamp, we need to find which frame it belongs to....
    % and apply the correct offset and scale.
    
     % From Plexon To Kofiko.
     % TS is given in Plexon.
    
    iNumFrames = length(strctSync.m_afStartFrameTS_Kofiko);
    % Find for each frame all the time stamps that belong to it.
    iNumTimePoints = length(afTS);
    afTransTS = NaN*ones(1,iNumTimePoints);
    for iFrameIter=1:iNumFrames
        
       if iFrameIter == 1
            abRelevantTS = afTS <= strctSync.m_afEndFrameTS_PLX(iFrameIter);
        elseif iFrameIter == iNumFrames
            abRelevantTS =afTS >= strctSync.m_afStartFrameTS_PLX(iFrameIter) ;
        else
            abRelevantTS = afTS >= strctSync.m_afStartFrameTS_PLX(iFrameIter) & afTS <= strctSync.m_afEndFrameTS_PLX(iFrameIter);
       end
        
        afTransTS(abRelevantTS) =   (afTS(abRelevantTS)-strctSync.m_afOffset(iFrameIter))/strctSync.m_afScale(iFrameIter);
    end    
    
    if sum(isnan(afTransTS)) > 0
        
        aiProblematicTS = find(isnan(afTransTS));
        for iIter=1:length(aiProblematicTS)
            [fDummy, iSelectedFramemin]  = min(min(abs(strctSync.m_afStartFrameTS_PLX-afTS(aiProblematicTS(iIter))),abs(strctSync.m_afEndFrameTS_PLX-afTS(aiProblematicTS(iIter)))));
                afTransTS(aiProblematicTS(iIter)) = (afTS(aiProblematicTS(iIter))-strctSync.m_afOffset(iSelectedFramemin)) /strctSync.m_afScale(iSelectedFramemin);
        end
        % 
%         fprintf('Warning, some time stamps may not have been transformed properly (sampling between plexon frames)\n');
     end;
 else
    afTransTS = (afTS-strctSync.m_fOffset) /strctSync.m_fScale;
end
return;
