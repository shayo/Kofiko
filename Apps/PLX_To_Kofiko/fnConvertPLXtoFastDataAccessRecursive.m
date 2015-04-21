function fnConvertPLXtoFastDataAccessRecursive(acFolders, strctOptions, hMajorWait, hMinorWait)
iNumFolders = length(acFolders);
acAllFolders = {};
for iFolderIter=1:iNumFolders
    acAllFolders = [acAllFolders;fnMyParseDirs(fnMyGenPath(acFolders{iFolderIter}))];
end
iNumFolders=length(acAllFolders);
acFiles = {};
for iFolderIter=1:iNumFolders
   astrctPLXFiles = dir([ acAllFolders{iFolderIter},filesep,'*.plx']);
   for k=1:length(astrctPLXFiles)
       acFiles = [acFiles, [ acAllFolders{iFolderIter},filesep,astrctPLXFiles(k).name]];
   end
end
iNumFiles=length(acFiles);
fprintf('%d PLX files were found!\n', iNumFiles);
fnResetWaitbar(hMajorWait);
for iFileIter=1:iNumFiles
    fnConvertPLXtoFastDataAccess(acFiles{iFileIter},strctOptions,hMinorWait);
    fnSetWaitbar(hMajorWait,iFileIter/iNumFiles);
end
fprintf('Done!\n');
return;
