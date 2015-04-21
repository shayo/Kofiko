function fnParseNeuralDataPackage(acInputFromSpikeServer)
global g_strctCycle
strCommand = acInputFromSpikeServer{1};
switch strCommand
    case 'DataPacket'
        dbg = 1;
        % Fill the following....
%         g_strctCycle.m_strctStatistics.m_a2fSpikeTimes
%         g_strctCycle.m_strctStatistics.m_aiSpikeTimeIndex
%                 
%         g_strctCycle.m_strctStatistics.m_a2fLFPData
%         g_strctCycle.m_strctStatistics.m_a2fLFPTimeStamp
%         g_strctCycle.m_strctStatistics.m_aiLFPCounter
%         g_strctCycle.m_strctStatistics.m_abFullLFPCycle
        
end

return;
