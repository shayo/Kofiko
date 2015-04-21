function fnParadigmFiveDotCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctEyeCalib g_strctParadigm g_strctStimulusServer 


switch strCallback
        case 'Start'
        g_strctParadigm.m_iMachineState = 1;


    case 'GazeSlider'
        iNewGazeTimeMS = round(get(g_strctParadigm.m_strctControllers.m_hGazeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hGazeEdit,'String',num2str(iNewGazeTimeMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeMS);
        fnDAQWrapper('StrobeWord', fnFindCode('Gaze Time Changed'));                
        fnLog('Setting gaze to %d', iNewGazeTimeMS);
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        iGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
        if iNewGazeTimeMS < iGazeTimeLowMS
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeLowSlider, iNewGazeTimeMS);
            set(g_strctParadigm.m_strctControllers.m_hGazeLowEdit,'String',num2str(iNewGazeTimeMS));
        end

        
    case 'GazeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hGazeEdit,'string');
        iNewGazeTimeMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewGazeTimeMS)
             iGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
            if iNewGazeTimeMS < iGazeTimeLowMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeLowSlider, iNewGazeTimeMS);
                set(g_strctParadigm.m_strctControllers.m_hGazeLowEdit,'String',num2str(iNewGazeTimeMS));
            end
            g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeSlider, iNewGazeTimeMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeMS);
            fnDAQWrapper('StrobeWord', fnFindCode('Gaze Time Changed'));                
            fnLog('Setting gaze to %d', iNewGazeTimeMS);
        end;

        
    case 'GazeLowSlider'
        iNewGazeTimeLowMS = round(get(g_strctParadigm.m_strctControllers.m_hGazeLowSlider,'value'));
        iGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
        if iNewGazeTimeLowMS > iGazeTimeMS
           g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeLowMS);
           fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeSlider, iNewGazeTimeLowMS);  
           set(g_strctParadigm.m_strctControllers.m_hGazeEdit,'String',num2str(iNewGazeTimeLowMS));
        end
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        set(g_strctParadigm.m_strctControllers.m_hGazeLowEdit,'String',num2str(iNewGazeTimeLowMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeLowMS);
        fnLog('Setting low gaze time to %d', iNewGazeTimeLowMS);
    case 'GazeLowEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hGazeLowEdit,'string');
        iNewGazeTimeLowMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewGazeTimeLowMS)
           
            iGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
            if iNewGazeTimeLowMS > iGazeTimeMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeLowMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeSlider, iNewGazeTimeLowMS);
                set(g_strctParadigm.m_strctControllers.m_hGazeEdit,'String',num2str(iNewGazeTimeLowMS));
            end

            g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeLowSlider, iNewGazeTimeLowMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeLowMS);
            fnLog('Setting low gaze time to %d', iNewGazeTimeLowMS);
        end;
        
        
  case 'PositiveIncSlider'
        iNewPositiveInc = round(get(g_strctParadigm.m_strctControllers.m_hPositiveIncSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hPositiveIncEdit,'String',num2str(iNewPositiveInc));
        g_strctParadigm= fnTsSetVar(g_strctParadigm,'PositiveIncrement',iNewPositiveInc);
        fnLog('Setting positive increment percentage to %d ', iNewPositiveInc);
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
    case 'PositiveIncEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hPositiveIncEdit,'string');
        iNewPositiveInc = fnMyStr2Num(strTemp);
        if ~isempty(iNewPositiveInc)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hPositiveIncSlider, iNewPositiveInc);
            g_strctParadigm= fnTsSetVar(g_strctParadigm,'PositiveIncrement',iNewPositiveInc);
             fnLog('Setting positive increment percentage to %d ', iNewPositiveInc);
             g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        end;
        
        
  case 'BlinkTimeSlider'
        iNewBlinkTime = round(get(g_strctParadigm.m_strctControllers.m_hBlinkTimeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hBlinkTimeEdit,'String',num2str(iNewBlinkTime));
        g_strctParadigm= fnTsSetVar(g_strctParadigm,'BlinkTimeMS',iNewBlinkTime);
        fnLog('Setting Blink time to %d ms', iNewBlinkTime);
    case 'BlinkTimeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hBlinkTimeEdit,'string');
        iNewBlinkTime = fnMyStr2Num(strTemp);
        if ~isempty(iNewBlinkTime)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBlinkTimeSlider, iNewBlinkTime);
            g_strctParadigm= fnTsSetVar(g_strctParadigm,'BlinkTimeMS',iNewBlinkTime);
            fnLog('Setting Blink time to %d ms', iNewBlinkTime);
        end;

        

    case 'FixationSizeSlider'
        % fnDAQWrapper('StrobeWord', New Fixation spot size);
        iNewFixationSizePix = round(get(g_strctParadigm.m_strctControllers.m_hFixationSizeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hFixationSizeEdit,'String',num2str(iNewFixationSizePix));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(...
            g_strctParadigm.m_strctStimulusParams,'FixationSizePix',iNewFixationSizePix);
        fnLog('Setting fixation spot to %d pixels', iNewFixationSizePix);

        pt2iCurrFixationSpot = g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);
        afBackgroundColor = ...
            squeeze(g_strctParadigm.m_strctStimulusParams.BackgroundColor.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.BackgroundColor.BufferIdx));
        fnParadigmToStimulusServer('Display',pt2iCurrFixationSpot, iNewFixationSizePix,afBackgroundColor);

    case 'FixationSizeEdit'
        % fnDAQWrapper('StrobeWord', New Fixation spot size);
        strTemp = get(g_strctParadigm.m_strctControllers.m_hFixationSizeEdit,'string');
        iNewFixationSizePix = fnMyStr2Num(strTemp);
        if ~isempty(iNewFixationSizePix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hFixationSizeSlider, iNewFixationSizePix);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(...
                g_strctParadigm.m_strctStimulusParams,'FixationSizePix',iNewFixationSizePix);
            fnLog('Setting fixation spot to %d pixels', iNewFixationSizePix);
            pt2iCurrFixationSpot = g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);
            afBackgroundColor = ...
                squeeze(g_strctParadigm.m_strctStimulusParams.BackgroundColor.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.BackgroundColor.BufferIdx));
            fnParadigmToStimulusServer('Display',pt2iCurrFixationSpot, iNewFixationSizePix,afBackgroundColor);
        end;
        

    case 'StimulusONSlider'
        iStimulusONTime = round(get(g_strctParadigm.m_strctControllers.m_hStimulusONSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hStimulusONEdit,'String',num2str(iStimulusONTime));

        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams ,'StimulusON_MS',iStimulusONTime);
        fnLog('Setting new stimulus ON time to %d ms', iStimulusONTime);
        if g_strctParadigm.m_iMachineState > 0
            g_strctParadigm.m_iMachineState = 1;
        end;
    case 'StimulusONEdit'
         strTemp = get(g_strctParadigm.m_strctControllers.m_hStimulusONEdit,'string');
        iStimulusONTime = fnMyStr2Num(strTemp);
        if ~isempty(iStimulusONTime)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hStimulusONSlider, iStimulusONTime);
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams ,'StimulusON_MS',iStimulusONTime);
            fnLog('Setting new stimulus ON time to %d ms', iStimulusONTime);
            if g_strctParadigm.m_iMachineState > 0
                g_strctParadigm.m_iMachineState = 1;
            end;
        end;


    case 'GazeRectSlider'
        % fnDAQWrapper('StrobeWord', );
        iGazeBoxPix = round(get(g_strctParadigm.m_strctControllers.m_hGazeRectSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hGazeRectEdit,'String',num2str(iGazeBoxPix));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'GazeBoxPix',iGazeBoxPix);
        fnLog('Setting new gaze reward area to %d pix', iGazeBoxPix);
    case 'GazeRectEdit'
        % fnDAQWrapper('StrobeWord', );
        strTemp = get(g_strctParadigm.m_strctControllers.m_hGazeRectEdit,'string');
        iGazeBoxPix = fnMyStr2Num(strTemp);
        if ~isempty(iGazeBoxPix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeRectSlider, iGazeBoxPix);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'GazeBoxPix',iGazeBoxPix);
            fnLog('Setting new gaze reward area to %d pix', iGazeBoxPix);
        end;


    case 'SpreadSlider'
        % fnDAQWrapper('StrobeWord', );
        iSpreadPix = round(get(g_strctParadigm.m_strctControllers.m_hSpreadSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hSpreadEdit,'String',num2str(iSpreadPix));
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'SpreadPix',iSpreadPix);
        if g_strctParadigm.m_iMachineState > 0 
            g_strctParadigm.m_iMachineState = 1;        
        end;
        fnLog('Setting new fixation spread to %d pix', iSpreadPix);
    case 'SpreadEdit'
        % fnDAQWrapper('StrobeWord', );
        strTemp = get(g_strctParadigm.m_strctControllers.m_hSpreadEdit,'string');
        iSpreadPix = fnMyStr2Num(strTemp);
        if ~isempty(iSpreadPix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hSpreadSlider, iSpreadPix);
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'SpreadPix',iSpreadPix);
            if g_strctParadigm.m_iMachineState > 0
                g_strctParadigm.m_iMachineState = 1;        
            end;
            fnLog('Setting new fixation spread to %d pix', iSpreadPix);
        end;

