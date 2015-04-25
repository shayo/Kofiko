function combineExperimentsOffline()

currentDirectory = pwd;
%dir(currentDirectory);
allMatFiles = dir([currentDirectory,'\*.mat']);

[~, ExperimentName, ~] = fileparts(currentDirectory);

ExperimentRecord = struct([]);
%order = sortrows(allMatFiles.datenum);
[~, indices] = sort(vertcat(allMatFiles(:).datenum));
allMatFiles = allMatFiles(indices);

for iFiles = 1:size(allMatFiles,1)
	load([currentDirectory,'\',allMatFiles(iFiles).name])
	ExperimentRecord = vertcat(ExperimentRecord,g_strctDynamicStimLog.TrialLog);

end

save([currentDirectory,'\',ExperimentName],'ExperimentRecord');


return;