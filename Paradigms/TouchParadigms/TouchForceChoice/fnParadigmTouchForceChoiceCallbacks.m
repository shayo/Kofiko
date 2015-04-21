function fnParadigmTouchForceChoiceCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global  g_strctParadigm g_strctStimulusServer  g_strctAppConfig


switch strCallback
    case 'RestartTrial'
        fnParadigmToKofikoComm('JuiceOff');
        g_strctParadigm.m_iMachineState = 1;
        
         if ~fnParadigmToKofikoComm('IsTouchMode')
            fnParadigmToStimulusServer('AbortTrial');
         else
            fnParadigmTouchForceChoiceDrawCycle({'AbortTrial'});
         end
    case 'EditDesign'
        fnParadigmToKofikoComm('JuiceOff');
        if ~fnParadigmToKofikoComm('IsTouchMode')
            fnParadigmToStimulusServer('AbortTrial');
        else
            fnParadigmTouchForceChoiceDrawCycle({'AbortTrial'});
        end
        fnHidePTB();
          iSelected = get(g_strctParadigm.m_strctDesignControllers.m_hFavroiteLists,'value');
         eval(['!notepad ',g_strctParadigm.m_acFavroiteLists{iSelected}]);
          fnShowPTB();  
          
         fnLoadDesignAux(g_strctParadigm.m_acFavroiteLists{iSelected});
    case 'Start'
        g_strctParadigm.m_iMachineState = 1;
    case 'TimingPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels([2,3,4,5,6]),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','on');
    case 'StimuliPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels([1,3,4,5,6]),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','on');
    case 'RewardPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels([1,2,4,5,6]),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','on');
    case 'MicrostimPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels([1,2,3,5,6]),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','on');
    case 'DesignPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels([1,2,3,4,6]),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','on');
    case 'StatPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels([1,2,3,4,5]),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','on');
        
    case 'JumpToBlock'
        fnParadigmToKofikoComm('SafeCallback','JumpToBlockSafe');        
    case 'JumpToBlockSafe'
        if g_strctParadigm.m_iSelectedBlockInDesignTable > 0
            
            fnParadigmToStimulusServer('AbortTrial');
            
            aiNumTrials = cumsum(g_strctParadigm.m_strctDesign.m_strctOrder.m_aiNumTrialsPerBlock);
            if g_strctParadigm.m_iSelectedBlockInDesignTable == 1
                g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = 1;
            else
                g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = aiNumTrials(g_strctParadigm.m_iSelectedBlockInDesignTable-1)+1;
            end
            g_strctParadigm.m_bTrialRepetitionOFF = true;
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'AddBlockToDesign'
        dbg = 1;
    case 'DeleteBlockFromDesign'
        dbg = 1;
    case 'JuiceTimeMS'
    case 'InterTrialIntervalMinSec'
    case 'InterTrialIntervalMaxSec'
    case 'HoldFixationToStartTrialMS'
    case 'HoldFixationAtTargetMS'
    case 'TimeoutMS'    
    case 'FixationRadiusPix'
    case 'HitRadius'
    case 'ImageHalfSizePix'
        g_strctParadigm.m_iMachineState = 1;
    case 'ChoicesHalfSizePix'
        g_strctParadigm.m_iMachineState = 1;
    case 'LoadDesign'
        fnParadigmToKofikoComm('SafeCallback','LoadDesignSafe');
    case 'LoadFavoriteList'
        fnParadigmToKofikoComm('SafeCallback','SafeLoadFavoriteDesign');
    case 'SafeLoadFavoriteDesign'
          iSelected = get(g_strctParadigm.m_strctDesignControllers.m_hFavroiteLists,'value');
          fnLoadDesignAux(g_strctParadigm.m_acFavroiteLists{iSelected});
    case 'LoadDesignSafe'
          % This is safe because callback was NOT during a call to
        % draw/cycle/.....
        fnParadigmToKofikoComm('JuiceOff');
	fnParadigmToStimulusServer('AbortTrial');
         % Abort Trial!
         g_strctParadigm.m_iMachineState = 2;
         
         if ~fnParadigmToKofikoComm('IsTouchMode')
            fnParadigmToStatServerComm('AbortTrial');
         else
            fnParadigmTouchForceChoiceDrawCycle({'AbortTrial'});
         end
        
        fnHidePTB();
        [strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultFolder,'*.xml']);
        fnShowPTB()
        if strFile(1) ~= 0
            strNextList = [strPath, strFile];
            fnLoadDesignAux(strNextList);
        end;        
        
    case 'ToggleExtinguish'
        g_strctParadigm.m_bExtinguishObjectsAfterSaccade = ~g_strctParadigm.m_bExtinguishObjectsAfterSaccade;
    case 'ToggleEmulator'
        g_strctParadigm.m_bEmulatorON = ~g_strctParadigm.m_bEmulatorON;
        fnParadigmToKofikoComm('MouseEmulator',g_strctParadigm.m_bEmulatorON);
        
    case 'NoiseLevel'
        g_strctParadigm.m_strctCurrentTrial.m_fNoiseLevel = fnTsGetVar(g_strctParadigm, 'NoiseLevel');
    case 'StairCaseUp'
    case 'StairCaseDown'
    case 'StairCaseStepPerc'
    case 'LoadNoiseFile'
        fnParadigmToKofikoComm('SafeCallback','SafeLoadNoiseFile');
    case 'SafeLoadNoiseFile'
        fnParadigmToKofikoComm('JuiceOff');
        fnParadigmToStimulusServer('PauseButRecvCommands');
        fnHidePTB();
        [strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultFolder,'*.mat']);
        fnShowPTB()
        if strFile(1) ~= 0
            strNoiseFile = [strPath, strFile];
            %fnLoadNoiseFile(strNoiseFile);

            fnTsSetVarParadigm('NoiseFile', strNoiseFile);
            g_strctParadigm.m_strctNoise = load(strNoiseFile);
            g_strctParadigm.m_iNoiseIndex = 1;
        end;
    case 'ResetDesignStat'
        if   isfield(g_strctParadigm,'m_strctDesign') && ~isempty(g_strctParadigm.m_strctDesign) && isfield(g_strctParadigm.m_strctDesign,'m_acTrialTypes')
            iNumTrialTypes = length(g_strctParadigm.m_strctDesign.m_acTrialTypes);
        else
            iNumTrialTypes = 0;    
        end
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumCorrect = zeros(1,iNumTrialTypes);
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumIncorrect = zeros(1,iNumTrialTypes);
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTimeout = zeros(1,iNumTrialTypes);
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumAborted = zeros(1,iNumTrialTypes);
        %g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_afResponseTime = zeros(1,iNumTrialTypes);
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTrials = zeros(1,iNumTrialTypes);
        
        if isfield(g_strctParadigm,'m_strctStatControllers') && isfield(g_strctParadigm.m_strctStatControllers,'m_hStatText')
           set(g_strctParadigm.m_strctStatControllers.m_hStatText,'String',fnPrepareSummaryResults());
        end
        
    case 'ResetAllDesignsStat'
        g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumCorrect = 0;
        g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumIncorrect = 0;
        g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTimeout = 0;
        g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumAborted = 0;
        g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTrials = 0;
        feval(g_strctParadigm.m_strCallbacks,'ResetDesignStat');
        
        if isfield(g_strctParadigm,'m_strctStatControllers') && isfield(g_strctParadigm.m_strctStatControllers,'m_hStatText')
            set(g_strctParadigm.m_strctStatControllers.m_hStatText,'String',fnPrepareSummaryResults());
        end

    case 'TrialOutcome'
        strctCurrentTrial = varargin{1};
        acOutcomes = lower(fnSplitString( strctCurrentTrial.m_strctTrialOutcome.m_strResult));
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTrials(strctCurrentTrial.m_iTrialType) = g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTrials(strctCurrentTrial.m_iTrialType) + 1;
        g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTrials = g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTrials + 1;
        bCorrect = ismember('correct',acOutcomes);
        bIncorrect = ismember('incorrect',acOutcomes);
        bAborted = ismember('aborted',acOutcomes);
        bTimeout = ismember('timeout',acOutcomes);
        %Touch Fixation
        if bCorrect
                g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumCorrect(strctCurrentTrial.m_iTrialType) = g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumCorrect(strctCurrentTrial.m_iTrialType)+1;
                g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumCorrect = g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumCorrect+1;
        elseif bIncorrect
                g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumIncorrect(strctCurrentTrial.m_iTrialType) = g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumIncorrect(strctCurrentTrial.m_iTrialType)+1;
                g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumIncorrect = g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumIncorrect+1;
        elseif bTimeout
                g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTimeout(strctCurrentTrial.m_iTrialType) = g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTimeout(strctCurrentTrial.m_iTrialType)+1;
                g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTimeout = g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTimeout + 1;
        elseif bAborted
                g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumAborted(strctCurrentTrial.m_iTrialType) = g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumAborted(strctCurrentTrial.m_iTrialType)+1;
                g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumAborted = g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumAborted + 1;
        end
        fnUpdateStatAux();
 
    case 'DrawAttentionEvent'
        fnParadigmToStatServerComm('AbortTrial');
         if ~g_strctParadigm.m_bMRI_Mode
            g_strctParadigm.m_iMachineState = 2;
         else
             % Did we start running?
             if g_strctParadigm.m_iTriggerCounter == 0
                g_strctParadigm.m_iMachineState = 200;
             else
                 g_strctParadigm.m_iMachineState = 2;
             end
         end
    case 'fMRI_Mode_Toggle'
        g_strctParadigm.m_bMRI_Mode = get( g_strctParadigm.m_strctDesignControllers.m_hfMRI_Mode,'value');
        if g_strctParadigm.m_bMRI_Mode
            
            % Verify that the design has specified block length in number
            % of TRs....
            
            if ~isfield(g_strctParadigm.m_strctDesign.m_strctOrder,'m_acNumTRsPerBlock')
                fnParadigmToKofikoComm('DisplayMessage', 'Design do not support fMRI');
                set( g_strctParadigm.m_strctDesignControllers.m_hfMRI_Mode,'value',0);
                return;
            end;
            
    
            
            
            fnParadigmToStimulusServer('AbortTrial');
            g_strctParadigm.m_iMachineState = 200;
        else
            fnParadigmToStimulusServer('AbortTrial');
            g_strctParadigm.m_iMachineState = 2;
        end
    case 'ChangeTR'
        fNewTRValue = str2num(get(g_strctParadigm.m_strctDesignControllers.m_hChangeTRValue,'string'));
        if isreal(fNewTRValue) && ~isnan(fNewTRValue)
            fnTsSetVarParadigm( 'TR',fNewTRValue);
            [strctCurrentTrial,strWhatHappened] =  fnParadigmTouchForceChoicePrepareTrial();
            if ~isempty(strctCurrentTrial)
                g_strctParadigm.m_strctCurrentTrial = strctCurrentTrial;
            end
            
        else
            fOldTRValue = fnTsGetVar(g_strctParadigm,'TR');
            set(g_strctParadigm.mn_strctDesignControllers.m_hChangeTRValue,'string',num2str(fOldTRValue));
        end
    case 'SimulateTrig'
            g_strctParadigm.m_iTriggerCounter = 1;
            g_strctParadigm.m_fFirstTriggerTS = GetSecs();
            fnParadigmToKofikoComm('StartRecording',0);
            % Force abort trial because we start a new fMRI run
            g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = 1;
            g_strctParadigm.m_bTrialRepetitionOFF = true;
            g_strctParadigm.m_iMachineState = 2;
        
    case 'Abort_fMRI_Run'
         g_strctParadigm.m_iMachineState = 201;
    case 'ReplotStat'
            fnUpdateStatAux();
    otherwise
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
end;


