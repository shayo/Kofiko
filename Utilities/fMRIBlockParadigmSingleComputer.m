[strFile, strPath] = uigetfile(['*.txt']);
if strFile(1) == 0
    return;
end;
strExperimentFile = [strPath,strFile];
[acNames] = textread(strExperimentFile,'%s');
strImageList = acNames{1};
strBlockList = acNames{2};
strRunList = acNames{3};

% Load Image List
[acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(strImageList);
fnKofikoClearTextureMemory();
[g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,...
    g_strctParadigm.m_abIsMovie,g_strctParadigm.m_aiApproxNumFrames, g_strctParadigm.m_afMovieLengthSec] = ...
    fnInitializeTexturesAux(acFileNames);

% Load Block List
[acImageIndices,acBlockNames] = fnLoadMRIStyleBlockList(strBlockList);
acBlocks = fnLoadBlockOrderListTextFile(strRunList);

fnUpdateListWithTime();
