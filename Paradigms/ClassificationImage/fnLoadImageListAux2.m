function fnLoadImageListAux2(strImageList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  g_strctStimulusServer  

[strPath, strFile, strExt] = fileparts(strImageList);
% Try to load the corresponding category file
strCatFile = [strPath,'\',strFile,'_Cat.mat'];
if exist(strCatFile,'file')
    Tmp = load(strCatFile);
    g_strctParadigm.m_a2bStimulusCategory = Tmp.a2bStimulusCategory > 0;
    g_strctParadigm.m_acCatNames = Tmp.acCatNames;
else
    g_strctParadigm.m_a2bStimulusCategory = [];
    g_strctParadigm.m_acCatNames = [];
end;

fnLog('Loading images locally on Kofiko');
acFileNames = fnLoadImagesToRAM(strImageList);
g_strctParadigm.m_acFileNames = acFileNames;    
g_strctParadigm.m_iNumStimuli = length(acFileNames);
g_strctParadigm.m_iNoiseImageIndex = -1;
for k=1:length(acFileNames)
    [strPath,strFile] = fileparts(acFileNames{k});
    if strcmpi(strFile,'empty')
        g_strctParadigm.m_iNoiseImageIndex = k;
    end;
end
assert(g_strctParadigm.m_iNoiseImageIndex ~= -1);

g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageList',strImageList);
fnDAQWrapper('StrobeWord', fnFindCode('Image List Changed'));
    
g_strctParadigm.m_iStimuliCounter = 1;
g_strctParadigm.m_iLastStimulusPresentedIndex  = 0;

if ~isfield(g_strctParadigm,'m_aiSelectedImageList')
    g_strctParadigm.m_aiSelectedImageList = 1:g_strctParadigm.m_iNumStimuli;
end

fnParadigmToKofikoComm('ResetStat');
g_strctParadigm.m_iRepeatitionCount  = 0;
if g_strctParadigm.m_iMachineState > 0
    g_strctParadigm.m_iMachineState = 1; % This will prevent us to get stuck waiting for some stimulus server code
end

return;