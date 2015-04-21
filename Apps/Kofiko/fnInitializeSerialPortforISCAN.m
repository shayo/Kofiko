function bOK= fnInitializeSerialPortforISCAN()
global g_strctDAQParams

% Many assumptions that should be moved to the XML config at some point....
% Thanks to Sebastian for finding all this stuff out!
hISCAN = [];
bOK = false;

% Assume that a single datapacket is no more than 16 Bytes, including
% any terminator bytes:
maxComponents = 3;	% horizontal H1, vertical V1, pupil diameter D1
maxReadQuantum = maxComponents * 7 + 2;	% last entry is followed by a tab!
lineTerminator = 10;
sampleFreq = 120;	
baudRate = 115200;

InputBufferSize = maxReadQuantum * sampleFreq * 60 * 60;	% Since we are pooling data at 2kHz, 60 seconds should be more than enough.... :)
joker='';    
specialSettings='';
readTimeout = min(21, max(10 * 1/sampleFreq, 15));
portSettings = sprintf('%s %s BaudRate=%i InputBufferSize=%i Terminator=%i ReceiveTimeout=%f', joker, specialSettings, baudRate, InputBufferSize, lineTerminator, readTimeout );

try
    g_strctDAQParams.m_hISCAN = IOPort('OpenSerialPort', g_strctDAQParams.m_strEyeSignalSerialCOM, portSettings);
catch
    fprintf('Error opening serial port!\n');
    return;
end
iscan_track_on_code = uint8(hex2dec('80'));
iscan_track_off_code = uint8(hex2dec('81'));

% Stop tracker, if not already stopped:
IOPort('Purge', g_strctDAQParams.m_hISCAN);

IOPort('Write',  g_strctDAQParams.m_hISCAN , iscan_track_off_code);

% Wait a bit...
WaitSecs(0.5);

% Purge data buffers, read and discard remaining junk:
IOPort('Purge', g_strctDAQParams.m_hISCAN);

WaitSecs(0.5);

% Really empty? Hope so.
if IOPort('BytesAvailable', g_strctDAQParams.m_hISCAN) > 0
    warning('ISCAN: data available in buffer even after we switched tracking off ?!?!?'); %#ok
end
% Configure background read.
asyncSetup = sprintf(' BlockingBackgroundRead=1 ReadFilterFlags=4');
IOPort('ConfigureSerialPort', g_strctDAQParams.m_hISCAN, asyncSetup);

% Start tracker:
IOPort('Write', g_strctDAQParams.m_hISCAN, iscan_track_on_code);
% Start asynchronous background data collection and timestamping. Use
% blocking mode for reading data -- easier on the system:
asyncSetup = sprintf(' StartBackgroundRead=%i',  maxReadQuantum);
IOPort('ConfigureSerialPort', g_strctDAQParams.m_hISCAN, asyncSetup);
bOK=true;
return;

