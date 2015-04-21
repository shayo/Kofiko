function fnEntryPoint_OptogeneticsFEF_Behavior_New()
% This block loads the data from disk (or uses the cache if data was
% already loaded
global g_acData 
%strPopulationList = 'D:\Data\Doris\Data For Publications\FEF Opto\Bert_Memory_Saccade_Task_All.mat';

% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120227\RAW\..\Processed\BehaviorStats\Julien-27-Feb-2012_15-11-08_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp2.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120228\RAW\..\Processed\BehaviorStats\Julien-28-Feb-2012_10-26-05_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp2.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120322\RAW\..\Processed\BehaviorStats\Julien-22-Mar-2012_14-59-02_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp4.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120322\RAW\..\Processed\BehaviorStats\Julien-22-Mar-2012_14-59-02_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp5.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120403\RAW\..\Processed\BehaviorStats\Julien-03-Apr-2012_16-03-35_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp7.mat','Mixed'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120403\RAW\..\Processed\BehaviorStats\Julien-03-Apr-2012_16-03-35_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp8.mat','Mixed'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120410\RAW\..\Processed\BehaviorStats\Julien-10-Apr-2012_14-44-46_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120410\RAW\..\Processed\BehaviorStats\Julien-10-Apr-2012_14-44-46_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120410\RAW\..\Processed\BehaviorStats\Julien-10-Apr-2012_14-44-46_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp13.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120502\RAW\..\Processed\BehaviorStats\Julien-02-May-2012_10-27-24_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120502\RAW\..\Processed\BehaviorStats\Julien-02-May-2012_10-27-24_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11_lowcurrent.mat','Electrical'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120502\RAW\..\Processed\BehaviorStats\Julien-02-May-2012_10-27-24_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp17_lowcurrent40ua.mat','Electrical'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120507\RAW\..\Processed\BehaviorStats\Julien-07-May-2012_10-18-46_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp19.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120509\RAW\..\Processed\BehaviorStats\Julien-09-May-2012_10-43-15_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp19.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120510\RAW\..\Processed\BehaviorStats\Julien-10-May-2012_14-40-59_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp19.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120511\RAW\..\Processed\BehaviorStats\Julien-11-May-2012_14-22-56_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp20.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\BehaviorStats\Julien-15-May-2012_11-45-45_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp19.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\BehaviorStats\Julien-15-May-2012_11-45-45_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp20.mat','ChR2'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120516\RAW\..\Processed\BehaviorStats\Julien-16-May-2012_10-23-37_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp21.mat','?'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120517\RAW\..\Processed\BehaviorStats\Julien-17-May-2012_10-23-14_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp23.mat','ElectricalCue'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120517\RAW\..\Processed\BehaviorStats\Julien-17-May-2012_10-23-14_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp24.mat','ElectricalCue'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120522\RAW\..\Processed\BehaviorStats\Julien-22-May-2012_09-33-55_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp23.mat','ElectricalCue'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\BehaviorStats\Julien-19-Jun-2012_12-19-15_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp29.mat','Detection'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120814\RAW\..\Processed\BehaviorStats\Julien-14-Aug-2012_17-04-18_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat','?'},...
% {'D:\Data\Doris\Electrophys\Julien\Optogenetics\120815\RAW\..\Processed\BehaviorStats\Julien-15-Aug-2012_16-38-59_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat','?'},...

acDataEntriesJulien = {...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120229\RAW\..\Processed\BehaviorStats\Julien-29-Feb-2012_13-04-08_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp2.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120302\RAW\..\Processed\BehaviorStats\Julien-02-Mar-2012_14-50-55_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp2.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120307\RAW\..\Processed\BehaviorStats\Julien-07-Mar-2012_15-50-21_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp2.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120308\RAW\..\Processed\BehaviorStats\Julien-08-Mar-2012_13-34-59_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp2.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120313\RAW\..\Processed\BehaviorStats\Julien-13-Mar-2012_11-42-59_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp2.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120321\RAW\..\Processed\BehaviorStats\Julien-21-Mar-2012_14-23-23_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp3.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120321\RAW\..\Processed\BehaviorStats\Julien-21-Mar-2012_14-23-23_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp4.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120327\RAW\..\Processed\BehaviorStats\Julien-27-Mar-2012_10-23-33_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp5.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120327\RAW\..\Processed\BehaviorStats\Julien-27-Mar-2012_10-23-33_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp6.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120404\RAW\..\Processed\BehaviorStats\Julien-04-Apr-2012_10-02-39_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp10.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120404\RAW\..\Processed\BehaviorStats\Julien-04-Apr-2012_10-02-39_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120405\RAW\..\Processed\BehaviorStats\Julien-05-Apr-2012_12-15-27_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120411\RAW\..\Processed\BehaviorStats\Julien-11-Apr-2012_14-48-08_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120411\RAW\..\Processed\BehaviorStats\Julien-11-Apr-2012_14-48-08_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120413\RAW\..\Processed\BehaviorStats\Julien-13-Apr-2012_11-41-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120413\RAW\..\Processed\BehaviorStats\Julien-13-Apr-2012_11-41-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120416\RAW\..\Processed\BehaviorStats\Julien-16-Apr-2012_15-22-01_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat','Control'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120416\RAW\..\Processed\BehaviorStats\Julien-16-Apr-2012_15-22-01_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat','Control'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120419\RAW\..\Processed\BehaviorStats\Julien-19-Apr-2012_13-55-19_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp9.mat','Control'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120423\RAW\..\Processed\BehaviorStats\Julien-23-Apr-2012_14-45-32_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120423\RAW\..\Processed\BehaviorStats\Julien-23-Apr-2012_14-45-32_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120424\RAW\..\Processed\BehaviorStats\Julien-24-Apr-2012_13-41-35_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp14.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120424\RAW\..\Processed\BehaviorStats\Julien-24-Apr-2012_13-41-35_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120523\RAW\..\Processed\BehaviorStats\Julien-23-May-2012_10-29-09_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp21.mat','ArchT'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120524\RAW\..\Processed\BehaviorStats\Julien-24-May-2012_10-36-43_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp26.mat','ArchT'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\BehaviorStats\Julien-26-May-2012_11-24-30_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat','ArchT'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120527\RAW\..\Processed\BehaviorStats\Julien-27-May-2012_10-12-26_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat','ArchT'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120528\RAW\..\Processed\BehaviorStats\Julien-28-May-2012_11-01-37_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp28.mat','ArchT'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120601\RAW\..\Processed\BehaviorStats\Julien-01-Jun-2012_15-57-08_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat','Control'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120624\RAW\..\Processed\BehaviorStats\Julien-24-Jun-2012_19-05-02_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat','ArchT'},...
{'D:\Data\Doris\Electrophys\Julien\Optogenetics\120625\RAW\..\Processed\BehaviorStats\Julien-25-Jun-2012_17-26-36_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat','ArchT'}...
};

