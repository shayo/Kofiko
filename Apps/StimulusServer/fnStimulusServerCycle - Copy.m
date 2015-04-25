function fnStimulusServerCycle()
global g_strctServerCycle g_strctNet g_strctPTB g_strctConfig g_strctSoundMedia

fCurrTime = GetSecs;
g_strctServerCycle.m_iNumCycles = g_strctServerCycle.m_iNumCycles + 1;

if fCurrTime-g_strctServerCycle.m_fCycleTimer > g_strctServerCycle.m_fCycleTimerRateMS/1e3
%    fprintf('%d\n',g_strctServerCycle.m_iNumCycles);
    g_strctServerCycle.m_fCycleTimer = fCurrTime;
    g_strctServerCycle.m_iNumCycles = 0;
end;


if fCurrTime-g_strctServerCycle.m_fKBCheckTimer > g_strctServerCycle.m_fKBCheckTimerRateMS/1e3
    g_strctServerCycle.m_fKBCheckTimer = fCurrTime;
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if keyIsDown && keyCode(27)
        fnLog('Stopping server');
        g_strctServerCycle.m_fbClientConnected = false;
        return;
    end;
end

acInputFromKofiko = msrecv(g_strctNet.m_iCommSocket,g_strctConfig.m_strctStimulusServer.m_fNetworkCmdTimeout);
if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};

    switch strCommand
        case 'StartPTB'
            fnStartPTB();
        case 'UpdateParadigm'
            g_strctServerCycle.m_iMachineState = 0;
            g_strctServerCycle.m_strDrawFunc = acInputFromKofiko{2};
            g_strctServerCycle.m_bPaused = false;
        case 'ParadigmSwitch'
            g_strctServerCycle.m_iMachineState = 0;
            if ~isempty(g_strctServerCycle.m_strDrawFunc)
                feval(g_strctServerCycle.m_strDrawFunc, {'ClearMemory'});
            end
            g_strctServerCycle.m_strDrawFunc = [];
        case 'Pause'
            g_strctServerCycle.m_bPaused = true;
            fnClearScreen();
        case 'Resume'
            g_strctServerCycle.m_bPaused = false;
        case 'ClearScreen'
            fnClearScreen();
        case 'Ping'
               % Send Pong
               fRandomNumber = acInputFromKofiko{2};
               fnStimulusServerToKofikoParadigm('Pong',fRandomNumber);
        case 'InStereoMode'
               fnStimulusServerToKofikoParadigm('StereoMode',g_strctPTB.m_bInStereoMode);
        case 'SetStereoMonoMode'
              strMode = acInputFromKofiko{2};
              switch lower(strMode)
                  case 'mono'
                        bSuccessful=fnSetPTB_SeteroMono(0);
                  case 'stereo'
                        bSuccessful=fnSetPTB_SeteroMono(1);
              end
              fnStimulusServerToKofikoParadigm('StereoModeSwitch',bSuccessful);
        case 'Echo'
               % Send Pong
               mssend(g_strctNet.m_iCommSocket, acInputFromKofiko{2:end});
        case 'PingGetSecs'
               % Used to sync clocks between stimulus server and kofiko
               iNumPings = acInputFromKofiko{2};
               fTimeoutSec = 20; 
               for k=1:iNumPings
                   acInputFromKofiko = msrecv(g_strctNet.m_iCommSocket,fTimeoutSec);
                   fnStimulusServerToKofikoParadigm('PongGetSecs',GetSecs());
               end
        case 'CloseConnection'
            fnClearScreen();
            g_strctServerCycle.m_fbClientConnected = false;
        case 'DrawAttention'
            fnDrawAttentionStimServer();
            return;
        case 'LoadSounds'
            acSoundFileNames = acInputFromKofiko{2};
            g_strctSoundMedia.m_acSounds = fnLoadSoundsAux(acSoundFileNames);
        case 'PlaySound'
            strSoundName = acInputFromKofiko{2};
            fnPlayAsyncSound(strSoundName);
        case 'ForceMessage'
            if ~isempty(g_strctServerCycle.m_strDrawFunc)
                feval(g_strctServerCycle.m_strDrawFunc, acInputFromKofiko(2:end));
            end
		% Changelog 10/14/13 Josh - unknown if this works or is necessary, sends resolution and framerate to control computer
		case 'getresolution'
			m_aiScreenSize = Screen('Resolution', g_strctStimulusServer.m_PTBScreen)
			m_hz = Screen('NominalFrameRate',2)
			fnStimulusServerToKofikoParadigm('SetStimulusServerResolution', m_aiScreenSize);
			fnStimulusServerToKofikoParadigm('SetStimulusServerHZ',m_Hz);
		% End Changelog ------------------------------------------------------
		% Changelog 10/22/2013 Josh - FitToScreen comms, stimulus server side
		case 'fittoscreenon'
			g_strctPTB.m_bFitToScreen = 1;
		case 'fittoscreenoff'
			g_strctPTB.m_bFitToScreen = 0;
		% End Changelog ------------------------------------------------------	
		
    end
