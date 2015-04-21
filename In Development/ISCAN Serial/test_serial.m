function [ output_args ] = test_serial( input_args )
%TEST_SERIAL test serial communication between PTB scripts and ISCAN
%   So far only serial trigger has been implemented...
try
	use_serial = 1;
	iscan_active = 0;
	if use_serial == 1,
		port = FindSerialPort([], 1, 1);
	
		if (~isempty(port)),
			configString = 'Lenient BaudRate=57600 Parity=None DataBits=8 StopBits=1 FlowControl=None OutputBufferSize=64 InputBufferSize=64';
			[serial_h, errmsg] = IOPort('OpenSerialPort', port, configString);
			if isempty(errmsg),
				disp(errmsg);
			end
			% could not open serial port
			if (serial_h < 0),
				disp('Could not open serial port, deactivating serial port use...');
				use_serial = 0;
			end
			% 		serial_port = 'com1';
			% 		portA = PsychSerial('Open', 'com1', 'com1', 9600);
		else
			% no serial port exsts
			disp('No serial port found, deactivating serial port use...');
			use_serial = 0;
		end
		% the ISCAN "codons"
		iscan_start_code = uint8(hex2dec('84'));
		iscan_stop_code = uint8(hex2dec('88'));
		
	end

	if iscan_active == 0,
		IOPort('Write', serial_h, iscan_start_code);
		iscan_active = ~iscan_active;
	end
	
	pause(3);
	
	if iscan_active == 1,
		IOPort('Write', serial_h, iscan_stop_code);
		iscan_active = ~iscan_active;
	end

	clean_up_serial(use_serial, iscan_active, serial_h, iscan_stop_code);

catch ME
	clean_up_serial(use_serial, iscan_active, serial_h, iscan_stop_code);
	rethrow(lasterror);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = clean_up_serial(use_serial, iscan_active, serial_h, iscan_stop_code)
if use_serial
	if iscan_active == 1,
		IOPort('Write', serial_h, iscan_stop_code);
		iscan_active = 0;
	end
	IOPort('Close', serial_h);
	IOPort('CloseAll')
end
clear IOPort;
return
