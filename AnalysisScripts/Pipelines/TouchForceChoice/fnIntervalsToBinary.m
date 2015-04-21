function abVector = fnIntervalsToBinary(astrctIntervals, iLength)
abVector = zeros(1,iLength)>0;
for k=1:length(astrctIntervals)
abVector(astrctIntervals(k).m_iStart:astrctIntervals(k).m_iEnd) =1;
end
return;
