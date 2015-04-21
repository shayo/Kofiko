function fnNanoStimulatorStopStimulation
global g_hNanoStimulatorPort
ABORT_STIMULATION = 22;
if ~isempty(g_hNanoStimulatorPort)
    try
        Res=IOPort('Write',  g_hNanoStimulatorPort , uint8([sprintf('%02d ',ABORT_STIMULATION),10]));
    catch
    end
end