return;


function fnLoadDesignAux(strNextList)
global g_strctParadigm g_strctPTB
% If not available in the favorite list, add it!

iIndex = -1;
for k=1:length(g_strctParadigm.m_acFavroiteLists)
    if strcmpi(g_strctParadigm.m_acFavroiteLists{k}, strNextList)
        iIndex = k;
        break;
    end
end
if iIndex == -1
    % Not found, add!
    g_strctParadigm.m_acFavroiteLists = [strNextList,g_strctParadigm.m_acFavroiteLists];
    set(g_strctParadigm.m_strctDesignControllers.m_hFavroiteLists,'String',fnCellToCharShort(g_strctParadigm.m_acFavroiteLists),'value',1);
else
    set(g_strctParadigm.m_strctDesignControllers.m_hFavroiteLists,'value',iIndex);
end

if isfield(g_strctParadigm,'m_strctDesign') && ~isempty(g_strctParadigm.m_strctDesign)
    bSameDesignName = strcmp(strNextList,g_strctParadigm.m_strctDesign.m_strDesignFileName);
else
    bSameDesignName = false;
end;
fnParadigmToStimulusServer('AbortTrial');
fnParadigmToKofikoComm('JuiceOff');
fnParadigmToKofikoComm('DisplayMessageNow','Loading XML file');
strctDesign = fnLoadForceChoiceNewDesignFile(strNextList);
if isempty(strctDesign)
    fnParadigmToKofikoComm('DisplayMessage','Failed to parse XML design file');
    % Restore the previous selected design in the list box
    if ~isempty(g_strctParadigm.m_strctDesign)
        iFallbackIndex = find(ismember(g_strctParadigm.m_acFavroiteLists,g_strctParadigm.m_strctDesign.m_strDesignFileName));
        set(g_strctParadigm.m_strctDesignControllers.m_hFavroiteLists,'value',iFallbackIndex);
    end
    return;
