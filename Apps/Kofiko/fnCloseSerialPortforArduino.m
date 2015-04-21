function fnCloseSerialPortforArduino()
global g_strctDAQParams
fprintf('Closing Arduino serial port \n');
try
IOPort('ConfigureSerialPort', g_strctDAQParams.m_hArduino, 'StopBackgroundRead');
% Close port and driver:
IOPort('Close', g_strctDAQParams.m_hArduino);
catch
end