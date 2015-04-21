function fnParadigmClassificationImageCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer  g_strctNoise

switch strCallback
    case 'Start'
        g_strctParadigm.m_iMachineState = 1;
    case 'LoadList'
        fnParadigmToStimulusServer('PauseButRecvCommands');
        fnHidePTB();
        [strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt']);
        fnShowPTB()
        if strFile(1) ~= 0
            g_strctParadigm.m_strNextImageList = [strPath,strFile];
            g_strctParadigm.m_iMachineState = 6; %              fnLoadImageListAux(strImageList);
        end;
   case 'Random'
 
        if g_strctParadigm.m_bRandom 
            fnLog('Turning random OFF');
            set(g_strctParadigm.m_strctControllers.m_hRandom,'String','Random is OFF','FontWeight','normal');
            g_strctParadigm.m_bRandom  = false;
        else
            fnLog('Turning random ON');
            set(g_strctParadigm.m_strctControllers.m_hRandom,'String','Random is ON','FontWeight','bold');
            g_strctParadigm.m_bRandom  = true;
            g_strctParadigm.m_iStimuliCounter = 1;  % This will generate new random indices 
        end;

    case 'GazeSlider'
        iNewGazeTimeMS = round(get(g_strctParadigm.m_strctControllers.m_hGazeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hGazeEdit,'String',num2str(iNewGazeTimeMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeMS);
        fnDAQWrapper('StrobeWord', fnFindCode('Gaze Time Changed'));                
        fnLog('Setting gaze to %d', iNewGazeTimeMS);
        
    case 'GazeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hGazeEdit,'string');
        iNewGazeTimeMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewGazeTimeMS)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeSlider, iNewGazeTimeMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeMS);
            fnDAQWrapper('StrobeWord', fnFindCode('Gaze Time Changed'));                
            fnLog('Setting gaze to %d', iNewGazeTimeMS);
        end;

    case 'FixationSizeSlider'
        iNewFixationSizePix = round(get(g_strctParadigm.m_strctControllers.m_hFixationSizeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hFixationSizeEdit,'String',num2str(iNewFixationSizePix));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'FixationSizePix',iNewFixationSizePix);
        fnDAQWrapper('StrobeWord', fnFindCode('Fixation Spot Size Changed'));                
        fnLog('Setting fixation spot to %d pixels', iNewFixationSizePix);
    case 'FixationSizeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hFixationSizeEdit,'string');
        iNewFixationSizePix = fnMyStr2Num(strTemp);
        if ~isempty(iNewFixationSizePix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hFixationSizeSlider, iNewFixationSizePix);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'FixationSizePix',iNewFixationSizePix);
            fnDAQWrapper('StrobeWord', fnFindCode('Fixation Spot Size Changed'));                
            fnLog('Setting fixation spot to %d pixels', iNewFixationSizePix);
        end;
        
    case 'StimulusONSlider'
        iStimulusONTime = round(get(g_strctParadigm.m_strctControllers.m_hStimulusONSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hStimulusONEdit,'String',num2str(iStimulusONTime));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'StimulusON_MS',iStimulusONTime);
        fnDAQWrapper('StrobeWord', fnFindCode('Stimulus ON Time Changed'));                
        fnLog('Setting new stimulus ON time to %d ms', iStimulusONTime);
    case 'StimulusONEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hStimulusONEdit,'string');
        iStimulusONTime = fnMyStr2Num(strTemp);
        if ~isempty(iStimulusONTime)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hStimulusONSlider, iStimulusONTime);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'StimulusON_MS',iStimulusONTime);
            fnDAQWrapper('StrobeWord', fnFindCode('Stimulus ON Time Changed'));                
            fnLog('Setting new stimulus ON time to %d ms', iStimulusONTime);
        end;
        
    case 'StimulusOFFSlider'
        iStimulusOFFTime = round(get(g_strctParadigm.m_strctControllers.m_hStimulusOFFSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hStimulusOFFEdit,'String',num2str(iStimulusOFFTime));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'StimulusOFF_MS',iStimulusOFFTime);
        fnDAQWrapper('StrobeWord', fnFindCode('Stimulus OFF Time Changed'));                
        fnLog('Setting new stimulus OFF time to %d ms', iStimulusOFFTime);
    case 'StimulusOFFEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hStimulusOFFEdit,'string');
        iStimulusOFFTime = fnMyStr2Num(strTemp);
        if ~isempty(iStimulusOFFTime)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hStimulusOFFSlider, iStimulusOFFTime);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'StimulusOFF_MS',iStimulusOFFTime);
            fnDAQWrapper('StrobeWord', fnFindCode('Stimulus OFF Time Changed'));                
            fnLog('Setting new stimulus OFF time to %d ms', iStimulusOFFTime);
        end;
        
        
        
   case 'RotationAngleSlider'
        iRotationAngle = round(get(g_strctParadigm.m_strctControllers.m_hRotationAngleSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hRotationAngleEdit,'String',num2str(iRotationAngle));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'RotationAngle',iRotationAngle);
        fnDAQWrapper('StrobeWord', fnFindCode('Rotation Angle Changed'));                
        fnLog('Setting Rotation Angle to %d deg', iRotationAngle);
    case 'RotationAngleEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hRotationAngleEdit,'string');
        iRotationAngle = fnMyStr2Num(strTemp);
        if ~isempty(iRotationAngle)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hRotationAngleSlider, iRotationAngle);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'RotationAngle',iRotationAngle);
            fnDAQWrapper('StrobeWord', fnFindCode('Rotation Angle Changed'));                
            fnLog('Setting Rotation Angle to %d deg', iRotationAngle);
        end;
        

   case 'NoiseLevelSlider'
        iNoiseLevel = round(get(g_strctParadigm.m_strctControllers.m_hNoiseLevelSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hNoiseLevelEdit,'String',num2str(iNoiseLevel));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'NoiseLevel',iNoiseLevel);
        fnLog('Setting Noise Level to %d ', iNoiseLevel);
    case 'NoiseLevelEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hNoiseLevelEdit,'string');
        iNoiseLevel = fnMyStr2Num(strTemp);
        if ~isempty(iNoiseLevel)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hNoiseLevelSlider, iNoiseLevel);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'NoiseLevel',iNoiseLevel);
            fnLog('Setting Noise Level to %d ', iNoiseLevel);
        end;
        
   case 'GazeRectSlider'
        iGazeBoxPix = round(get(g_strctParadigm.m_strctControllers.m_hGazeRectSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hGazeRectEdit,'String',num2str(iGazeBoxPix));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'GazeBoxPix',iGazeBoxPix);
        fnDAQWrapper('StrobeWord', fnFindCode('Gaze Reward Rect Changed'));                
        fnLog('Setting new gaze reward area to %d pix', iGazeBoxPix);
    case 'GazeRectEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hGazeRectEdit,'string');
        iGazeBoxPix = fnMyStr2Num(strTemp);
        if ~isempty(iGazeBoxPix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeRectSlider, iGazeBoxPix);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'GazeBoxPix',iGazeBoxPix);
            fnDAQWrapper('StrobeWord', fnFindCode('Gaze Reward Rect Changed'));                
            fnLog('Setting new gaze reward area to %d pix', iGazeBoxPix);
        end;
         
  case 'StimulusSizeSlider'
        iStimulusSizePix = round(get(g_strctParadigm.m_strctControllers.m_hStimulusSizeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hStimulusSizeEdit,'String',num2str(iStimulusSizePix));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'StimulusSizePix',iStimulusSizePix);
        fnDAQWrapper('StrobeWord', fnFindCode('Stimulus Size Changed'));                
        fnLog('Setting stimulus rect area to %d pix', iStimulusSizePix);
    case 'StimulusSizeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hStimulusSizeEdit,'string');
        iStimulusSizePix = fnMyStr2Num(strTemp);
        if ~isempty(iStimulusSizePix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hStimulusSizeSlider, iStimulusSizePix);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'StimulusSizePix',iStimulusSizePix);
            fnDAQWrapper('StrobeWord', fnFindCode('Stimulus Size Changed'));                
            fnLog('Setting stimulus rect area to %d pix', iStimulusSizePix);
        end;
        
  case 'JuiceTimeSlider'
        iNewJuiceTime = round(get(g_strctParadigm.m_strctControllers.m_hJuiceTimeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hJuiceTimeEdit,'String',num2str(iNewJuiceTime));
        g_strctParadigm= fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTime);
        fnDAQWrapper('StrobeWord', fnFindCode('Juice Time Changed'));                
        fnLog('Setting juice reward time to %d ms', iNewJuiceTime);
    case 'JuiceTimeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hJuiceTimeEdit,'string');
        iNewJuiceTime = fnMyStr2Num(strTemp);
        if ~isempty(iNewJuiceTime)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceTimeSlider, iNewJuiceTime);
            g_strctParadigm= fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTime);
            fnDAQWrapper('StrobeWord', fnFindCode('Juice Time Changed'));                
            fnLog('Setting juice reward time to %d ms', iNewJuiceTime);
        end;
        
        

  case 'ImageOffsetXSlider'
        iNewImageOffsetX = round(get(g_strctParadigm.m_strctControllers.m_hImageOffsetXSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hImageOffsetXEdit,'String',num2str(iNewImageOffsetX));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageOffsetX',iNewImageOffsetX);
        fnLog('Setting Image Offset to %d ms', iNewImageOffsetX);
    case 'ImageOffsetXEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hImageOffsetXEdit,'string');
        iNewImageOffsetX = fnMyStr2Num(strTemp);
        if ~isempty(iNewImageOffsetX)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hImageOffsetXSlider, iNewImageOffsetX);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageOffsetX',iNewImageOffsetX);
            fnLog('Setting Image Offset to %d ms', iNewImageOffsetX);
        end;

  case 'ImageOffsetYSlider'
        iNewImageOffsetY = round(get(g_strctParadigm.m_strctControllers.m_hImageOffsetYSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hImageOffsetYEdit,'String',num2str(iNewImageOffsetY));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageOffsetY',iNewImageOffsetY);
        fnLog('Setting Image Offset to %d ms', iNewImageOffsetY);
    case 'ImageOffsetYEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hImageOffsetYEdit,'string');
        iNewImageOffsetY = fnMyStr2Num(strTemp);
        if ~isempty(iNewImageOffsetY)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hImageOffsetYSlider, iNewImageOffsetY);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageOffsetY',iNewImageOffsetY);
            fnLog('Setting Image Offset to %d ms', iNewImageOffsetY);
        end;
        
  case 'ImageSizePixSlider'
        iNewImageSizePix = round(get(g_strctParadigm.m_strctControllers.m_hImageSizePixSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hImageSizePixEdit,'String',num2str(iNewImageSizePix));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageSizePix',iNewImageSizePix);
        fnLog('Setting Image Size to %d pix', iNewImageSizePix);
    case 'ImageSizePixEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hImageSizePixEdit,'string');
        iNewImageSizePix = fnMyStr2Num(strTemp);
        if ~isempty(iNewImageSizePix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hImageSizePixSlider, iNewImageSizePix);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageSizePix',iNewImageSizePix);
            fnLog('Setting Image Size to %d pix', iNewImageSizePix);
        end;        
        
        
    case 'BackgroundColor'
        
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
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'BackgroundColor',round(aiColor*255));
            %            fnDAQWrapper('StrobeWord', fnFindCode('Stimulus Position Changed'));
        end;
        if bPausing
            fnResumeParadigm();
        end

        
    case 'ResetStat'
        
        fnParadigmToKofikoComm('ResetStat'); 
        g_strctParadigm.m_iRepeatitionCount  = 0;        

    case 'StartRecording'   
        fnParadigmToKofikoComm('ResetStat'); 
        g_strctParadigm.m_iRepeatitionCount  = 0;        
