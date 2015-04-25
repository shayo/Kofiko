function [PlxData] = fnReadDynamicAFCPlexonFile(filename, directoryInformation,ExperimentRecord)
PlxData = [];
eventChannelNumber = 257;
trialStartStrobe = 32690;
trialEndStrobe = 32699;
dataPath = 'e:\data';

if isempty(ExperimentRecord)
	[pathstr,name,ext] = fileparts(filename); 
	load(filename)
end
%[subdirectories, AllFilesInSubDirectories] = subdir(dataPath);


name = [name,'.plx']

% find the plexon file for this experiment
% assume it's in E:\data somewhere
[fileID, plxFilename] = deal([]);

for i = 1:numel(directoryInformation.AllFilesInSubDirectories)
	if max(any(strcmp(name,directoryInformation.AllFilesInSubDirectories{1,i})))
		fileID = find(strcmp(name,directoryInformation.AllFilesInSubDirectories{1,i}))
		plxFilename = [directoryInformation.subdirectories{i},'\',directoryInformation.AllFilesInSubDirectories{i}{1,fileID}];
		[~,~,plxExt] = fileparts(plxFilename)
		if strcmp(plxExt,'.plx')
			
			break;
		else
			[fileID, plxFilename] = deal([]);
			disp('dsadj')
			continue
		end
	end
end
if isempty(plxFilename)
	warning('could not find the plexon file for this experiment')
	return;
end

[analogueData, events, channels] = LoadPlexonFile(plxFilename);

trialStartIndices = find(events.strobeNumber == trialStartStrobe);
trialEndIndices = find(events.strobeNumber == trialEndStrobe);

if ~isequal(size(trialStartIndices), size(trialEndIndices))
	warning('different numbers of trial start and trial end strobewords found, will attempt to discard trials with no end strobes')
end

for iTrials = 1:size(ExperimentRecord,1)
	% validate that this is the right trial using the trial vector
	if isequal(ExperimentRecord(iTrials).trialVec',events.strobeNumber([trialStartIndices(iTrials)+1:trialStartIndices(iTrials)+numel(ExperimentRecord(iTrials).trialVec)]))
		
		% Get the plexon start Timestamp for indexing to the analogue data
		
		%[rte, index] = min(abs(events.timeStamps - 2000));
		
		% get all the AD information from this trial. Different channels may sample at different rates so we have to calculate each
		% channel separately
		
		for iChannel = 1:size(channels,1)
			PlxData(iTrials).trialStartTS = floor(events.timeStamps(trialStartIndices(iTrials))*analogueData(iChannel).adfreq + analogueData(iChannel).timeStamps);
			PlxData(iTrials).AD(iChannel,:) = analogueData(iChannel).ad(trialStartTS:
		
	
	% otherwise, find the correct trial using the trial vector
	else
		[rte, index] = find(vertcat(
		% report that this trial seems to be out of order
		warning(sprintf('trial %s in Plexon file and Experiment Record do not match indices, attempting to find trial',num2str(iTrials)))


end





return;


function [analogueData, events, channels] = LoadPlexonFile(plxFilename)

[n, samplecounts] = plx_adchan_samplecounts(plxFilename)
channels = find(samplecounts);
% load all the analogue channels from this file. Hopefully this won't get too big for memory.
for iChannel = 1:size(channels,1)
	[analogueData(iChannel).adfreq, analogueData(iChannel).n, analogueData(iChannel).timeStamps,...
				analogueData(iChannel).fn, analogueData(iChannel).ad] = plx_ad_v(plxFilename, channels(iChannel));

end
% load the strobe events
[events.count, events.timeStamps, events.strobeNumber] = plx_event_ts(plxFilename, 257);
%{
[analogueData.eyeY.adfreq, analogueData.eyeY.n, analogueData.eyeY.timeStamps, analogueData.eyeY.fn, analogueData.eyeY.ad] = plx_ad_v(plxFilename, 61);
[analogueData.PD.adfreq, analogueData.PD.n, analogueData.PD.timeStamps, analogueData.PD.fn, analogueData.PD.ad] = plx_ad_v(plxFilename, 63);

%}
return;