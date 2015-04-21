function FuncPreprocSubmit(astrctRuns, strctMotionTemplate, acParams)
% This script submit the preprocessing pipeline on a set of EPIs
%
% Inputs:
% 
%

bUseCluster = str2num(fnGetParameterValue(acParams,'UseCluster'))>0;

if ~bUseCluster
    h=msgbox('Local processing has not been implemented yet!');
    waitfor(h);
   return; 
end

EOL = 10;
strSessionID = fnGetParameterValue(acParams,'SessionID');
%% Things that need to be declared for the prepare job
strSubfolderBOLD = fnGetParameterValue(acParams,'Subfolder_BOLD');
strEPIRoot = fnParseString(fullfile(fnGetParameterValue(acParams,'UnpackedRoot'),strSessionID,''),[]);

strJobFolder = [strEPIRoot,'/jobs/'];
if ~exist(strJobFolder,'dir')
    mkdir(strJobFolder);
end;

strKofikoFolder = [strEPIRoot,'/kofiko'];
strBoldRoot = [strEPIRoot,strSubfolderBOLD];
strMCFolder = [strBoldRoot,fnGetParameterValue(acParams,'Subfolder_Template')];
strMCFile = [strMCFolder,'/',fnGetParameterValue(acParams,'MotionCorrection_Template')];

strMasksFolder = [strBoldRoot,fnGetParameterValue(acParams,'Subfolder_Masks')];

strJobUID = [strSessionID,'_EPIPREPARE'];

acParams = fnSetParameterValue(acParams,'ScriptsFolder',pwd());

acParams = fnSetParameterValue(acParams,'Template4D_file',strctMotionTemplate.m_strBOLDFile);
acParams = fnSetParameterValue(acParams,'Template4D_frame',num2str(strctMotionTemplate.m_iSelectedTimePoint));

acParams = fnSetParameterValue(acParams,'TemplateFolder',strMCFolder);
acParams = fnSetParameterValue(acParams,'Template3DFileFullPath',strMCFile);

acParams = fnSetParameterValue(acParams,'B0_Mag_FullPath',astrctRuns(strctMotionTemplate.m_iFromRunIndex).m_strFieldMag);
acParams = fnSetParameterValue(acParams,'B0_Phase_FullPath',astrctRuns(strctMotionTemplate.m_iFromRunIndex).m_strFieldPhase);

acParams = fnSetParameterValue(acParams,'MasksFolder',strMasksFolder);

acParams = fnSetParameterValue(acParams,'KofikoFolder',strKofikoFolder);

strJobInputFile=fnPrepareJobInputFile(strJobFolder,strJobUID, acParams,[]);


%% "PrepareJob"
% This jobs will prep the motion correction template needed later
% all subsequent jobs will start running only after this one has finished!

strScript = 'FuncPreprocPrepare.csh';

[bOK, strPrepJobID] = fnSubmitToCluster(strScript,strJobInputFile,strJobFolder,strJobUID,[]);
if ~bOK
   fprintf('Failed to submit %s\n', strJobUID);
   fprintf('Aborting!\n');
   return;
end


fprintf('%s\n',strPrepJobID);
%% Job per EPI



acParams = fnSetParameterValue(acParams,'InputFolder',[strEPIRoot,'/']);


strPipelineScript = fnGetParameterValue(acParams,'Pipeline');
    
iNumRuns = length(astrctRuns);
for iRunIter=1:iNumRuns
    
    strJobUID = [strSessionID,'_EPIPREPROC_',astrctRuns(iRunIter).m_strRunFolder];
    
    acParams = fnSetParameterValue(acParams,'Seq',astrctRuns(iRunIter).m_strRunFolder);
    acParams = fnSetParameterValue(acParams,'InputFileFullPath',astrctRuns(iRunIter).m_strEPI);

    acParams = fnSetParameterValue(acParams,'B0_Mag_FullPath',astrctRuns(iRunIter).m_strFieldMag);
    acParams = fnSetParameterValue(acParams,'B0_Phase_FullPath',astrctRuns(iRunIter).m_strFieldPhase);
    strJobInputFile=fnPrepareJobInputFile(strJobFolder,strJobUID, acParams,[]);
    
    strScript = strPipelineScript;
    [bOK, strJobID] = fnSubmitToCluster(strScript,strJobInputFile,strJobFolder,strJobUID,strPrepJobID);
    if bOK
        acstrPreprocessJobID{iRunIter} = strJobID;
        fprintf('%s\n',acstrPreprocessJobID{iRunIter});
    else
        fprintf('Failed to submit %s\n',strJobUID);
    end
%     [Dummy, acstrPreprocessJobID{iRunIter}] = system(sprintf(...
%         'qsub -V -v InputScript=%s $MYSCRIPTS_DIR/FuncPreproc/%s -N %s -e %s -o %s -W depend=afterok:%s', ...
%         strJobInputFile,strPipelineScript,strJobUID,strJobFolder,strJobFolder,strPrepJobID));
    
%     if acstrPreprocessJobID{iRunIter}(end) == EOL
%         acstrPreprocessJobID{iRunIter} = acstrPreprocessJobID{iRunIter}(1:end-1);
%     end;
    
    
end



%% Email Job. Wait for all previous ones to finish.

% bSendEmail = str2num(fnGetParameterValue(acParams,'EmailWhenDone'))>0;
% if bSendEmail
%     strUserAddress = fnParseString(fnGetParameterValue(acParams,'EmailAddress'),[]);
%     strWait = '';
%     for iRunIter=1:iNumRuns
%         strWait=[strWait,':',acstrPreprocessJobID{iRunIter}];
%     end
%     strID = [strSessionID,'_EPIPREPROC_DONE'];
%     strAdditionalCmd = sprintf('echo sleep 1 | qsub -N %s -o %s -e %s -m e -M %s -W afterok%s',strID,...
%         strJobFolder,strJobFolder,strUserAddress,strWait);
%     [A,strEmailJob]=system(strAdditionalCmd);
% end



return;

