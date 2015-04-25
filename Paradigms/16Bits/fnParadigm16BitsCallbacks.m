function fnParadigm16BitsCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer  g_strctGUIParams g_strctCycle 

switch strCallback
    case 'BlockLoopingToggle'
        g_strctParadigm.m_bBlockLooping = get(g_strctParadigm.m_strctControllers.m_hLoopCurrentBlock,'value') > 0;
    case 'BlocksDoneAction'
        acOptions =get(g_strctParadigm.m_strctControllers.m_hBlocksDoneActionPopup,'String');
        iValue =get(g_strctParadigm.m_strctControllers.m_hBlocksDoneActionPopup,'value');
        g_strctParadigm.m_strBlockDoneAction = acOptions{iValue};
    case 'MicroStimFixedRateToggle'
        set(g_strctParadigm.m_strctControllers.m_hMicroStimPoissonRate,'value',0);
        bActive = get(g_strctParadigm.m_strctControllers.m_hMicroStimFixedRate,'value');
        if bActive
            % Turn on
            g_strctParadigm.m_strctMiroSctim.m_strMicroStimType = 'FixedRate';
            g_strctParadigm.m_strctMiroSctim.m_fMicroStimRateHz = 1/5;
            g_strctParadigm.m_strctMiroSctim.m_fNextStimTS = GetSecs();
            g_strctParadigm.m_strctMiroSctim.m_bActive = true;
        else
            % Turn off
            g_strctParadigm.m_strctMiroSctim.m_bActive = false;
        end
    case 'MicroStimPoissonRateToggle'
        set(g_strctParadigm.m_strctControllers.m_hMicroStimFixedRate,'value',0);
        bActive = get(g_strctParadigm.m_strctControllers.m_hMicroStimPoissonRate,'value');
        if bActive
            % Turn on
            g_strctParadigm.m_strctMiroSctim.m_strMicroStimType = 'Poisson';
            g_strctParadigm.m_strctMiroSctim.m_fMicroStimRateHz = 1/5;
            g_strctParadigm.m_strctMiroSctim.m_fNextStimTS = GetSecs();
            g_strctParadigm.m_strctMiroSctim.m_bActive = true;
            
        else
            % Turn off
            g_strctParadigm.m_strctMiroSctim.m_bActive = false;
        end
        
    case 'JumpToBlock'
        if isempty(g_strctParadigm.m_strctDesign)
            return;
        end;
        g_strctParadigm.m_iNumTimesBlockShown = 0;
        g_strctParadigm.m_iCurrentBlockIndexInOrderList = get(g_strctParadigm.m_strctControllers.m_hBlockLists,'value');
        g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
        iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
        iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
        if g_strctParadigm.m_bRandom
            [fDummy,g_strctParadigm.m_aiCurrentRandIndices] = sort(rand(1,iNumMediaInBlock));
        else
            g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
        end
    
    case 'LocalStereoMode'
         iNewStereoMode = get(g_strctParadigm.m_strctControllers.m_hLocalStereoModePopup,'value');
         acStereoModes = get(g_strctParadigm.m_strctControllers.m_hLocalStereoModePopup,'String');
         g_strctParadigm.m_strLocalStereoMode = acStereoModes{iNewStereoMode};
    case 'RepatNonFixatedToggle'
        g_strctParadigm.m_bRepeatNonFixatedImages=~g_strctParadigm.m_bRepeatNonFixatedImages;
    case 'NoiseOverlayToggle'
    bNoiseOverlayActive = fnTsGetVar('g_strctParadigm' , 'NoiseOverlayActive');
    bNoiseOverlayActive = ~bNoiseOverlayActive;
    fnTsSetVarParadigm('NoiseOverlayActive',bNoiseOverlayActive);
    
    if bNoiseOverlayActive
        if g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns > 0
            g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex = 1;
        end
        fnParadigmToKofikoComm('DisplayMessage', 'Resetting Noise Index');
    end
    case 'NoisePatternSwitch'
        iSelectedNoiseFile = get(g_strctParadigm.m_strctControllers.m_hNoisePatternPopup,'value');
        fnTsSetVarParadigm( 'NoiseFile', g_strctParadigm.m_acNoisePatternsFiles{iSelectedNoiseFile});
        strctTmp = load(['.\NoisePatterns\',g_strctParadigm.m_acNoisePatternsFiles{iSelectedNoiseFile}]);
        g_strctParadigm.m_a3fRandPatterns = strctTmp.a3fRand;
        g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns = size(g_strctParadigm.m_a3fRandPatterns,3);
        g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex = 0;
    
 
        
    case 'MicroStim'
        strctStimulation.m_iChannel = 1;
        strctStimulation.m_fDelayToTrigMS = 0;
        fnParadigmToKofikoComm('MultiChannelStimulation', strctStimulation);
    case 'JuicePanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','on');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');
    case 'DesignPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','on');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
    case 'MicrostimPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');        
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','on');
    case 'StimulusPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','on');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
    case 'FixationSizePix'
    case 'StimulusON_MS'
        ISI=1/g_strctStimulusServer.m_fRefreshRateHz*1e3;
         
        fStimulusON_MS = ISI*ceil(g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx)/ISI);
        fStimulusOFF_MS = ISI*ceil(g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx)/ISI);
        g_strctParadigm.m_strctStatServerDesign.TrialLengthSec = 1.1 * (fStimulusON_MS+fStimulusOFF_MS)/1e3; % multiple by 10% to account for possible jitter
        fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctStatServerDesign);        
        
    case 'StimulusOFF_MS'
        ISI=1/g_strctStimulusServer.m_fRefreshRateHz*1e3;
        
        fStimulusON_MS = ISI*ceil(g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx)/ISI);
        fStimulusOFF_MS = ISI*ceil(g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx)/ISI);
        g_strctParadigm.m_strctStatServerDesign.TrialLengthSec = 1.1 * (fStimulusON_MS+fStimulusOFF_MS)/1e3; % multiple by 10% to account for possible jitter
        
        fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctStatServerDesign);
        
    case 'RotationAngle'
        if g_strctParadigm.m_bParameterSweep
            fnInitializeParameterSweep();
        end
        
    case 'GazeBoxPix'
    case 'StimulusSizePix'
        if g_strctParadigm.m_bParameterSweep
            fnInitializeParameterSweep();
        end
        
    case 'BlinkTimeMS'
    case 'PositiveIncrement'
    case 'Resuming'
        if g_strctParadigm.m_iMachineState == 6
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'PhotoDiodeRectToggle'
        g_strctParadigm.m_bShowPhotodiodeRect = ~g_strctParadigm.m_bShowPhotodiodeRect;
    case 'Pausing'
    
    case 'LoadList'
        fnParadigmToKofikoComm('SafeCallback','LoadListSafe');
    case 'LoadListSafe'
        fnSafeLoadListAux();



