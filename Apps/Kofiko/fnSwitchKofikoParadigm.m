function fnSwitchKofikoParadigm(iSelectedParadigm)
global g_bParadigmRunning g_astrctAllParadigms g_handles g_iNextParadigm g_strctAppConfig 
% Now, switch to a new paradigm
g_bParadigmRunning = false; % this will take care of exiting from the main loop and switching to the new paradigm
g_iNextParadigm = iSelectedParadigm;

strctVersion = fnGetKofikoVersion();
set(g_handles.figure1,'Name',['Kofiko - ',strctVersion.m_strMajorVersion,' ',strctVersion.m_strRevisionNumber,', Paradigm: ',g_astrctAllParadigms{iSelectedParadigm}.m_strName]);
set(g_handles.hParadigmShift,'value',iSelectedParadigm);

if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    fnParadigmToStimulusServer('ParadigmSwitch');
end


if ~isfield(g_astrctAllParadigms{iSelectedParadigm},'m_fStartParadigmTimer')
    % Paradigm has never been started....
    set(g_handles.hPauseButton,'string','Pause','enable','off');
else
    fnPauseParadigm();
end

return;