function fnCloseCOMPort(hPort)
IOPort('ConfigureSerialPort', hPort, 'StopBackgroundRead');
IOPort('Close', hPort);
