function acFiles = fnGetAllFilesRecursive(strPath, strExt)
% for exampple: acFileNames = fnGetAllFilesRecursive('D:\Data\Doris\Stimuli\Caltech256\','.jpg')
if strPath(end) ~= filesep
    strPath(end+1) = filesep;
end;

astrctDir = dir(strPath);
acFiles = cell(0);

for k=1:length(astrctDir)
    if astrctDir(k).isdir && ~strcmp(astrctDir(k).name(1),'.')
        % Go recursive
        acFiles = [acFiles, fnGetAllFilesRecursive([strPath,astrctDir(k).name], strExt)];
    end;
    [strFilePath,strFile,strFileExt] = fileparts(astrctDir(k).name);
    
    if ~astrctDir(k).isdir && strcmpi(strFileExt,strExt)
            acFiles = [acFiles, {[strPath,astrctDir(k).name]}];
    end;
end;