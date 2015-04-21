function acAvailFiles=fnGetAllFilesRecursive(strFolder,acFileTypes, bPartialPath)
fprintf('Scanning...');
if ~iscell(acFileTypes)
    acFileTypes = {acFileTypes};
end
if strFolder(end) ~= filesep
    strFolder(end+1) = filesep;
end;
if ~exist('bPartialPath','var')
    bPartialPath = false;
end;
acDirs = parsedirs(genpath(strFolder));
iCounter = 1;
clear acAvailFiles
for k=1:length(acDirs)
    for m=1:length(acFileTypes)
        astrctFiles = dir([acDirs{k}(1:end-1),'/',acFileTypes{m}]);
        for j=1:length(astrctFiles)
            strP = [acDirs{k}(1:end-1),'/'];
            
            if bPartialPath
                strP = strP(length(strFolder)+1:end);
            end
            acAvailFiles{iCounter} = [strP,astrctFiles(j).name];
            iCounter=iCounter+1;
        end
    end
end
if iCounter==1
    acAvailFiles = cell(0);
else
    acAvailFiles = unique(acAvailFiles);
end
fprintf('Done!\n');
return;