%     case 'LFPStatToggle'
%         g_strctGUIParams.m_bShowLFPStat = ~g_strctGUIParams.m_bShowLFPStat;

    case 'Start'
        g_strctParadigm.m_iMachineState = 1;
        [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
        fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);

        g_strctParadigm.m_fLastFixatedTimer = GetSecs();
    case 'Random'
        g_strctParadigm.m_bRandom =  get(g_strctParadigm.m_strctControllers.m_hRandomImageIndex,'value');
        
        
        iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
        iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
        if g_strctParadigm.m_bRandom
                    [fDummy,g_strctParadigm.m_aiCurrentRandIndices] = sort(rand(1,iNumMediaInBlock));
        else
            g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
        end


    case 'GazeTimeMS'
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        iNewGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
        iGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
        if iNewGazeTimeMS < iGazeTimeLowMS
            fnTsSetVarParadigm('GazeTimeLowMS',iNewGazeTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeTimeLowMSSlider, iNewGazeTimeMS);
            set(g_strctParadigm.m_strctControllers.m_hGazeTimeLowMSEdit,'String',num2str(iNewGazeTimeMS));
        end

    case 'GazeTimeLowMS'
        iNewGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
        iGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
        if iNewGazeTimeLowMS > iGazeTimeMS
            fnTsSetVarParadigm('GazeTimeMS',iNewGazeTimeLowMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeTimeMSSlider, iNewGazeTimeLowMS);
            set(g_strctParadigm.m_strctControllers.m_hGazeTimeMSEdit,'String',num2str(iNewGazeTimeLowMS));
        end
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;

    case 'JuiceTimeMS'
        iNewJuiceTimeMS =  g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
        iJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
        if iNewJuiceTimeMS > iJuiceTimeHighMS
            fnTsSetVarParadigm('JuiceTimeHighMS',iNewJuiceTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceTimeHighMSSlider, iNewJuiceTimeMS);
            set(g_strctParadigm.m_strctControllers.m_hJuiceTimeHighMSEdit,'String',num2str(iNewJuiceTimeMS));
        end

    case 'JuiceTimeHighMS'
        iNewJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
        iJuiceTimeMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
        if iNewJuiceTimeHighMS < iJuiceTimeMS
            fnTsSetVarParadigm('JuiceTimeMS',iNewJuiceTimeHighMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceTimeMSSlider, iNewJuiceTimeHighMS);
            set(g_strctParadigm.m_strctControllers.m_hJuiceTimeMSEdit,'String',num2str(iNewJuiceTimeHighMS));
        end

    case 'FixationSpot'
        if g_strctParadigm.m_bUpdateFixationSpot
            g_strctParadigm.m_bUpdateFixationSpot = false;
            set( g_strctParadigm.m_strctControllers.m_hFixationSpotChange,'String','New Fixation Spot','fontweight','normal');
        else
            g_strctParadigm.m_bUpdateFixationSpot = true;
            set( g_strctParadigm.m_strctControllers.m_hFixationSpotChange,'String','Updating Fixation Spot','fontweight','bold');
        end;

    case 'StimulusPos'
        if g_strctParadigm.m_bUpdateStimulusPos
            g_strctParadigm.m_bUpdateStimulusPos = false;
            set( g_strctParadigm.m_strctControllers.m_hStimulusPosChange,'String','New Stimulus Pos','fontweight','normal');
        else
            g_strctParadigm.m_bUpdateStimulusPos = true;
            set( g_strctParadigm.m_strctControllers.m_hStimulusPosChange,'String','Updating Stimulus Pos','fontweight','bold');
        end;
        if g_strctParadigm.m_bParameterSweep
            fnInitializeParameterSweep();
        end

    case 'BackgroundColor'
        fnParadigmToKofikoComm('JuiceOff');
        bParadigmPaused = fnParadigmToKofikoComm('IsPaused');

        if ~bParadigmPaused
            bPausing = true;
            fnPauseParadigm()
        else
            bPausing = false;
        end


        fnShowHideWind('PTB Onscreen window [10]:','hide');
        aiColor  = uisetcolor();
        fnShowHideWind('PTB Onscreen window [10]:','show');
        if length(aiColor) > 1
            fnTsSetVarParadigm('BackgroundColor',round(aiColor*255));
            %            fnDAQWrapper('StrobeWord', fnFindCode('Stimulus Position Changed'));
        end;
        if bPausing
            fnResumeParadigm();
        end


    case 'ResetUnit'
        g_strctParadigm.m_strWhatToReset = 'Unit';
        set(g_strctParadigm.m_strctControllers.m_hResetUnit,'value',1);
        set(g_strctParadigm.m_strctControllers.m_hResetChannel,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetAllChannels,'value',0);
    case 'ResetChannel'
        g_strctParadigm.m_strWhatToReset = 'Channel';
        set(g_strctParadigm.m_strctControllers.m_hResetUnit,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetChannel,'value',1);
        set(g_strctParadigm.m_strctControllers.m_hResetAllChannels,'value',0);
    case 'ResetAllChannels'
        g_strctParadigm.m_strWhatToReset = 'AllChannels';
        set(g_strctParadigm.m_strctControllers.m_hResetUnit,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetChannel,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetAllChannels,'value',1);
    case 'ResetStat'
        fnParadigmToKofikoComm('ResetStat',g_strctParadigm.m_strWhatToReset);
        
    case 'StartRecording'
        fnParadigmToKofikoComm('ResetStat');

        
