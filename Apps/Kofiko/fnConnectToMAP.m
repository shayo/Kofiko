function strctPlexonMAP = fnConnectToMAP()
strctPlexonMAP = [];

hPlexon = PL_InitClient(0);
if hPlexon == 0
    return;
end;

strctPlexonMAP.m_hPlexonServer = hPlexon;

pars = PL_GetPars(strctPlexonMAP.m_hPlexonServer);

% ------------------------------------------------------------------------
% basic parameters
fprintf('Server Parameters:\n\n');
fprintf('DSP channels: %.0f\n', pars(1));
fprintf('Timestamp tick (in usec): %.0f\n', pars(2));
fprintf('Number of points in waveform: %.0f\n', pars(3));
fprintf('Number of points before threshold: %.0f\n', pars(4));
fprintf('Maximum number of points in waveform: %.0f\n', pars(5));
fprintf('Total number of A/D channels: %.0f\n', pars(6));
fprintf('Number of enabled A/D channels: %.0f\n', pars(7));
fprintf('A/D frequency (for continuous "slow" channels, Hz): %.0f\n', pars(8));
fprintf('A/D frequency (for continuous "fast" channels, Hz): %.0f\n', pars(13));
fprintf('Server polling interval (msec): %.0f\n', pars(9));

strctPlexonMAP.m_hAD_Freq = pars(8);

return;