end



% Send this information to statistics server
if fnParadigmToStatServerComm('IsConnected')
    fnParadigmToStatServerComm('SendDesign', strctDesign.m_strctStatServerDesign);
end

g_strctParadigm.m_strctDesign = strctDesign;
g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = 0;


feval(g_strctParadigm.m_strCallbacks,'ResetDesignStat');

bResetGlobalVars = get(g_strctParadigm.m_strctDesignControllers.m_hResetGlobalVars,'value');
if ~bSameDesignName
    bResetGlobalVars = true; % Always reset global variables when loading a design with a different name!
end;

fnAddTimeStampedVariablesFromDesignToParadigmStructure(strctDesign,bResetGlobalVars);

fnTsSetVarParadigm('ExperimentDesigns',g_strctParadigm.m_strctDesign);

% Instruct stimulus server to load media if not on the fly
% mode....
if ~g_strctParadigm.m_strctDesign.m_bLoadOnTheFly
    if fnParadigmToKofikoComm('IsTouchMode')
        fnParadigmTouchForceChoiceDrawCycle({'LoadMedia', g_strctParadigm.m_strctDesign.m_astrctMedia});
        g_strctParadigm.m_bStimulusServerLoadedMedia = true;
    else
        fnParadigmToStimulusServer('LoadMedia', g_strctParadigm.m_strctDesign.m_astrctMedia);
        if ~isempty(g_strctParadigm.m_acMedia)
            fnReleaseMedia(g_strctParadigm.m_acMedia);
        end
        g_strctParadigm.m_acMedia = fnLoadMedia(g_strctPTB.m_hWindow,g_strctParadigm.m_strctDesign.m_astrctMedia,true);
        g_strctParadigm.m_bStimulusServerLoadedMedia = false;
    end
