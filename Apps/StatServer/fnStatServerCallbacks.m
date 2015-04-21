function fnStatServerCallbacks(strEvent, varargin)
global g_strctCycle g_strctConfig g_strctNet g_strctNeuralServer g_strctWindows g_DebugDataLog g_counter 
switch strEvent
        
    case 'UpdateAxes'
        fnSetAxesForPlotting();
    case 'SetBarGraphRange'
        if strcmpi(varargin{1},'Start')
            g_strctConfig.m_strctGUIParams.m_fBarGraphFrom = varargin{2};
        else
            g_strctConfig.m_strctGUIParams.m_fBarGraphTo = varargin{2};
        end
    case 'UpdateAdvancer'
        
        if ~isempty(g_strctCycle.m_strSessionName)
            strSession = g_strctCycle.m_strSessionName;
        else
            strSession = g_strctCycle.m_strTmpSessionName;
        end
        
        iAdvancerIndex = varargin{1};
        fNewDepth = varargin{2};
        fTS_PTB = GetSecs();
        fTS_MapClockNow = TrialCircularBuffer('GetLastKnownTimestamp');
        fEstimatedTimeStampPLXFile = fTS_MapClockNow-g_strctCycle.m_strctPlexonFrame.m_fMAPClockAtFrameStart;
        strOutputText = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[strSession,'-Advancers.txt']);
        hFileID = fopen(strOutputText,'a+');
        fprintf(hFileID,'%d %f %d %f %f %f\r\n',iAdvancerIndex,fNewDepth, g_strctCycle.m_strctPlexonFrame.m_iCurrentPlexonFrame, fEstimatedTimeStampPLXFile,fTS_MapClockNow,fTS_PTB);
        fclose(hFileID);
        
    case 'SetVisualization'
        strMode = varargin{1};
        switch strMode
            case 'ToggleAutoRescale'
                g_strctConfig.m_strctGUIParams.m_bAutoRescale = ~g_strctConfig.m_strctGUIParams.m_bAutoRescale;
                fnDisplayOverview();
                
            case 'PSTH'
                g_strctConfig.m_strctGUIParams.m_strViewMode = 'PSTH';
                fnDisplayOverview();
            case 'Raster'
                g_strctConfig.m_strctGUIParams.m_strViewMode = 'Raster';
                fnDisplayOverview();
            case 'BarGraph'
                g_strctConfig.m_strctGUIParams.m_strViewMode = 'BarGraph';
                fnDisplayOverview();
            case 'ResetAxes'
                 fnDisplayOverview();
            case 'LinkAxes'
                bLink = get(g_strctWindows.m_strctSettingsPanel.m_hLinkAxes,'value');
                if bLink
                    linkaxes(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(:),'x');
                else
                    linkaxes(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes(:),'off');
                    
                end
                fnDisplayOverview();
            case 'SmoothCurves'
                g_strctConfig.m_strctGUIParams.m_bSmoothPSTH = get(g_strctWindows.m_strctSettingsPanel.m_hSmoothCurves,'value') > 0;
                fnDisplayOverview();
            otherwise
                fnStatLog('Unknown GUI Option');
        end
        
    case 'KofikoInput'
        fnParseInputFromKofiko(varargin{:});
    case 'ToggleActive'
        if isempty(g_strctCycle.m_strSessionName)
            return;
        end
         
        iChannel = varargin{1};
        iUnit = varargin{2};
        fLastKnownTS = TrialCircularBuffer('GetLastKnownTimestamp');
        
        NumAvailCh = size(g_strctNeuralServer.m_a2cActiveUnitsHistory,1);
        NumAvailUnit = size(g_strctNeuralServer.m_a2cActiveUnitsHistory,2);
        if iChannel > NumAvailCh || NumAvailUnit>NumAvailUnit
            return;
        end;
            
        iNumEntries = size(g_strctNeuralServer.m_a2cActiveUnitsHistory{iChannel,iUnit},1);
        
        if g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) > 0
           % Unit WAS active and we just lost it
           if iNumEntries == 0
               % BUG ?!?!?!
           else
                g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) = 0;
                g_strctNeuralServer.m_a2cActiveUnitsHistory{iChannel,iUnit}(iNumEntries,2) = fLastKnownTS;
