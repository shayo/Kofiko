function acFilesToTransferBack = fnWorker(strInputFile,strLogFileName,strOutputFile)
global g_hLogFileID
g_hLogFileID = fopen(strLogFileName,'w+');
acFilesToTransferBack = [];
try
    fnWorkerLog(sprintf('Worker started on machine %s at %s',getenv('COMPUTERNAME'),fnDoubleSlash(pwd())));
    strctTmp = load(strInputFile);
    if ~isfield(strctTmp,'strctJob')
        error('Incorrect input file');
    else
        strctJob = strctTmp.strctJob;
    end

    fnWorkerLog('Analyzing...');
    acFilesToTransferBack = fnExtractStatistics(strctJob);
    fnWorkerLog('Saving Jobargout');
    bJobCrashed = false;
    save(strOutputFile,'bJobCrashed','acFilesToTransferBack');
catch
    acFilesToTransferBack = [];
    fnHandleCrash();
    bJobCrashed = true;
    save(strOutputFile,'bJobCrashed','acFilesToTransferBack');

end

fnWorkerLog('Worker Finished');
fclose(g_hLogFileID);
clear global g_hLogFileID
return;

function acFilesToTransferBack = fnExtractStatistics(strctJob)
iNumAnalysisPipeliens = length(strctJob.m_acAnalysis);
acFilesToTransferBack = [];
for iPipelineIter=1:iNumAnalysisPipeliens
    acFilesToTransferBack = [acFilesToTransferBack,feval(strctJob.m_acAnalysis{iPipelineIter}.m_strAnalysisScript, strctJob.m_acAnalysis{iPipelineIter}.m_acParams{:})];
end

return;


function fnHandleCrash()
strctError = lasterror;
fnWorkerLog('**************Worker crashed*************** ');
fnWorkerLog(strctError.message);
fnPrintStack(strctError.stack);

return;

% 
% function fnCopyFilesToRemoteSystem(strctJob,acFilesToTransferBack)
% iMaxAttempts = 3;
% for iFileIter=1:length(acFilesToTransferBack)
%     fnWorkerLog('Copying %s',acFilesToTransferBack{iFileIter});
% 
%     for iAttempt=1:iMaxAttempts
%         bSuccess = copyfile(acFilesToTransferBack{iFileIter},fullfile(strctJob.m_strOutputFolder,acFilesToTransferBack{iFileIter}));
%         if bSuccess ~= 0
%             break
%         end
%         if (bSuccess == 0) && iAttempt == iMaxAttempts
%             error(sprintf('Failed to copy input file %s to %s',fnDoubleSlash(strctJob.m_astrctInputFiles{iFileIter}),fnDoubleSlash(pwd())));
%         else
%             fnWorkerLog('Timeout. Trying again...');
%             tic
%             while toc < 5
%             end
%         end
%     end
% end
% return;
% 
% function fnCopyFilesFromRemoteSystem(strctJob)
% iNumAttempts = 3;
% if isfield(strctJob,'m_astrctInputFiles')
%     for iFileIter=1:length(strctJob.m_astrctInputFiles)
% %         if ~exist(strctJob.m_astrctInputFiles{iFileIter},'file')
% %             error(sprintf('Failed to find input file %s',fnDoubleSlash(strctJob.m_astrctInputFiles{iFileIter})));
% %         end;
%         fnWorkerLog('Copying %s',strctJob.m_astrctInputFiles{iFileIter});
%         for iAttemptIter=1:iNumAttempts
%             bSuccess = copyfile(strctJob.m_astrctInputFiles{iFileIter},'.','f');
%             if (bSuccess~= 0)
%                 break;
%             end
%             if (bSuccess == 0) && iAttemptIter == iNumAttempts
%                 error(sprintf('Failed to copy input file %s',strctJob.m_astrctInputFiles{iFileIter}));
%             else
%                 fnWorkerLog('Timeout...Trying again');
%                 tic
%                 while toc < 5
%                 end
%             end
%         end
%     end
% end
% return;


function fnPrintStack(astrctStack)
fnWorkerLog('');
for i = 1: size(astrctStack, 1)
    strctStackElement = astrctStack(i);
    disp(['In <a href="error:' strctStackElement.file ',' num2str(strctStackElement.line) ',1">' strctStackElement.name ' at ' ...
        num2str(strctStackElement.line) '</a>']);
    fnWorkerLog(fnDoubleSlash(['In ',strctStackElement.file, ',' ...
        num2str(strctStackElement.line),' >',...
        strctStackElement.name, ' at ', num2str(strctStackElement.line)]));
end;
return;

function strDoubleSlash = fnDoubleSlash(strSingleSlash)
strDoubleSlash = '';
for k=1:length(strSingleSlash)
    switch strSingleSlash(k)
        case '\'
            strDoubleSlash(end+1) = '\';
            strDoubleSlash(end+1) = '\';
        case '%'
            strDoubleSlash(end+1) = '%';
            strDoubleSlash(end+1) = '%';
        otherwise
            strDoubleSlash(end+1) = strSingleSlash(k);
    end;
end;