%     case 'JuiceTimeSlider'
%         % fnDAQWrapper('StrobeWord', );
%         iJuiceTime = round(get(g_strctParadigm.m_strctControllers.m_hJuiceTimeSlider,'value'));
%         set(g_strctParadigm.m_strctControllers.m_hJuiceTimeEdit,'String',num2str(iJuiceTime));
%         g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iJuiceTime);
%         fnLog('Setting new juice time to %d ms', iJuiceTime);
%     case 'JuiceTimeEdit'
%         % fnDAQWrapper('StrobeWord', );
%         strTemp = get(g_strctParadigm.m_strctControllers.m_hJuiceTimeEdit,'string');
%         iJuiceTime = fnMyStr2Num(strTemp);
%         if ~isempty(iJuiceTime)
%             fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceTimeSlider, iJuiceTime);
%             g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iJuiceTime);
%             fnLog('Setting new juice time to %d ms', iJuiceTime);
%         end;

   case 'JuiceSlider'
        iNewJuiceTimeMS = round(get(g_strctParadigm.m_strctControllers.m_hJuiceSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_hJuiceEdit,'String',num2str(iNewJuiceTimeMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeMS);
        fnDAQWrapper('StrobeWord', fnFindCode('Juice Time Changed'));                
        fnLog('Setting Juice to %d', iNewJuiceTimeMS);
        
        iJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
        if iNewJuiceTimeMS > iJuiceTimeHighMS
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceHighSlider, iNewJuiceTimeMS);
            set(g_strctParadigm.m_strctControllers.m_hJuiceHighEdit,'String',num2str(iNewJuiceTimeMS));
        end

        
    case 'JuiceEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hJuiceEdit,'string');
        iNewJuiceTimeMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewJuiceTimeMS)
             iJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
            if iNewJuiceTimeMS > iJuiceTimeHighMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceHighSlider, iNewJuiceTimeMS);
                set(g_strctParadigm.m_strctControllers.m_hJuiceHighEdit,'String',num2str(iNewJuiceTimeMS));
            end
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceSlider, iNewJuiceTimeMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeMS);
            fnDAQWrapper('StrobeWord', fnFindCode('Juice Time Changed'));                
            fnLog('Setting Juice to %d', iNewJuiceTimeMS);
        end;

        
    case 'JuiceHighSlider'
        iNewJuiceTimeHighMS = round(get(g_strctParadigm.m_strctControllers.m_hJuiceHighSlider,'value'));
        iJuiceTimeMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
        if iNewJuiceTimeHighMS < iJuiceTimeMS
           g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeHighMS);
           fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceSlider, iNewJuiceTimeHighMS);  
           set(g_strctParadigm.m_strctControllers.m_hJuiceEdit,'String',num2str(iNewJuiceTimeHighMS));
        end
        
        set(g_strctParadigm.m_strctControllers.m_hJuiceHighEdit,'String',num2str(iNewJuiceTimeHighMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeHighMS);
        fnLog('Setting High Juice time to %d', iNewJuiceTimeHighMS);
    case 'JuiceHighEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hJuiceHighEdit,'string');
        iNewJuiceTimeHighMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewJuiceTimeHighMS)
           
            iJuiceTimeMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
            if iNewJuiceTimeHighMS < iJuiceTimeMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeHighMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceSlider, iNewJuiceTimeHighMS);
                set(g_strctParadigm.m_strctControllers.m_hJuiceEdit,'String',num2str(iNewJuiceTimeHighMS));
            end

            
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceHighSlider, iNewJuiceTimeHighMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeHighMS);
            fnLog('Setting High Juice time to %d', iNewJuiceTimeHighMS);
        end;
                
    case 'EyeXGainSlider'
        % fnDAQWrapper('StrobeWord', );
        fGainX = get(g_strctParadigm.m_strctControllers.m_hEyeXGainSlider,'value');
        if ~isempty(fGainX)
            if fGainX == 0
                fGainX = 0.05;
            end;
            set(g_strctParadigm.m_strctControllers.m_hEyeXGainEdit,'String',num2str(fGainX));
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainX', fGainX);
            fnLog('Setting new eye X gain %.2f', fGainX);
        end;
    case 'EyeXGainEdit'
        % fnDAQWrapper('StrobeWord', );
        strTemp = get(g_strctParadigm.m_strctControllers.m_hEyeXGainEdit,'string');
        fGainX = fnMyStr2Num(strTemp);
        if ~isempty(fGainX)
            if fGainX == 0
                fGainX = 0.05;
            end;
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hEyeXGainSlider, fGainX);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainX', fGainX);
            fnLog('Setting new eye X gain %.2f', fGainX);
        end;

    case 'EyeYGainSlider'
        % fnDAQWrapper('StrobeWord', );
        fGainY = get(g_strctParadigm.m_strctControllers.m_hEyeYGainSlider,'value');
        if ~isempty(fGainY)
            if fGainY == 0
                fGainY = 0.05;
            end;
            set(g_strctParadigm.m_strctControllers.m_hEyeYGainEdit,'String',num2str(fGainY));
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainY', fGainY);
            fnLog('Setting new eye Y gain %.2f', fGainY);
        end;
    case 'EyeYGainEdit'
        % fnDAQWrapper('StrobeWord', );
        strTemp = get(g_strctParadigm.m_strctControllers.m_hEyeYGainEdit,'string');
        fGainY = fnMyStr2Num(strTemp);
        if length(fGainY) ~= 1
            return;
        end;
        if ~isempty(fGainY)  
            if fGainY == 0
                fGainY = 0.05;
            end;
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hEyeYGainSlider, fGainY);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainY', fGainY);
            fnLog('Setting new eye Y gain %.2f', fGainY);
        end;
    case 'DrawAttention'
        fnLog('Trying to draw subject''s attention');
        fnDrawAttention();
         g_strctParadigm.m_iMachineState = 1;
    case 'FreePoint'
        if g_strctParadigm.m_iMachineState > 0
            if g_strctParadigm.m_bUpdateFixationSpot
                g_strctParadigm.m_bUpdateFixationSpot = false;
                set( g_strctParadigm.m_strctControllers.m_hFixationSpotChange,'String','Free Point','fontweight','normal');
            else
                g_strctParadigm.m_pt2iUserDefinedSpot = g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);
                g_strctParadigm.m_bUpdateFixationSpot = true;
                g_strctParadigm.m_iMachineState = 1;
                set( g_strctParadigm.m_strctControllers.m_hFixationSpotChange,'String','Updating Fixation Spot','fontweight','bold');
            end;
        end
    case 'BackgroundColor'
        
        bParadigmPaused = fnParadigmToKofikoComm('IsPaused');
     
        if ~bParadigmPaused  
            bPausing = true;
            fnPauseParadigm()
        else
            bPausing = false;
        end

        fnHidePTB();
        aiColor  = uisetcolor();
        fnShowPTB();
        if length(aiColor) > 1
            g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'BackgroundColor',round(aiColor*255));
        end;
        if g_strctParadigm.m_iMachineState >0
            g_strctParadigm.m_iMachineState = 1;
        end
        if bPausing
            fnResumeParadigm();
        end

        
        
    case 'EyeTrace'
      if g_strctParadigm.m_strctStimulusParams.m_bShowEyeTraces
          g_strctParadigm.m_strctStimulusParams.m_bShowEyeTraces = false;
          set(g_strctParadigm.m_strctControllers.m_hEyeTraceButton,'fontweight','normal');
          fnParadigmToKofikoComm('HideEyeTraces');
          fnParadigmToKofikoComm('ClearEyeTraces');
      else
          g_strctParadigm.m_strctStimulusParams.m_bShowEyeTraces = true;
          set(g_strctParadigm.m_strctControllers.m_hEyeTraceButton,'fontweight','bold');
          fnParadigmToKofikoComm('ShowEyeTraces');
      end;
    case 'MotionStarted'
        g_strctParadigm.m_iMachineState = 0;
        fnParadigmToStimulusServer('ClearScreen');
    case 'MotionFinished'
        if ~fnParadigmToKofikoComm('IsPaused')
            g_strctParadigm.m_iMachineState = 1;
        end
    otherwise
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
         
end;


return;
