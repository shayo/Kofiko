function [a2bStimulusCategory,acCatNames,strImageListDescrip] = fnLoadCategoryFile(strImageListUsed)
[strPath,strFile] = fileparts(strImageListUsed);
strCatFile = [strFile, '_Cat.mat'];
if ~exist(strCatFile,'file') && exist([strPath,filesep,strCatFile],'file')
	strCatFile =  [strPath,filesep,strCatFile];
end

if exist(strCatFile,'file')
    strctTmp = load(strCatFile);
    a2bStimulusCategory = strctTmp.a2bStimulusCategory;
    acCatNames = strctTmp.acCatNames;
    if isfield(strctTmp,'strImageListDescrip')
        strImageListDescrip = strctTmp.strImageListDescrip;
    else
        strImageListDescrip = strFile;
    end
    return;
end

% No category file was found. Treat each stimulus as a category
fnWorkerLog('Warning, no category file was found for image %s',strImageListUsed);

a2bStimulusCategory = [];
acCatNames = [];
strImageListDescrip = [];
return;
