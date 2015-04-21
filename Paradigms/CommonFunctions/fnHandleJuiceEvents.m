function bEventHandled = fnHandleJuiceEvents(strCallback,varargin)
global g_strctParadigm  

bEventHandled = true;
switch strCallback

    case 'GazeSlider'
        iNewGazeTimeMS = round(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeEdit,'String',num2str(iNewGazeTimeMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeMS);
        fnDAQWrapper('StrobeWord', fnFindCode('Gaze Time Changed'));                
        fnLog('Setting gaze to %d', iNewGazeTimeMS);
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        iGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
        if iNewGazeTimeMS < iGazeTimeLowMS
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowSlider, iNewGazeTimeMS);
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowEdit,'String',num2str(iNewGazeTimeMS));
        end

        
    case 'GazeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeEdit,'string');
        iNewGazeTimeMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewGazeTimeMS)
             iGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
            if iNewGazeTimeMS < iGazeTimeLowMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowSlider, iNewGazeTimeMS);
                set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowEdit,'String',num2str(iNewGazeTimeMS));
            end
            g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeSlider, iNewGazeTimeMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeMS);
            fnDAQWrapper('StrobeWord', fnFindCode('Gaze Time Changed'));                
            fnLog('Setting gaze to %d', iNewGazeTimeMS);
        end;

        
    case 'GazeLowSlider'
        iNewGazeTimeLowMS = round(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowSlider,'value'));
        iGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
        if iNewGazeTimeLowMS > iGazeTimeMS
           g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeLowMS);
           fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeSlider, iNewGazeTimeLowMS);  
           set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeEdit,'String',num2str(iNewGazeTimeLowMS));
        end
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowEdit,'String',num2str(iNewGazeTimeLowMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeLowMS);
        fnLog('Setting low gaze time to %d', iNewGazeTimeLowMS);
    case 'GazeLowEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowEdit,'string');
        iNewGazeTimeLowMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewGazeTimeLowMS)
           
            iGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
            if iNewGazeTimeLowMS > iGazeTimeMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeMS',iNewGazeTimeLowMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeSlider, iNewGazeTimeLowMS);
                set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeEdit,'String',num2str(iNewGazeTimeLowMS));
            end

            g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeLowSlider, iNewGazeTimeLowMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeTimeLowMS',iNewGazeTimeLowMS);
            fnLog('Setting low gaze time to %d', iNewGazeTimeLowMS);
        end;
        
        
   case 'GazeRectSlider'
        iGazeBoxPix = round(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeRectSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeRectEdit,'String',num2str(iGazeBoxPix));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeBoxPix',iGazeBoxPix);
        fnDAQWrapper('StrobeWord', fnFindCode('Gaze Reward Rect Changed'));                
        fnLog('Setting new gaze reward area to %d pix', iGazeBoxPix);
    case 'GazeRectEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeRectEdit,'string');
        iGazeBoxPix = fnMyStr2Num(strTemp);
        if ~isempty(iGazeBoxPix)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hGazeRectSlider, iGazeBoxPix);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'GazeBoxPix',iGazeBoxPix);
            fnDAQWrapper('StrobeWord', fnFindCode('Gaze Reward Rect Changed'));                
            fnLog('Setting new gaze reward area to %d pix', iGazeBoxPix);
        end;
         
         
    case 'JuiceSlider'
        iNewJuiceTimeMS = round(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceEdit,'String',num2str(iNewJuiceTimeMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeMS);
        fnDAQWrapper('StrobeWord', fnFindCode('Juice Time Changed'));                
        fnLog('Setting Juice to %d', iNewJuiceTimeMS);
        
        iJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
        if iNewJuiceTimeMS > iJuiceTimeHighMS
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighSlider, iNewJuiceTimeMS);
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighEdit,'String',num2str(iNewJuiceTimeMS));
        end

        
    case 'JuiceEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceEdit,'string');
        iNewJuiceTimeMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewJuiceTimeMS)
             iJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
            if iNewJuiceTimeMS > iJuiceTimeHighMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighSlider, iNewJuiceTimeMS);
                set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighEdit,'String',num2str(iNewJuiceTimeMS));
            end
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceSlider, iNewJuiceTimeMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeMS);
            fnDAQWrapper('StrobeWord', fnFindCode('Juice Time Changed'));                
            fnLog('Setting Juice to %d', iNewJuiceTimeMS);
        end;

        
    case 'JuiceHighSlider'
        iNewJuiceTimeHighMS = round(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighSlider,'value'));
        iJuiceTimeMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
        if iNewJuiceTimeHighMS < iJuiceTimeMS
           g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeHighMS);
           fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceSlider, iNewJuiceTimeHighMS);  
           set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceEdit,'String',num2str(iNewJuiceTimeHighMS));
        end
        
        set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighEdit,'String',num2str(iNewJuiceTimeHighMS));
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeHighMS);
        fnLog('Setting High Juice time to %d', iNewJuiceTimeHighMS);
    case 'JuiceHighEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighEdit,'string');
        iNewJuiceTimeHighMS = fnMyStr2Num(strTemp);
        if ~isempty(iNewJuiceTimeHighMS)
           
            iJuiceTimeMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
            if iNewJuiceTimeHighMS < iJuiceTimeMS
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeMS',iNewJuiceTimeHighMS);
                fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceSlider, iNewJuiceTimeHighMS);
                set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceEdit,'String',num2str(iNewJuiceTimeHighMS));
            end

            
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hJuiceHighSlider, iNewJuiceTimeHighMS);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'JuiceTimeHighMS',iNewJuiceTimeHighMS);
            fnLog('Setting High Juice time to %d', iNewJuiceTimeHighMS);
        end;
                
        
  case 'BlinkTimeSlider'
        iNewBlinkTime = round(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hBlinkTimeSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hBlinkTimeEdit,'String',num2str(iNewBlinkTime));
        g_strctParadigm= fnTsSetVar(g_strctParadigm,'BlinkTimeMS',iNewBlinkTime);
        fnLog('Setting Blink time to %d ms', iNewBlinkTime);
    case 'BlinkTimeEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hBlinkTimeEdit,'string');
        iNewBlinkTime = fnMyStr2Num(strTemp);
        if ~isempty(iNewBlinkTime)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hBlinkTimeSlider, iNewBlinkTime);
            g_strctParadigm= fnTsSetVar(g_strctParadigm,'BlinkTimeMS',iNewBlinkTime);
            fnLog('Setting Blink time to %d ms', iNewBlinkTime);
        end;

  case 'PositiveIncSlider'
        iNewPositiveInc = round(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPositiveIncSlider,'value'));
        set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPositiveIncEdit,'String',num2str(iNewPositiveInc));
        g_strctParadigm= fnTsSetVar(g_strctParadigm,'PositiveIncrement',iNewPositiveInc);
        fnLog('Setting positive increment percentage to %d ', iNewPositiveInc);
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
    case 'PositiveIncEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPositiveIncEdit,'string');
        iNewPositiveInc = fnMyStr2Num(strTemp);
        if ~isempty(iNewPositiveInc)
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPositiveIncSlider, iNewPositiveInc);
            g_strctParadigm= fnTsSetVar(g_strctParadigm,'PositiveIncrement',iNewPositiveInc);
             fnLog('Setting positive increment percentage to %d ', iNewPositiveInc);
             g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        end;
        
    otherwise
        bEventHandled = false;
end

return