acDataEntriesBert = {...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120322\RAW\..\Processed\BehaviorStats\Bert-22-Mar-2012_11-20-14_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp1.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120322\RAW\..\Processed\BehaviorStats\Bert-22-Mar-2012_11-20-14_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp2.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120323\RAW\..\Processed\BehaviorStats\Bert-23-Mar-2012_15-21-50_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp1.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120323\RAW\..\Processed\BehaviorStats\Bert-23-Mar-2012_15-21-50_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp2.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120323\RAW\..\Processed\BehaviorStats\Bert-23-Mar-2012_15-21-50_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp4.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120325\RAW\..\Processed\BehaviorStats\Bert-25-Mar-2012_16-42-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp1.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120325\RAW\..\Processed\BehaviorStats\Bert-25-Mar-2012_16-42-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp2.mat','Control'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120325\RAW\..\Processed\BehaviorStats\Bert-25-Mar-2012_16-42-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp4.mat','Control'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120402\RAW\..\Processed\BehaviorStats\Bert-02-Apr-2012_15-26-29_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp4.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120402\RAW\..\Processed\BehaviorStats\Bert-02-Apr-2012_15-26-29_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp5.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120402\RAW\..\Processed\BehaviorStats\Bert-02-Apr-2012_15-26-29_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp6.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120402\RAW\..\Processed\BehaviorStats\Bert-02-Apr-2012_15-26-29_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp7.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120425\RAW\..\Processed\BehaviorStats\Bert-25-Apr-2012_12-06-41_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120425\RAW\..\Processed\BehaviorStats\Bert-25-Apr-2012_12-06-41_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120425\RAW\..\Processed\BehaviorStats\Bert-25-Apr-2012_12-06-41_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp9.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120607\RAW\..\Processed\BehaviorStats\Bert-07-Jun-2012_15-51-42_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp8.mat','ChR2'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120609\RAW\..\Processed\BehaviorStats\Bert-09-Jun-2012_11-42-09_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat','ChR2'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\BehaviorStats\Bert-10-Jun-2012_11-17-17_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp8.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120612\RAW\..\Processed\BehaviorStats\Bert-12-Jun-2012_13-16-40_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp8.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120624\RAW\..\Processed\BehaviorStats\Bert-24-Jun-2012_11-47-33_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120625\RAW\..\Processed\BehaviorStats\Bert-25-Jun-2012_10-54-48_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120813\RAW\..\Processed\BehaviorStats\Bert-13-Aug-2012_10-24-42_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120814\RAW\..\Processed\BehaviorStats\Bert-14-Aug-2012_10-04-56_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\120815\RAW\..\Processed\BehaviorStats\Bert-15-Aug-2012_12-34-14_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\121124\RAW\..\Processed\BehaviorStats\Bert-24-Nov-2012_10-22-44_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp11.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\121125\RAW\..\Processed\BehaviorStats\Bert-25-Nov-2012_10-04-37_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp13.mat','ChR2'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\121125\RAW\..\Processed\BehaviorStats\Bert-25-Nov-2012_10-04-37_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp14.mat','ChR2'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\121125\RAW\..\Processed\BehaviorStats\Bert-25-Nov-2012_15-56-42_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp15.mat','Halo'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\121126\RAW\..\Processed\BehaviorStats\Bert-26-Nov-2012_09-33-43_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp15.mat','ChR2'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\121127\RAW\..\Processed\BehaviorStats\Bert-27-Nov-2012_10-37-43_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp15.mat','Arch'},...
{'D:\Data\Doris\Electrophys\Bert\Optogenetics\121127\RAW\..\Processed\BehaviorStats\Bert-27-Nov-2012_18-34-13_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp15.mat','Arch'} };

% clear global 
bJulien = false;
if bJulien
     acDataEntries = acDataEntriesJulien;
else
    acDataEntries = acDataEntriesBert;
end
iNumExperiments = length(acDataEntries);
%Tmp=load(strPopulationList);
acExperimentFileName = cell(1, iNumExperiments);
acExperimentDate = cell(1, iNumExperiments);
acExperimentSite = cell(1, iNumExperiments);
for k=1:iNumExperiments
    acExperimentDate{k} = acDataEntries{k}{1}(45:50);
    acExperimentSite{k} = acDataEntries{k}{2};
    acExperimentFileName{k} = acDataEntries{k}{1};
end

bReload = false;
if isempty(g_acData) || bReload
    g_acData = fnLoadDataEntries(acExperimentFileName);
end