% Changelog 10/22/2013 Josh - attempt at fixing calculatestimrect problems
try 
	if ~exist(g_strctPTB.m_bFitToScreen)
	fnStimulusServerToKofikoParadigm('GetFitToScreen')
	end
catch
	fnStimulusServerToKofikoParadigm('GetFitToScreen')
end

% End Changelog
else
    acInputFromKofiko = [];
end;

if ~isempty(g_strctServerCycle.m_strDrawFunc) && ~g_strctServerCycle.m_bPaused
    feval(g_strctServerCycle.m_strDrawFunc, acInputFromKofiko);
end


return;

function fnClearScreen()
global g_strctPTB  g_strctConfig 
if g_strctPTB.m_bRunning && ~g_strctConfig.m_strctStimulusServer.m_fVirtualServer
    if g_strctPTB.m_bInStereoMode
        Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,0); % Left Eye
        Screen(g_strctPTB.m_hWindow,'FillRect',0);
        Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,1); % Right Eye
        Screen(g_strctPTB.m_hWindow,'FillRect',0);
    else
        Screen(g_strctPTB.m_hWindow,'FillRect',0);
    end
    fnFlipWrapper(g_strctPTB.m_hWindow);
end
return;


function fnStartPTB()
global g_strctPTB g_strctConfig g_strctNet g_strctDraw
       iWindowSize = 400;
        iShift = 30;
clear global g_strctDraw 
if g_strctConfig.m_strctStimulusServer.m_fVirtualServer
    if g_strctConfig.m_strctStimulusServer.m_fDebugMode
        
        fnStimulusServerToKofikoParadigm('ScreenSize', [0 0 iWindowSize iWindowSize]);
        fnStimulusServerToKofikoParadigm('RefreshRate',60);        
    else
        Screen('Preference', 'SkipSyncTests', 1);
        [g_strctPTB.m_hWindow,g_strctPTB.m_aiRect] = Screen(g_strctConfig.m_strctStimulusServer.m_fPTBScreen,'OpenWindow',g_strctConfig.m_strctStimulusServer.m_fPTBScreen,[],[],2);
        g_strctPTB.m_iRefreshRate=Screen('FrameRate', g_strctConfig.m_strctStimulusServer.m_fPTBScreen);
        
        Screen('CloseAll');
        fnStimulusServerToKofikoParadigm('ScreenInfo',g_strctPTB.m_aiRect/2);
        fnStimulusServerToKofikoParadigm('RefreshRate',g_strctPTB.m_iRefreshRate);
    end
