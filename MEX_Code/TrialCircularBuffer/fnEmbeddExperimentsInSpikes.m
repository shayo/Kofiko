function [n,a2fSpikeAndEvents] = fnEmbeddExperimentsInSpikes(a2fSpikes,TRIAL_START,TRIAL_END,TRIAL_OUTCOME1)
a2fSpikeAndEvents = a2fSpikes;

% add sequential experiments every X seconds...
tstart = a2fSpikeAndEvents(1,4);
tend = a2fSpikeAndEvents(end,4);
ExperimentLength = 0.5; 
InterExperimentTime = 0.5;

t = tstart;
while (t<tend)
    
end
n =size(a2fSpikeAndEvents,1);
return;
