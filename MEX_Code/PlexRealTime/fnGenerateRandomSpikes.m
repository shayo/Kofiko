function [n,t]=fnGenerateRandomSpikes(NumChannels, NumUnitsPerChannel, FiringRate, NumSeconds,toffset)
% outputs:
% n- number of entries
% t(:,1) - 1
% t(:,2) = Ch
% t(:,3) = unit
% t(:,4) = timestamp
N=ceil(FiringRate* NumSeconds);
a2fUniformDist=rand(NumChannels, NumUnitsPerChannel, N);
a2fExpDist = -log(a2fUniformDist); % exponentially distributed random values.
z = a2fExpDist/FiringRate;
a3fSpikeTimes = cumsum(z,3);

[sortedT, aiSortedInd]=sort(a3fSpikeTimes(:));
[Ch,Unit,Dummy]=ind2sub(size(a3fSpikeTimes),aiSortedInd);
t = zeros(NumChannels*NumUnitsPerChannel*N,4);
t(:,1) = 1;
t(:,2) = Ch;
t(:,3) = Unit;
t(:,4) = toffset+sortedT;
n=size(t,1);
return;