else
    g_strctParadigm.m_bStimulusServerLoadedMedia = true;
end
 fnUpdateForceChoiceDesignTable();
 
 
 %%
    if isfield(g_strctParadigm.m_strctDesign.m_strctOrder,'m_acNumTRsPerBlock')
        % Special operation using Number of TRs per block....
        
        iNumBlocks = length(g_strctParadigm.m_strctDesign.m_strctOrder.m_acNumTRsPerBlock);
        % Parse the number of TRs....
        aiNumTRs = zeros(1,iNumBlocks);
        for k=1:iNumBlocks
            aiNumTRs(k) = fnParseVariable(g_strctParadigm.m_strctDesign.m_strctOrder,'m_acNumTRsPerBlock',0,k);
        end
        fTS_Sec = fnTsGetVar(g_strctParadigm, 'TR') / 1e3;
        g_strctParadigm.m_aiCumulativeTRs = cumsum(aiNumTRs);
        set(g_strctParadigm.m_strctDesignControllers.m_hTotalNumberOfTRs,'String', sprintf('#TRs in design: %d', g_strctParadigm.m_aiCumulativeTRs(end)));
    else
        set(g_strctParadigm.m_strctDesignControllers.m_hTotalNumberOfTRs,'String', sprintf('#TRs in design: NaN'));
    end 
 %%
 
 