if ~bJulien
   % Plot the electircal evoked saccades during these days
   % This is not from the same day, but same grid hole & depth
    strctGrassStim=load('D:\Data\Doris\Electrophys\Bert\Optogenetics\120814\RAW\..\Processed\ElectricalMicrostim\Bert-14-Aug-2012_10-04-56_Microstim_Channel_1_Depth_30-01_Trig_Grass1.mat');
    a2fX = strctGrassStim.strctStimStat.m_astrctStimulation(1).m_a2fXpix;
    a2fY = strctGrassStim.strctStimStat.m_astrctStimulation(1).m_a2fYpix;
    fnPrintSaccadeAux(a2fX,a2fY,10,0,20,16, 700);
      
        
    strctGrassStim=load('D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-80_Trig_Grass1.mat');
    a2fX = strctGrassStim.strctStimStat.m_astrctStimulation(2).m_a2fXpix;
    a2fY = strctGrassStim.strctStimStat.m_astrctStimulation(2).m_a2fYpix;
    fnPrintSaccadeAux(a2fX,a2fY,10,0,20,16, 700);

   
    aiRelevantExperimentsBert = [18,24];
    abShowColorBarBert = [true, false];
    fnNewBehaviorAnalysis(g_acData,acExperimentSite,acExperimentDate,aiRelevantExperimentsBert,abShowColorBarBert);
    
   

    
else
    
    strctGrassStim=load('D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\ElectricalMicrostim\Julien-26-May-2012_11-24-30_Microstim_Channel_1_Depth_31-60_Trig_Grass1.mat');
    a2fX = strctGrassStim.strctStimStat.m_astrctStimulation(7).m_a2fXpix;
    a2fY = strctGrassStim.strctStimStat.m_astrctStimulation(7).m_a2fYpix;
    fnPrintSaccadeAux(a2fX,a2fY,10,0,20,16, 700);

    strctGrassStim=load('D:\Data\Doris\Electrophys\Julien\Optogenetics\120315\RAW\..\Processed\ElectricalMicrostim\Julien-15-Mar-2012_10-49-38_ElectricalMicrostim_Channel2.mat');
    a2fX = strctGrassStim.strctStimStat.m_astrctStimulation(1).m_a2fXpix;
    a2fY = strctGrassStim.strctStimStat.m_astrctStimulation(1).m_a2fYpix;
    fnPrintSaccadeAux(a2fX(70:end,:),a2fY(70:end,:),10,0,20,16, 500);

    aiRelevantExperimentsJulien = [11,16]; % 14
    %acExperimentFileName{aiRelevantExperimentsJulien}
    abShowColorBarJulien = [false, false];
    fnNewBehaviorAnalysis(g_acData,acExperimentSite,acExperimentDate,aiRelevantExperimentsJulien,abShowColorBarJulien);
%     D:\Data\Doris\Electrophys\Julien\Optogenetics\120404\RAW\..\Processed\BehaviorStats\Julien-04-Apr-2012_10-02-39_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp9.mat
%     D:\Data\Doris\Electrophys\Julien\Optogenetics\120413\RAW\..\Processed\BehaviorStats\Julien-13-Apr-2012_11-41-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat

end


% Psych curves...
fnPlotPyschCurves();
% Fitting didn't work. Done manually and then copied the values...
%fnPsychCurves(a3fTrialStats_NoStim, afContrastValue,bMonkeyB);



%

function fnPlotPyschCurves()
x = 0:0.1:30;
paramsValuesJulien = [15.8,0.95 0.25 0];
afContrastJulien = [11.7647   13.7255   14.5098   15.6863   16.0784   16.8627   17.6471];
afPerformanceJulien = [65.6584   35.8491   45.4867   56.0527   65.1251   84.6241   90.0730];

paramsValuesBert = [15.5,0.75 0.25 0];
afContrastBert = [   15.2941   15.6863   16.0784   16.8627   17.6471   19.6078];
afPerformanceBert = [    63.4306   66.8285   65.0000   76.9799   87.1560   96.7169];


figure(11);
clf;hold on;
hold on;




plot(x, 1e2*PAL_Logistic(paramsValuesBert,x),'color','k');
plot(afContrastBert, afPerformanceBert,'o','color',[1 0 0])
set(gca,'xlim',[12 20],'ylim',[0 110]);
hold on;
plot([0 100],100*[1/4 1/4],'--','color',[0.5 0.5 0.5])


plot(x, 1e2*PAL_Logistic(paramsValuesJulien,x),'color','k','LineStyle','--');
plot(afContrastJulien, afPerformanceJulien,'^','color',[1 0 0])
set(gca,'xlim',[12 20],'ylim',[0 110]);


set(gca,'fontsize',7)
set(gcf,'position',[     1533        1005         198          93]);

return

