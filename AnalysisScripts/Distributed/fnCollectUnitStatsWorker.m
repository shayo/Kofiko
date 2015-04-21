function acFilesToTransferBack = fnCollectUnitStatsWorker(strKofikoFile, strPlexonFile, iExperimentIndex, strctConfig)
acFilesToTransferBack = [];

if isempty(strPlexonFile) || isempty(strKofikoFile)
    % This is not a kofiko file!
    error('Missing input files (either Kofiko or Plexon)');
end
    

fnWorkerLog('Reading Kofiko File %s',strKofikoFile);
strctKofiko = load(strKofikoFile);

if ~isfield(strctKofiko,'g_strctAppConfig')
    % This is not a kofiko file!
    fnWorkerLog('Could not analyze file %s  - not a koifko file?!?!?\n',strKofikoFile);
    return;
end
    
if ~isfield(strctKofiko.g_strctAppConfig,'m_strTimeDate')
    strctTmp = dir(strKofikoFile);
    strctKofiko.g_strctAppConfig.m_strTimeDate = strctTmp.date;
end;

fnWorkerLog('Reading Plexon File %s',strPlexonFile);
strctPlexon = fnReadPlexonFileAllCh(strPlexonFile, strctConfig.m_strctChannels);

iNumExperimentsInPlexonFile = length(strctPlexon.m_strctEyeX.m_aiStart);

assert(iNumExperimentsInPlexonFile <= 1);

fnWorkerLog('Extracting experiment information');
[strctExperiment,strctPlexon] = fnExtractSingleSessionInfo(strctKofiko, strctPlexon, strctKofiko.g_strctSystemCodes, iExperimentIndex);


acUnitsStat = fnCollectUnitStats(strctConfig,strctKofiko, strctPlexon,strctExperiment,iExperimentIndex);

% Save units to disk
iNumUnits = length(acUnitsStat);
for iUnitIter=1:iNumUnits
    
    acUnitsStat{iUnitIter}.m_strKofikoFileName = strKofikoFile;
    acUnitsStat{iUnitIter}.m_strPlexonFileName = strPlexonFile;
    
    strctUnit = acUnitsStat{iUnitIter};
    strTimeDate = datestr(datenum(strctUnit.m_strRecordedTimeDate),31);
    strTimeDate(strTimeDate == ':') = '-';
    strTimeDate(strTimeDate == ' ') = '_';
        
    strParadigm = strctUnit.m_strParadigm;
    strParadigm(strParadigm == ' ') = '_';
    strDesr = strctUnit.m_strParadigmDesc;
    strDesr(strDesr == ' ') = '_';
    acFilesToTransferBack{iUnitIter} = sprintf('%s_%s_Exp_%02d_Ch_%03d_Unit_%03d_%s_%s.mat',...
        strctUnit.m_strSubject, strTimeDate,strctUnit.m_iRecordedSession,...
        strctUnit.m_iChannel(1),strctUnit.m_iUnitID(1), strParadigm, strDesr);
    save(acFilesToTransferBack{iUnitIter},  'strctUnit');
end;


return;

