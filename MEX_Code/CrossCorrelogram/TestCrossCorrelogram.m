% Test cross correleograms

afSpikesA = [0 1 2 3 4 5 6 7 8 9 ]*1e-3;
afSpikesB = [0.2+[0:100]]*1e-3;

addpath('..\..\MEX\x64\');
BinSizeMS = 1;
[afCrossCorrelogram, afBinCenter] = CrossCorrelogram(afSpikesA, afSpikesB, 15, BinSizeMS);
[fDummy,iIndex]=max(afCrossCorrelogram);
afBinCenter(iIndex)-BinSizeMS/2

figure(1);clf;
bar(afBinCenter,afCrossCorrelogram)

NumChannels = 1;
NumUnitsPerChannel = 2;
FiringRate = 30;
NumSeconds = 600;
toffset  = 0;
[n,t]=fnGenerateRandomSpikes(NumChannels, NumUnitsPerChannel, FiringRate, NumSeconds,toffset);
afSpikesA=t(t(:,3) == 1,4);
afSpikesB=t(t(:,3) == 2,4);

[afCrossCorrelogram, afBinCenter] = CrossCorrelogram(afSpikesA, afSpikesB, 200, 10);

figure;
bar(afBinCenter,afCrossCorrelogram);

% Now, shuddle the two correlograms
% afSpikesBrand = afSpikesB(randperm(length(afSpikesB)));
% [afCrossCorrelogramRand, afBinCenterRand] = CrossCorrelogram(afSpikesA, afSpikesBrand, 200, 10);
