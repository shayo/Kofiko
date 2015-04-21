function hPort = fnInitCOMPort(strPort, strInitCommand, strResponse, baudRate, InputBufferSize, fInitTimeSec1,fInitTimeSec2, fWaitTime)
lineTerminator = 10;
%baudRate = 115200;
%InputBufferSize = 100000; % Should be more than enough....
joker='';
specialSettings='';
readTimeout = 5; % 5 sec?
portSettings = sprintf('%s %s BaudRate=%i InputBufferSize=%i Terminator=%i ReceiveTimeout=%f', joker, specialSettings, baudRate, InputBufferSize, lineTerminator, readTimeout );

try
    hPort = IOPort('OpenSerialPort', strPort, portSettings);
catch
    fprintf('Error opening serial port!\n');
    return;
end

    IOPort('Purge',hPort);

WaitSecs(fInitTimeSec1); % allow time to load the sketch?

% Start asynchronous background data collection and timestamping. Use
% blocking mode for reading data -- easier on the system:
asyncSetup = sprintf(' StartBackgroundRead=%i',  1);
IOPort('ConfigureSerialPort', hPort, asyncSetup);

WaitSecs(fInitTimeSec2); % allow time to load the sketch?

IOPort('Purge',hPort);
IOPort('Write',  hPort , [strInitCommand,10]);
IOPort('Write',  hPort , [strInitCommand,10]);

WaitSecs(fWaitTime);
% Really empty? Hope so.
NumBytesAvail =  IOPort('BytesAvailable', hPort);
if NumBytesAvail < length(strResponse)
    fprintf('Failed to get a response from Arduino. Are you sure the correct Sketch is loaded?\n');
    IOPort('ConfigureSerialPort', hPort, 'StopBackgroundRead');
    IOPort('Close', hPort);
    hPort = -1;
    return;
end

strBuffer=IOPort('Read',hPort,0,NumBytesAvail);
aiIndices = strfind(char(strBuffer), strResponse);
if isempty(aiIndices)
    % Try one last time...
    IOPort('Write',  hPort , [strInitCommand,10]);
    WaitSecs(fWaitTime);
    NumBytesAvail =  IOPort('BytesAvailable', hPort);
    if NumBytesAvail < length(strResponse)
        fprintf('Failed to get a response from Arduino. Are you sure the correct Sketch is loaded?\n');
        IOPort('ConfigureSerialPort', hPort, 'StopBackgroundRead');
        IOPort('Close', hPort);
        hPort = -1;
        return;
    end
    
    strBuffer=IOPort('Read',hPort,0,NumBytesAvail);
    aiIndices = strfind(char(strBuffer), strResponse);
    if isempty(aiIndices)
        
        
        fprintf('Failed to get a response from Arduino. Are you sure the correct Sketch is loaded?\n');
        IOPort('ConfigureSerialPort', hPort, 'StopBackgroundRead');
        IOPort('Close', hPort);
        hPort = -1;
        return;
    end
end
    
    return;
    
    
    
