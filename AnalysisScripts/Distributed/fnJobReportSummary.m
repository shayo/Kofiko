strJobFolder = 'D:\Data\Doris\Electrophys\Jobs\100908_164329\';
astrctFiles = dir(strJobFolder);
iNumFiles = length(astrctFiles);
abInputFile = zeros(1,iNumFiles)>0;
abOutputFile = zeros(1,iNumFiles)>0;
abLogFile = zeros(1,iNumFiles)>0;
abCrashed = zeros(1,iNumFiles)>0;
acAllNames = {astrctFiles.name};
afFileSize = cat(1,astrctFiles.bytes);
for iFileIter=1:iNumFiles
    abInputFile(iFileIter) = ~isempty(strfind( astrctFiles(iFileIter).name,'_IN_'));
    abOutputFile(iFileIter) = ~isempty(strfind( astrctFiles(iFileIter).name,'_OUT_'));
    abLogFile(iFileIter) = ~isempty(strfind( astrctFiles(iFileIter).name,'_LOG_'));
    if abOutputFile(iFileIter)
        strctTmp = load([strJobFolder,astrctFiles(iFileIter).name]);
        abCrashed(iFileIter) = strctTmp.bJobCrashed > 0;
    end
end
fprintf('%d Jobs submitted \n',sum(abInputFile));
fprintf('%d Jobs have an output file\n',sum(abOutputFile));
fprintf('%d Jobs have a non zero log file \n',sum(abLogFile & afFileSize'>0));
fprintf('%d Jobs crashed \n',sum(abOutputFile & abCrashed));

%% Why did it crash?
aiCrashed = find(abCrashed);
iCrashIndex = aiCrashed(9);
strFirstCrash = astrctFiles(iCrashIndex).name;
strLog = strrep(strrep(strFirstCrash,'_OUT_','_LOG_'),'.mat','.txt');
eval(['!notepad ',strJobFolder,strLog])

%% Recompile...
fnCompileWorker()
copyfile('.\CompiledWorker\Worker.exe',strJobFolder,'f')
copyfile('.\CompiledWorker\Worker.ctf',strJobFolder,'f')

%% Resubmit crashed jobs
for iCrashedJobsIter=1:length(aiCrashed)
    
    strOutputFile = astrctFiles(aiCrashed(iCrashedJobsIter)).name;
    strInputFile = strrep(strOutputFile,'_OUT_','_IN_');
    strLogFile = strrep(strrep(strOutputFile,'_OUT_','_LOG_'),'.mat','.txt');
    strSubmitFileName = sprintf('submit_crash_%s_%d.txt',strOutputFile(1:13),iCrashedJobsIter);
    aiSep = find(strInputFile=='_');
    strUID = strInputFile(1:aiSep(3)-1);
    fprintf('Submitting %d [%s]\n',iCrashedJobsIter,strUID);
    [strP,strF,strE]=fileparts(strInputFile);
    iTaskNumber = str2num(strF(aiSep(4)+1:end));
    % Load original submit file to know where files are stored...
    strOriginalSubmitFile = [strJobFolder,'submit_',strUID,'.txt'];
    strReSubmitFile = [strJobFolder,'resubmit_',strUID,'_',num2str(iTaskNumber),'.txt'];
    
    S = fileread(strOriginalSubmitFile);
    Sn = regexprep(S, '\$\(process\)', num2str(iTaskNumber));
    iIndex = strfind(Sn,'Queue');
    Sn(iIndex:end) = [];
    strQueue = sprintf('\r\nQueue 1\r\n');
    Sn = [Sn, strQueue];
    
    hFileID = fopen(strReSubmitFile,'w+');
    fprintf(hFileID,'%s',Sn);
    fclose(hFileID);
    strCurrPwd = pwd();
    cd(strJobFolder);
    eval(['!condor_submit ',strReSubmitFile]);
    cd(strCurrPwd);
end
%%



% Find input jobs that have no output file
aiInputFiles = find(abInputFile);
iNumJobs = length(aiInputFiles);
acAllFileNames = {astrctFiles.name};
abJobHasOutputFile = zeros(1,iNumJobs)>0;
for iFileIter=1:iNumJobs
     strDesiredOutFile = strrep(astrctFiles(aiInputFiles(iFileIter)).name,'_IN_','_OUT_');
     abJobHasOutputFile(iFileIter)=ismember(strDesiredOutFile,acAllFileNames);
     if ~abJobHasOutputFile(iFileIter)
         fprintf('%s has no out file\n',astrctFiles(aiInputFiles(iFileIter)).name)
     end
     
end

find(~abJobHasOutputFile)


