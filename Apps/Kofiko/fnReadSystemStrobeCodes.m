function strctSystemCodes=fnReadSystemStrobeCodes(strSystemStrobeFile)
[acSystemCodesDesc, aiAvailSystemCodes] = fnReadStrobeCode(strSystemStrobeFile);

acDesiredCodes = {'No Stimulus','Juice OFF','Juice ON','Stop Recording','Start Recording','Comment','Start Paradigm','Pause Paradigm','Stop Paradigm','Resume Paradigm','Recenter Gaze','Sync','Paradigm Switch'};
acDesiredCodesVarName = {'m_iNoStimulus','m_iJuiceOFF','m_iJuiceON','m_iStopRecord','m_iStartRecord','m_iComment','m_iStartParadigm','m_iPauseParadigm','m_iStopParadigm','m_iResumeParadigm','m_iRecenterGaze','m_iSync','m_iParadigmSwitch'};
strctSystemCodes = [];
abFound = zeros(1, length(acDesiredCodes));
for k=1:length(acDesiredCodes)
    for j=1:length(aiAvailSystemCodes)
        if strcmpi(acDesiredCodes{k},  acSystemCodesDesc{aiAvailSystemCodes(j)})
                strctSystemCodes =  setfield(strctSystemCodes, acDesiredCodesVarName{k},aiAvailSystemCodes(j)-1);
                abFound(k) = 1;
        end;
    end;
end;

% Missing system codes?
aiMissingCodes = find(~abFound);
if ~isempty(aiMissingCodes)
    fprintf('CRITICAL ERROR: Could not find strobe word codes for:\n');
    for j=1:length(aiMissingCodes)
        fprintf('%s\n',acDesiredCodes{aiMissingCodes(j)})
    end;
    error('Stopping!');
end;

return;
