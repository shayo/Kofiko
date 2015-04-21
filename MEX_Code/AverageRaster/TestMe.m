addpath(genpath('W:\'));
load('Debug_Average_Raster')

A=GetSecs();
a2fTemp  = 1e3 * fnAverageByCell(a2bRasterShifted, aiStimuli, a2cConditions(:), iTimeSmoothingMS, true);
B=GetSecs();

(B-A)*1e3

A=GetSecs();
a2fTemp2  = fnAverageRaster(double(a2bRasterShifted), aiStimuli, a2cConditions(:));
afSmoothingKernelMS = fspecial('gaussian',[1 7*iTimeSmoothingMS],iTimeSmoothingMS);
a2Output= 1e3*conv2(a2fTemp2,afSmoothingKernelMS ,'same');
B=GetSecs();

round((B-A)*1e3)
