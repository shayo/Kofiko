function [strFile, strPath] = fnMyPutFile(strInput)
fnParadigmToKofikoComm('JuiceOff');
bParadigmPaused = fnParadigmToKofikoComm('IsPaused');
if ~bParadigmPaused
    bPausing = true;
    fnPauseParadigm()
else
    bPausing = false;
end
fnHidePTB();
[strFile, strPath] = uiputfile(strInput); 
fnShowPTB();
if bPausing
    fnResumeParadigm();
end

return;