function fnNewBehaviorAnalysisJulien(acData,acExperimentSite,acExperimentDate)
a2cCompareTrials = {...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp'};
  
 acCanonicalTargets = {'SaccadeTaskRight','SaccadeTaskLeft','SaccadeTaskUp','SaccadeTaskDown','SaccadeTaskRightUp','SaccadeTaskRightDown','SaccadeTaskLeftUp','SaccadeTaskLeftDown'};
 acCanonicalTargetsStim = {'MicrostimSaccadeTaskRight','MicrostimSaccadeTaskLeft','MicrostimSaccadeTaskUp','MicrostimSaccadeTaskDown','MicrostimSaccadeTaskRightUp','MicrostimSaccadeTaskRightDown','MicrostimSaccadeTaskLeftUp','MicrostimSaccadeTaskLeftDown'};
   
afContrastValue = fnReadContrastValues(acData);
a3fTrialStats_NoStim = fnExtractTrialStats(acData,a2cCompareTrials(:,1),true,acCanonicalTargets);
a3fTrialStats_Stim = fnExtractTrialStats(acData,a2cCompareTrials(:,2),true,acCanonicalTargetsStim);
strctStat_Relaxed= fnFindSignificantChanges(a3fTrialStats_NoStim ,a3fTrialStats_Stim);
if 1
fnPsychCurves(a3fTrialStats_NoStim, afContrastValue,false);
end

aiSubset = find(ismember(acExperimentSite,'Halo'));
figure(3);clf;imagesc(1:8,1:length(aiSubset),strctStat_Relaxed.m_a2fPercCorrectChange(aiSubset,:),[-40 40]);set(gca,'ytick',1:length(aiSubset));colorbar
hold on;
for k=1:length(aiSubset)
    aiSig = find(strctStat_Relaxed.m_a2fPValue(aiSubset(k),:)<0.05);
    if ~isempty(aiSig)
        plot(aiSig,k,'k*');
    end
end

aiSubset = find(ismember(acExperimentSite,'Arch'));
figure(2);clf;imagesc(1:8,1:length(aiSubset),strctStat_Relaxed.m_a2fPercCorrectChange(aiSubset,:),[-40 40]);set(gca,'ytick',1:length(aiSubset));colorbar
hold on;
for k=1:length(aiSubset)
    aiSig = find(strctStat_Relaxed.m_a2fPValue(aiSubset(k),:)<0.05);
    if ~isempty(aiSig)
        plot(aiSig,k,'k*');
    end
end


a2fPercCorrect_NoStim = reshape(a3fTrialStats_NoStim(:,2,:) ./ (a3fTrialStats_NoStim(:,2,:)+a3fTrialStats_NoStim(:,3,:)) * 1e2, 8, size(a3fTrialStats_NoStim,3))';
a2fPercCorrect_Stim = reshape(a3fTrialStats_Stim(:,2,:) ./ (a3fTrialStats_Stim(:,2,:)+a3fTrialStats_Stim(:,3,:)) * 1e2, 8, size(a3fTrialStats_Stim,3))';

%%
iSelectedExperiment = aiSubset(10);
aiSig = find(strctStat_Relaxed.m_a2fPValue(iSelectedExperiment,:) < 0.05);
afGreen = [0,176,80]/255;
figure(4);clf;hold on;
h=bar([a2fPercCorrect_NoStim(iSelectedExperiment,:);a2fPercCorrect_Stim(iSelectedExperiment,:)]');
% plot(aiSig, a2fPercCorrect_NoStim(iSelectedExperiment,aiSig)+ 10,'k*');
set(h(1),'facecolor',[0.5 0.5 0.5]);
set(h(2),'facecolor', afGreen);
set(gca,'xtick',1:8,'xticklabel',{'N','NE','E','SE','S','SW','W','NW'});
set(gca,'xlim',[0.5 8.5],'ylim',[0 100]);
set(gca,'fontsize',7);	
%%
set(gcf,'position',[ 1083         974         154         124]);

return


function [strctStat]= fnFindSignificantChanges(a3fTrialStats_NoStim ,a3fTrialStats_Stim)
%% Significant performance?
iNumEntries = size(a3fTrialStats_NoStim ,3);
afPValue = zeros(1,iNumEntries);
afChi2Stat=  zeros(1,iNumEntries);
a2fPValue = zeros(iNumEntries,8);
a2fChi2Stat = zeros(iNumEntries,8);
afPercCorrectChange= zeros(1,iNumEntries); % Pos means better without stimulation.
a2fPercCorrectChange = zeros(iNumEntries,8); % Pos means better without stimulation.
for iEntryIter=1:iNumEntries
    a2fPerf_NoStim = a3fTrialStats_NoStim(:,:,iEntryIter);
    a2fPerf_Stim = a3fTrialStats_Stim(:,:,iEntryIter);

    
    fPercCorrect_NoStim = sum(a2fPerf_NoStim(:,2)) / (sum(a2fPerf_NoStim(:,2))+sum(a2fPerf_NoStim(:,3)));
    fPercCorrect_Stim = sum(a2fPerf_Stim(:,2)) / (sum(a2fPerf_Stim(:,2))+sum(a2fPerf_Stim(:,3)));
    afPercCorrectChange(iEntryIter) = (fPercCorrect_NoStim-fPercCorrect_Stim)*1e2;
    
    a2iObservedTable2x2 = [sum(a2fPerf_NoStim(:,2)), sum(a2fPerf_NoStim(:,3));
        sum(a2fPerf_Stim(:,2)),   sum(a2fPerf_Stim(:,3));];
    [afPValue(iEntryIter), afChi2Stat(iEntryIter)] = fnChiTable(a2iObservedTable2x2,1 );
    
    for iDirectionIter=1:8
        a2iObservedTable2x2_Direction = [a2fPerf_NoStim(iDirectionIter,2), a2fPerf_NoStim(iDirectionIter,3);
            a2fPerf_Stim(iDirectionIter,2), a2fPerf_Stim(iDirectionIter,3);];
        [a2fPValue(iEntryIter,iDirectionIter), a2fChi2Stat(iEntryIter,iDirectionIter)] = fnChiTable(a2iObservedTable2x2_Direction,1 );
       
        
       fPercCorrect_NoStim = sum(a2fPerf_NoStim(iDirectionIter,2)) / (sum(a2fPerf_NoStim(iDirectionIter,2))+sum(a2fPerf_NoStim(iDirectionIter,3)));
        fPercCorrect_Stim = sum(a2fPerf_Stim(iDirectionIter,2)) / (sum(a2fPerf_Stim(iDirectionIter,2))+sum(a2fPerf_Stim(iDirectionIter,3)));
        a2fPercCorrectChange(iEntryIter,iDirectionIter) = (fPercCorrect_NoStim-fPercCorrect_Stim)*1e2;
    

    end

end

strctStat.m_afPValue = afPValue;
strctStat.m_afChi2Stat = afChi2Stat;
strctStat.m_a2fPValue = a2fPValue;
strctStat.m_a2fChi2Stat = a2fChi2Stat;
strctStat.m_afPercCorrectChange = afPercCorrectChange;
strctStat.m_a2fPercCorrectChange = a2fPercCorrectChange;
strctStat.m_aiSignificantExperiments = find(sum(a2fPValue<0.05,2));

return

afPercCorrectChange(aiSignificantExperiments)
mean(a2fPercCorrectChange(a2fPValue<0.05))
std(a2fPercCorrectChange(a2fPValue<0.05))


acExperimentSite(aiSignificantExperiments)
afContrastValue(aiSignificantExperiments)


return;




function fnPsychCurves(acData,a2cCompareTrials,acCanonicalTargets)
a3fTrialStats_NoStim = fnExtractTrialStats(acData,a2cCompareTrials(:,1),true,acCanonicalTargets);

afContrastValue = fnReadContrastValues(acData);
bMonkeyB = ~isempty(strfind(acData{1}.strctDesignStat.m_strDesignName,'Bert'));

[afUniqueContrasts,~,aiMapToUnique] = unique(afContrastValue);
iNumUniqueContrast = length(afUniqueContrasts);
afPerformanceIncludingAbortedTimeout = zeros(1,iNumUniqueContrast);
afPerformanceExcludingAbortedTimeout = zeros(1,iNumUniqueContrast);

a2fUniqueStats = zeros(iNumUniqueContrast,5);
for iUniqueContrastIter=1:iNumUniqueContrast
    a2fTotalStat = sum(a3fTrialStats_NoStim(:,:, aiMapToUnique == iUniqueContrastIter),3);
    afTotalStat = sum(a2fTotalStat,1);
    a2fUniqueStats(iUniqueContrastIter,:) = afTotalStat;
    afPerformanceIncludingAbortedTimeout(iUniqueContrastIter) = afTotalStat(2) / afTotalStat(1) * 1e2;
    afPerformanceExcludingAbortedTimeout(iUniqueContrastIter) = afTotalStat(2) / sum(afTotalStat(2:3))*1e2;
end
if bMonkeyB
    afExcludeContrasts = [30,35,255];
    aiPlot = ~ismember(afUniqueContrasts,afExcludeContrasts);
else
    afExcludeContrasts = [38 ,   39,255];
  aiPlot = ~ismember(afUniqueContrasts,afExcludeContrasts);
end
%%
% options = PAL_minimize('options');
% PF = @PAL_Logistic;
% searchGrid.alpha =12:0.1:19;% [-1:.01:1];    %structure defining grid to
% searchGrid.beta =0.1:0.1:1; %search for initial values
% searchGrid.gamma = 1/4; % Fix chance level (!)
% searchGrid.lambda = [0:.0001:.005];
% paramsFree = [1 1 0 1];
% 
% %Fit data:
% paramsValues = PAL_PFML_Fit(afUniqueContrasts(aiPlot)/255*1e2, a2fUniqueStats(aiPlot,2), a2fUniqueStats(aiPlot,1)+a2fUniqueStats(aiPlot,2), ...
%     searchGrid, paramsFree, PF,'lapseLimits',[0 1], 'searchOptions',options);
% %
% %   paramsValues = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, ...
% %       searchGrid, paramsFree, PF,'lapseLimits',[0 1],'guessLimits',...
% %       [0 1], 'searchOptions',options)
x = 0:0.1:30;
%
%%
paramsValues = [14.8,0.55 0.25 0];

figure(11);
clf;hold on;
%plot(afUniqueContrasts(aiPlot)/255*100, afAvgPerf(abLowContrast),'ko');
plot(x, 1e2*PAL_Logistic(paramsValues,x),'color','k');
%plot(afUniqueContrasts(aiPlot)/255*1e2, afPerformanceIncludingAbortedTimeout(aiPlot)/100,'b*')
plot(afUniqueContrasts(aiPlot)/255*1e2, 1e2*afPerformanceExcludingAbortedTimeout(aiPlot)/100,'o','color',[0.5 0.5 0.5])


% [15.8,0.95 0.25 0]
%   11.7647   13.7255   14.5098   15.6863   16.0784   16.8627   17.6471
%   65.6584   35.8491   45.4867   56.0527   65.1251   84.6241   90.0730
%plot(1e2*afUniqueContrasts(aiPlot)/255, afPerformanceExcludingAbortedTimeout(aiPlot),'ro')
set(gca,'xlim',[12 22],'ylim',[0 110]);

hold on;
plot([0 100],100*[1/4 1/4],'--','color',[0.5 0.5 0.5])
set(gca,'fontsize',7)
set(gcf,'position',[    680        1031         138          67]);
%%
return;


function [a3fTrialStats, a3iIncorrectResponses] = fnExtractTrialStats(acData,acTrialNames,bUseReAnalysis,acCanonicalTargets)
iNumDataEntries = length(acData);
iNumTrialTypes = length(acTrialNames);
a3fTrialStats = zeros(iNumTrialTypes,5,iNumDataEntries); % [Num trials, Num correct, Num Incorrect, Num Aborted, Num Timeout]
a3iIncorrectResponses = zeros(iNumTrialTypes,iNumTrialTypes,iNumDataEntries);

for iDataEntryIter=1:iNumDataEntries

    a2iIncorrectResponses = zeros(iNumTrialTypes,iNumTrialTypes);
    iNumAllTrialTypes = length(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes);
    acAllTrialNames = cell(1, iNumAllTrialTypes);
    aiMapToOutput = ones(1, iNumAllTrialTypes) * NaN;
    
    for iTrialTypeIter=1:iNumAllTrialTypes
        acAllTrialNames{iTrialTypeIter} =  acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.TrialParams.Name;
        iOutputIndex = find(ismember(lower(acTrialNames), lower(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.TrialParams.Name)));
        if ~isempty(iOutputIndex)
            aiMapToOutput(iTrialTypeIter) = iOutputIndex;
        end
    end
     
    iNumTrials = length(acData{iDataEntryIter}.strctDesignStat.m_acTrials);
    a2fPerformance = zeros(iNumTrialTypes,5); % [Num trials, Num correct, Num Incorrect, Num Aborted, Num Timeout]

    for iTrialIter=1:iNumTrials 
        iOutputIndex = aiMapToOutput(acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_iTrialType);
        if ~isnan(iOutputIndex)
            a2fPerformance(iOutputIndex,1) = a2fPerformance(iOutputIndex,1) + 1;
            if bUseReAnalysis 
                strOutcome = acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcomeRelaxed;
            else
                strOutcome = acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome;
            end
            
         
            
            switch strOutcome
                case 'Correct'
                    a2fPerformance(iOutputIndex,2) = a2fPerformance(iOutputIndex,2) + 1;
                case 'Incorrect'
                    a2fPerformance(iOutputIndex,3) = a2fPerformance(iOutputIndex,3) + 1;
                    iIndexTarget = find(ismember(acTrialNames,    acCanonicalTargets{acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_iTargetIndex}));
                    iIndexIncorrectChoice = find(ismember(acTrialNames,    acCanonicalTargets{acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_iSelectedTarget}));
%                     figure;
%                     plot(acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_afEyeXpixZero,...
%                         acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_afEyeYpixZero);
%                     axis ij
%                     axis equal
%                     set(gca,'xlim',[-500 500],'ylim',[-500 500]);
                    a2iIncorrectResponses(iIndexTarget, iIndexIncorrectChoice)=a2iIncorrectResponses(iIndexTarget, iIndexIncorrectChoice)+1;
                    
                case 'Aborted'
                    a2fPerformance(iOutputIndex,4) = a2fPerformance(iOutputIndex,4) + 1;
                case 'Aborted;BreakFixationDuringCue'
                    a2fPerformance(iOutputIndex,4) = a2fPerformance(iOutputIndex,4) + 1;
                case 'Timeout'
                    a2fPerformance(iOutputIndex,5) = a2fPerformance(iOutputIndex,5) + 1;
                otherwise
                    fprintf('Unknown trial type %s\n',acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome);
            end
        end
    end
    a3fTrialStats(:,:,iDataEntryIter) = a2fPerformance;
    a3iIncorrectResponses(:,:,iDataEntryIter) = a2iIncorrectResponses;
end

return


function afContrastValue = fnReadContrastValues(acData)
iNumDataEntries = length(acData);
afContrastValue = zeros(1,iNumDataEntries);
acCueFile = cell(1,iNumDataEntries);
for iDataEntryIter=1:iNumDataEntries
    % Find one trial to infer contrast...
    for iTrialTypeIter=1:length(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes)
        if strcmpi(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.TrialParams.Name,'SaccadeTaskLeft')
            iMediaIndex = find(ismember(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acMediaName,...            
                acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.Cue.CueMedia));
            acCueFile{iDataEntryIter} = acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
            Tmp=imread(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName);
            afContrastValue(iDataEntryIter)= max(max(Tmp(:,:,1)));
            break;
        end
    end
end
return;


%% 
function fnPlotMemorySaccadeExperiment(strctData, abSignificant, aiStat_NoStim, aiStat_Stim)
a2cCompareTrials = {...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp'};
  
iCorrectIndex = find(ismember(strctData.m_acUniqueOutcomes,'Correct'));
iIncorrectIndex = find(ismember(strctData.m_acUniqueOutcomes,'Incorrect'));



   a2fTargetCenter = [400 0;
        -400 0;
        0 -400;
        0 400;
        280 -280;
        280 280;
        -280 -280;
        -280 280]/2;



    afTheta = linspace(0,2*pi,20);

figure(12);
clf;
for iDirection = 1:8
    iEntry = find(ismember( strctData.m_acUniqueTrialNames, a2cCompareTrials(iDirection,1)));
    
    aiCorrectTrialInd = strctData.m_a2cTrialsIndicesSorted{iEntry,iCorrectIndex};
    aiIncorrectTrialInd = strctData.m_a2cTrialsIndicesSorted{iEntry,iIncorrectIndex};
    subplot(2,4,iDirection);
    hold on;
    
    
    % plot targets
    for q=1:8
        plot(a2fTargetCenter(q,1)+80*cos(afTheta),a2fTargetCenter(q,2)+80*sin(afTheta),'color',[0.5 0.5 0.5]);
    end
    
    
    for k=1:length(aiCorrectTrialInd)
        strctTrial = strctData.m_acTrials{aiCorrectTrialInd(k)};
        aiSubset = strctTrial.m_strctNewTrialOutcome.m_iSaccadeOnset:strctTrial.m_strctNewTrialOutcome.m_iFixationOnset;
        afX = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeXpixZero,fspecial('gaussian',[50 1],2));
        afY = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeYpixZero,fspecial('gaussian',[50 1],2));
        if ~isnan(aiSubset)
            plot(afX(aiSubset),afY(aiSubset),'color',[0.5 0.5 0.5]);
        end
    end
    
    for k=1:length(aiIncorrectTrialInd)
        strctTrial = strctData.m_acTrials{aiIncorrectTrialInd(k)};
        aiSubset = strctTrial.m_strctNewTrialOutcome.m_iSaccadeOnset:strctTrial.m_strctNewTrialOutcome.m_iFixationOnset;
        if ~isnan(aiSubset)
        afX = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeXpixZero,fspecial('gaussian',[50 1],2));
        afY = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeYpixZero,fspecial('gaussian',[50 1],2));
        if ~isnan(aiSubset)
            plot(afX(aiSubset),afY(aiSubset),'b');
        end
 
         end
        
    end
    axis equal
    axis ij
    axis([-400 400 -400 400]);
    title(a2cCompareTrials(iDirection,1))
