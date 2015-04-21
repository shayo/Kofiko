strctDataFromEvents = load_events_version_0_31('C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2012\Release64\bin\filter_test3_2014-03-20_15-20-18\all_channels.events',true);
[data, timestamps, info] = load_continuous_data('C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2012\Release64\bin\filter_test3_2014-03-20_15-20-18\100_CH1.continuous');


[b,a] = fnNotch(info.header.sampleRate,60);
data_notched=filtfilt(b,a,subdata);

[b,a]=butter(3,[300 6000]*2/info.header.sampleRate,'bandpass');
aiSpikeInd = strctDataFromEvents.Spikes(:,2);
filteredData=filtfilt(b,a,data_notched);
selectedSpike = 10;
offset = 2;
figure(11);
clf;
plot(timestamps,filteredData);
hold on;
for selectedSpike =1:length(strctDataFromEvents.Spikes)
t0=strctDataFromEvents.Spikes(selectedSpike,2);
spikeTime=t0+[-8:31];
plot(spikeTime-offset,strctDataFromEvents.AllWaveforms(selectedSpike,:)/info.header.bitVolts,'r');
end
 