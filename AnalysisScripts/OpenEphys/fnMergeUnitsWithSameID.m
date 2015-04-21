function astrctSpikesMerged=fnMergeUnitsWithSameID(astrctSpikes)
IDs=cat(1,astrctSpikes.m_iUnitIndex);
[aiUniqueIDs,~,aiMapToUnique]=unique(IDs);
for k=1:length(aiUniqueIDs)
    aiRelevant = find(aiMapToUnique == k);
    astrctSpikesMerged(k).m_iUnitIndex = aiUniqueIDs(k);
    astrctSpikesMerged(k).m_afTimestamps = cat(2,astrctSpikes(aiRelevant).m_afTimestamps);
    astrctSpikesMerged(k).m_iChannel = astrctSpikes(aiRelevant(1)).m_iChannel;
    astrctSpikesMerged(k).m_afInterval = [min(astrctSpikesMerged(k).m_afTimestamps),max(astrctSpikesMerged(k).m_afTimestamps)];
    astrctSpikesMerged(k).m_a2fWaveforms = cat(1,astrctSpikes(aiRelevant).m_a2fWaveforms);
end
