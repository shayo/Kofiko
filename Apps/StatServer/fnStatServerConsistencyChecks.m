function fnStatServerConsistencyChecks()
global g_strctCycle g_strctConfig g_strctWindows g_strctNeuralServer

fCurrTime = GetSecs();
if g_strctConfig.m_strctConsistencyChecks.m_bLostUnits && (fCurrTime-g_strctCycle.m_fConsistencyTimerUnits  > g_strctConfig.m_strctConsistencyChecks.m_fLostUnitCheckSec)
    g_strctCycle.m_fConsistencyTimerUnits   = fCurrTime;
     [a2fLastKnownTS, fCurrTS] = TrialCircularBuffer('GetUnitsLastKnownTS');
     a2bPrevLost = g_strctNeuralServer.m_a2bLostWarning;
     
     g_strctNeuralServer.m_a2bLostWarning = ~isnan(a2fLastKnownTS) & (fCurrTS - a2fLastKnownTS > g_strctConfig.m_strctConsistencyChecks.m_fDeclareUnitThresSec);

     aiUnitLost = find(g_strctNeuralServer.m_a2bLostWarning & ~a2bPrevLost & g_strctNeuralServer.m_a2iCurrentActiveUnits)>0; % We only care about units being recorded...
     if ~isempty(aiUnitLost)
        [aiChannel,aiUnit] = ind2sub(size(g_strctNeuralServer.m_a2bLostWarning),aiUnitLost);
        for k=1:length(aiUnitLost)                     
             fnStatCriticalLog('Channel %d, Unit %d may be lost!',  aiChannel(k),aiUnit(k));
        end
     else
         fnStatLog('Consistency Check OK');
     end
     
end