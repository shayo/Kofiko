addpath('Z:\MEX\x64');

BufSize = 100;
N =100;
W = 40;
NumCh = 16;

h=ChannelCircularBuffer('Init',NumCh,BufSize,W);

Waves = randi(4096, [N W])-2048;
aiChannels = ones(1,N);

aiAssignments = ChannelCircularBuffer('Update',h, aiChannels, Waves'); % important! waves must be WxN (num points in wave form x num samples)

[WavesInBuffer, aiUnitAssociation, a2fPCA_Projection] = ChannelCircularBuffer('GetBuffer',h, 1); % important! waves must be WxN (num points in wave form x num samples)

[a2fPCA,afMean]=ChannelCircularBuffer('RunPCA',h, 1); % important! waves must be WxN (num points in wave form x num samples)

%% Test Tetrodes?

BufSize = 500;
N =500;
W = 160;
NumCh = 2;
ht=ChannelCircularBuffer('Init',NumCh,BufSize,W);

Waves = randi(4096, [N W])-2048;
aiChannels = ones(1,N);

aiAssignments = ChannelCircularBuffer('Update',ht, aiChannels, Waves'); % important! waves must be WxN (num points in wave form x num samples)

[a2fPCA,afMean]=ChannelCircularBuffer('RunPCA',ht, 1); % important! waves must be WxN (num points in wave form x num samples)

[WavesInBuffer, aiUnitAssociation, a2fPCA_Projection] = ChannelCircularBuffer('GetBuffer',ht, 1); % important! waves must be WxN (num points in wave form x num samples)