if fnParadigmToKofikoComm('IsPaused')
    % Important, otherwise we won't get the message saying data was loaded!
    fnResumeParadigm();
    g_strctParadigm.m_iMachineState = 0;
end    

if g_strctParadigm.m_iMachineState > 0
    g_strctParadigm.m_iMachineState = 1;
end

g_strctParadigm.m_iTrialCounter = 1;
g_strctParadigm.m_iTrialRep = 0;

g_strctParadigm.m_strctCurrentTrial = [];


if isfield(strctDesign.m_strctOrder,'m_acNumTRsPerBlock')
    % Automatically activate fMRI block mode.
    set( g_strctParadigm.m_strctDesignControllers.m_hfMRI_Mode,'value',1);
    fnParadigmTouchForceChoiceCallbacks('fMRI_Mode_Toggle');
end
    
return;


function acResult = fnPrepareSummaryResults()
global g_strctParadigm
iNumTrialsAllDesigns = g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTrials;
acResult{1} = 'Global Statistics:';
acResult{2} = sprintf('Num Trials : %d', iNumTrialsAllDesigns);
acResult{3} = sprintf('Num Correct    : %d (%.2f%%)', g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumCorrect, g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumCorrect/iNumTrialsAllDesigns*100);
acResult{4} = sprintf('Num Incorrect  : %d (%.2f%%)', g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumIncorrect, g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumIncorrect/iNumTrialsAllDesigns*100);
acResult{5} = sprintf('Num Timeout    : %d (%.2f%%)', g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTimeout, g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumTimeout/iNumTrialsAllDesigns*100);
acResult{6} = sprintf('Num Aborted    : %d (%.2f%%)', g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumAborted, g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumAborted/iNumTrialsAllDesigns*100);
iNumTrials=g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumCorrect+g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumIncorrect;
acResult{7} = sprintf('* No Aborted/Timeout Stats:');
acResult{8} = sprintf('  Correct (%.2f%%)', g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumCorrect/iNumTrials*100);
acResult{9} = sprintf('  Incorrect (%.2f%%)', g_strctParadigm.m_strctStatistics.m_strctAllDesigns.m_iNumIncorrect/iNumTrials*100);


return;


function fnUpdateStatAux()
global g_strctParadigm
iNumTrialTypes = length(g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumCorrect);
a2cStatTable = cell(iNumTrialTypes,6);
acTrialName = cell(1,iNumTrialTypes);
bPercent = get(g_strctParadigm.m_strctStatControllers.m_hPercentCheckBox,'value')>0;
for k=1:iNumTrialTypes
    acTrialName{k} = g_strctParadigm.m_strctDesign.m_acTrialTypes{k}.TrialParams.Name;
    a2cStatTable{k,1} = acTrialName{k};
    iTotal = g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumCorrect(k) + ...
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumIncorrect(k) + ...
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTimeout(k) + ...
        g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumAborted(k);
    
    if bPercent
        a2cStatTable{k,2} = sprintf('%d', round(g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumCorrect(k)/iTotal*1e2));
        a2cStatTable{k,3} = sprintf('%d', round(g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumIncorrect(k)/iTotal*1e2));
        a2cStatTable{k,4} = sprintf('%d', round(g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTimeout(k)/iTotal*1e2));
        a2cStatTable{k,5} = sprintf('%d', round(g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumAborted(k)/iTotal*1e2));
        a2cStatTable{k,6} = '100';
    else
        a2cStatTable{k,2} = sprintf('%d',g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumCorrect(k));
        a2cStatTable{k,3} = sprintf('%d',g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumIncorrect(k));
        a2cStatTable{k,4} = sprintf('%d',g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumTimeout(k));
        a2cStatTable{k,5} = sprintf('%d',g_strctParadigm.m_strctStatistics.m_strctCurrentDesign.m_aiNumAborted(k));
        a2cStatTable{k,6} = sprintf('%d',iTotal);
    end
    
    
end
set(g_strctParadigm.m_strctStatControllers.m_hStatTable,'RowName',[],'ColumnName',{'Name','Correct','Incorrect','Timeout','Aborted','Total'},'Data',a2cStatTable,'ColumnWidth',{150 30 30 30 30});
set(g_strctParadigm.m_strctStatControllers.m_hStatText,'String',fnPrepareSummaryResults());
return;
