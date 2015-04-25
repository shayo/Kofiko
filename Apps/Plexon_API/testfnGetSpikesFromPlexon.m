function [g_strctPlexon] = fnGetSpikesFromPlexon(g_strctPlexon)
g_strctPlexon.m_strctLastCheck = [];


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


[g_strctPlexon.m_strctLastCheck.m_iWFCount, g_strctPlexon.m_strctLastCheck.m_afTimeStamps, g_strctPlexon.m_strctLastCheck.m_afWaveForms] = PL_GetWFEvs(g_strctPlexon.m_iServerID);

% Sum the spikes that are in the first sorted channel
g_strctPlexon.m_strctLastCheck.m_afCounts(1) = size(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(:,3) == 1),1);



%g_strctPlexon.m_strctLastCheck.m_afCounts = raw_spikeCounts;
%g_strctPlexon.m_strctLastCheck.m_iTSCount =  raw_tsCount;
%g_strctPlexon.m_strctLastCheck.m_afTimeStamps = raw_timeStamps;

%disp(g_strctPlexon.m_strctLastCheck.m_iTSCount)
%disp(g_strctPlexon.m_strctLastCheck.m_afTimeStamps)
%disp(g_strctPlexon.m_strctLastCheck.m_afCounts(1))

return;