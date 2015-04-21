function [strFile, strPath] = fnMyGetFile(strInput)
fnParadigmToKofikoComm('JuiceOff');
bParadigmPaused = fnParadigmToKofikoComm('IsPaused');
if ~bParadigmPaused
    bPausing = true;
    fnPauseParadigm();
else
    bPausing = false;
end
fnHidePTB();
[strFile, strPath] = uigetfile(strInput); %[g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt']);
fnShowPTB();
if bPausing
    fnResumeParadigm();
end

return;
