cd('..\..\');
addpath(genpath(pwd));
fndllMiceHook('Init');

X=fndllMiceHook('GetNumMice');
acAdvancerNames=fndllMiceHook('GetMiceName');

x=TrialCircularBuffer('InitPlexon');

%%
if (x==1)
    acGrids = [];
    acChannelNames = TrialCircularBuffer('GetChannelNames');
    acGrids=ElectrophysGUI(acChannelNames,acGrids,acAdvancerNames);
    [acGrids, a2iChannelToGridHoleAdvancer]=ElectrophysGUI(acChannelNames,acGrids,acAdvancerNames);    
    
    aiUsedAdvancers = unique(a2iChannelToGridHoleAdvancer(:,3));
    aiUsedAdvancers = aiUsedAdvancers(~isnan(aiUsedAdvancers));
    
    aiUsedChannels = unique(a2iChannelToGridHoleAdvancer(:,1));
    aiUsedChannels=aiUsedChannels(~isnan(aiUsedChannels));
end