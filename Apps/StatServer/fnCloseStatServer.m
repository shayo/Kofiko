function fnCloseStatServer()
global g_strctCycle g_bAppIsRunning g_strctWindows 
set(1,'visible','off');
drawnow
if ~g_strctCycle.m_bShutDownDone
    % Clean up
    fnTurnOffAllActiveUnits(false);
    fnSaveStatServerMatData();
    
    
    
    % Search for exit scripts
    astrctScripts = dir('.\Apps\StatServer\ExitScripts\*.m');
    if ~isempty(astrctScripts)
        
        iSelectScriptIndex=listdlg('PromptString','Select exit script or click cancel','SelectionMode','single','ListString',{astrctScripts.name},'ListSize',[400 200]);
        if ~isempty(iSelectScriptIndex)
            
            if ~isempty(g_strctCycle.m_strSessionName)
                strSessionFullName = g_strctCycle.m_strSessionName;
            else
                strSessionFullName = g_strctCycle.m_strTmpSessionName;
            end
            aiSep = find(strSessionFullName=='_');
            strSubject = strSessionFullName(aiSep(2)+1:end);
            strSession = strSessionFullName(1:aiSep(2)-1);
            drawnow
            try
                [strP,strF]=fileparts(astrctScripts(iSelectScriptIndex).name);
                feval(strF, strSession, strSubject);
            catch
                fprintf('********* Crashed during exit script!!! ************ \n');
            end
            
        end
        
    end
    
    
    
    TrialCircularBuffer('Release');
    fnCloseListeningSocket();
    fnDisconnectFromNeuralServer();
    fndllMiceHook('Release');
    g_strctCycle.m_bShutDownDone = true;
    g_bAppIsRunning = false;
    if ishandle(g_strctWindows.m_hFigure)
        delete(g_strctWindows.m_hFigure);
    end;
    
    
    
end

return;