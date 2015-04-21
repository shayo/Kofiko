function [strctConfig,astrctParadigms, strctSystemCodes] = fnLoadKofikoConfigXML(strConfigurationFile)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

[strctConfig,astrctParadigms] = fnLoadConfigXML(strConfigurationFile);

if ~isfield(strctConfig.m_strctDAQ,'m_afExternalTriggers') && isfield(strctConfig.m_strctDAQ,'m_fExternalTriggers')
    strctConfig.m_strctDAQ.m_afExternalTriggers= strctConfig.m_strctDAQ.m_fExternalTriggers;
    strctConfig.m_strctDAQ = rmfield(strctConfig.m_strctDAQ,'m_fExternalTriggers');
end;

if ~isfield(strctConfig.m_strctDAQ,'m_afStimulationPort')
    strctConfig.m_strctDAQ.m_afStimulationPort = [];
end

if isfield(strctConfig.m_strctDAQ,'m_fStimulationPort')
    strctConfig.m_strctDAQ.m_afStimulationPort =  strctConfig.m_strctDAQ.m_fStimulationPort;
    strctConfig.m_strctDAQ = rmfield(strctConfig.m_strctDAQ,'m_fStimulationPort');
end

if ~isfield(strctConfig.m_strctDAQ,'m_afExternalTriggers')
    strctConfig.m_strctDAQ.m_afExternalTriggers = [];
end

if ~isfield(strctConfig.m_strctDAQ,'m_fMotionPort')
    strctConfig.m_strctDAQ.m_fMotionPort = [];
end


if ~exist('astrctParadigms','var')
    error('Could not find a single paradigm in XML file?!?!?!');
end;



% read strobe code files...
for k=1:length(astrctParadigms)
    if isfield(astrctParadigms{k},'m_strStrobeCodes') && exist(astrctParadigms{k}.m_strStrobeCodes,'file')
        
        [astrctParadigms{k}.m_acCodeDescription, astrctParadigms{k}.m_aiAvailableCodes] = ...
            fnReadStrobeCode(astrctParadigms{k}.m_strStrobeCodes);
    else
        astrctParadigms{k}.m_acCodeDescription = [];
        astrctParadigms{k}.m_aiAvailableCodes = [];
    end
    
end

[acSystemCodesDesc, aiAvailSystemCodes] = fnReadStrobeCode(strctConfig.m_strctDAQ.m_strSystemStrobeFile);


% Make sure all the required system codes are available and that they do
% not overlap with paradigm strobe codes

acDesiredCodes = {'No Stimulus','Juice OFF','Juice ON','Stop Recording','Start Recording','Comment','Start Paradigm','Pause Paradigm','Stop Paradigm','Resume Paradigm','Recenter Gaze','Sync','Paradigm Switch','Micro Stimulation'};
acDesiredCodesVarName = {'m_iNoStimulus','m_iJuiceOFF','m_iJuiceON','m_iStopRecord','m_iStartRecord','m_iComment','m_iStartParadigm','m_iPauseParadigm','m_iStopParadigm','m_iResumeParadigm','m_iRecenterGaze','m_iSync','m_iParadigmSwitch','m_iMicroStim'};
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
% Overlapping codes?
for k=1:length(astrctParadigms)
    if ~isempty(intersect(astrctParadigms{k}.m_aiAvailableCodes, aiAvailSystemCodes))
        fprintf('CRITICAL ERROR: paradigm %s has the following common codes with system codes:',astrctParadigms{k}.m_strName);  
        error('Stopping!');
    end;
end;

strctConfig.m_strTimeDate = datestr(now);

return;
