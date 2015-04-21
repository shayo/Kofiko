% Demonstrate the basic interaction with the nano stimulator
addpath('Z:\PublicLib\Msocket\src');

UDP_MODIFY_PULSE_FREQ = 1;
UDP_MODIFY_PULSE_WIDTH = 2;
UDP_MODIFY_SECOND_PULSE = 3;
UDP_MODIFY_TRAIN_LENGTH = 4;
UDP_MODIFY_TRAIN_FREQ = 5;
UDP_MODIFY_NUM_TRAINS = 6;
UDP_MODIFY_TRIG_DELAY = 7;
UDP_MODIFY_SECOND_PULSE_WIDTH = 8;
UDP_MODIFY_SECOND_PULSE_DELAY = 9;
UDP_MODIFY_AMPLITUDE = 10;
UDP_SOFT_TRIGGER = 11;
UDP_SAVE_PRESET = 12;
UDP_LOAD_PRESET = 13;
UDP_TOGGLE_CHANNEL_ACTIVE = 14;

UDP_GET_CURRENT_SETTINGS = 15;
UDP_GET_PRESET_NAMES = 16;
UDP_MODIFY_PRESET_NAME = 17;

NUM_MAX_PRESETS = 6;

sock = udp_msconnect('192.168.50.17',6000);

% Pulse frequency
for channel=0:1
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 150.0',UDP_MODIFY_PULSE_FREQ,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    
    % Pulse Width
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 50',UDP_MODIFY_PULSE_WIDTH,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    
    % Bipolar
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 1',UDP_MODIFY_SECOND_PULSE,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    % Train length
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 1500000',UDP_MODIFY_TRAIN_LENGTH,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    % Train freuqncy
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 10.0',UDP_MODIFY_TRAIN_FREQ,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    % Number of trains
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d  %d 1',UDP_MODIFY_NUM_TRAINS,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    % Trigger delay
     T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d  %d 0',UDP_MODIFY_TRIG_DELAY,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    
    % Second pulse width
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 50',UDP_MODIFY_SECOND_PULSE_WIDTH,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    
    % Second pulse delay
     T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 50',UDP_MODIFY_SECOND_PULSE_DELAY,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    % Modify amplitude
     T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d 50.0',UDP_MODIFY_AMPLITUDE,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
    
    % Simulate soft trigger
    T=udp_msrecvraw_mod(sock,0);
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d',UDP_SOFT_TRIGGER,channel)));
    T=udp_msrecvraw_mod(sock,1);
    fprintf('%s\n',char(T));
end

% Save current settings to a preset
T=udp_msrecvraw_mod(sock,0);
success = udp_mssendraw_mod(sock,uint8(sprintf('%02d 0',UDP_SAVE_PRESET)));
T=udp_msrecvraw_mod(sock,1);
fprintf('%s\n',char(T));

% load settings to a preset
T=udp_msrecvraw_mod(sock,0);
success = udp_mssendraw_mod(sock,uint8(sprintf('%02d 0',UDP_LOAD_PRESET)));
T=udp_msrecvraw_mod(sock,1);
fprintf('%s\n',char(T));


% disable a channel
T=udp_msrecvraw_mod(sock,0);
success = udp_mssendraw_mod(sock,uint8('14 1 0'));
T=udp_msrecvraw_mod(sock,1);
fprintf('%s\n',char(T));

% enable a channel
T=udp_msrecvraw_mod(sock,0);
success = udp_mssendraw_mod(sock,uint8(sprintf('%02d 1 1',UDP_TOGGLE_CHANNEL_ACTIVE)));
T=udp_msrecvraw_mod(sock,1);
fprintf('%s\n',char(T));


% Read preset parameters....
 
while (1)
    T=udp_msrecvraw_mod(sock,0);
    if isempty(T)
        break;
    end;
end
success = udp_mssendraw_mod(sock,uint8(sprintf('%02d',UDP_GET_CURRENT_SETTINGS)));
for iChannel=1:2
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_fPulseFrequencyHz = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_iPulse_Width_Microns = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_iTrain_Length_Microns = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_fTrain_Freq_Hz = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_iNumTrains_Per_Trigger = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_bSecondPulse = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_iSecond_Pulse_Delay_Microns = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_iSecond_Pulse_Width_Microns = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_iTriggerDelay_Microns = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_fAmplitude = str2num(char(T'));
T=udp_msrecvraw_mod(sock,1);astrctChannel(iChannel).m_bActive = str2num(char(T'));
end       

%%
sock = udp_msconnect('192.168.50.17',6000);


success = udp_mssendraw_mod(sock,uint8(sprintf('%02d',UDP_GET_PRESET_NAMES)));
for k=1:6
    T=udp_msrecvraw_mod(sock,1);
    acPresetNames{k} = char(T(1:end-1)'); % cut the zero at the end
end

T=udp_msrecvraw_mod(sock,0);
for k=1:NUM_MAX_PRESETS
    success = udp_mssendraw_mod(sock,uint8(sprintf('%02d %d Preset%d',UDP_MODIFY_PRESET_NAME,k-1,k-1)));
end

