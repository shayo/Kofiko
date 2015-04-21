function fnSaveParadigmsToDisk(bCropBuffer)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_iCurrParadigm g_astrctAllParadigms g_strctParadigm  g_strctDAQParams g_strctLog
global g_strctSystemCodes g_strLogFileName g_strctAppConfig g_strctEyeCalib g_strctStimulusServer g_handles g_strctSharedParadigmData

strOutFile = [g_strLogFileName(1:end-4),'.mat'];
fnLog('Writing all paradigms to %s',strOutFile);
if ~isempty(g_handles) && isfield(g_handles,'hLogLine') && ishandle(g_handles.hLogLine)
    set(g_handles.hLogLine,'string','Saving session...please wait...');
    drawnow
end;
if bCropBuffer
    fprintf('Cropping buffers... this might take some time...!\n');
    g_astrctAllParadigms = fnCropBuffer(g_astrctAllParadigms);
    g_strctAppConfig = fnCropBuffer(g_strctAppConfig);
    g_strctSystemCodes = fnCropBuffer(g_strctSystemCodes);
%    g_strctLog = fnCropBuffer(g_strctLog);
    g_strctDAQParams = fnCropBuffer(g_strctDAQParams);
    g_strctEyeCalib = fnCropBuffer(g_strctEyeCalib);    
    g_strctStimulusServer = fnCropBuffer(g_strctStimulusServer);        
    g_strctSharedParadigmData = fnCropBuffer(g_strctSharedParadigmData);
end;
fprintf('Saving Kofiko file...(%s)!\n',strOutFile);

save(strOutFile,'g_astrctAllParadigms','g_strctAppConfig','g_strctSystemCodes',...
    'g_strctEyeCalib','g_strctDAQParams','g_strctLog','g_strctStimulusServer','g_strctSharedParadigmData');

fprintf('Data saved!\n');

fnLog('Data Saved!');

return;