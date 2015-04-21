function [bOK, strJobID] = fnSubmitToCluster(strScript, strJobInputFile, strJobFolder, strJobUID, acStrDependencyJobID)
% Build the command

if isempty(acStrDependencyJobID)
    strCommand = sprintf('qsub -V -v InputScript=%s %s -N %s -e %s -o %s', ...
        strJobInputFile,strScript,strJobUID,strJobFolder,strJobFolder);
else
    if ~iscell(acStrDependencyJobID)
        acStrDependencyJobID = {acStrDependencyJobID};
    end
    strWait = '';
    for iRunIter=1:length(acStrDependencyJobID)
        strWait=[strWait,':',acStrDependencyJobID{iRunIter}];
    end
    
    strCommand = sprintf('qsub -V -v InputScript=%s %s -N %s -e %s -o %s -W depend=afterok%s', ...
        strJobInputFile,strScript,strJobUID,strJobFolder,strJobFolder,strWait);
end

if exist([strJobFolder,'/',strJobUID,'.finished'],'file')
    delete([strJobFolder,'/',strJobUID,'.finished']);
end;

% Write down the command to a file in the job folder
hFileID = fopen([strJobFolder,'/',strJobUID,'.cmd'],'w+');
fprintf(hFileID,'%s\n',strCommand);
fclose(hFileID);

% Execute the command
[Dummy, strJobID] = system(strCommand);

% Make sure we got it submited
bOK = Dummy == 0;

if bOK
    EOL = 10;
    if strJobID(end) == EOL
        strJobID = strJobID(1:end-1);
    end;
else
    fprintf('%s\n',strJobID);
    strJobID = [];
end
