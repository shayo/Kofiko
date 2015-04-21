function astrctAllUnits = fnComputeUnitSNR(astrctAllUnits)
% Compute single unit Signal to noise ratio (see Kelly et al. J.
% Neuroscience 2007)
for k=1:length(astrctAllUnits)
    if isempty(astrctAllUnits(k).m_afTimestamps)
        astrctAllUnits(k).m_fSNR = NaN;
        astrctAllUnits(k).m_afSNR_Time= NaN;
    else
        [astrctAllUnits(k).m_fSNR,astrctAllUnits(k).m_afSNR_Time] = fnComputeUnitSNR_Aux(astrctAllUnits(k).m_a2fWaveforms, astrctAllUnits(k).m_afTimestamps);
    end
end
return

% 
% figure;
% plot(astrctAllUnits(7).m_a2fWaveforms')
% plot(astrctAllUnits(7).m_afSNR_Time)