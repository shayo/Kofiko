function fnGetSpikesFromPlexon()
global g_strctPlexon g_strctParadigm

%raw_spikeCounts = PL_GetSpikeCounts(g_strctPlexon.m_iServerID);
%[raw_tsCount, raw_timeStamps] = PL_GetTS(g_strctPlexon.m_iServerID);


% Output:
%   n - 1 by 1 matrix, number of waveforms retrieved
%
%   t - n by 4 matrix, timestamp info:
%       t(:, 1) - timestamp type (1 - neuron, 4 - external event)
%       t(:, 2) - channel numbers
%       t(:, 3) - unit numbers
%       t(:, 4) - timestamps in seconds
%
%   w - n by wf_len matrix of waveforms, where wf_len is the waveform length
%       (in data points)
%       w(1,:) - first waveform, w(2,:) - second waveform, etc.
%       waveforms for external events (when t(:,1) == 4) are all zeros
[g_strctPlexon.m_strctLastCheck.m_iWFCount,...
 g_strctPlexon.m_strctLastCheck.m_afTimeStamps,...
 g_strctPlexon.m_strctLastCheck.m_afWaveForms] = PL_GetWFEvs(g_strctPlexon.m_iServerID);
%{
 = n;
 = zeros(size(TS));
g_strctPlexon.m_strctLastCheck.m_afTimeStamps = TS;
 = zeros(size(WF));
g_strctPlexon.m_strctLastCheck.m_afWaveForms = WF;
%}

% Separate strobe events
%strobeIndices = g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,2) == 257,:);

g_strctPlexon.m_strctLastCheck.m_aiStrobeEvents = zeros(size(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,2) == 257),1),4);

g_strctPlexon.m_strctLastCheck.m_aiStrobeEvents = g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,2) == 257,:);
if any(g_strctPlexon.m_strctLastCheck.m_aiStrobeEvents == 32757)
	g_strctPlexon.m_fLastTimeStampSync(1) = g_strctPlexon.m_strctLastCheck.m_aiStrobeEvents(g_strctPlexon.m_strctLastCheck.m_aiStrobeEvents == 32757,4);
	g_strctPlexon.m_fLastTimeStampSync(2) = GetSecs();
end
% separate noise (Unsorted spikes)
g_strctPlexon.m_strctLastCheck.m_afUnsortedSpikes = g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,3) == 0,:);

% Separate spikes, events, etc by channel, not including external events
for iUnits = 1:max(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,1) ~= 4))
	%find this channel's indices
	unitIndex = g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,3) == iUnits,:);
	
	unitIndex = g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,3) == iUnits;
	
	g_strctPlexon.m_strctLastCheck.m_strctChannels(iUnits).m_afWaveForms = zeros(size(g_strctPlexon.m_strctLastCheck.m_afWaveForms(...
														unitIndex,:)));
														
	g_strctPlexon.m_strctLastCheck.m_strctChannels(iUnits).m_afWaveForms =  g_strctPlexon.m_strctLastCheck.m_afWaveForms(unitIndex,:);
	
	g_strctPlexon.m_strctLastCheck.m_strctChannels(iUnits).m_afTimeStamps = zeros(size(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(...
														unitIndex,:)));
														
	g_strctPlexon.m_strctLastCheck.m_strctChannels(iUnits).m_afTimeStamps = g_strctPlexon.m_strctLastCheck.m_afTimeStamps(unitIndex,:);
	
	g_strctPlexon.m_strctLastCheck.m_strctChannels(iUnits).m_aiCounts = size(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(unitIndex),1);
end
[g_strctPlexon.m_strctLastCheck.m_iTrialStartIndices,g_strctPlexon.m_strctLastCheck.m_iStrobeTrialStartIndices] = deal([]);
g_strctPlexon.m_strctLastCheck.m_iTrialStartIndices = find(...
                g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,3) == ...
                g_strctParadigm.m_strctStatServerDesign.TrialStartCode);
g_strctPlexon.m_strctLastCheck.m_iStrobeTrialStartIndices = find(g_strctPlexon.m_strctLastCheck.m_aiStrobeEvents(:,3) ==...
    g_strctParadigm.m_strctStatServerDesign.TrialStartCode);

return;