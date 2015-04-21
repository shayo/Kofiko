% res=fnDAQ('Init',0);
while (1)
GatePort = 18;
TriggerPort = 19;
TriggerDelayMS = 1;
GatePeriodMS = 3;
FirstPulseLengthMS = 0.15;
SecondPulseLengthMS = 0.15;
InterPulseIntervalMS = 0.1;
fnDAQ('DelayedTrigger',GatePort,TriggerPort,TriggerDelayMS,GatePeriodMS,FirstPulseLengthMS,SecondPulseLengthMS,InterPulseIntervalMS );
WaitSecs(0.5);

end

clear mex
res=fnDAQ('Init',0);
fnDAQ('WaveFormOut');
