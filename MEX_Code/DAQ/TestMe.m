addpath('..\..\MEX\win32\');
bTest = fnDAQ('Init',0);

 fnDAQ('WaveFormOut');


addpath('D:\Code\Doris\BehaviorGUI\MEX\win32');
addpath('C:\Shay\Code\PublicLib\Plexon');

bTest = fnDAQ('Init');

strZeros = '000000000000000';
for k=1:15
    strOut = strZeros;
    strOut(16-k) = '1';
    ValueToSend = bin2dec(strOut);
    fprintf('%s\n',strOut);
    fndllfnDAQ('StrobeWord',ValueToSend);
    tic 
    while toc < 0.2
    end
end;

% Working:
% 14,13,12,11,10, 8, 7, 6, 5,4, 2
% 
% Not working:
% 1 - always on
% 3,9, 15 -always off.


StartingFileName = 'C:\Shay\Data\Strobe3.plx';
[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = plx_information(StartingFileName);
[tscounts, wfcounts, evcounts] = plx_info(OpenedFileName,1);

[nev, evts, evsv] = plx_event_ts(OpenedFileName, 257);
dec2bin(-evsv,15)
A=GetSecs;
fndllfnDAQ('StrobeWord',ValueToSend);
B=GetSecs;
fprintf('%.2f ms \n',(B-A)*1e3);

JUICE_PORT = 16;

fndllfnDAQ('SetBit',JUICE_PORT,1);
tic
while toc < 0.1
end
fndllfnDAQ('SetBit',16,0);


A = 63521;

PortB = bitand(A, 255);
PortA = bitshift(uint16(A),-8);

%% Analog input

[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreThresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = ...
    plx_information('\\plexon\PLEXON_Shared\diode.plx');

PLEXON_EYE_X_PORT = 48;
PLEXON_EYE_Y_PORT = 49;
PLEXON_JUICE_REWARD_PORT = 50;
PLEXON_PHOTOSENSOR_PORT = 51;



[adfreq, nad, tsad, fnad, ad] = plx_ad(OpenedFileName, PLEXON_PHOTOSENSOR_PORT);
t_sec = tsad:1/adfreq:tsad + (nad-1)*1/adfreq;
figure(1);
clf;
plot(t_sec,ad)

%%
A=GetSecs;
[pt2iPos] = fndllfnDAQ('GetEyePosition');
B=GetSecs;
fprintf('%.2f ms \n',(B-A)*1e3);

    
figure(1);
clf;
hold on;
for k=1:10000
    [pt2iPos] = fndllfnDAQ('GetEyePosition');
    plot(k, pt2iPos(1),'ro');
    plot(k, pt2iPos(2),'go');    
    drawnow
end;
