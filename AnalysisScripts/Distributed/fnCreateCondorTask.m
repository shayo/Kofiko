function fnCreateCondorTask(strSubmitFileName, strJobInputFile, strJobLog, strJobOut, strKofikoFileName,strPlexonFile, strUID, acMachinesToUse)
hFileID = fopen(strSubmitFileName,'w+');
fprintf(hFileID,'Universe      = vanilla \r\n');
fprintf(hFileID,'Executable    = Worker.exe \r\n');
fprintf(hFileID,'output        = %s \r\n',strUID);
fprintf(hFileID,'arguments     = %s %s %s\r\n',strJobInputFile,strJobLog,strJobOut);
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


%strPlexonPrefix = strctSession.m_acstrPlexonFileNames{1}(1:end-5);

fprintf(hFileID,'getenv        = false \r\n');
fprintf(hFileID,'\r\n');
fprintf(hFileID,'should_transfer_files = YES \r\n');
fprintf(hFileID,'when_to_transfer_output = ON_EXIT \r\n');
fprintf(hFileID,'\r\n');
fprintf(hFileID,'transfer_input_files  = %s,Worker.exe,Worker.ctf,%s,%s\r\n',...
    strJobInputFile,strKofikoFileName,strPlexonFile);
fprintf(hFileID,'Queue 1 ');
fclose(hFileID);% 