end






for iDirection = 1:8
    iEntry = find(ismember( strctData.m_acUniqueTrialNames, a2cCompareTrials(iDirection,2)));
    
    aiCorrectTrialInd = strctData.m_a2cTrialsIndicesSorted{iEntry,iCorrectIndex};
    aiIncorrectTrialInd = strctData.m_a2cTrialsIndicesSorted{iEntry,iIncorrectIndex};
    subplot(2,4,iDirection);
    hold on;
     
    for k=1:length(aiCorrectTrialInd)
        strctTrial = strctData.m_acTrials{aiCorrectTrialInd(k)};
        aiSubset = strctTrial.m_strctNewTrialOutcome.m_iSaccadeOnset:strctTrial.m_strctNewTrialOutcome.m_iFixationOnset;
        afX = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeXpixZero,fspecial('gaussian',[50 1],2));
        afY = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeYpixZero,fspecial('gaussian',[50 1],2));
        if ~isnan(aiSubset)
            plot(afX(aiSubset),afY(aiSubset),'color',[0.5 0.5 0.5]);
        end
    end
    
    for k=1:length(aiIncorrectTrialInd)
        strctTrial = strctData.m_acTrials{aiIncorrectTrialInd(k)};
        aiSubset = strctTrial.m_strctNewTrialOutcome.m_iSaccadeOnset:strctTrial.m_strctNewTrialOutcome.m_iFixationOnset;
        if ~isnan(aiSubset)
        afX = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeXpixZero,fspecial('gaussian',[50 1],2));
        afY = conv2(strctTrial.m_strctNewTrialOutcome.m_afEyeYpixZero,fspecial('gaussian',[50 1],2));
        if ~isnan(aiSubset)
            plot(afX(aiSubset),afY(aiSubset),'g');
        end
 
         end
        
    end
