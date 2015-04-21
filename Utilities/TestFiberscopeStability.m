%[adfreq1, n1, ts1, fn1, ad1] =plx_ad_v('\\plexon-23b\Shay\Houdini\Laser_Stability_Test6.plx',26);
%[adfreq2, n2, ts2, fn2, ad2] =plx_ad_v('\\plexon-23b\Shay\Houdini\Laser_Stability_Test6.plx',27);

[strctAnalog, afTime] = fnReadDumpAnalogFile('D:\Data\Doris\Electrophys\Houdini\ML_AL_Project\131122\RAW\131122_135903_Houdini-Amplified_Photodiode.raw');
figure;
plot(strctAnalog.m_afData);