%        set(g_strctParadigm.m_strctControllers.m_hLoadList,'enable','off');
    case 'StopRecording'   
%        set(g_strctParadigm.m_strctControllers.m_hLoadList,'enable','on');
    case 'ChangeParadigmMode'
        
        

        
        iNewParadigmMode = get(g_strctParadigm.m_strctControllers.m_hParadigmMode,'value');
        if iNewParadigmMode ~= 3
            fnTsSetVarParadigm('CurrParadigmMode', iNewParadigmMode);
        elseif isfield(g_strctParadigm,'m_afNeurometricCurve')
            fnTsSetVarParadigm('CurrParadigmMode', iNewParadigmMode);
        end
            
        g_strctParadigm.m_iMachineState = 1;
    case 'SelectImages'
        g_strctParadigm.m_aiSelectedImageList = get(g_strctParadigm.m_strctControllers.hImageList,'value');
        iNumImages = length(g_strctParadigm.m_aiSelectedImageList);
        % Generate a new set of random indices
        [afDummy, aiSortInd] = sort(rand(1,iNumImages));
        g_strctParadigm.m_aiCurrentRandIndices = g_strctParadigm.m_aiSelectedImageList(aiSortInd);
        g_strctParadigm.m_iStimuliCounter = 1;
        g_strctParadigm.m_iRepeatitionCount = 0;
       
        fnParadigmToKofikoComm('ResetStat');
    case 'RandFixationSpot'
        g_strctParadigm.m_bRandFixPos = ~g_strctParadigm.m_bRandFixPos;
        if g_strctParadigm.m_bRandFixPos
            set(g_strctParadigm.m_strctControllers.m_hRandomPosition,'FontWeight','bold');
        else
            set(g_strctParadigm.m_strctControllers.m_hRandomPosition,'FontWeight','normal');
            % return it to center....
            
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams, 'FixationSpotPix', ...
                g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            fnParadigmToKofikoComm('SetFixationPosition',g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            if g_strctParadigm.m_bRandFixSyncStimulus
                g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams, 'StimulusPos', ...
                    g_strctStimulusServer.m_aiScreenSize(3:4)/2);
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
        
    case 'RandFixationSync'
        g_strctParadigm.m_bRandFixSyncStimulus = ~g_strctParadigm.m_bRandFixSyncStimulus;
        
    case 'NoiseFile'
        fnParadigmToKofikoComm('JuiceOff');
        fnParadigmToStimulusServer('PauseButRecvCommands');
        fnHidePTB();
        [strPath,strFile] = fileparts(g_strctParadigm.m_strRandFile);
        [strFile, strPath] = uigetfile([strPath,'\*.mat']);
        if strFile(1) ~= 0
            strNewNoiseFile = [strPath,strFile];
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'RandFile',strNewNoiseFile);
             
            strctTmp = load(strNewNoiseFile,'a2fRand');
            g_strctNoise.m_a2fRand = strctTmp.a2fRand;
            clear strctTmp
            g_strctParadigm.m_iMachineState = 0;
        end;
        fnShowPTB()
    case 'ToggleUseTrigger'
        g_strctParadigm.m_bUseTriggerToStart = ~g_strctParadigm.m_bUseTriggerToStart;
    otherwise
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
end;

return;

