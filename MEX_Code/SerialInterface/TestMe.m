% Test Serial Interface
addpath('..\..\MEX\win32\');
hPort = fndllSerialInterface('Open','COM5');

fndllSerialInterface('Send',hPort ,['setbit 4 1',10]);

fndllSerialInterface('Close',hPort );
