function strJobInputFileName=fnGenerateJobInputFileForNeuralAnalysis(strSubmitFolder,strJobOutputFolder,strctConfig, strctSession,iPlexonFileIter)
strJobUniqueID = [strctSession.m_strUID,'_IN_',num2str(iPlexonFileIter-1)];

strctJob.m_astrctInputFiles{1} = strctSession.m_strKofikoFileName;
strctJob.m_astrctInputFiles{2} = strctSession.m_acstrPlexonFileNames{iPlexonFileIter};
[strInputPath, strKofikoFile,strExt] = fileparts(strctSession.m_strKofikoFileName);
[strDummy, strPlexonFile,strPlxExt] = fileparts(strctSession.m_acstrPlexonFileNames{iPlexonFileIter});

strctAnalysisCollectUnitStats.m_strAnalysisScript = 'fnCollectUnitStatsWorker';
strctAnalysisCollectUnitStats.m_acParams{1} = [ strKofikoFile,strExt];
strctAnalysisCollectUnitStats.m_acParams{2} =  [strPlexonFile,strPlxExt];
strctAnalysisCollectUnitStats.m_acParams{3} = iPlexonFileIter;
strctAnalysisCollectUnitStats.m_acParams{4} = strctConfig;

strctJob.m_strOutputFolder = strJobOutputFolder;
strctJob.m_acAnalysis{1} = strctAnalysisCollectUnitStats;

strJobInputFileName = [strSubmitFolder,strJobUniqueID,'.mat']; 
save(strJobInputFileName,'strctJob');
return;