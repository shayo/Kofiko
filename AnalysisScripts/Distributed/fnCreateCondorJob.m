function fnCreateCondorJob(strSubmitFileName, strctSession, iNumTasksInJob, acMachinesToUse)
hFileID = fopen(strSubmitFileName,'w+');
fprintf(hFileID,'Universe      = vanilla \r\n');
fprintf(hFileID,'Executable    = Worker.exe \r\n');
fprintf(hFileID,'output        = %s_LOG_$(process).txt \r\n',strctSession.m_strUID);
fprintf(hFileID,'arguments     = %s_IN_$(process).mat %s_LOG_$(process).txt %s_OUT_$(process).mat \r\n',strctSession.m_strUID,strctSession.m_strUID,strctSession.m_strUID);
if isempty(acMachinesToUse)
    fprintf(hFileID,'Requirements = (Arch == "INTEL") && (OpSys == "WINNT50" || OpSys == "WINNT51" || OpSys == "WINNT60" || OpSys == "WINNT61") && Memory >= 500 \r\n');
else
    fprintf(hFileID,'Requirements = (Arch == "INTEL") && ( OpSys == "WINNT51" || OpSys == "WINNT61") && Memory >= 500 && (');
    if length(acMachinesToUse) == 1
        fprintf(hFileID,'(Machine == "%s")',acMachinesToUse{1});
    else
        for k=1:length(acMachinesToUse)-1
            fprintf(hFileID,'(Machine == "%s") || ',acMachinesToUse{k});
        end
        fprintf(hFileID,'(Machine == "%s") ',acMachinesToUse{end});
    end
    fprintf(hFileID,')\r\n');
end


strPlexonPrefix = strctSession.m_acstrPlexonFileNames{1}(1:end-5);

%  || (OpSys == "WINNT61")) && (Disk >= DiskUsage) && ((Memory * 1024) >= ImageSize) && (HasFileTransfer)\r\n
fprintf(hFileID,'getenv        = false \r\n');
fprintf(hFileID,'log           = %s_CondorLog_$(process).txt \r\n',strctSession.m_strUID);
fprintf(hFileID,'\r\n');
fprintf(hFileID,'should_transfer_files = YES \r\n');
fprintf(hFileID,'when_to_transfer_output = ON_EXIT \r\n');
fprintf(hFileID,'\r\n');
fprintf(hFileID,'transfer_input_files  = %s_IN_$(process).mat,Worker.exe,Worker.ctf,%s,%s$(process).plx\r\n',...
    strctSession.m_strUID,strctSession.m_strKofikoFileName,strPlexonPrefix);
%fprintf(hFileID,'transfer_output_files = %s_OUT_$(process).mat, %s_LOG_$(process).txt\r\n',strJobName,strJobName);
fprintf(hFileID,'Queue %d ', iNumTasksInJob);
fclose(hFileID);% 

