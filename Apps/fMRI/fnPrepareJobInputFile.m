function strJobInputFile=fnPrepareJobInputFile(strJobFolder,strJobUID, acParams,astrctExtraParse)
strJobInputFile = fullfile(strJobFolder,[strJobUID,'.input']);
strJobLogFile = fullfile(strJobFolder,[strJobUID,'.log']);
    
% Append acParams with some more variables
acParams = fnAddParam(acParams,'JobUID',strJobUID);
acParams = fnAddParam(acParams,'JobInputFile',strJobInputFile);
acParams = fnAddParam(acParams,'JobLogFile',strJobLogFile);
acParams = fnAddParam(acParams,'JobFolder',strJobFolder);

hFileID = fopen(strJobInputFile,'w+');

fprintf(hFileID,'#! /bin/csh -f\n');
fprintf(hFileID,'echo Job %s\n',strJobUID);

% for iParamIter=1:length(acParams)
%     fprintf(hFileID,'echo %s %s\n',acParams{iParamIter}.Name,acParams{iParamIter}.Value);
% end

for iParamIter=1:length(acParams)
    strValue = fnParseString(acParams{iParamIter}.Value, astrctExtraParse);
    % Switch white spaces to underscore
    if sum(strValue == ' ') > 0
        strValue = ['"',strValue,'"'];
   % strValue(strValue==' ') = '_';
    end
    fprintf(hFileID,'setenv %s %s\n',acParams{iParamIter}.Name,strValue);
end
fprintf(hFileID,'\n');

fclose(hFileID);
return;
