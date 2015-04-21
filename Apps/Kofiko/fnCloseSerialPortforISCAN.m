function fnCloseSerialPortforISCAN()
global g_strctDAQParams
fprintf('Closing ISCAN serial port \n');
try
IOPort('ConfigureSerialPort', g_strctDAQParams.m_hISCAN, 'StopBackgroundRead');
iscan_track_off_code = uint8(hex2dec('81'));

% Now the driver has discarded the data and is in synchronous manual mode
% of operation again. You could add any kind of IOPort commands to shut
% down your serial device now...

% Stop tracker:
IOPort('Write', g_strctDAQParams.m_hISCAN, iscan_track_off_code);

% Wait a bit...
WaitSecs(0.5);

% Close port and driver:
IOPort('Close', g_strctDAQParams.m_hISCAN);
catch
end