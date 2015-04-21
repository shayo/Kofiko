addpath('Z:\MEX\win32\');

Res = fnDAQRedBoxI2C('Init',0);
assert(Res == 0);
SDA = 0;
SCL = 1;
SLEEP = 10*1e-3;

fnDAQRedBoxI2C('I2CStart');
fnDAQRedBoxI2C('I2CSend',hex2dec('00'));
fnDAQRedBoxI2C('I2CAck');
fnDAQRedBoxI2C('I2CSend','A');
fnDAQRedBoxI2C('I2CStop');

fnDAQRedBoxI2C('I2CStart');
fnDAQRedBoxI2C('I2CSend',hex2dec('43'));
fnDAQRedBoxI2C('I2CAck');
data_l = fnDAQRedBoxI2C('I2CRead');
fnDAQRedBoxI2C('I2CAck');
data_2 = fnDAQRedBoxI2C('I2CRead');
fnDAQRedBoxI2C('I2CNak');
fnDAQRedBoxI2C('I2CStop');

%   return ( (data_m << 8) + data_l);   // return 16 bits data

fnDAQRedBoxI2C('I2CStart');

% SEND DEVICE ADDRESS
fnDAQRedBoxI2C('SetBitWithDelay',SDA,1,SLEEP); % Bit 1
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP); % Bit 2
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

fnDAQRedBoxI2C('SetBitWithDelay',SDA,1,SLEEP); % Bit 3
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP); % Bit 4
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP); % Bit 5
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP); % Bit 6
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP); % Bit 7
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

%'ALL OPENS START WITH A WRITE R/W BIT
fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP); 
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);

SDA_Value= fnDAQRedBoxI2C('GetBit',SDA);

fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);

if SDA_Value == 1
    % First Ack Failed!
end

fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP);


for k=1:8
    af(k)= fnDAQRedBoxI2C('GetBit',SDA);
    fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
    fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);
end

SDA_Value= fnDAQRedBoxI2C('GetBit',SDA);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);

if SDA_Value == 1
    % First Ack Failed!
end

fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP);

for k=9:16
    af(k)= fnDAQRedBoxI2C('GetBit',SDA);
    fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);
    fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);
end

SDA_Value= fnDAQRedBoxI2C('GetBit',SDA);
fnDAQRedBoxI2C('SetBitWithDelay',SCL,1,SLEEP);

if SDA_Value == 1
    % First Ack Failed!
end
fnDAQRedBoxI2C('SetBitWithDelay',SCL,0,SLEEP);
fnDAQRedBoxI2C('SetBitWithDelay',SDA,0,SLEEP);



return;