%                set(g_strctWindows.m_strctStatPanel.m_a2hPushButtons(iChannel,iUnit+1),'String', sprintf('Activate [%d:%d]',iChannel,iUnit),'FontWeight','Normal');
            
           end
        else
           % Unit was inactive and we just activated it.
           g_strctCycle.m_iGlobalUnitCounter = g_strctCycle.m_iGlobalUnitCounter + 1;
           g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) =  g_strctCycle.m_iGlobalUnitCounter ;

           TrialCircularBuffer('ResetUnitTrialCounter',iChannel,iUnit);
           
           if iNumEntries == 0
               g_strctNeuralServer.m_a2cActiveUnitsHistory{iChannel,iUnit} = [fLastKnownTS, NaN];
           else
               g_strctNeuralServer.m_a2cActiveUnitsHistory{iChannel,iUnit}(iNumEntries+1,:) = [fLastKnownTS, NaN];
           end
%           set(g_strctWindows.m_strctStatPanel.m_a2hPushButtons(iChannel,iUnit+1),'String', sprintf('[%d:%d] is Active!',iChannel,iUnit),'FontWeight','Bold');
        end
        
          % Save this immediately to disk ?
        
%         strOutput = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[g_strctCycle.m_strSessionName,'-Electrophsyiology.mat']);
%         save(strOutput,'g_strctNeuralServer');
        
        if ~isempty(g_strctCycle.m_strSessionName)
            strSession = g_strctCycle.m_strSessionName;
        else
            strSession = g_strctCycle.m_strTmpSessionName;
        end

        strOutputText = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[strSession,'-ActiveUnits.txt']);
        hFileID = fopen(strOutputText,'a+');
        
        fTS_PTB = GetSecs();
        fTS_MapClockNow = TrialCircularBuffer('GetLastKnownTimestamp');
        fEstimatedTimeStampPLXFile = fTS_MapClockNow-g_strctCycle.m_strctPlexonFrame.m_fMAPClockAtFrameStart;
        
        fprintf(hFileID,'%d %d %d %d %f %f %f\r\n',iChannel,iUnit,g_strctNeuralServer.m_a2iCurrentActiveUnits(iChannel,iUnit) > 0,  g_strctCycle.m_strctPlexonFrame.m_iCurrentPlexonFrame, fEstimatedTimeStampPLXFile,fTS_MapClockNow,fTS_PTB);
        fclose(hFileID);
        
%        fnUpdatePushButtonsTitle();
%         if g_strctCycle.m_bConditionInfoAvail
%             fnDisplayOverview();
%         end
end

return;

