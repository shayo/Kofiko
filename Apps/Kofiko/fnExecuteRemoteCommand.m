function fnExecuteRemtoeCommand(acInputFromRemoteClient)
global g_bParadigmRunning g_iCurrParadigm g_iNextParadigm g_bAppIsRunning g_astrctAllParadigms g_strctParadigm g_strctDAQParams
global g_strctSystemCodes g_strctAppConfig g_strctGUIParams g_strctCycle

strCommand = acInputFromRemoteClient{1};
fnParadigmToKofikoComm('DisplayMessage',sprintf('Remote Client : %s',strCommand));
switch lower(strCommand)
    case 'paradigmsavail'
        iNumParadigms = length(g_astrctAllParadigms);
        acParadigmNames = cell(1,iNumParadigms);
        for k=1:iNumParadigms
            acParadigmNames{k}= g_astrctAllParadigms{k}.m_strName;
        end
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,{'paradigmsavail',acParadigmNames});
    case 'currentparadigm'
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,{'currentparadigm',g_strctParadigm.m_strName});
    case 'currentstate'
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,{'currentstate',g_strctCycle.m_strState});
    case 'gettrials'
        acTrials = feval(g_strctParadigm.m_strQuery,'trials');
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,{'trials',acTrials});
    case 'startparadigm'
        fnStartParadigm();
    case 'pauseparadigm'
        fnPauseParadigm();
    case 'geteyeposition'
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,{'eyeposition',strctInputs.m_pt2iEyePosScreen});
    case 'recenter'
        fnRecenterGaze();
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,{'recentergaze',1});
    case 'paradigmcallback'
        if length(acInputFromRemoteClient) > 2
            feval(g_strctParadigm.m_strCallbacks,acInputFromRemoteClient{2},acInputFromRemoteClient(3:end));
        else
            feval(g_strctParadigm.m_strCallbacks,acInputFromRemoteClient{2});
        end
    case 'juicepulse'
        fnParadigmToKofikoComm('Juice', g_strctGUIParams.m_fJuiceTimeMS)
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,{'juicepulse',1});
    case 'getparadigm'
        mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket, {'paradigm',g_strctParadigm});
    case 'switchparadigm'
        strDesiredParadigm = acInputFromRemoteClient{2};
        iSelectedParadigm  = [];
        for k=1:length(g_astrctAllParadigms)
            if strcmpi(g_astrctAllParadigms{k}.m_strName,strDesiredParadigm)
                iSelectedParadigm = k;
            end
        end
        if isempty(iSelectedParadigm )
            mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket, {'switchparadigm', 0});
        else
            fnSwitchKofikoParadigm(iSelectedParadigm );
            mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket, {'switchparadigm', 1});
        end
    case 'getvideoframe'
            [a3iImage, fTimestamp] = fnParadigmToKofikoComm('getvideoframe');
            mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket, {'videoframe',a3iImage,fTimestamp});
   case 'getvideoframenow'
            [a3iImage, fTimestamp] = fnParadigmToKofikoComm('getvideoframenow');
            mssend(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket, {'videoframe',a3iImage,fTimestamp});
    otherwise
        fnParadigmToKofikoComm('DisplayMessage',sprintf('Remote Client: Unknown Command: %s',strCommand));
        
end
    
return;
