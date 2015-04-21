function aiTriggers = fnGetNanoStimulatorTriggerCount()
global g_hNanoStimulatorPort

QUERY_CODE = 21;

aiTriggers = [];

IOPort('Purge',g_hNanoStimulatorPort);
IOPort('Write',g_hNanoStimulatorPort,uint8([sprintf('%02d ',QUERY_CODE),10]));
 WaitSecs(0.1);
NumBytesAvail =  IOPort('BytesAvailable', g_hNanoStimulatorPort);
strBuffer=char(IOPort('Read',g_hNanoStimulatorPort,0,NumBytesAvail));
aiIndices = strfind(char(strBuffer), 'TriggerCount');
if ~isempty(aiIndices)
    aiIndices2 = strfind(char(strBuffer), 'OK');
    if ~isempty(aiIndices2 )
        aiTriggers =str2num(strBuffer(aiIndices(1)+13:aiIndices2(1)-1));
    end
end