%        set(g_strctParadigm.m_strctControllers.m_hLoadList,'enable','off');
%        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'enable','off');
    case 'StopRecording'
%        set(g_strctParadigm.m_strctControllers.m_hLoadList,'enable','on');
%        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'enable','on');
        [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
        fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);
    case 'LoadFavoriteList'
        fnParadigmToKofikoComm('SafeCallback','LoadFavoriteListSafe');
    case 'LoadFavoriteListSafe'
        fnParadigmToKofikoComm('JuiceOff');
        iSelectedImageList = get(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'value');
        if ~fnLoadPassiveFixationDesign(g_strctParadigm.m_acFavroiteLists{iSelectedImageList});
            return;
        end
                
        [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
        fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);
        fnResetStat();
        
        g_strctParadigm.m_iNumTimesBlockShown = 0;
        g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
        g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
        g_strctParadigm.m_iCurrentOrder = 1;
        
        g_strctParadigm.m_strctCurrentTrial = [];
        
    case 'RandFixationSpot'
        g_strctParadigm.m_bRandFixPos = ~g_strctParadigm.m_bRandFixPos;
        if g_strctParadigm.m_bRandFixPos
            set(g_strctParadigm.m_strctControllers.m_hRandomPosition,'FontWeight','bold');
        else
            set(g_strctParadigm.m_strctControllers.m_hRandomPosition,'FontWeight','normal');
            % return it to center....
            fnTsSetVarParadigm('FixationSpotPix', g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            fnParadigmToKofikoComm('SetFixationPosition',g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            if g_strctParadigm.m_bRandFixSyncStimulus
                fnTsSetVarParadigm('StimulusPos', g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            end
        end;
    case 'RandFixationSpotMinEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hRandomPositionMinEdit,'string');
        iRandMin = fnMyStr2Num(strTemp);
        if ~isempty(iRandMin)
            g_strctParadigm.m_fRandFixPosMin = iRandMin;
            fnLog('Random fixation changes after at least %d images', iRandMin);
        end;
    case 'RandFixationSpotMaxEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hRandomPositionMaxEdit,'string');
        iRandMax = fnMyStr2Num(strTemp);
        if ~isempty(iRandMax)
            g_strctParadigm.m_fRandFixPosMax = iRandMax;
            fnLog('Random fixation changes after at max %d images', iRandMax);
        end;
    case 'RandFixationSpotRadiusEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hRandomPositionRadiusEdit,'string');
        iRandRadius = fnMyStr2Num(strTemp);
        if ~isempty(iRandRadius)
            g_strctParadigm.m_fRandFixRadius = iRandRadius;
            fnLog('Random fixation radius set to %d pixels', iRandRadius);
        end;
    case 'ParameterSweep'
        g_strctParadigm.m_bParameterSweep = get(g_strctParadigm.m_strctControllers.m_hParameterSweep,'value');
        if (g_strctParadigm.m_bParameterSweep)
            
           g_strctParadigm.m_strctSavedParam.m_pt2fStimulusPosition = fnTsGetVar('g_strctParadigm','StimulusPos');
           g_strctParadigm.m_strctSavedParam.m_fTheta = fnTsGetVar('g_strctParadigm','RotationAngle');
           g_strctParadigm.m_strctSavedParam.m_fSize = fnTsGetVar('g_strctParadigm','StimulusSizePix');
            
            fnInitializeParameterSweep();
            g_strctParadigm.m_iStimuliCounter = 1;
            g_strctParadigm.m_iMachineState = 1;
       
            
        else
            
            fnTsSetVarParadigm('StimulusPos',g_strctParadigm.m_strctSavedParam.m_pt2fStimulusPosition);
            fnTsSetVarParadigm('RotationAngle',g_strctParadigm.m_strctSavedParam.m_fTheta);
            fnTsSetVarParadigm('StimulusSizePix',g_strctParadigm.m_strctSavedParam.m_fSize);
            
        end
	% Changelog 10/21/13 josh - other components of FitToScreen setting	
	case 'FitToScreen'
		g_strctParadigm.m_bFitToScreen = get(g_strctParadigm.m_strctControllers.m_hFitToScreen, 'value');
		
	
	% End Changelog
    case 'RandFixationSync'
        g_strctParadigm.m_bRandFixSyncStimulus = ~g_strctParadigm.m_bRandFixSyncStimulus;

    case 'MotionStarted'
        g_strctParadigm.m_iMachineState = 0;
        fnParadigmToStimulusServer('PauseButRecvCommands');
        g_strctParadigm.m_bPausedDueToMotion = true;
    case 'MotionFinished'
        if ~fnParadigmToKofikoComm('IsPaused')
             g_strctParadigm.m_strctCurrentTrial = fnPassiveFixationPrepareTrial();
            g_strctParadigm.m_iMachineState = 1;
        end
        g_strctParadigm.m_bPausedDueToMotion = false;
    case 'HideNotLookingToggle'
        g_strctParadigm.m_bHideStimulusWhenNotLooking = ~g_strctParadigm.m_bHideStimulusWhenNotLooking;
        if ~g_strctParadigm.m_bHideStimulusWhenNotLooking
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'ParameterSweepMode'
        g_strctParadigm.m_iParameterSweepMode = get(g_strctParadigm.m_strctControllers.m_hParameterSweepPopup,'value');
        fnInitializeParameterSweep();
    case 'UpdateListFiringRate'
        [Dummy, acShortFileNames] = fnCellToCharShort(g_strctParadigm.m_acImageFileNames);
        
%         for k=1:length(acShortFileNames)
%             acShortFileNames{k} = sprintf('%.2f %s',...
%                 g_strctCycle.m_a2fAvgStimulusResponse(g_strctGUIParams.m_iSelectedChannelPSTH,k),acShortFileNames{k});
%         end
%          
%         set(g_strctParadigm.m_strctControllers.m_hImageList,'String',acShortFileNames);


    case 'PlayStimuliLocally'
        g_strctParadigm.m_bDisplayStimuliLocally = ~g_strctParadigm.m_bDisplayStimuliLocally;
    case 'ShowWhileLoading'
        g_strctParadigm.m_bShowWhileLoading = ~g_strctParadigm.m_bShowWhileLoading;
    case 'ForceStereoToggle'
         bForceStereo = fnTsGetVar('g_strctParadigm','ForceStereoOnMonocularLists') > 0;
         bForceStereo = ~bForceStereo;
         fnTsSetVarParadigm('ForceStereoOnMonocularLists',bForceStereo);
         set(g_strctParadigm.m_strctControllers.m_hForceStereoOnMonocularLists,'value',bForceStereo);
    case 'DrawAttentionEvent'
        g_strctParadigm.m_iMachineState = 1;

    otherwise
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
         
end;

return;

function fnSafeLoadListAux()
global g_strctParadigm
fnParadigmToKofikoComm('JuiceOff');
fnParadigmToStimulusServer('PauseButRecvCommands');
fnHidePTB();
[strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt;*.xml']);

fnShowPTB()
if strFile(1) ~= 0
    g_strctParadigm.m_strNextImageList = [strPath,strFile];
    
    if ~fnLoadPassiveFixationDesign(g_strctParadigm.m_strNextImageList);
        return;
    end;
    
    [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
    fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);

    % If not available in the favorite list, add it!
    iIndex = -1;
    for k=1:length(g_strctParadigm.m_acFavroiteLists)
        if strcmpi(g_strctParadigm.m_acFavroiteLists{k}, g_strctParadigm.m_strNextImageList)
            iIndex = k;
            break;
        end
    end


    if iIndex == -1
        % Not found, add!
        g_strctParadigm.m_acFavroiteLists = [g_strctParadigm.m_strNextImageList,g_strctParadigm.m_acFavroiteLists];
        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'String',fnCellToCharShort(g_strctParadigm.m_acFavroiteLists),'value',1);
    else
        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'value',iIndex);
    end
    
      

end;