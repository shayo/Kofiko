strTrigFile = strTrig1;
strTrainFile = strTrain1;

strTrain1='D:\Data\Doris\Electrophys\Julien\Optogenetics\120509\RAW\120509_104252_Julien-Grass_Train.raw';
 strTrain2='D:\Data\Doris\Electrophys\Julien\Optogenetics\120509\RAW\120509_104252_Julien-Grass_Train2.raw';
strTrig1='D:\Data\Doris\Electrophys\Julien\Optogenetics\120509\RAW\120509_104252_Julien-Stimulation_Trig.raw';
strTrig2='D:\Data\Doris\Electrophys\Julien\Optogenetics\120509\RAW\120509_104252_Julien-Stimulation_Trig2.raw';

[strctTrigger1, afTriggerTime1] = fnReadDumpAnalogFile(strTrig1);
[Dummy,astrctPulseIntervals1] = fnIdentifyStimulationTrains(strctTrigger1,afTriggerTime1, false);
strctTrain1 = fnReadDumpAnalogFile(strTrain1);

afTrainOnset1TS = afTriggerTime1(cat(1,astrctPulseIntervals1.m_iStart));

afTrainOnset1TS=afTrainsGrass2TS

afPeri = [-200:500]/1e3;

iNumPulses = length(afTrainOnset1TS);

a2fSampleTimes1 = zeros(iNumPulses, length(afPeri));
for k=1:iNumPulses
    a2fSampleTimes1(k,:) = afTrainOnset1TS(k) + afPeri;
end

 %missed trains
a2fValues1 = fnReadDumpAnalogFile(strTrain1,'Resample',a2fSampleTimes1);

figure;
plot(a2fValues1.m_afData');


aiNumEvents = sum(a2fValues1.m_afData(:,200:300)>100,2);
aiProblematicEvents = find(aiNumEvents==0);
sum(aiNumEvents>0)

% what about "spurious" trains (?) (i.e., ones that were elicited manually
% without a trigger ?)
astrctIntervalsRAW = fnGetIntervals(strctTrain1.m_afData > 100);
fMergeDistanceMS = 100;
iMergeDistancePoints = fMergeDistanceMS/1000 * strctTrain1.m_fSamplingFreq;
astrctIntervals = fnMergeIntervals(astrctIntervalsRAW, iMergeDistancePoints);




figure(12);
plot(a2fValues1.m_afData(aiProblematicEvents,:)');

figure(11);
clf;hold on
plot(a2fValues2.m_afData','k')



figure;plot(strctTrain1.m_afData(1:100000))


[strctTrain1, afTrainTime1] = fnReadDumpAnalogFile(strTrain1);
figure;plot(strctTrain1.m_afData(1:500000))

[Dummy,astrctPulseIntervals1] = fnIdentifyStimulationTrains(strctTrigger1,afTriggerTime1, false);




[strctTrigger2, afTriggerTime2] = fnReadDumpAnalogFile(strTrig2);
[Dummy,astrctPulseIntervals2] = fnIdentifyStimulationTrains(strctTrigger2,afTriggerTime2, false);


a2fValues2 = fnReadDumpAnalogFile(strTrain2,'Resample',a2fSampleTimes);


figure(11);
clf;hold on
plot(a2fValues2.m_afData','k')
plot(a2fValues1.m_afData','r')
 
for k=1:iNumPulses
    plot(k+a2fValues2.m_afData(k,:)/4000,'k')
    plot(k+a2fValues1.m_afData(k,:)/4000,'r')
end

