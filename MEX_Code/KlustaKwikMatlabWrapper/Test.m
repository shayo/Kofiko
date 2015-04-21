addpath('W:\MEX\x64');
load('U:\test');
iMaxCluster = 10;
figure;
plot(a2fPCAFeatures)


aiClusters = fndllKlustaKwikMatlabWrapper(a2fPCAFeatures',[],'MinClusters',1,'MaxClusters',iMaxCluster, 'MaxPossibleClusters',iMaxCluster);
  