% Test Digital Compass readout using I2C Protocol

addpath('Z:\MEX\win32\');

Res = fnDAQRedBoxI2C('Init',0);
assert(Res == 0);
SDA = 0;
SCL = 1;
fnDAQRedBoxI2C('SetSDAPort',SDA);
fnDAQRedBoxI2C('SetSCLPort',SCL);



fnDAQRedBoxI2C('I2CInit');

fnDAQRedBoxI2C('I2CStart');

fnDAQRedBoxI2C('I2CSend', hex2dec('21'));
fnDAQRedBoxI2C('I2CAck');


                I2CSend(0x00);
                I2CAck();
                I2CRestart();
                I2CSend(0xD1);
                I2CAck();



SDA_Value = fnDAQRedBoxI2C('GetBit',SDA);
SCL_Value = fnDAQRedBoxI2C('GetBit',SCL);

fnDAQRedBoxI2C('I2CRestart');

fnDAQRedBoxI2C('I2CStart');
hmc6352_GetData      = 'A';
fnDAQRedBoxI2C('I2CSend',hmc6352_GetData);

x1 = fnDAQRedBoxI2C('I2CRead');
x2 = fnDAQRedBoxI2C('I2CRead');

fnDAQRedBoxI2C('I2CStop');

% 
% 
%     hmc6352_Address      = 0x21,
%     hmc6352_WriteEEPROM  = 'w',
%     hmc6352_ReadEEPROM   = 'r',
%     hmc6352_WriteRAM     = 'G',
%     hmc6352_ReadRAM      = 'g',
%     hmc6352_Sleep        = 'S',
%     hmc6352_Wakeup       = 'W',
%     hmc6352_BridgeOffset = 'O',
%     hmc6352_EnterCal     = 'C',
%     hmc6352_ExitCal      = 'E',
%     hmc6352_SaveOPMode   = 'L',
%     hmc6352_GetData      = 'A',