end



%%
function fnNewBehaviorAnalysis(acData,acExperimentSite,acExperimentDate,aiRelevantExperiments,abShowColorBar)
a2cCompareTrials = {...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp'};
    
   

acCanonicalTargets = {'SaccadeTaskRight','SaccadeTaskLeft','SaccadeTaskUp','SaccadeTaskDown','SaccadeTaskRightUp','SaccadeTaskRightDown','SaccadeTaskLeftUp','SaccadeTaskLeftDown'};
 acCanonicalTargetsStim = {'MicrostimSaccadeTaskRight','MicrostimSaccadeTaskLeft','MicrostimSaccadeTaskUp','MicrostimSaccadeTaskDown','MicrostimSaccadeTaskRightUp','MicrostimSaccadeTaskRightDown','MicrostimSaccadeTaskLeftUp','MicrostimSaccadeTaskLeftDown'};
 
% 
% a3fTrialStats_NoStim = fnExtractTrialStats(acData,a2cCompareTrials(:,1),false);
% a3fTrialStats_Stim = fnExtractTrialStats(acData,a2cCompareTrials(:,2),false);
% strctStat = fnFindSignificantChanges(a3fTrialStats_NoStim ,a3fTrialStats_Stim);

[a3fTrialStats_NoStim, a3iIncorrectStat_NoStim] = fnExtractTrialStats(acData,a2cCompareTrials(:,1),true,acCanonicalTargets);
[a3fTrialStats_Stim, a3iIncorrectStat_Stim] = fnExtractTrialStats(acData,a2cCompareTrials(:,2),true,acCanonicalTargetsStim);
strctStat_Relaxed= fnFindSignificantChanges(a3fTrialStats_NoStim ,a3fTrialStats_Stim);

a2fPercCorrect_NoStim = reshape(a3fTrialStats_NoStim(:,2,:) ./ (a3fTrialStats_NoStim(:,2,:)+a3fTrialStats_NoStim(:,3,:)) * 1e2, 8, size(a3fTrialStats_NoStim,3))';
a2fPercCorrect_Stim = reshape(a3fTrialStats_Stim(:,2,:) ./ (a3fTrialStats_Stim(:,2,:)+a3fTrialStats_Stim(:,3,:)) * 1e2, 8, size(a3fTrialStats_Stim,3))';

abArchExperiments = ismember(acExperimentSite,'Arch');
abSignificant = (min(strctStat_Relaxed.m_a2fPValue,[],2) < 0.05)';
aiSubset = find(abSignificant & abArchExperiments);


aiControlSessions = find(ismember(acExperimentSite,'Control'));
min(strctStat_Relaxed.m_a2fPValue(aiControlSessions,:),[],2)
% aiRelevantExperiments=aiControlSessions
afContrastValue = fnReadContrastValues(acData);

for iExpIter=1:length(aiRelevantExperiments)

    acDirections = {'N','NE','E','SE','S','SW','W','NW'};
    iSelectedExperiment = aiRelevantExperiments(iExpIter);
    fprintf('Experiment %d : n= %d\n',iSelectedExperiment,sum(sum(a3fTrialStats_NoStim(:,2:3,    iSelectedExperiment)))+sum(sum(a3fTrialStats_Stim(:,2:3,    iSelectedExperiment))));
    
    aiSig = find(strctStat_Relaxed.m_a2fPValue(iSelectedExperiment,:) < 0.05);
    afGreen = [0,176,80]/255;
    figure(100+2*iExpIter);clf;hold on;
    h=bar([a2fPercCorrect_NoStim(iSelectedExperiment,:);a2fPercCorrect_Stim(iSelectedExperiment,:)]');
    % plot(aiSig, a2fPercCorrect_NoStim(iSelectedExperiment,aiSig)+ 10,'k*');
    set(h(1),'facecolor',[0.5 0.5 0.5]);
    set(h(2),'facecolor', afGreen);
    set(gca,'xtick',1:8,'xticklabel',acDirections);
    set(gca,'xlim',[0.5 8.5],'ylim',[0 100]);
    set(gca,'fontsize',7);
    set(gcf,'position',[ 1083         974         154         124]);
    
    a2fIncorrectStat_Stim = a3iIncorrectStat_Stim(:,:,iSelectedExperiment) ./ repmat(sum(a3iIncorrectStat_Stim(:,:,iSelectedExperiment),2),1,8);
    a2fIncorrectStat_NoStim = a3iIncorrectStat_NoStim(:,:,iSelectedExperiment) ./ repmat(sum(a3iIncorrectStat_NoStim(:,:,iSelectedExperiment),2),1,8);
    a2fDiff = a2fIncorrectStat_Stim-a2fIncorrectStat_NoStim;
    figure(101+2*iExpIter);
    imagesc(1:8,1:8,1e2*a2fDiff,[-20 20]);colormap winter;
    if abShowColorBar(iExpIter)
        colorbar('location','westoutside');
        set(gca,'xtick',1:8,'ytick',1:8,'xticklabel',acDirections,'yticklabel',acDirections)
        set(gca,'fontsize',7);
        set(gcf,'position',[   1250         914         172         109]);
        
    else
        set(gca,'xtick',1:8,'ytick',1:8,'xticklabel',acDirections,'yticklabel',[])
        set(gca,'fontsize',7);
        %set(gcf,'position',[    1250         909         128         114]);
        set(gcf,'position',[    1250         909         161         114]);
        set(gca,'xtick',1:8,'ytick',1:8,'xticklabel',acDirections,'yticklabel',acDirections,'yAxisLocation','right')
    end
end

%%

%% Population analysis

aiSubset = find(ismember(acExperimentSite,'Halo'));
figure(3);clf;imagesc(1:8,1:length(aiSubset),strctStat_Relaxed.m_a2fPercCorrectChange(aiSubset,:),[-40 40]);set(gca,'ytick',1:length(aiSubset));colorbar
hold on;
for k=1:length(aiSubset)
    aiSig = find(strctStat_Relaxed.m_a2fPValue(aiSubset(k),:)<0.05);
    if ~isempty(aiSig)
        plot(aiSig,k,'k*');
    end
end


aiSubset = find(ismember(acExperimentSite,'Arch'));
figure(2);clf;imagesc(1:8,1:length(aiSubset),strctStat_Relaxed.m_a2fPercCorrectChange(aiSubset,:),[-40 40]);set(gca,'ytick',1:length(aiSubset));colorbar
hold on;
for k=1:length(aiSubset)
    aiSig = find(strctStat_Relaxed.m_a2fPValue(aiSubset(k),:)<0.05);
    if ~isempty(aiSig)
        plot(aiSig,k,'k*');
    end
end

% a2fChanges=strctStat_Relaxed.m_a2fPercCorrectChange;
% a2fChanges(~ismember(acExperimentSite,'Arch'),:) = NaN;
% aiArchExperiments = find(ismember(acExperimentSite,'Arch'));
% 
% sum(ismember(acExperimentSite,'Arch'))
% sum(sum(strctStat_Relaxed.m_a2fPValue(ismember(acExperimentSite,'Arch'),:) < 0.05,2) > 0)
% aiSessionsWithSignificantChange = find(sum(strctStat_Relaxed.m_a2fPValue(ismember(acExperimentSite,'Arch'),:) < 0.05,2) > 0);
% 
% Tmp = sum(strctStat_Relaxed.m_a2fPValue(ismember(acExperimentSite,'Arch'),:) < 0.05,2) 
% mean(Tmp(Tmp>2))
% std(Tmp(Tmp>0))
% 
aiSubset = 1:length(acExperimentSite);
figure(2);clf;imagesc(1:8,1:length(aiSubset),a2fChanges(aiSubset,:),[-40 40]);set(gca,'ytick',1:length(aiSubset));colorbar
hold on;
for k=1:length(aiSubset)
    aiSig = find(strctStat_Relaxed.m_a2fPValue(aiSubset(k),:)<0.05);
    if ~isempty(aiSig)
        plot(aiSig,k,'k*');
    end
end


%%



function fnPrintSaccadeAux(X,Y,iBaseFigure,XOffset,MaxVisualAngle,fMaxAmplitude,fRange2)
if ~exist('fRange2','var')
    fRange2 = 400;
end;
% Sample at 100 ms post stimulation (typically, a good place...)
afMedianX = median(X,1);
afMedianY = median(Y,1);
a2fGaze = sqrt(X.^2+Y.^2);
afBaselineDist = max(a2fGaze(:,150:250)',[],1);

aiAmplitudeInterval = 360:410;
afAmplitude = mean(a2fGaze(:,aiAmplitudeInterval),2);


abNoBlink= max(a2fGaze(:,1:500),[],2)' < 1000;
abStableBaseline = afBaselineDist<60;
abValid = abStableBaseline & abNoBlink ;


abLargeAmplitude = afAmplitude > 50;

aiSamplingInterval = 200+[150:200];%380:400;% 200+[120:160]
afAvgX = mean(X(abValid' & abLargeAmplitude,aiSamplingInterval),2);
afAvgY = mean(Y(abValid' & abLargeAmplitude,aiSamplingInterval),2);
% Average angle ?
afAvgAngle = atan2(-afAvgY,afAvgX);


[tout,rout]=rose(afAvgAngle,20);
rout=rout/sum(rout);

fPIX_TO_VISUAL_ANGLE = 28.8/800;

[afHist,afCent]=hist(afAmplitude(abValid),[0:2:fMaxAmplitude]/fPIX_TO_VISUAL_ANGLE);
%
figure(iBaseFigure+4);
clf;
plot(X(abValid,200:400)',-Y(abValid,200:400)','k');    hold on;
%     plot(X(abStableBaseline & abNoSaccade,500)',Y(abStableBaseline& abNoSaccade,500)','r*');
%     plot([0 cos(fSaccadeDirection)]*300,[0 sin(fSaccadeDirection)]*300,'g');
axis equal
axis([-fRange2 fRange2 -fRange2 fRange2]);
plot(0,0,'r+');
set(gca,'xtick',[],'ytick',[]);
set(gcf,'position',[ 1066-XOffset         409         128          94]);
% scale bar:
if 1
    rectangle('position',[-fRange2+50 fRange2-80 5/fPIX_TO_VISUAL_ANGLE 20],'facecolor','k');
end

return;