else
    if g_strctConfig.m_strctStimulusServer.m_fDebugMode
        g_strctPTB.m_iScreenIndex = 0;
        Screen('Preference', 'SkipSyncTests', 1);
        Screen('Preference', 'TextRenderer', 0);
         g_strctPTB.m_aiScreenRect =[iShift 20 iShift+iWindowSize 20+iWindowSize];
        [g_strctPTB.m_hWindow, g_strctPTB.m_aiRect] = Screen(g_strctPTB.m_iScreenIndex,...
            'OpenWindow',0,g_strctPTB.m_aiScreenRect,[],2);
        Screen(g_strctPTB.m_hWindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        g_strctPTB.m_iRefreshRate=Screen('FrameRate', 0);
        fnStimulusServerToKofikoParadigm('ScreenSize', [0 0 iWindowSize iWindowSize]);
        fnStimulusServerToKofikoParadigm('RefreshRate',g_strctPTB.m_iRefreshRate);        
        %HideCursor;
        Screen(g_strctPTB.m_hWindow,'FillRect',0);
        fnFlipWrapper(g_strctPTB.m_hWindow);
        g_strctPTB.m_bNonRectMakeTexture = true;
        g_strctPTB.m_bInStereoMode = false;
    else
        Screen('Preference', 'SkipSyncTests', g_strctConfig.m_strctStimulusServer.m_fSkipSyncTests);
        g_strctPTB.m_bInStereoMode = false;
        
%         try
            g_strctPTB.m_aiRect=Screen('Rect', g_strctConfig.m_strctStimulusServer.m_fPTBScreen);
            try
                g_strctPTB.m_hWindow=Screen('OpenWindow',g_strctConfig.m_strctStimulusServer.m_fPTBScreen, 0,[],32,2, 0);
            catch
                try
                    g_strctPTB.m_hWindow=Screen('OpenWindow',g_strctConfig.m_strctStimulusServer.m_fPTBScreen, 0,[],32,2, 0);
                catch
                    g_strctPTB.m_hWindow=Screen('OpenWindow',g_strctConfig.m_strctStimulusServer.m_fPTBScreen, 0,[],32,2, 0);
                end
            end
            
            

%            [g_strctPTB.m_hWindow] = Screen('OpenWindow',g_strctConfig.m_strctStimulusServer.m_fPTBScreen);
            Screen(g_strctPTB.m_hWindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
%             hTexture = Screen('MakeTexture', g_strctPTB.m_hWindow,uint8(ones(200,200)));
            g_strctPTB.m_bNonRectMakeTexture = true;
%             Screen('Close',hTexture);
%         catch
%             [g_strctPTB.m_hWindow,g_strctPTB.m_aiRect] = Screen(g_strctConfig.m_strctStimulusServer.m_fPTBScreen,'OpenWindow',g_strctConfig.m_strctStimulusServer.m_fPTBScreen,0,[],2);
%             g_strctPTB.m_bNonRectMakeTexture = false;
%         end
        
        g_strctPTB.m_aiScreenRect = g_strctPTB.m_aiRect;
        fnStimulusServerToKofikoParadigm('ScreenSize',g_strctPTB.m_aiRect);
        g_strctPTB.m_iRefreshRate=Screen('FrameRate', 0);
        fnStimulusServerToKofikoParadigm('RefreshRate',g_strctPTB.m_iRefreshRate);        
        HideCursor;
        Screen(g_strctPTB.m_hWindow,'FillRect',0);
        fnFlipWrapper(g_strctPTB.m_hWindow);
    end;
end;
g_strctPTB.m_bRunning = true;
g_strctPTB.m_bRunningOnStimulusServer = true;
if g_strctConfig.m_strctStimulusServer.m_fCaptureOtherScreens
    aiOtherScreens = setdiff(Screen('Screens'), [0,g_strctConfig.m_strctStimulusServer.m_fPTBScreen]);
    for iIter=1:length(aiOtherScreens)
        Screen(aiOtherScreens(iIter),'OpenWindow',0,[],[],2);
    end;
end
return;

function bSuccessful=fnSetPTB_SeteroMono(bSetToStereo)
global g_strctPTB g_strctConfig
if (g_strctPTB.m_bInStereoMode && bSetToStereo) || (~g_strctPTB.m_bInStereoMode && ~bSetToStereo)
     % Nothing to do. Already in the desired mode.
      bSuccessful = true;
     return;
end;
Screen('Close',g_strctPTB.m_hWindow); 
  bSuccessful = true;
if bSetToStereo
    % Try going to stereo mode.
    % if failed, return error message and switch back to mono mode...
    try
    [g_strctPTB.m_hWindow,g_strctPTB.m_aiRect] = ...
        Screen('OpenWindow',...
        0,[0 0 0],[],[],[],g_strctConfig.m_strctStimulusServer.m_fStereoMode);
    bSuccessful = true;
    
     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,0); % Left Eye
     Screen('FillRect', g_strctPTB.m_hWindow,[0,0,0]);
     Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,1); % Right Eye
     Screen('FillRect', g_strctPTB.m_hWindow,[0,0,0]);
        fnFlipWrapper(g_strctPTB.m_hWindow);
    
    g_strctPTB.m_bInStereoMode = true;
    catch
        bSuccessful = false;
    [g_strctPTB.m_hWindow,g_strctPTB.m_aiRect] = ...
        Screen('OpenWindow',...
        g_strctConfig.m_strctStimulusServer.m_fPTBScreen,[0 0 0],[],[],[],0);
    g_strctPTB.m_bInStereoMode = false;
    end
    
else
    % Back to mono world
    g_strctPTB.m_bInStereoMode = false;
    [g_strctPTB.m_hWindow,g_strctPTB.m_aiRect] = ...
        Screen('OpenWindow',...
        g_strctConfig.m_strctStimulusServer.m_fPTBScreen,[0 0 0],[],[],[],0);
end

Screen(g_strctPTB.m_hWindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

return;
