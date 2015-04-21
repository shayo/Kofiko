function fnPipelineTouchForceChoice_v2(strctInputs)

strDataRootFolder = strctInputs.m_strDataRootFolder;
strConfigFolder   = strctInputs.m_strConfigFolder;
strSession        = strctInputs.m_strSession;

if strDataRootFolder(end) ~= filesep()
    strDataRootFolder(end+1) = filesep();
end;
fnWorkerLog('Starting force choice standard analysis pipline...');
fnWorkerLog('Session : %s',strSession);
fnWorkerLog('Data Root : %s',strDataRootFolder);

strRawFolder = [strDataRootFolder,'RAW',filesep()];
strKofikoFile = fullfile(strRawFolder,[strSession,'.mat']);
strStrobeFile = fullfile(strRawFolder,[strSession,'-strobe.raw']);
strAnalogFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  % any can suffice...
strSyncFile = fullfile(strRawFolder,[strSession,'-sync.mat']);
strConfigFile = [strConfigFolder,'AnalysisPipelines',filesep, 'PipelineTouchForceChoice.xml'];

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'SingleUnitDataEntries',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end;

%% Verify everything is around.
fnCheckForFilesExistence({strKofikoFile,...
    strStrobeFile,strAnalogFile,strSyncFile,strConfigFile});

% Load needed information to do processing
fnWorkerLog('Loading Sync file...');
load(strSyncFile);
fnWorkerLog('Loading Kofiko file...');
strctKofiko = load(strKofikoFile);

%%
strctConfig = fnMyXMLToStruct(strConfigFile);

afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;

acParadigms = fnCellStructToArray( strctKofiko.g_astrctAllParadigms,'m_strName');

iParadigmIndex = find(ismember(acParadigms,'Touch Force Choice'),1,'first');
if isempty(iParadigmIndex)
    fnWorkerLog('Session : %s does not contain force choice. Aborting!',strSession);
    return;
end;


strBehaviorStatFolder = [strDataRootFolder,filesep,'Processed',filesep,'BehaviorStats',filesep()];
if ~exist(strBehaviorStatFolder,'dir')
    mkdir(strBehaviorStatFolder);
end;
fnMidSaccadeStimSpecialScript(strctKofiko,strRawFolder,strSession,strctSync,strBehaviorStatFolder);
return;

function fnCheckForFilesExistence(acFileList)
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        fprintf('The following file is missing: %s\n',acFileList{k});
        error('FileMissing');
    end
end