function fnParseInputFromKofiko(acInputFromKofiko)
global g_strctCycle g_strctNeuralServer g_strctWindows g_strctConfig
strCommand = acInputFromKofiko{1};
%
switch lower(strCommand)
    case 'pong'
        
        fLocalTimeSend = acInputFromKofiko{2};
        fKofikoTime = acInputFromKofiko{3};
        fNow = GetSecs();
        fJitterMS = (fNow-fLocalTimeSend)*1e3;
        g_strctCycle.m_strctSync = fnTsSetVar(g_strctCycle.m_strctSync,'KofikoSyncPingPong', [fLocalTimeSend, fKofikoTime, fJitterMS]);
    case 'syncwithkofiko'
        fKofikoTime = acInputFromKofiko{2};
        g_strctCycle.m_strctSync = fnTsSetVar(g_strctCycle.m_strctSync,'KofikoSync', [GetSecs(), fKofikoTime]);
    case 'plexonframestart'
        g_strctCycle.m_strctPlexonFrame.m_fMAPClockAtFrameStart = TrialCircularBuffer('GetLastKnownTimestamp');
        g_strctCycle.m_strctPlexonFrame.m_iCurrentPlexonFrame = acInputFromKofiko{2};
        g_strctCycle.m_strctPlexonFrame.m_fKofiko_TS = acInputFromKofiko{3};
        g_strctCycle.m_strctPlexonFrame.m_fStatServerTS = GetSecs();
        g_strctCycle.m_strctSync = fnTsSetVar(g_strctCycle.m_strctSync,'PlexonSync', [g_strctCycle.m_strctPlexonFrame.m_fMAPClockAtFrameStart,g_strctCycle.m_strctPlexonFrame.m_iCurrentPlexonFrame,g_strctCycle.m_strctPlexonFrame.m_fKofiko_TS,g_strctCycle.m_strctPlexonFrame.m_fStatServerTS    ]);
        
        g_strctCycle.m_bPlexonIsRecording = true;
        set(g_strctWindows.m_strctStatPanel.m_a2hPushButtons(~isnan(g_strctWindows.m_strctStatPanel.m_a2hPushButtons)),'enable','on');
        
    case 'plexonframeend'
        fnTurnOffAllActiveUnits(false);
        g_strctCycle.m_strctPlexonFrame.m_fMAPClockAtFrameStart = NaN;
        g_strctCycle.m_strctPlexonFrame.m_iCurrentPlexonFrame = NaN;
        g_strctCycle.m_bPlexonIsRecording = false;
        
        set(g_strctWindows.m_strctStatPanel.m_a2hPushButtons(~isnan(g_strctWindows.m_strctStatPanel.m_a2hPushButtons)),'enable','off');
        
    case 'startnewsession'
        if isempty(g_strctCycle.m_strSessionName) 
            g_strctCycle.m_strKofikoLog = acInputFromKofiko{2};
            
          % Re-opened while kofiko still running ?
        [strP,strF]=fileparts(g_strctCycle.m_strKofikoLog);
        
        g_strctCycle.m_strSessionName = strF;
          
            
        % rename files...
        strActiveUnitsTmpFile = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[g_strctCycle.m_strTmpSessionName,'-ActiveUnits.txt']);
        if exist(strActiveUnitsTmpFile,'file')
            strActiveUnitsFile = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[g_strctCycle.m_strSessionName,'-ActiveUnits.txt']);
            movefile(strActiveUnitsTmpFile,strActiveUnitsFile);
        end
        
        strAdvancersTmpFile = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[g_strctCycle.m_strTmpSessionName,'-Advancers.txt']);
        if exist(strAdvancersTmpFile,'file')
            strAdvancersFile = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[g_strctCycle.m_strSessionName,'-Advancers.txt']);
            movefile(strAdvancersTmpFile,strAdvancersFile);
        end
            
        
        
        strOutput = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[strF,'-Electrophsyiology.mat']);
        
        if exist(strOutput,'file')
           strAnswer = questdlg('Information about this session exist. Reload from disk?','Warning!','Yes','No','Yes');
           if strcmp(strAnswer,'Yes')
                strctInfo = load( strOutput);
                % Take only relevant information....
                if all(size(g_strctNeuralServer.m_a2iCurrentActiveUnits) == size(strctInfo.g_strctNeuralServer.m_a2iCurrentActiveUnits) )
                    g_strctNeuralServer.m_a2iCurrentActiveUnits = strctInfo.g_strctNeuralServer.m_a2iCurrentActiveUnits;
                    g_strctNeuralServer.m_a2cActiveUnitsHistory = strctInfo.g_strctNeuralServer.m_a2cActiveUnitsHistory;
                end
           end
        end
        else
            
            % Kofiko crashed.... problematic...
            assert(false);
     
            
        end
    case 'cleardesign'
         g_strctCycle.m_bConditionInfoAvail = false;
         % release buffers...
         
    case 'design'
        strctDesign = acInputFromKofiko{2};
        
        fnStatLog('New Design Received');
       
        NumPointsInWaveform = g_strctNeuralServer.m_fNumPointsInWaveform;
        NumChannels = g_strctNeuralServer.m_iNumActiveSpikeChannels;
        NumUnitsPerChannel = g_strctNeuralServer.m_iNumberUnitsPerChannel;
        LFP_Sampled_Freq = g_strctNeuralServer.m_fAD_Freq;
        LFP_Stored_Freq = g_strctNeuralServer.m_fAD_Freq/5; % ideally, sampled is 2K and stored is 400Hz
        assert( mod(LFP_Stored_Freq,10) == 0)
        
        if ~isfield(strctDesign,'NumTrialsInCircularBuffer') || ~isfield(strctDesign,'TrialLengthSec') || ~isfield(strctDesign,'Pre_TimeSec') || ...
                ~isfield(strctDesign,'Post_TimeSec') ||     ~isfield(strctDesign,'TrialStartCode')
        
            fnStatLog('Failed to update design!');
            fnStatLog('Some fields are missing!');
            g_strctCycle.m_bConditionInfoAvail = false;
            return;
        end;
            
        
        NumTrials = strctDesign.NumTrialsInCircularBuffer;
        TrialLengthSec = strctDesign.TrialLengthSec;
        Pre_TimeSec = strctDesign.Pre_TimeSec;
        Post_TimeSec = strctDesign.Post_TimeSec;
        
        fnStatLog('Allocating memory for trials...');
        fprintf('LFP is %d Hz, Sampled LFP is %d\n',LFP_Sampled_Freq,LFP_Stored_Freq);
        aiChannels = g_strctNeuralServer.m_aiActiveSpikeChannels;
        TrialCircularBuffer('Allocate',aiChannels,NumUnitsPerChannel,LFP_Sampled_Freq,LFP_Stored_Freq,NumTrials,TrialLengthSec,Pre_TimeSec,Post_TimeSec,NumPointsInWaveform);
        
        
        strctOpt.TrialStartCode = strctDesign.TrialStartCode;
        strctOpt.TrialEndCode = strctDesign.TrialEndCode;
        strctOpt.TrialAlignCode = strctDesign.TrialAlignCode;
        strctOpt.TrialOutcomesCodes = strctDesign.TrialOutcomesCodes;
        strctOpt.KeepTrialOutcomeCodes = strctDesign.KeepTrialOutcomeCodes;
        
        % Augment conditions with "All kept trials"
        NumTrialsTypes = size(strctDesign.TrialTypeToConditionMatrix,1);
        NumConditions = size(strctDesign.TrialTypeToConditionMatrix,2);
        if isempty(strctDesign.ConditionNames)
            strctDesign.ConditionNames = cell(1,NumConditions);
            for k=1:NumConditions
                strctDesign.ConditionNames{k} = sprintf('Unknwon Condition %d',k);
            end
        end
        TrialToConditionAug = [ones(NumTrialsTypes,1)>0, strctDesign.TrialTypeToConditionMatrix];
        
        strctOpt.TrialTypeToConditionMatrix = TrialToConditionAug;
        
        AugOutcomeFilter = cell(1, NumConditions+1);
        AugOutcomeFilter(2:end) = strctDesign.ConditionOutcomeFilter;
        strctOpt.ConditionOutcomeFilter = AugOutcomeFilter;
        strctOpt.PSTH_BinSizeMS = 10;
        strctOpt.LFP_ResolutionMS = 5;
        
        AugNames = cell(1,NumConditions+1);
        AugNames{1} = 'All Kept Trials';
        AugNames(2:end) = strctDesign.ConditionNames;
        strctOpt.ConditionNames = AugNames;
        strctOpt.NumChannels = NumChannels;
        strctOpt.NumUnitsPerChannel = NumUnitsPerChannel;
        strctOpt.LFP_Sampled_Freq = LFP_Sampled_Freq;
        strctOpt.LFP_Stored_Freq = LFP_Stored_Freq ;
        strctOpt.NumTrials = NumTrials;
        strctOpt.TrialLengthSec = TrialLengthSec;
        strctOpt.Pre_TimeSec = Pre_TimeSec;
        strctOpt.Post_TimeSec = Post_TimeSec;
        
        TrialCircularBuffer('SetOpt',strctOpt);
        
        g_strctCycle.m_strctTrialBufferOpt = strctOpt;
        g_strctCycle.m_bConditionInfoAvail = true;
        
        
       if isfield(strctDesign,'ConditionVisibility') && length(strctDesign.ConditionVisibility) == NumConditions
         g_strctCycle.m_abDisplayConditions = [true, strctDesign.ConditionVisibility] > 0;
       else        
         g_strctCycle.m_abDisplayConditions = ones(1,NumConditions+1) > 0;
       end
        g_strctCycle.m_abDisplayConditionsRaster = zeros(1,NumConditions+1) > 0;
        g_strctCycle.m_abDisplayConditionsRaster(1) = true;
        g_strctCycle.m_a2fConditionColors = lines(NumConditions+1);
        
        fnStatLog('Allocation finished successfully.');
        fnUpdateConditionList();
        
        % Clear spike and LFP buffer. It might still contain information
        % about previous trials that are not irrelevant....
        
        [NumSpikeAndStrobeEvents, a2fSpikeAndEvents, a2fWaveForms] =PL_GetWFEvs(g_strctNeuralServer.m_hSocket); 
        [NumAnalog, afAnalogTime, a2fLFP] = PL_GetADVEx(g_strctNeuralServer.m_hSocket);
        

end



% Opt = TrialCircularBuffer('GetOpt');
% War = TrialCircularBuffer('GetWarningCounters');
% NumTr = TrialCircularBuffer('GetNumTrialsInBuffer');
% 
% CORRECT_OUTCOME = 32698;
% TrialLength = zeros(1,NumTr);
% TrialAlignFromStart = zeros(1,NumTr);
% TrialOutcome = zeros(1,NumTr);
% for k=1:NumTr
%     astrctTrials(k) = TrialCircularBuffer('GetTrial',k-1);
%     TrialLength(k) = astrctTrials(k).End_TS-astrctTrials(k).Start_TS;
%     TrialAlignFromStart(k) = astrctTrials(k).Align_TS - astrctTrials(k).Start_TS;
%     TrialOutcome(k) = astrctTrials(k).Outcome;
% end
% 
% find(TrialOutcome == CORRECT_OUTCOME)
% figure;
% plot(TrialLength,'b');
% hold on;
% plot(TrialAlignFromStart,'r');
% 
