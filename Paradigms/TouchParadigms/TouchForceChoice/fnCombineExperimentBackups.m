function fnCombineExperimentBackups()
global g_strctParadigm


strExperimentPath = [g_strctParadigm.m_strLogPath,'\',g_strctParadigm.m_strExperimentName,'\'];
allMatFiles = dir([strExperimentPath,'*.mat']);
ExperimentRecord = struct([]);
[~, indices] = sort(vertcat(allMatFiles(:).datenum));
allMatFiles = allMatFiles(indices);

for iFiles = 1:size(allMatFiles,1)
	load([strExperimentPath,allMatFiles(iFiles).name])
	ExperimentRecord = vertcat(ExperimentRecord,g_strctDynamicStimLog.TrialLog);

end

save([strExperimentPath,'\',g_strctParadigm.m_strExperimentName],'ExperimentRecord');
return;