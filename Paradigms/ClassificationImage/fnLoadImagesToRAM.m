function acFileNames = fnLoadImagesToRAM(strImageList)
global g_strctParadigm 
% Generate PTB handles for fast drawing.
if isfield(g_strctParadigm,'m_acImages');
    g_strctParadigm.m_acImages = [];
end
    
[acFileNames] = fnReadImageList(strImageList);
iNumImages = length(acFileNames);

g_strctParadigm.m_acImages = cell(1,iNumImages);
for iFileIter=1:iNumImages
    g_strctParadigm.m_acImages{iFileIter} = imread(acFileNames{iFileIter});
end;

return;
