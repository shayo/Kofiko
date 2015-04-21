function fnEntryPoint_OptogeneticsFEF()

afBlue = [0,176,240]/255;
afGreen = [0,176,80]/255;
afOrange = [255,192,0]/255;
afPurple = [0.54 0.09 1];
afCyan = [64,255,191]/255;
afDarkBlue = [0,0,191]/255;
for k=1:20
    try
        close(k);
    catch
    end;
end;
warning off


global g_strRootDrive
g_strRootDrive = 'D';



   

if 0
    fnPrintPopulationSaccadeMemoryTask();

    acAngularInfoControls = fnPrintNoIncreaseInSaccadeProbabilityForControls();
    acAngularInfoChR2 = fnPrintIncreaseInSaccadeProbabilityChR2();
end
if 0
fnPrintArchDuringMemorySaccadeTask
end
if 0
acAngularArch= fnPrintIncreaseInSaccadeProbabilityForArchSite()
end

if 0
acAngularInfoSpecialSiteBert= fnPrintOpticalInducedSaccadesPlot();
end


if 0
    acAngularInfoChR2 = fnPrintIncreaseInSaccadeProbabilityChR2();
end


if 0
    acAngularInfoControls = fnPrintNoIncreaseInSaccadeProbabilityForControls();
    fnPrintConentration(acAngularInfoChR2,acAngularInfoControls,acAngularInfoSpecialSiteBert)

end



if 0


 
 strhSyn_ChETAExample= 'D:\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\Optogenetic_Analysis\Anakin-130309_152128_OptogeneticsMicrostim_Channel_1_Interval23_Trigger_Grass2.mat';
fnPrintExampleOpticalStimulationCell(strhSyn_ChETAExample, 5,[],80,afCyan,2);


    strHaloSUAExample = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120405\RAW\..\Processed\Optogenetic_Analysis\Julien-120405_121515_OptogeneticsMicrostim_Channel_1_Interval11_Trigger_Grass1.mat'];
fnPrintExampleOpticalStimulationCell(strHaloSUAExample, 1,200:400,70,[1 0.75 0]);

% strHaloSUAExample3 = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\111212\RAW\..\Processed\Optogenetic_Analysis\Bert-111212_144722_OptogeneticsMicrostim_Channel_1_Interval94_Trigger_Grass1.mat'];
% fnPrintExampleOpticalStimulationCell(strHaloSUAExample3, 1,50:200,70,[1 0.75 0],2);
% strHaloSUAExample2 = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120425\RAW\..\Processed\Optogenetic_Analysis\Bert-120425_120557_OptogeneticsMicrostim_Channel_2_Interval34_Trigger_Grass1.mat'];
% fnPrintExampleOpticalStimulationCell(strHaloSUAExample2, 2, [],70,[1 0.75 0],3);


strArchSUAExample = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120302\RAW\..\Processed\Optogenetic_Analysis\Julien-120302_145041_OptogeneticsMicrostim_Channel_1_Interval65_Trigger_Grass1.mat'];
fnPrintExampleOpticalStimulationCell(strArchSUAExample, 1,[],60,[0 0.69 0.31]);

strChR2ChetaCamKIIExample2 =  'D:\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\Optogenetic_Analysis\Anakin-130308_152100_OptogeneticsMicrostim_Channel_1_Interval36_Trigger_Grass2.mat';
fnPrintExampleOpticalStimulationCell(strChR2ChetaCamKIIExample2, 5,[],80,[0.54 0.09 1],2);


%    D:\Data\Doris\Electrophys\Bert\Optogenetics\111222\RAW\..\Processed\Optogenetic_Analysis\Bert-111222_165707_OptogeneticsMicrostim_Channel_1_Interval4_Trigger_Grass1.mat

strChR2SUAExample4 =  [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120229\RAW\..\Processed\Optogenetic_Analysis\Julien-120229_130405_OptogeneticsMicrostim_Channel_1_Interval19_Trigger_Grass1.mat'];
strChR2SUAExample4 =  [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\111222\RAW\..\Processed\Optogenetic_Analysis\Bert-111222_165707_OptogeneticsMicrostim_Channel_1_Interval4_Trigger_Grass1.mat'];

   
strChR2SUAExample3 =  [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120105\RAW\..\Processed\Optogenetic_Analysis\Bert-120105_093819_OptogeneticsMicrostim_Channel_1_Interval16_Trigger_Grass1.mat'];
fnPrintExampleOpticalStimulationCell(strChR2SUAExample4, 1,[1:20],80,[0 0.69 0.94],2);
% 
% strChR2SUAExample2 =  [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120307\RAW\..\Processed\Optogenetic_Analysis\Julien-120307_155009_OptogeneticsMicrostim_Channel_1_Interval26_Trigger_Grass1.mat'];
% fnPrintExampleOpticalStimulationCell(strChR2SUAExample2, 1,[],80,[0 0.69 0.94],1.5);

%strChR2SUAExample =  [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120307\RAW\..\Processed\Optogenetic_Analysis\Julien-120307_155009_OptogeneticsMicrostim_Channel1_Interval12.mat';
% strChR2SUAExample =  [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120307\RAW\..\Processed\Optogenetic_Analysis\Julien-120307_155009_OptogeneticsMicrostim_Channel_1_Interval29_Trigger_Grass1.mat'];
% fnPrintExampleOpticalStimulationCell(strChR2SUAExample, 1,70:180,80,[0 0.69 0.94],1.5);
end

if 1
    strChR2File = [g_strRootDrive,':\Data\Doris\Data For Publications\FEF Opto\ChR2_PopulationStats.mat'];
    afIncreaseRatioChR2 = fnPrintPopulationNeuralResponses(strChR2File,-500:1000,afBlue,28,450,550, 'ChR2');
end

if 1
strhSyn_ChETAFile = [g_strRootDrive,':\Data\Doris\Data For Publications\FEF Opto\hSyn_hChR2(E123A)_PopulationStats.mat'];
afIncreaseRatioCheta_hSyn = fnPrintPopulationNeuralResponses(strhSyn_ChETAFile,-500:1000,afCyan,0,350,2550, 'Cheta');
end
%4.2
% fnGenerateLFPPlot(strChR2File,afBlue,500,300);
if 1
strCamKII_ChETAFile = [g_strRootDrive,':\Data\Doris\Data For Publications\FEF Opto\CamKII_hChR2(E123A)_PopulationStats.mat'];
afIncreaseRatioCheta_CamKII = fnPrintPopulationNeuralResponses(strCamKII_ChETAFile,-500:1000,afPurple,0,350,2550,'Cheta');
end
if exist('afIncreaseRatioChR2','var') && exist('afIncreaseRatioCheta_hSyn','var') && exist('afIncreaseRatioCheta_CamKII','var')
    afChR2_H134R = afIncreaseRatioChR2(~isinf(afIncreaseRatioChR2) & afIncreaseRatioChR2 < 400);
    afChR2_E123A_hSyn = afIncreaseRatioCheta_hSyn(~isinf(afIncreaseRatioCheta_hSyn) & afIncreaseRatioCheta_hSyn < 400);
    afChR2_E123A_CamKII = afIncreaseRatioCheta_CamKII(~isinf(afIncreaseRatioCheta_CamKII) & afIncreaseRatioCheta_CamKII < 400);
    [a,b]=kstest2(afChR2_E123A_hSyn(:), afChR2_H134R(:),0.05,'larger')
    
%   [afHist1, afCent1]=hist(afChR2_H134R,0:5:200)
%   [afHist2, afCent2]=hist(afChR2_E123A_hSyn,0:5:200)
%   afHist1 = afHist1 / sum(afHist1);
%   afHist2 = afHist2 / sum(afHist2);
%   
%    figure(11);clf; hold on;
%   plot((afCent1),cumsum(afHist1),'color',afBlue);
%   plot((afCent2),cumsum(afHist2),'color',afCyan);

    
end


if 1

strArchFile = [g_strRootDrive,':\Data\Doris\Data For Publications\FEF Opto\Arch_PopulationStats.mat'];
%fnGenerateLFPPlot(strArchFile,afGreen,500,300);
fnPrintPopulationNeuralResponses(strArchFile,-500:1000,afGreen,28.5,450,550,'Arch');
end
if 1

    strHaloFile = [g_strRootDrive,':\Data\Doris\Data For Publications\FEF Opto\eNpHR3.0_PopulationStats.mat'];
    fnPrintPopulationNeuralResponses(strHaloFile,[-500:1500],afOrange,29,950,1100, 'Halo');
end




%D:\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\Optogenetic_Analysis\Anakin-130311_152015_OptogeneticsMicrostim_Channel_1_Interval18_Trigger_Grass2.mat
% 50 Hz:
%D:\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\Optogenetic_Analysis\Anakin-130309_152128_OptogeneticsMicrostim_Channel_1_Interval35_Trigger_Grass2.mat
% 80 Hz:
%

%D:\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\Optogenetic_Analysis\Anakin-130313_130434_OptogeneticsMicrostim_Channel_1_Interval10_Trigger_Grass2.mat


% strArchSUAExample2 = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120302\RAW\..\Processed\Optogenetic_Analysis\Julien-120302_145041_OptogeneticsMicrostim_Channel_1_Interval58_Trigger_Grass1.mat'];
% fnPrintExampleOpticalStimulationCell(strArchSUAExample2, 1,[],60,[0 0.69 0.31]);
% 
% strArchSUAExample3 = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120302\RAW\..\Processed\Optogenetic_Analysis\Julien-120302_145041_OptogeneticsMicrostim_Channel_1_Interval57_Trigger_Grass1.mat'];
% fnPrintExampleOpticalStimulationCell(strArchSUAExample3, 1,50:150,60,[0 0.69 0.31]);
% 








% strChR2ChetaCamKIIExample1 =  [g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\Optogenetic_Analysis\Anakin-130307_145520_OptogeneticsMicrostim_Channel_1_Interval11_Trigger_Grass2.mat'];
% fnPrintExampleOpticalStimulationCell(strChR2ChetaCamKIIExample1, 1,[],80,[0.54 0.09 1],2);









fnPrintArchDuringMemorySaccadeTask()
fnPrintPopulationSaccadeMemoryTask()
% 
fnPrintArchDuringMemorySaccadeTask();
fnPrintOpticalInducedSaccadesPlot()

%%


strChR2SUAExample1 =  [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\111216\RAW\..\Processed\Optogenetic_Analysis\Bert-111216_161304_OptogeneticsMicrostim_Channel_1_Interval15_Trigger_Grass1.mat'];
fnPrintExampleOpticalStimulationCell(strChR2SUAExample1, 1,[],80,[0 0.69 0.94],2);










fnPrintArchDuringMemorySaccadeTask()


strJulienSession = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\BehaviorStats\Julien-26-May-2012_11-24-30_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];
fnPrintIncreaseInSaccadeLatency(strJulienSession, 2);
strBertSession = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\BehaviorStats\Bert-10-Jun-2012_11-17-17_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp8.mat'];
fnPrintIncreaseInSaccadeLatency(strBertSession, 6);

























%%

%%






fnPrintIncreaseInSaccadeProbability();


fnPrintPopulationSaccadeMemoryTask();



%fnPrintExampleEyeMovementDuringElecricalStimulation()


fnPrintPopulationEyeMovementDuringOpticalStimulation();







% Final script to generate figures for the Optogenetics FEF paper
strArchMUAExample = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120327\RAW\..\Processed\Optogenetic_Analysis\Julien-120327_102326_OptogeneticsMicrostim_Channel1_Interval38.mat'];
fnPrintExampleOpticalStimulationCell(strArchMUAExample, 1,1:100,60,[0 0.69 0.31]);

strHaloMUAExample = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120405\RAW\..\Processed\Optogenetic_Analysis\Julien-120405_121515_OptogeneticsMicrostim_Channel1_Interval11.mat'];
fnPrintExampleOpticalStimulationCell(strHaloMUAExample, 1,1:100,70,[1 0.75 0]);


fnPrintSaccadesBeforeInjection();


fnPrintPopulationEyeMovementDuringOpticalStimulationControl()

% Final script to generate figures for the Optogenetics FEF paper
strChR2SUAExample =  [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120307\RAW\..\Processed\Optogenetic_Analysis\Julien-120307_155009_OptogeneticsMicrostim_Channel1_Interval12.mat'];
fnPrintExampleOpticalStimulationCell(strChR2SUAExample, 1,1:100,80,[0 0.69 0.94]);








return;

fnPrintSaccadesBeforeInjection();

figure(2);fnPrintExampleEyeMovementDuringElecricalStimulation()


fnPrintPopulationEyeMovementDuringPulsedOpticalStimulation()

function fnPrintConentration(acAngularInfoChR2,acAngularInfoControls,acAngularInfoSpecialSiteBert,fnPrintConentration)

acAngularStat = [acAngularInfoChR2,acAngularInfoControls];
afAngularStd = [];
for k=1:length(acAngularStat)
    afAngularStd(k) = acAngularStat{k}{1};
end
[afHist, afCent]=hist(afAngularStd);
figure(11);
clf;
bar(afCent,afHist,'facecolor',[0.5 0.5 0.5]);
hold on;
rectangle('Position',[acAngularInfoSpecialSiteBert{1}-10 0 20 1],'facecolor','k')
set(gca,'fontsize',7);
P=get(gcf,'position');
P(3:4)=[235         174];set(gcf,'position',P);

    [p,h]=ttest(afAngularStd, 263)
    
    
    X1=acAngularInfoSpecialSiteBert{3};
    Y1=acAngularInfoSpecialSiteBert{4};
    
    fnPrintSaccadeAux(X1,Y1,10,0,20,16);
    
    X1 = acAngularStat{2}{3};
    Y1 = acAngularStat{2}{4};
  
    figure(501);
    clf; hold on;
    for k=1:size(X1,1)
        plot(X1(k,1:500),-Y1(k,1:500),'k');
    end;
    axis([-800 800 -800 800])
    box on
    axis on
    hold on
    plot(0,0,'r+');
    set(gca,'xtick',[],'ytick',[])
    
%    
    


% 
% 
% 
% 
% 
% 
% figure(13);clf;
% semilogy(afAngularStd/pi*180);
% hold on;
% plot([0 14],acAngularInfoSpecialSiteBert{1}*ones(1,2)/pi*180,'r');
% set(gca,'ylim',[10^-2 10^2])    
% figure(14);
% clf;
% 
% N=18;
% for k=1:length(acAngularStat)
%     aiNum(k)=size(acAngularStat{k}{2},1);
%     subplot(4,4,k);
%     [afAngular(k),aiN(k)]=fnPrintSaccadeAux3(acAngularStat{k}{2},acAngularStat{k}{3},600);
%     title(sprintf('%.4f',afAngular(k)));
% end
% subplot(4,4,16);
% S2=fnPrintSaccadeAux3(acAngularInfoSpecialSiteBert{2},acAngularInfoSpecialSiteBert{3},400);
%     title(sprintf('%.4f',S2));

    



function acAngularStats= fnPrintIncreaseInSaccadeProbabilityForArchSite()
global g_strRootDrive
acSessionDataFilesJulien = {...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120523\RAW\..\Processed\ElectricalMicrostim\Julien-23-May-2012_10-29-09_Microstim_Channel_1_Depth_28-30_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120523\RAW\..\Processed\ElectricalMicrostim\Julien-23-May-2012_10-29-09_Microstim_Channel_1_Depth_28-30_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120523\RAW\..\Processed\ElectricalMicrostim\Julien-23-May-2012_10-29-09_Microstim_Channel_1_Depth_28-30_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120524\RAW\..\Processed\ElectricalMicrostim\Julien-24-May-2012_10-36-43_Microstim_Channel_1_Depth_30-90_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120524\RAW\..\Processed\ElectricalMicrostim\Julien-24-May-2012_10-36-43_Microstim_Channel_1_Depth_30-90_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120524\RAW\..\Processed\ElectricalMicrostim\Julien-24-May-2012_10-36-43_Microstim_Channel_1_Depth_30-90_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\ElectricalMicrostim\Julien-26-May-2012_11-24-30_Microstim_Channel_1_Depth_31-60_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\ElectricalMicrostim\Julien-26-May-2012_11-24-30_Microstim_Channel_1_Depth_31-60_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\ElectricalMicrostim\Julien-26-May-2012_11-24-30_Microstim_Channel_1_Depth_31-60_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120527\RAW\..\Processed\ElectricalMicrostim\Julien-27-May-2012_10-12-26_Microstim_Channel_1_Depth_30-03_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120527\RAW\..\Processed\ElectricalMicrostim\Julien-27-May-2012_10-12-26_Microstim_Channel_1_Depth_30-03_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120527\RAW\..\Processed\ElectricalMicrostim\Julien-27-May-2012_10-12-26_Microstim_Channel_1_Depth_30-03_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120528\RAW\..\Processed\ElectricalMicrostim\Julien-28-May-2012_11-01-37_Microstim_Channel_1_Depth_31-30_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120528\RAW\..\Processed\ElectricalMicrostim\Julien-28-May-2012_11-01-37_Microstim_Channel_1_Depth_31-30_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120528\RAW\..\Processed\ElectricalMicrostim\Julien-28-May-2012_11-01-37_Microstim_Channel_1_Depth_31-30_Trig_Grass2.mat']},...
    };

acSessionDataFilesBert = {...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-06_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-06_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-06_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-60_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-60_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-60_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-80_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-80_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-80_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120611\RAW\..\Processed\ElectricalMicrostim\Bert-11-Jun-2012_08-54-54_Microstim_Channel_1_Depth_30-21_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120611\RAW\..\Processed\ElectricalMicrostim\Bert-11-Jun-2012_08-54-54_Microstim_Channel_1_Depth_30-21_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120611\RAW\..\Processed\ElectricalMicrostim\Bert-11-Jun-2012_08-54-54_Microstim_Channel_1_Depth_30-21_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120611\RAW\..\Processed\ElectricalMicrostim\Bert-11-Jun-2012_08-54-54_Microstim_Channel_1_Depth_30-41_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120611\RAW\..\Processed\ElectricalMicrostim\Bert-11-Jun-2012_08-54-54_Microstim_Channel_1_Depth_30-41_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120611\RAW\..\Processed\ElectricalMicrostim\Bert-11-Jun-2012_08-54-54_Microstim_Channel_1_Depth_30-41_Trig_Grass2.mat']}
    };
fnPrintChangesInSaccadeProbability(acSessionDataFilesBert,true,'g');
fnPrintChangesInSaccadeProbability([acSessionDataFilesJulien,acSessionDataFilesBert],false,'g');

 fnPrintChangesInSaccadeProbability(acSessionDataFilesJulien,false,'g');


return;


function acAngularStat = fnPrintIncreaseInSaccadeProbabilityChR2()
global g_strRootDrive
acSessionDataFilesJulien = {...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120516\RAW\..\Processed\ElectricalMicrostim\Julien-16-May-2012_10-23-37_Microstim_Channel_1_Depth_31-61_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120516\RAW\..\Processed\ElectricalMicrostim\Julien-16-May-2012_10-23-37_Microstim_Channel_1_Depth_31-61_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120516\RAW\..\Processed\ElectricalMicrostim\Julien-16-May-2012_10-23-37_Microstim_Channel_1_Depth_31-61_Trig_Grass2.mat']}...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\ElectricalMicrostim\Julien-15-May-2012_11-45-45_Microstim_Channel_1_Depth_30-30_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\ElectricalMicrostim\Julien-15-May-2012_11-45-45_Microstim_Channel_1_Depth_30-30_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\ElectricalMicrostim\Julien-15-May-2012_11-45-45_Microstim_Channel_1_Depth_30-30_Trig_Grass2.mat']}...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\ElectricalMicrostim\Julien-15-May-2012_11-45-45_Microstim_Channel_1_Depth_30-32_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\ElectricalMicrostim\Julien-15-May-2012_11-45-45_Microstim_Channel_1_Depth_30-32_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120515\RAW\..\Processed\ElectricalMicrostim\Julien-15-May-2012_11-45-45_Microstim_Channel_1_Depth_30-32_Trig_Grass2.mat']}...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120511\RAW\..\Processed\ElectricalMicrostim\Julien-11-May-2012_14-22-56_Microstim_Channel_1_Depth_30-80_Trig_Grass1.mat'],... % Early sessions. Might not be useable....
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120511\RAW\..\Processed\ElectricalMicrostim\Julien-11-May-2012_14-22-56_Microstim_Channel_1_Depth_30-80_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120511\RAW\..\Processed\ElectricalMicrostim\Julien-11-May-2012_14-22-56_Microstim_Channel_1_Depth_30-80_Trig_Grass2.mat']}...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120510\RAW\..\Processed\ElectricalMicrostim\Julien-10-May-2012_14-40-59_Microstim_Channel_1_Depth_30-20_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120510\RAW\..\Processed\ElectricalMicrostim\Julien-10-May-2012_14-40-59_Microstim_Channel_1_Depth_30-20_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120510\RAW\..\Processed\ElectricalMicrostim\Julien-10-May-2012_14-40-59_Microstim_Channel_1_Depth_30-20_Trig_Grass2.mat']};...
    };

    acSessionDataFilesBert = {...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120607\RAW\..\Processed\ElectricalMicrostim\Bert-07-Jun-2012_15-51-42_Microstim_Channel_1_Depth_29-50_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120607\RAW\..\Processed\ElectricalMicrostim\Bert-07-Jun-2012_15-51-42_Microstim_Channel_1_Depth_29-50_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120607\RAW\..\Processed\ElectricalMicrostim\Bert-07-Jun-2012_15-51-42_Microstim_Channel_1_Depth_29-50_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120609\RAW\..\Processed\ElectricalMicrostim\Bert-09-Jun-2012_11-42-09_Microstim_Channel_1_Depth_30-39_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120609\RAW\..\Processed\ElectricalMicrostim\Bert-09-Jun-2012_11-42-09_Microstim_Channel_1_Depth_30-39_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120609\RAW\..\Processed\ElectricalMicrostim\Bert-09-Jun-2012_11-42-09_Microstim_Channel_1_Depth_30-39_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120609\RAW\..\Processed\ElectricalMicrostim\Bert-09-Jun-2012_11-42-09_Microstim_Channel_1_Depth_30-60_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120609\RAW\..\Processed\ElectricalMicrostim\Bert-09-Jun-2012_11-42-09_Microstim_Channel_1_Depth_30-60_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120609\RAW\..\Processed\ElectricalMicrostim\Bert-09-Jun-2012_11-42-09_Microstim_Channel_1_Depth_30-60_Trig_Grass2.mat']}};




acSessionDataFilesAnakinHSyn = {...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130314\RAW\..\Processed\ElectricalMicrostim\Anakin-14-Mar-2013_10-39-24_Microstim_Channel_1_Depth_25-65_Trig_Grass1.mat'],...
 [g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130314\RAW\..\Processed\ElectricalMicrostim\Anakin-14-Mar-2013_10-39-24_Microstim_Channel_1_Depth_25-65_Trig_Grass1and2.mat'],...
 [g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130314\RAW\..\Processed\ElectricalMicrostim\Anakin-14-Mar-2013_10-39-24_Microstim_Channel_1_Depth_25-65_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_26-45_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_26-45_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_26-45_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-00_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-00_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-00_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-43_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-43_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-43_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-80_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-80_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130311\RAW\..\Processed\ElectricalMicrostim\Anakin-11-Mar-2013_15-20-31_Microstim_Channel_1_Depth_27-80_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_25-30_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_25-30_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_25-30_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_26-42_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_26-42_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_26-42_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_26-80_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_26-80_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_26-80_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_27-10_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_27-10_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130309\RAW\..\Processed\ElectricalMicrostim\Anakin-09-Mar-2013_15-21-53_Microstim_Channel_1_Depth_27-10_Trig_Grass2.mat']},...
};
% 7 March: CamKII
% 8 March: CamKII
% 12 March: CamKII
% 13 March: CamKII
% 15 March: CamKII

acSessionDataFilesAnakinCamKII = {...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_11-34-53_Microstim_Channel_1_Depth_24-50_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_11-34-53_Microstim_Channel_1_Depth_24-50_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_11-34-53_Microstim_Channel_1_Depth_24-50_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_13-04-47_Microstim_Channel_1_Depth_24-95_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_13-04-47_Microstim_Channel_1_Depth_24-95_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_13-04-47_Microstim_Channel_1_Depth_24-95_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_13-04-47_Microstim_Channel_1_Depth_25-30_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_13-04-47_Microstim_Channel_1_Depth_25-30_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130313\RAW\..\Processed\ElectricalMicrostim\Anakin-13-Mar-2013_13-04-47_Microstim_Channel_1_Depth_25-30_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130312\RAW\..\Processed\ElectricalMicrostim\Anakin-12-Mar-2013_15-46-00_Microstim_Channel_1_Depth_25-35_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130312\RAW\..\Processed\ElectricalMicrostim\Anakin-12-Mar-2013_15-46-00_Microstim_Channel_1_Depth_25-35_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130312\RAW\..\Processed\ElectricalMicrostim\Anakin-12-Mar-2013_15-46-00_Microstim_Channel_1_Depth_25-35_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130312\RAW\..\Processed\ElectricalMicrostim\Anakin-12-Mar-2013_15-46-00_Microstim_Channel_1_Depth_25-96_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130312\RAW\..\Processed\ElectricalMicrostim\Anakin-12-Mar-2013_15-46-00_Microstim_Channel_1_Depth_25-96_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130312\RAW\..\Processed\ElectricalMicrostim\Anakin-12-Mar-2013_15-46-00_Microstim_Channel_1_Depth_25-96_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_26-00_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_26-00_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_26-00_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-10_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-10_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-10_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-40_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-40_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-40_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-90_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-90_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_27-90_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_28-31_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_28-31_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130308\RAW\..\Processed\ElectricalMicrostim\Anakin-08-Mar-2013_15-21-17_Microstim_Channel_1_Depth_28-31_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_25-11_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_25-11_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_25-11_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_25-67_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_25-67_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_25-67_Trig_Grass2.mat']},...
{[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_26-00_Trig_Grass1.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_26-00_Trig_Grass1and2.mat'],...
[g_strRootDrive,':\Data\Doris\Electrophys\Anakin\Optogenetics\130307\RAW\..\Processed\ElectricalMicrostim\Anakin-07-Mar-2013_14-55-42_Microstim_Channel_1_Depth_26-00_Trig_Grass2.mat']}...
};

acAngularStat = [];
acAngularStat = fnPrintChangesInSaccadeProbability(acSessionDataFilesBert,true,'b');
acAngularStat=[acAngularStat,fnPrintChangesInSaccadeProbability(acSessionDataFilesJulien,false,'b');];
acAngularStat=[acAngularStat,fnPrintChangesInSaccadeProbability(acSessionDataFilesAnakinHSyn,false,'b');];
if 0
    fnPrintChangesInSaccadeProbability([acSessionDataFilesJulien,acSessionDataFilesBert,acSessionDataFilesAnakinHSyn,acSessionDataFilesAnakinCamKII] ,false,'b');
    
    fnPrintChangesInSaccadeProbability([acSessionDataFilesJulien,acSessionDataFilesBert,acSessionDataFilesAnakinHSyn] ,false,'b');
    fnPrintChangesInSaccadeProbability(acSessionDataFilesAnakinCamKII,false,'b');
    
end




function acAngularStat=fnPrintChangesInSaccadeProbability(acSessionDataFiles,bPrintExampleSession,strColor)
global g_strRootDrive
iNumSessions = length(acSessionDataFiles);

if bPrintExampleSession
    if strColor == 'b'
        iExampleSession = 1;
        fAmplitudeSelected = 25;
        fRangeView = 20;
        fRangeView2= 400;
    else
        iExampleSession =2;  %D:\Data\Doris\Electrophys\Julien\Optogenetics\120510\RAW\..\Processed\ElectricalMicrostim\Julien-10-May-2012_14-40-59_Microstim_Channel_1_Depth_30-10_Trig_Grass1.mat
        fAmplitudeSelected = 35;
        fRangeView = 40;
        fRangeView2 = 800;
    end
    
    % First, plot an example session
    strctGrass1 = load(acSessionDataFiles{iExampleSession}{1});
    strctGrass1and2 = load(acSessionDataFiles{iExampleSession}{2});
    strctGrass2 = load(acSessionDataFiles{iExampleSession}{3});
    
    afAmplitude1 = cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_fAmplitude);
    afAmplitude1and2 = cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation.m_fAmplitude);
    afAmplitude2 = cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_fAmplitude);
    
    % Pick the maximal amplitude...
    iAmplitude = find(afAmplitude1 == fAmplitudeSelected);
    % first, find the typical saccade direction...
    X=cat(1,strctGrass1.strctStimStat.m_astrctStimulation(iAmplitude).m_a2fXpix);
    Y=cat(1,strctGrass1.strctStimStat.m_astrctStimulation(iAmplitude).m_a2fYpix);
    
    fnPrintSaccadeAux(X,Y,10,0,fRangeView,16, fRangeView2);
    figure(13);set(gca,'xticklabel',[]);
    figure(11);set(gca,'xticklabel',[]);
    

    %% Now, plot the same thing for combined optical and electrical
    iAmplitudeIndex12 = find(afAmplitude1and2 == fAmplitudeSelected);
    % first, find the typical saccade direction...
    X=cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation(iAmplitudeIndex12).m_a2fXpix);
    Y=cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation(iAmplitudeIndex12).m_a2fYpix);
    fnPrintSaccadeAux(X,Y,20,400,fRangeView,16,fRangeView2);
    figure(23);set(gca,'xticklabel',[]);
    figure(21);set(gca,'xticklabel',[]);
    
    X=cat(1,strctGrass2.strctStimStat.m_astrctStimulation(1).m_a2fXpix);
    Y=cat(1,strctGrass2.strctStimStat.m_astrctStimulation(1).m_a2fYpix);
    
    fnPrintSaccadeAux(X,Y,30,800,fRangeView,16,fRangeView2);
       figure(33);set(gca,'xticklabel',[]);
 
end
% Now, plot population statistics.....
fAngleThresholdDeg=40;
fPIX_TO_VISUAL_ANGLE_OldRig = 28.8/800;
fPIX_TO_VISUAL_ANGLE_NewRig = 28.8/1920;
fAmplitudeThreshold_OldRig = 1.8;
fAmplitudeThreshold_NewRig = 0.7;



afAllLatencies1 = [];
afAllLatencies12 = [];

afAllAmplitudes1= [];
afAllAmplitudes12= [];

afAllDirections1 = [];
afAllDirections12 = [];

afAllGazeBaselineStd = [];
afAllGazeBaselineMean = [];

abAllFixation_Electrical = [];
abAllFixation_Both = [];
   
a2fSessionAmplitude = [];
acAngularStat = cell(0);
aiMonkey = zeros(1,iNumSessions);
aiMonkeySessions = [];
abCamKIISessions  = [];

afAllLatencyTTestResult = [];
afPercentSaccadesOnlyElectrical_FixON_All = [];
afPercentSaccadesElectricalandOptical_FixON_All = [];
afPercentSaccadesOnlyElectrical_FixOFF_All = [];
afPercentSaccadesElectricalandOptical_FixOFF_All = [];


abCamKII = zeros(1,iNumSessions)>0;
for iSessionIter=1:iNumSessions
    bMonkeyJ = ~isempty(strfind(lower(acSessionDataFiles{iSessionIter}{1}),'julien'));
    bMonkeyB = ~isempty(strfind(lower(acSessionDataFiles{iSessionIter}{1}),'bert'));
    bMonkeyA = ~isempty(strfind(lower(acSessionDataFiles{iSessionIter}{1}),'anakin'));
    if bMonkeyJ
        aiMonkey(iSessionIter) = 1;
    elseif bMonkeyB
        aiMonkey(iSessionIter) = 2;
    elseif bMonkeyA
        aiMonkey(iSessionIter) = 3;
    end
    abCamKII(iSessionIter) = iSessionIter >= iNumSessions-12;
    
    
    if bMonkeyA
        fPIX_TO_VISUAL_ANGLE = fPIX_TO_VISUAL_ANGLE_NewRig;
        fAmplitudeThreshold = fAmplitudeThreshold_NewRig ;
    else
         fPIX_TO_VISUAL_ANGLE = fPIX_TO_VISUAL_ANGLE_OldRig;
         fAmplitudeThreshold = fAmplitudeThreshold_OldRig;
    end
 
    
    
    strctGrass1 = load(acSessionDataFiles{iSessionIter}{1});
    strctGrass1and2 = load(acSessionDataFiles{iSessionIter}{2});
    strctGrass2 = load(acSessionDataFiles{iSessionIter}{3});
    
    afCurrentAmplitude1 = cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_fAmplitude);
    afCurrentAmplitude1and2 = cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation.m_fAmplitude);
    afOverlappingAmplitudes = intersect(afCurrentAmplitude1,afCurrentAmplitude1and2);
    if isempty(afOverlappingAmplitudes)
        afCurrentAmplitude1and2(end) = afCurrentAmplitude1(end);
    afOverlappingAmplitudes = intersect(afCurrentAmplitude1,afCurrentAmplitude1and2);
    end
    afPercentSaccadesOnlyElectrical = zeros(1, length(afOverlappingAmplitudes));
    afPercentSaccadesElectricalandOptical = zeros(1, length(afOverlappingAmplitudes));
    
    afPercentSaccadesOnlyElectrical_FixON = zeros(1, length(afOverlappingAmplitudes));
    afPercentSaccadesElectricalandOptical_FixON = zeros(1, length(afOverlappingAmplitudes));
    afPercentSaccadesOnlyElectrical_FixOFF = zeros(1, length(afOverlappingAmplitudes));
    afPercentSaccadesElectricalandOptical_FixOFF = zeros(1, length(afOverlappingAmplitudes));
    
    
    afMeanSaccadeAmplitudeElectrical = zeros(1,  length(afOverlappingAmplitudes));
    afMeanSaccadeAmplitudeOpticalAndElectrical = zeros(1,  length(afOverlappingAmplitudes));
    afSigAmplitudeDifference = zeros(1,  length(afOverlappingAmplitudes));
    afBinomialTestResult = zeros(1,  length(afOverlappingAmplitudes));
    aiNumElectricalTrials = zeros(1,  length(afOverlappingAmplitudes));
    aiNumBothTrials= zeros(1,  length(afOverlappingAmplitudes));
    
    afSigDirection = NaN*ones(1,  length(afOverlappingAmplitudes));
    afMedianDirection1 = NaN*ones(1,  length(afOverlappingAmplitudes));
    afMedianDirection1and2 = NaN*ones(1,  length(afOverlappingAmplitudes));
    
    afMeanSaccadeLatency1 = NaN*ones(1,  length(afOverlappingAmplitudes));
    afMeanSaccadeLatency1and2 = NaN*ones(1,  length(afOverlappingAmplitudes));
    afSigLatencyDiff = NaN*ones(1,  length(afOverlappingAmplitudes));
    
    
    % Use the two highest electrical current to estimate saccade direction.

    
    
    a2fX=cat(1,strctGrass1.strctStimStat.m_astrctStimulation(end-1:end).m_a2fXpix);
    a2fY=cat(1,strctGrass1.strctStimStat.m_astrctStimulation(end-1:end).m_a2fYpix);
    [fSaccadeDirection, afDistToSaccade,afAmplitude,abValid,afDirectionsAll,afSaccadeLatencyAllMS, fMeanBaselinePix,fStdBaselinePix] = fnGetSaccadeDirection(a2fX,a2fY,fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
  
    
      abSuccessfulSaccades = find(afAmplitude'>1.8 & abValid) ;
      [fMue, fKappa]=fnVonMisesFit(afDirectionsAll(abSuccessfulSaccades));
      if fKappa > 200
          dbg = 1;
      end;
      %fDirection = circ_mean(afDirections1(abSuccessfulSaccades));
      [S s] = circ_var(afDirectionsAll(abSuccessfulSaccades));
      % Fit a von-mises distribution to data....
        
      acAngularStat{end+1} = {fKappa, S, a2fX(abSuccessfulSaccades,:), a2fY(abSuccessfulSaccades,:)};
       
        
    
    
    
    for iAmplitudeIter=1:length(afOverlappingAmplitudes)
        
        fAmplitude = afOverlappingAmplitudes(iAmplitudeIter);
        iIndex1 = find(afCurrentAmplitude1 == fAmplitude );
        iIndex2 = find(afCurrentAmplitude1and2 == fAmplitude );
        
        N = size(strctGrass1.strctStimStat.m_astrctStimulation(iIndex1).m_a2fXpix,1);
        % Find number of induced saccades
        a2fX_All=[strctGrass1.strctStimStat.m_astrctStimulation(iIndex1).m_a2fXpix
            strctGrass1and2.strctStimStat.m_astrctStimulation(iIndex2).m_a2fXpix];
        a2fY_All=[strctGrass1.strctStimStat.m_astrctStimulation(iIndex1).m_a2fYpix
            strctGrass1and2.strctStimStat.m_astrctStimulation(iIndex2).m_a2fYpix];
        
        abFixate1 = strctGrass1.strctStimStat.m_astrctStimulation(iIndex1).m_abFixationSpotOnScreen;
        abFixate1and2 = strctGrass1and2.strctStimStat.m_astrctStimulation(iIndex2).m_abFixationSpotOnScreen;
        
         
        [fSaccadeDirection, afDistToSaccade,afAmplitude,abValid,afDirectionsAll,afSaccadeLatencyAllMS, fMeanBaselinePix,fStdBaselinePix] = fnGetSaccadeDirection(a2fX_All,a2fY_All,fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
        afAllGazeBaselineStd = [afAllGazeBaselineStd,fStdBaselinePix];
        afAllGazeBaselineMean = [afAllGazeBaselineMean,fMeanBaselinePix];
        afDist1 = afDistToSaccade(1:N);
        afDist1and2 = afDistToSaccade(N+1:end);
        abValid1 = abValid(1:N);
        afDirections1 = afDirectionsAll(1:N);
        afLatency1 =afSaccadeLatencyAllMS(1:N);
        
        abAllFixation_Electrical = [abAllFixation_Electrical,abFixate1];
        abAllFixation_Both = [abAllFixation_Both,abFixate1and2];
        
            
        afAmplitude1 = afAmplitude(1:N);
        afAmplitude1and2 = afAmplitude(N+1:end);
        abValid1and2 = abValid(N+1:end);
        afDirections1and2 = afDirectionsAll(N+1:end);
        afLatency1and2 =afSaccadeLatencyAllMS(N+1:end);
        
        afValidLatency1 = afLatency1(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold);
        afValidLatency1and2 = afLatency1and2(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold);
        
        [~,pValueLatency]=ttest2(afValidLatency1,afValidLatency1and2);

        
        afMeanSaccadeLatency1(iAmplitudeIter) = nanmean(afValidLatency1);
        afMeanSaccadeLatency1and2(iAmplitudeIter) = nanmean(afValidLatency1and2);
        if ~isempty(afValidLatency1) && ~isempty(afValidLatency1and2)
            afAllLatencyTTestResult = [afAllLatencyTTestResult,pValueLatency];
            afAllLatencies1 = [afAllLatencies1, afValidLatency1(:)'];
            afAllLatencies12 =[afAllLatencies12, afValidLatency1and2(:)'];
            aiMonkeySessions = [aiMonkeySessions, aiMonkey(iSessionIter) * ones(size(afValidLatency1(:)'))];
            abCamKIISessions = [abCamKIISessions, abCamKII(iSessionIter) * ones(size(afValidLatency1(:)'))];
        end
        
        
        afAmplitudeElectricalValid = afAmplitude1(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold);
        afAmplitudeBothValid = afAmplitude1and2(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold);
        
        
        afAllAmplitudes1= [afAllAmplitudes1, afAmplitudeElectricalValid(:)'];
        afAllAmplitudes12= [afAllAmplitudes12,afAmplitudeBothValid(:)'];
        
        
        afDirections1Valid = afDirections1(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold);
        afDirections1and2Valid = afDirections1and2(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold);
        
          
        if ~isempty(afDirections1Valid) && ~isempty(afDirections1and2Valid)
            afAllDirections1 = [afAllDirections1,afDirections1Valid'];
            afAllDirections12 = [afAllDirections12,afDirections1and2Valid'];
            
            afMedianDirection1(iAmplitudeIter) = circ_median(afDirections1Valid);
            afMedianDirection1and2(iAmplitudeIter) = circ_median(afDirections1and2Valid);
            afSigDirection(iAmplitudeIter) = circ_cmtest(afDirections1Valid,afDirections1and2Valid);
        end
        
        afMeanSaccadeAmplitudeElectrical(iAmplitudeIter) = mean(afAmplitudeElectricalValid);
        afMeanSaccadeAmplitudeOpticalAndElectrical(iAmplitudeIter) = mean(afAmplitudeBothValid);
        if isempty(afAmplitudeElectricalValid) || isempty(afAmplitudeBothValid)
            afSigAmplitudeDifference(iAmplitudeIter) = 1;
        else
            afSigAmplitudeDifference(iAmplitudeIter) = ranksum(afAmplitudeElectricalValid, afAmplitudeBothValid);
        end
        
        
        
        a2fSessionAmplitude = [a2fSessionAmplitude, [iSessionIter;iAmplitudeIter]];
        
        afPercentSaccadesOnlyElectrical(iAmplitudeIter) = sum(abValid1' &  afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold) / sum(abValid1' )*100;
        afPercentSaccadesElectricalandOptical(iAmplitudeIter) = sum(abValid1and2' &  afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold) / sum(abValid1and2' )*100;
        
        afPercentSaccadesOnlyElectrical_FixON(iAmplitudeIter) = sum(abFixate1' & abValid1' &  afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold) / sum(abFixate1' & abValid1' )*100;
        afPercentSaccadesElectricalandOptical_FixON(iAmplitudeIter) = sum(abFixate1and2' &  abValid1and2' &  afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold) / sum(abFixate1and2' & abValid1and2' )*100;
        afPercentSaccadesOnlyElectrical_FixOFF(iAmplitudeIter)= sum(~abFixate1' & abValid1' &  afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold) / sum(~abFixate1' & abValid1' )*100;
        afPercentSaccadesElectricalandOptical_FixOFF(iAmplitudeIter) = sum(~abFixate1and2' & abValid1and2' &  afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold) / sum(~abFixate1and2' & abValid1and2' )*100;
        
        afPercentSaccadesOnlyElectrical_FixON_All = [afPercentSaccadesOnlyElectrical_FixON_All,afPercentSaccadesOnlyElectrical_FixON];
        afPercentSaccadesElectricalandOptical_FixON_All = [afPercentSaccadesElectricalandOptical_FixON_All,afPercentSaccadesElectricalandOptical_FixON];
        afPercentSaccadesOnlyElectrical_FixOFF_All = [afPercentSaccadesOnlyElectrical_FixOFF_All ,afPercentSaccadesOnlyElectrical_FixOFF];
        afPercentSaccadesElectricalandOptical_FixOFF_All = [afPercentSaccadesElectricalandOptical_FixOFF_All,afPercentSaccadesElectricalandOptical_FixOFF];

        % Do a binomial test .
        % Assume probability of a saccade using electrical is known
        % ...and estimate the probability of seeing the number of
        % saccades in the joint case.
        iNumSaccadesBoth = sum( abValid1and2' & afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold);
        iNumTrials = sum(abValid1and2'  );
        fProbSaccade = afPercentSaccadesOnlyElectrical(iAmplitudeIter)/100;
        afBinomialTestResult(iAmplitudeIter)=fnMyBinomTest(iNumSaccadesBoth,iNumTrials,fProbSaccade,'Two') ;
        aiNumElectricalTrials(iAmplitudeIter) = sum(abValid1' );
        aiNumBothTrials(iAmplitudeIter) = sum(abValid1and2' );
        
        
    end
    
    
    % Now compute statistics for optical only...
    
    a2fX_All=[cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_a2fXpix)
        cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation.m_a2fXpix)];
    a2fY_All=[cat(1,strctGrass1.strctStimStat.m_astrctStimulation(:).m_a2fYpix)
        cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation(:).m_a2fYpix)];
    [fSaccadeDirection, afDistToSaccade,afAmplitude,abValid] = fnGetSaccadeDirection(a2fX_All,a2fY_All,fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
    
    
    [afDistanceToSaccadeAngleDeg, afAmplitudeOnly2,abValidOptical] = fnGetSaccadesInSpecificDirection(...
        cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fXpix),...
        cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fYpix), fSaccadeDirection, fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
    abFixate2 = cat(2,strctGrass2.strctStimStat.m_astrctStimulation.m_abFixationSpotOnScreen);
    
    astrctSessionStat(iSessionIter).m_afDepth = ones(1,length(aiNumElectricalTrials))*strctGrass2.strctStimStat.m_astrctStimulation(1).m_fDepth;
    
        astrctSessionStat(iSessionIter).m_aiNumTrainsElectrical = aiNumElectricalTrials;
    astrctSessionStat(iSessionIter).m_aiNumTrainBoth = aiNumBothTrials;
    astrctSessionStat(iSessionIter).m_aiNumTrainOptical = sum(abValidOptical);
    

    astrctSessionStat(iSessionIter).m_afMeanSaccadeLatency1 = afMeanSaccadeLatency1;
    astrctSessionStat(iSessionIter).m_afMeanSaccadeLatency1and2 = afMeanSaccadeLatency1and2;
    astrctSessionStat(iSessionIter).m_afSigLatencyDiff = afSigLatencyDiff;
      
        
    astrctSessionStat(iSessionIter).m_afBinomialTestResult=afBinomialTestResult;
    astrctSessionStat(iSessionIter).m_afCurrents = afOverlappingAmplitudes;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectrical = afPercentSaccadesOnlyElectrical;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOptical = afPercentSaccadesElectricalandOptical;
    astrctSessionStat(iSessionIter).m_aiMonkey = aiMonkey(iSessionIter)*ones(1,length(afOverlappingAmplitudes));
    astrctSessionStat(iSessionIter).m_abCamKII = abCamKII(iSessionIter)*ones(1,length(afOverlappingAmplitudes));
    
    
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectrical_FixON = afPercentSaccadesOnlyElectrical_FixON;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOptical_FixON = afPercentSaccadesElectricalandOptical_FixON;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectrical_FixOFF = afPercentSaccadesOnlyElectrical_FixOFF;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOptical_FixOFF = afPercentSaccadesElectricalandOptical_FixOFF;
    
    astrctSessionStat(iSessionIter).m_afSigAmplitudeDifference= afSigAmplitudeDifference;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOptical = sum(abValidOptical' & afDistanceToSaccadeAngleDeg < fAngleThresholdDeg & afAmplitudeOnly2 > fAmplitudeThreshold) / sum(abValidOptical' )*100;

    astrctSessionStat(iSessionIter).m_afPercentSaccadesOptical_FixateON = sum(abFixate2' &    abValidOptical' & afDistanceToSaccadeAngleDeg < fAngleThresholdDeg & afAmplitudeOnly2 > fAmplitudeThreshold) / sum(abFixate2' & abValidOptical' )*100;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOptical_FixateOFF = sum(~abFixate2' &abValidOptical' & afDistanceToSaccadeAngleDeg < fAngleThresholdDeg & afAmplitudeOnly2 > fAmplitudeThreshold) / sum(~abFixate2' & abValidOptical' )*100;
    

    astrctSessionStat(iSessionIter).m_afMeanSaccadeAmplitudeElectrical = afMeanSaccadeAmplitudeElectrical;
    astrctSessionStat(iSessionIter).m_afMeanSaccadeAmplitudeOpticalAndElectrical = afMeanSaccadeAmplitudeOpticalAndElectrical;
    
    
    
    astrctSessionStat(iSessionIter).m_afSigDirection = afSigDirection;
    astrctSessionStat(iSessionIter).m_afMedianDirection1 = afMedianDirection1;
    astrctSessionStat(iSessionIter).m_afMedianDirection1and2 = afMedianDirection1and2;
    
    %     astrctSessionStat(iSessionIter).m_afSEMSaccadeAmplitudeElectrical = afStdSaccadeAmplitudeElectrical;
    %     astrctSessionStat(iSessionIter).m_afSEMSaccadeAmplitudeOpticalAndElectrical = afStdSaccadeAmplitudeOpticalAndElectrical;
    
    astrctSessionStat(iSessionIter).m_abMonkeyJ = bMonkeyJ * ones(1,length(afOverlappingAmplitudes))>0;
    
%     figure(100+iSessionIter);
%     plot(afOverlappingAmplitudes,afPercentSaccadesOnlyElectrical,'k');
%     hold on;
%     plot(afOverlappingAmplitudes,afPercentSaccadesElectricalandOptical,'b');
%     
    
    astrctSessionStat(iSessionIter).m_afCurrents = afOverlappingAmplitudes;
    astrctSessionStat(iSessionIter).m_afCurrentsNormalized = linspace(0, 1,length(afOverlappingAmplitudes));
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectrical = afPercentSaccadesOnlyElectrical;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOptical = afPercentSaccadesElectricalandOptical;
    
    
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectricalInterp = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesOnlyElectrical, 0:0.1:1);
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOpticalInterp = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesElectricalandOptical,0:0.1:1);

    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectricalInterpFIX_ON = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesOnlyElectrical_FixON, 0:0.1:1);
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectricalInterpFIX_OFF = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesOnlyElectrical_FixOFF, 0:0.1:1);
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOpticalInterpFIX_ON = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesElectricalandOptical_FixON,0:0.1:1);
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOpticalInterpFIX_OFF = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesElectricalandOptical_FixOFF,0:0.1:1);
    
end
 astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterp

[afHist1, afCent]=hist(afAllLatencies1, 50:200);
[afHist2, afCent]=hist(afAllLatencies12, 50:200);
afHist1 = afHist1 / sum(afHist1);
afHist2 = afHist2 / sum(afHist2);
figure(4000);
clf;hold on;
plot(afCent, cumsum(afHist1),'k','linewidth',2);
plot(afCent, cumsum(afHist2),strColor,'linewidth',2);
set(gca,'xlim',[50 200]);
set(gca,'ylim',[0 1]);
set(gca,'fontsize',7);
set(gcf,'position',[ 1296        1000         147          98]);
[a,pValueLatency]=kstest2(afAllLatencies12(:), afAllLatencies1(:),0.05,'larger')

fprintf('Mean Latency electrical: %.2f ± %.2f \n',nanmean(afAllLatencies1), nanstd(afAllLatencies1));
fprintf('Mean Latency electrical+optical: %.2f ± %.2f \n',nanmean(afAllLatencies12), nanstd(afAllLatencies12));
fprintf('KS -test2 : %.5f\n',pValueLatency);

aiEle = cat(2,astrctSessionStat.m_aiNumTrainsElectrical) 
aiBoth = cat(2,astrctSessionStat.m_aiNumTrainBoth)
[h,p]=ttest(aiEle,aiBoth,0.05,'right')
aiOpt = cat(2,astrctSessionStat.m_aiNumTrainOptical)
mean(aiEle), std(aiEle)
mean(aiBoth), std(aiBoth)
mean(aiOpt ), std(aiOpt )
%%
abMonkeyJ = cat(2,astrctSessionStat.m_abMonkeyJ);

% abCamKII = zeros(size(afAllLatencies1))>0;
% abCamKII(end-12:end) = true;

[afHistLat1, afCent]= hist(afAllLatencies1(aiMonkeySessions == 3), 0:5:300);
[afHistLat2, afCent]= hist(afAllLatencies12(aiMonkeySessions == 3), 0:5:300);

figure(224);
clf;hold on;
plot(afCent,cumsum(afHistLat1)/sum(afHistLat1),'k','Linewidth',2);
plot(afCent,cumsum(afHistLat2)/sum(afHistLat2),strColor,'Linewidth',2);
[h,p]=kstest2(afAllLatencies1,afAllLatencies12)
axis([0  200 0 1])
set(gca,'ytick',0:0.2:1)
set(gcf,'position',[921   941   319   157]);

set(gca,'ytick',[]);
axis([50  150 0 1])
set(gcf,'position',[921   941   75 75]);
% 
% afLatency1=     cat(2,astrctSessionStat.m_afMeanSaccadeLatency1);
% afLatency12=     cat(2,astrctSessionStat.m_afMeanSaccadeLatency1and2);
% abValidLatency = ~isnan(afLatency1) & ~isnan(afLatency12)
% ranksum(afLatency1(abValidLatency),afLatency12(abValidLatency))

fThresP=0.01;

abSigDir = ~isnan(cat(2,astrctSessionStat.m_afSigDirection) ) &  cat(2,astrctSessionStat.m_afSigDirection) <  fThresP;
% plot difference in directions?
afDirectionElec =     cat(2,astrctSessionStat.m_afMedianDirection1)/pi*180;
afDirectionBoth =     cat(2,astrctSessionStat.m_afMedianDirection1and2 )/pi*180;
figure(500);
clf;hold on;
plot([-180 180],[-180 180],'k--');
plot(afDirectionElec(~abSigDir),afDirectionBoth(~abSigDir),'.','color',[0.5 0.5 0.5]);
plot(afDirectionElec(abSigDir),afDirectionBoth(abSigDir),'k.');
set(gca,'xtick',-180:60:180,'ytick',-180:60:180);
axis([-180 180 -180 180]);
set(gcf,'position',[1033 925 155         127])
set(gca,'fontsize',7);

fprintf('Average angular deviation: %.2f +- %.2f\n',nanmean(abs(afDirectionBoth-afDirectionElec)), nanstd(abs(afDirectionBoth-afDirectionElec)));
fprintf('Average angular deviation: %.2f +- %.2f\n',nanmean(abs(afDirectionBoth(abSigDir)-afDirectionElec(abSigDir))), nanstd(abs(afDirectionBoth(abSigDir)-afDirectionElec(abSigDir))));

figure(501);clf;
[afHist,afCent]=hist(afDirectionElec-afDirectionBoth);
bar(afCent,afHist,'facecolor',[0.5 0.5 0.5]);
set(gca,'xlim',[-60 60]);
box off
set(gca,'fontsize',7);

[a,g]=ttest(afDirectionBoth,afDirectionElec)

set(gca,'fontsize',7);
nanmean(abs(afDirectionBoth-afDirectionElec))
nanstd(abs(afDirectionBoth-afDirectionElec))

    
fThresP=0.01;
% Plot population ?
afAmp1 = cat(2,astrctSessionStat.m_afMeanSaccadeAmplitudeElectrical);
afAmp12 = cat(2,astrctSessionStat.m_afMeanSaccadeAmplitudeOpticalAndElectrical);
abAmpNotNan = ~isnan(afAmp1) & ~isnan(afAmp12)
[h,p]=ttest(afAmp1(abAmpNotNan), afAmp12(abAmpNotNan))

afSigAmplitude = cat(2,astrctSessionStat.m_afSigAmplitudeDifference )
figure(5);
clf;hold on;


plot(afAmp1(afSigAmplitude>fThresP),afAmp12(afSigAmplitude>fThresP),'.','color',[0.5 0.5 0.5]);
plot(afAmp1(afSigAmplitude<fThresP),afAmp12(afSigAmplitude<fThresP),'k.');

plot([0 25],[0 25],'k--');
axis([0 25 0 25]);
set(gca,'xtick',0:5:25,'ytick',0:5:25)
set(gcf,'position',[1033 925 207 173])
set(gca,'fontsize',7);

figure(502);clf;
[afHist,afCent]=hist(afAmp1-afAmp12);
bar(afCent,afHist,'facecolor',[0.5 0.5 0.5]);
set(gca,'xlim',[-10 10]);
box off
set(gca,'fontsize',7);
mean(afAmp12(afSigAmplitude<fThresP)-afAmp1(afSigAmplitude<fThresP))
std(afAmp12(afSigAmplitude<fThresP)-afAmp1(afSigAmplitude<fThresP))


% Pool across all currents and use a sign test
aiMonkeyForFigure = cat(2,astrctSessionStat.m_aiMonkey);
abCamKIIForFigure = cat(2,astrctSessionStat.m_abCamKII);

afPercElectrical = cat(2, astrctSessionStat.m_afPercentSaccadesOnlyElectrical);
afPercBoth= cat(2,astrctSessionStat.m_afPercentSaccadesElectricalandOptical );
[p,h,stat]= ttest(afPercBoth,afPercElectrical,0.05,'right');
fprintf('Pooling across all currents, sign test shows significance of %.10f\n',p);

afPValue = cat(2,astrctSessionStat.m_afBinomialTestResult);

figure(300);clf;hold on;
fThresP=0.01;
% plot(afPercElectrical(abMonkeyJ),afPercBoth(abMonkeyJ),'.');
% plot(afPercElectrical(~abMonkeyJ),afPercBoth(~abMonkeyJ),'k.');
fprintf('Optical evoked saccades: %.2f +- %.2f\n',mean(cat(1,astrctSessionStat.m_afPercentSaccadesOptical)),std(cat(1,astrctSessionStat.m_afPercentSaccadesOptical)))


plot(afPercElectrical(afPValue>fThresP),afPercBoth(afPValue>fThresP),'.','color',[0.5 0.5 0.5]);
% 
% plot(afPercElectrical(afPValue<fThresP & aiMonkeyForFigure == 1),afPercBoth(afPValue<fThresP & aiMonkeyForFigure == 1),'rx');
% plot(afPercElectrical(afPValue<fThresP & aiMonkeyForFigure == 2),afPercBoth(afPValue<fThresP & aiMonkeyForFigure == 2),'gd');
% plot(afPercElectrical(afPValue<fThresP & aiMonkeyForFigure == 3),afPercBoth(afPValue<fThresP & aiMonkeyForFigure == 3),'bo');
% 
plot(afPercElectrical(afPValue<fThresP),afPercBoth(afPValue<fThresP),'k.');
% plot(afPercElectrical(afPValue<fThresP),afPercBoth(afPValue<fThresP),'ko');

plot([0 100],[0 100],'k--');
set(gca,'xtick',[0:25:100],'ytick',0:25:100);
set(gcf,'position',[1033 925 207 173])

%%

% afDepths = cat(2,astrctSessionStat.m_afDepth );
% afDepths(abMonkeyJ & afPValue<fThresP)
% afDepths(abMonkeyJ & afPValue>fThresP)
% 
% afDepths(~abMonkeyJ & afPValue<fThresP)
% afDepths(~abMonkeyJ & afPValue>fThresP)

fprintf('%d out of %d sessions were significant \n',  sum(afPValue<fThresP), length(aiMonkeyForFigure))

fprintf('%d out of %d sessions were significant in Julien\n',  sum(aiMonkeyForFigure == 1 & afPValue<fThresP), sum(aiMonkeyForFigure == 1));
fprintf('%d out of %d sessions were significant in Bert\n',  sum(aiMonkeyForFigure == 2 & afPValue<fThresP), sum(aiMonkeyForFigure == 2));
fprintf('%d out of %d sessions were significant in Anakin\n',  sum(aiMonkeyForFigure == 3 & afPValue<fThresP), sum(aiMonkeyForFigure == 3));

fprintf('%d out of %d sessions were significant in Anakin CamKII\n',  sum(aiMonkeyForFigure == 3 & afPValue<fThresP & abCamKIIForFigure), sum(aiMonkeyForFigure == 3 & abCamKIIForFigure));

fprintf('%d out of %d sessions were significant in Anakin hSyn\n',  sum(aiMonkeyForFigure == 3 & afPValue<fThresP & ~abCamKIIForFigure), sum(aiMonkeyForFigure == 3 & ~abCamKIIForFigure));



fprintf('%d out of %d sessions were significant in Julien\n',  sum(aiMonkeyForFigure == 3 & afPValue<fThresP), sum(aiMonkeyForFigure == 3));

fprintf('%d out of %d sessions were significant in B\n',  sum(~abMonkeyJ(afPValue<fThresP)), sum(~abMonkeyJ));
set(gca,'fontsize',7)

afMeanElectrical_FIX_ON = nanmean(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterpFIX_ON),1);
afMeanBoth_FIX_ON = nanmean(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterpFIX_ON),1);
afMeanElectrical_FIX_OFF = nanmean(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterpFIX_OFF),1);
afMeanBoth_FIX_OFF = nanmean(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterpFIX_OFF),1);

afSEMElectrical_FIX_ON = nanstd(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterpFIX_ON),1)/sqrt(iNumSessions);
afSEMBoth_FIX_ON=  nanstd(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterpFIX_ON),1)/sqrt(iNumSessions);
afSEMElectrical_FIX_OFF = nanstd(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterpFIX_OFF),1)/sqrt(iNumSessions);
afSEMBoth_FIX_OFF=  nanstd(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterpFIX_OFF),1)/sqrt(iNumSessions);


%%
afNormalizedCurrent = 0:0.1:1;

afMeanElectrical = nanmean(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterp),1);
afSEMElectrical = nanstd(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterp),1)/sqrt(iNumSessions);
afMeanBoth =  nanmean(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterp),1);
afSEMBoth=  nanstd(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterp),1)/sqrt(iNumSessions);

a2fElectricalInterpolated = cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterp);
a2fBothInterpolated = cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterp);
for k=1:length(afNormalizedCurrent)
    [a,b,ci]=ttest(a2fElectricalInterpolated(:,k));
    a2fConfidenceElectrical(:,k) = ci;
    [a,b,ci]=ttest(a2fBothInterpolated(:,k));
    a2fConfidenceBoth(:,k) = ci;
end

figure(1125);
clf;hold on;
W=0.01;
plot(afNormalizedCurrent,afMeanElectrical,'k');
plot(afNormalizedCurrent,afMeanBoth, strColor);
for k=1:length(afNormalizedCurrent)
    plot(afNormalizedCurrent(k),afMeanBoth(k),[strColor,'S']);
    plot(afNormalizedCurrent(k),afMeanElectrical(k),'kS');
    
    plot(afNormalizedCurrent(k)+[-W W],ones(1,2)*a2fConfidenceBoth(1,k),strColor);
    plot(afNormalizedCurrent(k)+[-W W],ones(1,2)*a2fConfidenceBoth(2,k),strColor);
    
    plot(afNormalizedCurrent(k)+[-W W],ones(1,2)*a2fConfidenceElectrical(1,k),'k');
    plot(afNormalizedCurrent(k)+[-W W],ones(1,2)*a2fConfidenceElectrical(2,k),'k');
    
    plot(afNormalizedCurrent(k)*ones(1,2), a2fConfidenceBoth(:,k),strColor);
    plot(afNormalizedCurrent(k)*ones(1,2),a2fConfidenceElectrical(:,k),'k');
end

figure(125);
clf;hold on;
W=0.01;
plot(afNormalizedCurrent,afMeanElectrical,'k');
plot(afNormalizedCurrent,afMeanBoth, strColor);
for k=1:length(afNormalizedCurrent)
    plot(afNormalizedCurrent(k),afMeanBoth(k),[strColor,'S'],'markersize',5);
    plot(afNormalizedCurrent(k),afMeanElectrical(k),'kS','markersize',5);
    
    plot(afNormalizedCurrent(k)+[-W W],[afMeanBoth(k)-afSEMBoth(k)]*ones(1,2),strColor);
    plot(afNormalizedCurrent(k)+[-W W],[afMeanElectrical(k)-afSEMElectrical(k)]*ones(1,2),'k');
    
    plot(afNormalizedCurrent(k)+[-W W],[afMeanBoth(k)+afSEMBoth(k)]*ones(1,2),strColor);
    plot(afNormalizedCurrent(k)+[-W W],[afMeanElectrical(k)+afSEMElectrical(k)]*ones(1,2),'k');
    
    plot(afNormalizedCurrent(k)*ones(1,2),[afMeanBoth(k)-afSEMBoth(k),afMeanBoth(k)+afSEMBoth(k)],strColor);
    plot(afNormalizedCurrent(k)*ones(1,2),[afMeanElectrical(k)-afSEMElectrical(k),afMeanElectrical(k)+afSEMElectrical(k)],'k');
end
axis([0 1 0 100]);

% plot([0 1],ones(1,2)*mean(cat(1,astrctSessionStat.m_afPercentSaccadesOptical)),'r');
plot([0 1],ones(1,2)*mean(cat(1,astrctSessionStat.m_afPercentSaccadesOptical)),'r');
std(cat(1,astrctSessionStat.m_afPercentSaccadesOptical))
mean(cat(1,astrctSessionStat.m_afPercentSaccadesOptical))

p=get(gcf,'position')
p(3) =  174    ;p(4) = 84;
set(gcf,'position',p);
set(gca,'fontsize',7);
set(gca,'xtick',[0 0.5 1]);

figure(122);clf;hold on;
afNormalizedCurrent = 0:0.1:1;
W=0.01;
plot(afNormalizedCurrent,afMeanElectrical_FIX_ON,'k','LineWidth',2);
plot(afNormalizedCurrent,afMeanElectrical_FIX_OFF,'k--','LineWidth',2);
plot(afNormalizedCurrent,afMeanBoth_FIX_ON, strColor,'LineWidth',2);
plot(afNormalizedCurrent,afMeanBoth_FIX_OFF, strColor,'LineStyle','--','LineWidth',2);

set(gcf,'position',[   680   979    154          98]);
% Plot latency...
set(gca,'fontsize',7);
set(gca,'xtick',[0 0.5 1]);


%

[a,b]=kstest2(afPercentSaccadesOnlyElectrical_FixON_All  ,   afPercentSaccadesOnlyElectrical_FixOFF_All )
[a,b]=kstest2(afPercentSaccadesElectricalandOptical_FixON_All  ,   afPercentSaccadesElectricalandOptical_FixOFF_All )
   
     
return

function [fDirection, afDistanceToSaccadeAngleDeg, afAmplitude,abValid,afDirections, aiSaccadeOnsetMS, fMeanGazePix, fStdGazeBaseline] = fnGetSaccadeDirection(X,Y, fAmplitude,fPIX_TO_VISUAL_ANGLE)
% Sample at 100 ms post stimulation (typically, a good place...)
a2fGaze = sqrt(X.^2+Y.^2);
afBaselineDist = max(a2fGaze(:,150:250)',[],1);
%afAmplitude = max(a2fGaze(:,300:450),[],2)';
aiAmplitudeInterval = 360:410; % 160-210
afAmplitude = nanmean(a2fGaze(:,aiAmplitudeInterval),2)*fPIX_TO_VISUAL_ANGLE;
abNoBlink= max(a2fGaze,[],2)' < 800;  %1000
abStableBaseline = afBaselineDist<60;
abValid = abStableBaseline & abNoBlink ;
abLargeAmplitude = afAmplitude > fAmplitude;
aiSamplingInterval = 200+[150:200];%380:400;% 200+[120:160]
% 
% figure(11);
% clf;hold on;
% plot(a2fGaze','color',[0.5 0.5 0.5]);
% plot(a2fGaze(abValid'&abLargeAmplitude,:)','color','k');
% set(gca,'ylim',[-100 700]);
% plot([-100 700],fAmplitude/fPIX_TO_VISUAL_ANGLE*ones(1,2),'g');

a2fGazeBaseline = a2fGaze(abValid,150:180);
fStdGazeBaseline = std(a2fGazeBaseline(:));
fMeanGazePix = nanmean(a2fGazeBaseline(:));
aiBaselineInterval = 200 + [20:60];
afThreshold = nanmean(a2fGaze(:, aiBaselineInterval),2) + 5*std(a2fGaze(:, aiBaselineInterval),[],2);
aiSaccadeOnsetMS = NaN*ones(1,size(X,1));
for k=1:size(X,1)
    astrctIntervals = fnGetIntervals( a2fGaze(k,200:end) > afThreshold(k));
    iEntry = NaN;
    if ~isempty(astrctIntervals)
        afLengthsMS = cat(1,astrctIntervals.m_iLength) ;
        iSelectedInterval = find(afLengthsMS > 10,1,'first');
        if ~isempty(iSelectedInterval)
            iEntry = astrctIntervals(iSelectedInterval).m_iStart;
            %iEntry = find(a2fGaze(k,200:end) > afThreshold(k),1,'first');
            if ~isempty(iEntry)
                aiSaccadeOnsetMS(k) = iEntry;
            end
        end
    end
%     if ~isnan(iEntry) && abValid(k) && abLargeAmplitude(k)
%     figure(10);
%     clf;
%     plot(a2fGaze(k,200:end));
%     hold on;
%     plot(iEntry,a2fGaze(k,200+iEntry),'r*');
%     title(num2str(k));
%     axis([0 400 0 400]);
%     pause
%     end
end

a2fDirections = atan2(Y(abValid' & abLargeAmplitude,aiSamplingInterval),X(abValid' & abLargeAmplitude,aiSamplingInterval));
if isempty(a2fDirections)
    fDirection = NaN;
    afDistanceToSaccadeAngleDeg = ones(size(X,1),1)*NaN;
    afDirections= ones(size(X,1),1)*NaN;
    return;
end
fDirection = circ_median(a2fDirections(:));
a2fDirectionsAll = atan2(Y(:,aiSamplingInterval),X(:,aiSamplingInterval));
afDirections = circ_median(a2fDirectionsAll');
afDistanceToSaccadeAngleDeg = acos([cos(afDirections)*cos(fDirection)+sin(afDirections)*sin(fDirection)] )/pi*180;

% figure(13);clf;
% plot(afDirections(abLargeAmplitude & abValid'));
% hold on;
% plot([0 sum(abLargeAmplitude & abValid')],ones(1,2)*fDirection,'r');
% aiRelevant = find(abLargeAmplitude & abValid');
% 
% 
% figure(12);
% clf;hold on;
% plot(X(abLargeAmplitude & abValid',250:450)',Y(abLargeAmplitude & abValid',250:450)','color',[0.5 0.5 0.5]);
% plot(mean(X(abLargeAmplitude & abValid',250:450)),mean(Y(abLargeAmplitude & abValid',250:450)),'k','LineWidth',2);
% axis([-300 300 -300 300]);
% plot(0,0,'r+');
% plot([0 cos(fDirection)]*200,[0 sin(fDirection)]*200,'g','LineWidth',2);
% plot(X(aiRelevant(23), 250:350),Y(aiRelevant(23), 250:350),'m');
return




function [afDistanceToSaccadeAngleDeg, afAmplitude,abValidOptical] = fnGetSaccadesInSpecificDirection(X,Y, fSaccadeDirection, fAmplitude,fPIX_TO_VISUAL_ANGLE)
% Sample at 100 ms post stimulation (typically, a good place...)
a2fGaze = sqrt(X.^2+Y.^2);
afBaselineDist = max(a2fGaze(:,150:250)',[],1);
%    afAmplitude = max(a2fGaze(:,300:450),[],2)';
aiAmplitudeInterval = 360:410;
afAmplitude = mean(a2fGaze(:,aiAmplitudeInterval),2)*fPIX_TO_VISUAL_ANGLE;

abNoBlink= max(a2fGaze,[],2)' < 400;
abStableBaseline = afBaselineDist<60;
abValidOptical = abStableBaseline & abNoBlink ;

aiSamplingInterval = 200+[150:200];%380:400;% 200+[120:160]

a2fDirections = atan2(Y(:,aiSamplingInterval),X(:,aiSamplingInterval));
afDirections = circ_median(a2fDirections');
afDistanceToSaccadeAngleDeg = acos([cos(afDirections)*cos(fSaccadeDirection)+sin(afDirections)*sin(fSaccadeDirection)] )/pi*180;

%     afAmplitude = afAmplitude(abValid);
return


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


abNoBlink= max(a2fGaze,[],2)' < 1000;
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
figure(iBaseFigure);clf;
h=fnMyPolar(tout,rout,'k');
set(h,'linewidth',2);
set(gcf,'position',[ 1070-XOffset         978         170         120]);
% Screen is 21.6 3 28.8 visual degrees, which correspond to 800x600
% resolution!
%600->21.6
% 1->21.6/600
% ot
% 1->28.8/800
fPIX_TO_VISUAL_ANGLE = 28.8/800;

[afHist,afCent]=hist(afAmplitude(abValid),[0:2:fMaxAmplitude]/fPIX_TO_VISUAL_ANGLE);
figure(iBaseFigure+1);
clf;
hBar=bar(afCent*fPIX_TO_VISUAL_ANGLE,afHist);
set(hBar,'facecolor',[0.5 0.5 0.5]);
set(gcf,'position',[ 1069-XOffset         789        147          66]);
set(gca,'xlim',[-1.5 fMaxAmplitude+1],'ylim',[0 20]);
set(gca,'fontsize',7);
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
if 0
    rectangle('position',[-fRange2+50 fRange2-80 5/fPIX_TO_VISUAL_ANGLE 20],'facecolor','k');
end
figure(iBaseFigure+3);
clf;
iMaxTime = size(a2fGaze,2)-200-1;
plot(-200:iMaxTime,fPIX_TO_VISUAL_ANGLE* a2fGaze(abValid,:)','color',[0.5 0.5 0.5]);
axis([-100 400 0 MaxVisualAngle]);
hold on;
plot(-200:iMaxTime,fPIX_TO_VISUAL_ANGLE* median(a2fGaze,1),'k','LineWidth',2);
set(gcf,'position',[1068-XOffset            605         181          65]);
set(gca,'fontsize',7);
% set(gca,'xticklabel',[])

return;





function fnPrintSaccadeAux4(X,Y,iBaseFigure,XOffset,MaxVisualAngle,fMaxAmplitude,fRange2)
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


abNoBlink= max(a2fGaze,[],2)' < 1000;
abStableBaseline = afBaselineDist<60;
abValid = abStableBaseline & abNoBlink ;


abLargeAmplitude = afAmplitude > 50;

aiSamplingInterval = 200+[150:200];%380:400;% 200+[120:160]
afAvgX = mean(X(abValid' & abLargeAmplitude,aiSamplingInterval),2);
afAvgY = mean(Y(abValid' & abLargeAmplitude,aiSamplingInterval),2);
% Average angle ?
afAvgAngle = atan2(afAvgY,afAvgX);


[tout,rout]=rose(afAvgAngle,20);
rout=rout/sum(rout);
% Screen is 21.6 3 28.8 visual degrees, which correspond to 800x600
% resolution!
%600->21.6
% 1->21.6/600
% ot
% 1->28.8/800
fPIX_TO_VISUAL_ANGLE = 28.8/800;

[afHist,afCent]=hist(afAmplitude(abValid),[0:2:fMaxAmplitude]/fPIX_TO_VISUAL_ANGLE);
%

figure(iBaseFigure+3);
clf;
iMaxTime = size(a2fGaze,2)-200-1;
plot(-200:iMaxTime,fPIX_TO_VISUAL_ANGLE* a2fGaze(abValid,:)','color',[0 0 0]);
axis([-100 400 0 MaxVisualAngle]);
hold on;
set(gcf,'position',[1068-XOffset            605         254          84]);


return;



function fnPrintExampleOpticalStimulationCell(strFile, iTrainIter,aiRestrictedRange, fFig, afColor, fRangeX)

strctTmp = load(strFile);
strctData = strctTmp.strctUnitInterval;
if isempty(aiRestrictedRange)
    aiRestrictedRange = 1:size(strctData.m_astrctTrain(iTrainIter).m_a2fSmoothRaster,1);
else
    aiRestrictedRange = intersect( 1:size(strctData.m_astrctTrain(iTrainIter).m_a2fSmoothRaster,1),aiRestrictedRange);
end;
%%
figure(fFig);
clf;
fTimeScaleFactor = 1e3;
afX = strctData.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS/fTimeScaleFactor;
afFiringRateSmooth = mean(strctData.m_astrctTrain(iTrainIter).m_a2fSmoothRaster(aiRestrictedRange,:),1)*1e3;


plot(afX,afFiringRateSmooth,'k');

fTrainHeight = 0.1*max(ceil(afFiringRateSmooth));
fSpikesOffset = 1.2*max(ceil(afFiringRateSmooth));

aiInd=find(strctData.m_astrctTrain(iTrainIter).m_a2bRaster(aiRestrictedRange,:));
[aiTrial,aiSpike]=ind2sub(size(strctData.m_astrctTrain(iTrainIter).m_a2bRaster(aiRestrictedRange,:)), aiInd);
% raster will occupy same space as the the average...
iNumTrials = size(strctData.m_astrctTrain(iTrainIter).m_a2bRaster(aiRestrictedRange,:),1);
hold on;
iRasterLine = 1/iNumTrials*max(ceil(afFiringRateSmooth));
for iSpikeIter=1:length(aiSpike)
    rectangle('Position',[afX(aiSpike(iSpikeIter)) fSpikesOffset+aiTrial(iSpikeIter)*iRasterLine 1/fTimeScaleFactor iRasterLine ],'facecolor','k');
end

if ~exist('fRangeX','var')
    if abs(ceil(afX(end))-afX(end)) < 0.1
        fRangeX=ceil(afX(end));
    else
        fRangeX=ceil(afX(end))-0.5;
    end
end

set(gca,'xlim', [afX(1), fRangeX]);
set(gca,'ylim',[0 fSpikesOffset+iRasterLine*iNumTrials]);
set(gca,'xtick',-1:3)
if fSpikesOffset > 200
set(gca,'ytick',0:60:fSpikesOffset)
elseif fSpikesOffset > 99
    set(gca,'ytick',0:30:fSpikesOffset)
else
    set(gca,'ytick',0:10:fSpikesOffset)
end

%set(gca,'xtick',[-0.5 0 0.5 1],'xlim',[-0.5 1])
set(gca,'xtick',[-1 0 1 2 3],'xlim',[-1 3])

set(gcf,'position',[680   927   116    99]);%[680 813 319 285]);
set(gca,'fontsize',7)
figure(fFig+1);
set(fFig+1,'Color',[ 1 1  1] );
clf;hold on;
fnFancyPlot2(1:40, strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormBefore, strctData.m_astrctTrain(iTrainIter).m_afStdWaveFormBefore,[0.5 0.5 0.5],[0 0 0]);
axis([0 40 -1500 1500]);
axis off
set(fFig+1,'Position',[ 680   972   116   126]);
figure(fFig+2);clf;hold on;
set(fFig+2,'Color',[ 1 1  1] );
fnFancyPlot2(1:40, strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormDuring, strctData.m_astrctTrain(iTrainIter).m_afStdWaveFormDuring,afColor*0.5,afColor);
axis([0 40 -1500 1500]);
axis off
set(fFig+2,'Position',[ 680   972   116   126]);

%%
%
%     % Significance
%     tightsubplot(3,2,2,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
%     hold on;
%     bar(1:3,[    mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore),    mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring),    mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)],'facecolor',[74,126,187]/255)
%     fMax = max( [mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore)+std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore),...
%                            mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring)+std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring),...
%                            mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)+std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)]);
%
%     plot([1 1],mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore)+[-1 1]*std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore),'k','linewidth',2)
%     plot([2 2],mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring)+[-1 1]*std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring),'k','linewidth',2)
%     plot([3 3],mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)+[-1 1]*std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter),'k','linewidth',2)
%     set(gca,'xtick',1:3,'xticklabel',{'Before','During','After'});
%     set(gca,'ylim',[0 1.2*fMax]);
%     if log10(strctData.m_astrctTrain(iTrainIter).m_afStatisticalTests(1)) < -4
%         text(2,1.1*fMax,'***','color','r','horizontalalignment','center');
%     elseif log10(strctData.m_astrctTrain(iTrainIter).m_afStatisticalTests(1)) < -3
%         text(2,1.1*fMax,'**','color','r','horizontalalignment','center');
%     elseif log10(strctData.m_astrctTrain(iTrainIter).m_afStatisticalTests(1)) < -2
%         text(2,1.1*fMax,'*','color','r','horizontalalignment','center');
%     end
%
%     % SUA/MUA ?  - Waveform
%     tightsubplot(3,2,4,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
%     hold on;
%     iNumSamplesInWaveForm = length(strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormBefore);
%     afWaveFormTimeMicrosec = round(1e3*linspace(0,1,iNumSamplesInWaveForm));
%     afBlue =  [74,126,187]/255;
%     afRed = [190,75,72]/255;
%
%     fnFancyPlot2(afWaveFormTimeMicrosec, strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormBefore, strctData.m_astrctTrain(iTrainIter).m_afStdWaveFormBefore, afBlue,0.9*afBlue);
%     fnFancyPlot2(afWaveFormTimeMicrosec, strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormDuring, strctData.m_astrctTrain(iTrainIter).m_afStdWaveFormDuring, afRed,0.9*afRed);
%     set(gca,'ytick',[]);
%
%     % LFP
%
%     tightsubplot(3,2,6,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
%     hold on;
%     N = size(strctData.m_astrctTrain(iTrainIter).m_strctLFP.m_afData,1);
%     fnFancyPlot2(  afX,  mean(strctData.m_astrctTrain(iTrainIter).m_strctLFP.m_afData),    std(strctData.m_astrctTrain(iTrainIter).m_strctLFP.m_afData)/sqrt(N),  0.9*afBlue,afBlue);
%     set(gca,'ytick',[]);
%     set(gca,'xlim', [afX(1), afX(end)]);



function [afIncreaseRatio] = fnPrintPopulationNeuralResponses(strResultsFile, aiRange, afBaseColor, fIgnoreDepth, fTrainLengthLow,fTrainLengthHigh, strOpsin)
strctTmp=load(strResultsFile);
%%
figure(42);
clf;
% hold on;
% plot([0 100],[0 100],'k--');
abSig = strctTmp.strctPopulationOpticalStim.m_afPValue < 0.05;
abSUA = strctTmp.strctPopulationOpticalStim.m_afMUA_Contamination < 2;
% figure(1);
% clf;
% plot(strctTmp.strctPopulationOpticalStim.m_afSpikeWidth,strctTmp.strctPopulationOpticalStim.m_afSpikeHeight,'.');
%
% afDiffCent = -50:1:30;
% afHistDiff = hist(strctTmp.strctPopulationOpticalStim.m_afMeanDuring-strctTmp.strctPopulationOpticalStim.m_afMeanBefore,afDiffCent);
% figure(6);
% clf;
% bar(afDiffCent,afHistDiff,'facecolor','k','edgecolor','none')
% hold on;
% plot([0 0],[0 max(afHistDiff)],'r','Linewidth',2);
% axis([-50 50 0 max(afHistDiff)])
% set(gca,'xlim',[-50 50]);


for k=1:length(strctTmp.strctPopulationOpticalStim.m_acDataEntries)
    acSubject{k} = strctTmp.strctPopulationOpticalStim.m_acDataEntries{k}.m_a2cAttributes{2,1};
    acDate{k} = strctTmp.strctPopulationOpticalStim.m_acDataEntries{k}.m_a2cAttributes{2,2};
end

abMonkeyJ=ismember(strctTmp.strctPopulationOpticalStim.m_acSubject,'Julien');
abIgnoreSessions = ismember(acDate,{'120425_120557','120402_152621','120327_102326'});

abJunkUnits = strctTmp.strctPopulationOpticalStim.m_afLatencyMS_SO > 50 | strctTmp.strctPopulationOpticalStim.m_afJunkArtifactUnit > 7;
% axis off
abIgnore=strctTmp.strctPopulationOpticalStim.m_afRecordingDepth <= fIgnoreDepth & ~abSig | ~abSUA | abIgnoreSessions | abJunkUnits;

%abDepth=strctTmp.strctPopulationOpticalStim.m_afRecordingDepth < 28.5 & ~abMonkeyJ;
% abLowAmp = strctTmp.strctPopulationOpticalStim.m_afSpikeHeight < 500;
loglog(strctTmp.strctPopulationOpticalStim.m_afMeanBefore(~abIgnore & ~abSig),strctTmp.strctPopulationOpticalStim.m_afMeanDuring(~abIgnore & ~abSig),'.','color',[0.5 0.5 0.5],'markersize',2);; hold on;
loglog(strctTmp.strctPopulationOpticalStim.m_afMeanBefore(~abIgnore & abSig),strctTmp.strctPopulationOpticalStim.m_afMeanDuring(~abIgnore & abSig),'k.','markersize',2)
loglog([1e-1 1000],[1e-1 1000],'k');

% figure;
% hist(strctTmp.strctPopulationOpticalStim.m_afMeanDuring(~abIgnore)-strctTmp.strctPopulationOpticalStim.m_afMeanBefore(~abIgnore))
[h,p,c]=ttest(strctTmp.strctPopulationOpticalStim.m_afMeanBefore(~abIgnore),strctTmp.strctPopulationOpticalStim.m_afMeanDuring(~abIgnore))

% plot(strctTmp.strctPopulationOpticalStim.m_afMeanBefore(~abIgnore & ~abSig),strctTmp.strctPopulationOpticalStim.m_afMeanDuring(~abIgnore & ~abSig),'.','color',[0.5 0.5 0.5]);
% plot(strctTmp.strctPopulationOpticalStim.m_afMeanBefore(~abIgnore & abSig),strctTmp.strctPopulationOpticalStim.m_afMeanDuring(~abIgnore & abSig),'k.');

%%
abReduction = strctTmp.strctPopulationOpticalStim.m_afMeanBefore > strctTmp.strctPopulationOpticalStim.m_afMeanDuring;
% afRatio = strctTmp.strctPopulationOpticalStim.m_afMeanBefore ./ strctTmp.strctPopulationOpticalStim.m_afMeanDuring;
% sum(abReduction & abMonkeyJ)
%
% [strctTmp.strctPopulationOpticalStim.m_aiGridHoleX(abReduction & abMonkeyJ)
% strctTmp.strctPopulationOpticalStim.m_aiGridHoleY(abReduction & abMonkeyJ)]


afIncreaseRatio = strctTmp.strctPopulationOpticalStim.m_afMeanDuring(~abReduction & ~abIgnore &abSig) ./ strctTmp.strctPopulationOpticalStim.m_afMeanBefore(~abReduction & ~abIgnore &abSig);
fprintf('Median population increase is : %.5f\n',median(afIncreaseRatio(~isinf(afIncreaseRatio))));
 %6.1771


% axis(aiRange);
axis([1e-1 1e3 1e-1 1e3])
% set(gca,'
set(gca,'xtick',1.0e+003 *[    0.000001    0.00001    0.0001    0.0010    0.0100    0.1000    1.0000]);
set(gca,'ytick',1.0e+003 *[    0.000001    0.00001    0.0001    0.0010    0.0100    0.1000    1.0000]);
box off
fprintf('%d cells in total\n',length(strctTmp.strctPopulationOpticalStim.m_afMeanBefore)-sum(abIgnore));
fprintf('Out of which %d were SUA and %d MUA\n', sum(abSUA & ~abIgnore), sum(~abSUA & ~abIgnore));
fprintf('%d were from monkey J and %d from monkey B\n',sum(abMonkeyJ & ~abIgnore), sum(~abMonkeyJ & ~abIgnore));
fprintf('%d were significantly modulated  (%d in J and %d in B) \n',sum(abSig & ~abIgnore), sum(abSig & abMonkeyJ & ~abIgnore ),  sum(abSig & ~abMonkeyJ & ~abIgnore) )
fprintf('%d significantly reduced firing rate and %d significantly increased firing rate \n',sum(abSig & abReduction & ~abIgnore),sum(abSig & ~abReduction & ~abIgnore))
fprintf('Latency median: %.2f\n',nanmedian(strctTmp.strctPopulationOpticalStim.m_afLatencyMS_Ilka(abSig & ~abIgnore)));
set(42,'position',[ 1013         842         116          95]);
set(gca,'fontsize',7);
fprintf('%d units in Julien were Significant and increased: \n',sum(abMonkeyJ & ~abIgnore & abSig & abSUA & ~abReduction));
fprintf('%d units in Julien were Significant and decreased: \n',sum(abMonkeyJ & ~abIgnore & abSig & abSUA & abReduction));
fprintf('%d units in Bert were Significant and increased: \n',sum(~abMonkeyJ & ~abIgnore & abSig & abSUA & ~abReduction));
fprintf('%d units in Bert were Significant and decreased: \n',sum(~abMonkeyJ & ~abIgnore & abSig & abSUA & abReduction));


a2fColors = [0.5*afBaseColor;afBaseColor;[0.5,0.5,0.5]];
afPieData = [sum(abSig& abReduction & ~abIgnore),sum(abSig& ~abReduction & ~abIgnore),sum(~abSig& ~abIgnore)];
afPieData/sum(afPieData)*1e2
figure(41);
clf; hold on;
pie(afPieData)
colormap(a2fColors);
axis off
set(41,'position',[  1522         984        116         106])

% N=(length(abSig) - sum(abIgnore))/1e2;
% bar(1,sum(abSig & ~abIgnore)/N,'facecolor',afBaseColor)
% bar(2,sum(abSig& abReduction & ~abIgnore)/N,'facecolor',afBaseColor)
% bar(3,sum(abSig& ~abReduction & ~abIgnore)/N,'facecolor',0.5*afBaseColor)
% bar(4,sum(~abSig & ~abIgnore)/N,'facecolor', [0.5 0.5 0.5]);
% set(gca,'xlim',[0 5],'ylim',[0 100]);
% set(gca,'xtick',1:4,'xticklabel',[]);
% set(gcf,'position',[1124        1019         116          79]);


% afIncrease = strctTmp.strctPopulationOpticalStim.m_afMeanDuring-strctTmp.strctPopulationOpticalStim.m_afMeanBefore  
% find(strctTmp.strctPopulationOpticalStim.m_afLatencyMS_Ilka== 1 & abSUA & abSig &~abIgnore)
% afIncrease(strctTmp.strctPopulationOpticalStim.m_afLatencyMS_Ilka== 1 & abSUA & abSig &~abIgnore)

figure(43);
clf;
afCent = 0:20;  
afLatencies = strctTmp.strctPopulationOpticalStim.m_afLatencyMS_SO(abSUA & abSig &~abIgnore);
afLatenciesInhibited = strctTmp.strctPopulationOpticalStim.m_afLatencyMS_SO(abSUA & abSig &~abIgnore & abReduction);
afHist = histc(afLatencies ,afCent);
fprintf('The mean (median) latency is : %.2f (%.2f)\n',nanmean(afLatencies),nanmedian(afLatencies));

bar(afCent,1e2*afHist/sum(afHist),'facecolor',[0.5 0.5 0.5]);
set(gca,'xlim',[-0.05 20],'xtick',[0 5 10 15 20]);
set(gca,'ylim',[0 100]);
set(gcf,'position',[1187        1030         132          68])

box off
set(gca,'fontsize',7);


%
switch strOpsin
    case 'ChR2'
    aiRelevantUnitsCont = find(abSig & ~abReduction &  strctTmp.strctPopulationOpticalStim.m_aiNumPulsesInTrain==1 & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS >= fTrainLengthLow & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS< fTrainLengthHigh);
    aiRange2=-500:1000;
    fLFPRange = 500;
    case 'Cheta'
    aiRelevantUnitsCont = find(abSig & ~abReduction & strctTmp.strctPopulationOpticalStim.m_aiNumPulsesInTrain==1 & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS == 2000);
    aiRange2=-1000:3000;
    fLFPRange = 800;
    case 'Halo'
    aiRelevantUnitsCont = find(abSig & abReduction & strctTmp.strctPopulationOpticalStim.m_aiNumPulsesInTrain==1 & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS > 900 & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS < 1100);
    aiRange2=-1000:2000;
     fLFPRange = 800;
    case 'Arch'
    aiRelevantUnitsCont = find(abSig & abReduction & strctTmp.strctPopulationOpticalStim.m_aiNumPulsesInTrain==1 & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS > 490 & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS < 510);
    aiRange2=-500:1000;
     fLFPRange = 800;
     
end
clear a2fResponse a2fResponseNorm a2fRange


iNumSessionsSubset = length(aiRelevantUnitsCont);
for i=1:iNumSessionsSubset
    afResFilt = conv2(strctTmp.strctPopulationOpticalStim.m_acResponse{aiRelevantUnitsCont(i)}(2,:),fspecial('gaussian',[1 80],2),'same');
    afRes = interp1( strctTmp.strctPopulationOpticalStim.m_acResponse{aiRelevantUnitsCont(i)}(1,:),afResFilt,aiRange2);
    a2fResponse(i,:)= afRes;
    a2fResponseNorm(i,:) =afRes/max(afRes); 
    a2fRange(i,:) = strctTmp.strctPopulationOpticalStim.m_a2fDepth(aiRelevantUnitsCont(i),:);
end
T=[-1;a2fRange(:,1);];
aiRelevantUnitsForLFP_Analysis = aiRelevantUnitsCont(find(diff(T)));
a2fLFP = zeros(length(aiRelevantUnitsForLFP_Analysis),length(aiRange2));
for i=1:length(aiRelevantUnitsForLFP_Analysis)
    a2fLFP(i,:)=interp1(strctTmp.strctPopulationOpticalStim.m_acLFP_TS{aiRelevantUnitsForLFP_Analysis(i)},strctTmp.strctPopulationOpticalStim.m_acLFP{aiRelevantUnitsForLFP_Analysis(i)}, aiRange2);
end
afMeanLFP = mean(a2fLFP,1);
afSEM = std(a2fLFP,[],1);%/sqrt(iNumSessionsSubset);
figure(48);clf; hold on;
plot(aiRange2/1e3,afMeanLFP+afSEM,'--','color',[0.5 0.5 0.5])
plot(aiRange2/1e3,afMeanLFP-afSEM,'--','color',[0.5 0.5 0.5])
plot(aiRange2/1e3,afMeanLFP,'color','k','LineWidth',2)

axis([aiRange2(1)/1e3 aiRange2(end)/1e3 -fLFPRange fLFPRange]);
set(gcf,'position',[ 1187        1030         132          68]);
set(gca,'fontsize',7);


% 
% 
% afMean = mean(a2fResponse,1)*1e3;
% afSEM = std(1e3*a2fResponse,1)/sqrt(length(aiRelevantUnitsCont));
% figure(44);clf;hold on;
% plot(aiRange2,afMean+afSEM,'color',[0.5 0.5 0.5],'linestyle','--')
% plot(aiRange2,afMean-afSEM,'color',[0.5 0.5 0.5],'linestyle','--');
% plot(aiRange2,afMean,'color',afBaseColor)
% axis([aiRange2(1),aiRange2(end) 0 80]);
% set(gcf,'position',[1036         913         279         185])

afMean = nanmean(a2fResponseNorm,1);
afSEM = nanstd(a2fResponseNorm,1);%/sqrt(length(aiRelevantUnitsCont));
figure(440);clf;hold on;
plot(aiRange2/1e3,afMean+afSEM,'color',[0.5 0.5 0.5],'linestyle','--')
plot(aiRange2/1e3,afMean-afSEM,'color',[0.5 0.5 0.5],'linestyle','--');
plot(aiRange2/1e3,afMean,'color','k','LineWidth',2)

axis([aiRange2(1)/1e3,aiRange2(end)/1e3 0 1]);
set(gcf,'position',[1187        1030         132          68])
set(gca,'fontsize',7);
%%
% 
% aiRelevantUnitsCont = find(abReduction & strctTmp.strctPopulationOpticalStim.m_aiNumPulsesInTrain==1 & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS >= fTrainLengthLow & strctTmp.strctPopulationOpticalStim.m_afTrainLengthMS<fTrainLengthHigh);
% clear a2fResponse a2fResponseNorm
% for i=1:length(aiRelevantUnitsCont)
%     afRes = interp1( strctTmp.strctPopulationOpticalStim.m_acResponse{aiRelevantUnitsCont(i)}(1,:),strctTmp.strctPopulationOpticalStim.m_acResponse{aiRelevantUnitsCont(i)}(2,:),aiRange);;
%     a2fResponse(i,:)= afRes;
%     a2fResponseNorm(i,:) =afRes/max(afRes); 
% end
% afMean = nanmean(a2fResponseNorm,1);
% afSEM = nanstd(a2fResponseNorm,1)/sqrt(length(aiRelevantUnitsCont));
% 
% figure(441);clf;hold on;
% plot(aiRange,afMean+afSEM,'color',[0.5 0.5 0.5],'linestyle','--')
% plot(aiRange,afMean-afSEM,'color',[0.5 0.5 0.5],'linestyle','--');
% plot(aiRange,afMean,'color',afBaseColor)
% 
% axis([ aiRange(1),aiRange(end) 0 0.2]);
% set(gcf,'position',[1036         913         279         185])
%%
% aiRelevantUnitsCont = find(~abReduction & strctTmp.strctPopulationOpticalStim.m_aiNumPulsesInTrain >=46 & strctTmp.strctPopulationOpticalStim.m_aiNumPulsesInTrain <=52);
% clear a2fResponse
% for i=1:length(aiRelevantUnitsCont)
%     a2fResponse(i,:)= interp1( strctTmp.strctPopulationOpticalStim.m_acResponse{aiRelevantUnitsCont(i)}(1,:),strctTmp.strctPopulationOpticalStim.m_acResponse{aiRelevantUnitsCont(i)}(2,:),-500:1500);
% end
% % if exist('a2fResponse','var') && ~isempty(a2fResponse)
% afMean = mean(a2fResponse,1)*1e3;
% afSEM = std(1e3*a2fResponse,1)/sqrt(length(aiRelevantUnitsCont));
% figure(45);clf;hold on;
% plot(-500:1500,afMean+afSEM,'color',[0.5 0.5 0.5],'linestyle','--')
% plot(-500:1500,afMean-afSEM,'color',[0.5 0.5 0.5],'linestyle','--');
% plot(-500:1500,afMean,'b')
% axis([-500 1500 0 140]);
% set(gcf,'position',[1036         913         279         59])
% 
% figure(46);clf;hold on;
% plot(-500:1500,afMean+afSEM,'color',[0.5 0.5 0.5],'linestyle','--')
% plot(-500:1500,afMean-afSEM,'color',[0.5 0.5 0.5],'linestyle','--');
% plot(-500:1500,afMean,'b')
% axis([ -46.7035   80.8256 0 80]);
% set(gcf,'position',[1036         913         279         185])
% end
return


function fnPrintPopulationEyeMovementDuringPulsedOpticalStimulation
global g_strRootDrive
strPopulationOutputfile = [g_strRootDrive,':\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\EyeMovementDuringOpticalStimulationPulsed_Population.mat'];
strctPop = load(strPopulationOutputfile);
aiInteresting = find(strctPop.strctEyePopulationOptical.m_afMaxDistAfter> 15);


acSubPop=strctPop.acDataEntries(strctPop.strctEyePopulationOptical.m_aiUnitIndex);
for k=1:28
    strctTmp=load(acSubPop{k}.m_strFile);
    for j=1:length(strctTmp.strctUnitInterval.m_astrctTrain)
        [strctTmp.strctUnitInterval.m_astrctTrain(j).m_strctTrain.m_iPulsesPerTrain,mean(strctTmp.strctUnitInterval.m_astrctTrain(j).m_strctTrain.m_afPulseLengthMS)]
    end
    %
end

k=1
figure(31+k);
strInterestingInterval = strctPop.acDataEntries{ strctPop.strctEyePopulationOptical.m_aiUnitIndex(aiInteresting(k))}.m_strFile
[~,strOpsin]=fnFindAttribute( strctPop.strctEyePopulationOptical.m_acAttributes{25},'Opsin')
strctData = load(strInterestingInterval);
fnPrintExampleEyeMovementDuringOpticalStimulation(strctData,1,400,false)
set(32,'position',[ 873   736   487   181])



for i=1:28
    for j=1:28
        a2fTmp(i,j) = sqrt((strctPop.strctEyePopulationOptical.m_afMaxDistBefore(j)-strctPop.strctEyePopulationOptical.m_afMaxDistBefore(i)).^2+...
            (strctPop.strctEyePopulationOptical.m_afMaxDistAfter(j)-strctPop.strctEyePopulationOptical.m_afMaxDistAfter(i)).^2);
    end;
end
NumDuplicates = (sum(a2fTmp(:) == 0) - 28)/2;

fMax =20;
figure(30);
clf;hold on;
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore,strctPop.strctEyePopulationOptical.m_afMaxDistAfter,'.','color',[0.5 0.5 0.5]);
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(25),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(25),'k.');
plot([0 fMax],[0 fMax],'k--');
% plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(aiInteresting),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(aiInteresting),'r.');
%
% plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(aiInteresting(3)),35,'r.');
box on
% xlabel('Distance before stimulation');
% ylabel('Distance after stimulation');
axis equal
axis([0 fMax 0 fMax]);
set(gca,'xtick',0:10:fMax);
set(gca,'ytick',0:10:40,'yticklabel',{'0','10','20','30','150'});
box on


function fnPrintPopulationEyeMovementDuringOpticalStimulationControl()
global g_strRootDrive
strctPop = load([g_strRootDrive,':\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\EyeMovementDuringOpticalStimulation_PopulationControl.mat']);
figure(80);
clf;
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore,strctPop.strctEyePopulationOptical.m_afMaxDistAfter,'.');
for k=1:length(strctPop.strctEyePopulationOptical.m_afMaxDistBefore)
    text(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(k),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(k), num2str(k));
end
hold on;
plot([0 50],[0 50],'k--');
for j=1:length(strctPop.acDataEntries)
    figure(200+j);clf;hold on;
    strctTmp=load(strctPop.acDataEntries{j}.m_strFile);
    fnPrintExampleEyeMovementDuringOpticalStimulation(strctTmp,1,400,false)
    
end


function fnPrintPopulationEyeMovementDuringOpticalStimulation()
global g_strRootDrive
strPopulationOutputfile = [g_strRootDrive,':\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\EyeMovementDuringOpticalStimulation_Population.mat'];
strctPop = load(strPopulationOutputfile);

for j=1:length(strctPop.strctEyePopulationOptical.m_acAttributes)
    [~,acOpsin{j}] = fnFindAttribute(strctPop.strctEyePopulationOptical.m_acAttributes{j},'Opsin');
end

%aiSmallAmp = setdiff(find(strctPop.strctEyePopulationOptical.m_afMaxIntervalLength > 10),aiInteresting);
% aiSmallAmp = 69;
% strctData = load(strctPop.acDataEntries{ strctPop.strctEyePopulationOptical.m_aiUnitIndex(aiSmallAmp)}.m_strFile);%load([g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\111212\Processed\Optogenetic_Analysis\\Bert-111212_144722_OptogeneticsMicrostim_Channel1_Interval1.mat');
% figure(11);fnPrintExampleEyeMovementDuringOpticalStimulation(strctData,1,200,false)
% set(11,'position',[ 873   736   487   181]);
% set(gca,'xticklabel',[])

aiInteresting = find(strctPop.strctEyePopulationOptical.m_afMaxIntervalLength > 60);
%%
aiInterestingToDraw =aiInteresting;
for j=1:length(aiInterestingToDraw)
    iInteresting=aiInterestingToDraw(j);
    figure(11+j);
    strInterestingInterval = strctPop.acDataEntries{ strctPop.strctEyePopulationOptical.m_aiUnitIndex(iInteresting)}.m_strFile
    if strncmpi(strInterestingInterval,[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120314\RAW\..\Processed\Optogenetic_Analysis\Julien-120314_142604'],111)
        continue;
    end;
    strctData = load(strInterestingInterval);
    fnPrintExampleEyeMovementDuringOpticalStimulation(strctData,1,400,false)
    strctTmp=load(strctPop.acDataEntries{ strctPop.strctEyePopulationOptical.m_aiUnitIndex(iInteresting)}.m_strFile);
    
    figure(50+j);
    clf;hold on;
    iOffset = find(strctTmp.strctUnitInterval.m_astrctTrain( strctPop.strctEyePopulationOptical.m_aiTrainIndex(iInteresting)).m_aiPeriStimulusRangeMS==0);
    iNumTrain = size(strctTmp.strctUnitInterval.m_astrctTrain( strctPop.strctEyePopulationOptical.m_aiTrainIndex(iInteresting)).m_a2fXEyePix,1);
    for k=1:iNumTrain
        afX = strctTmp.strctUnitInterval.m_astrctTrain( strctPop.strctEyePopulationOptical.m_aiTrainIndex(iInteresting)).m_a2fXEyePix(k,iOffset-200:iOffset+400);
        afY = strctTmp.strctUnitInterval.m_astrctTrain( strctPop.strctEyePopulationOptical.m_aiTrainIndex(iInteresting)).m_a2fYEyePix(k,iOffset-200:iOffset+400);
        afX=(afX-afX(1))* (21/600);
        afY=(afY-afY(1) )* (30/800);
        plot(afX(1:10:end),afY(1:10:end),'color','k');
    end;
    axis equal
    axis([-20 20 -20 20]);
    set(50+j,'position',[    1593         873         192         130]);
    set(gca,'xtick',-20:10:20,'xticklabel',[]);
    set(gca,'ytick',-20:10:20,'yticklabel',[]);
    plot(0,0,'r.','MarkerSize',11);
    box on
end
%%
% Figure size:
% 680   871   560   227

%
% for i=1:187
%     for j=1:187
%         a2fTmp(i,j) = sqrt((strctPop.strctEyePopulationOptical.m_afMaxDistBefore(j)-strctPop.strctEyePopulationOptical.m_afMaxDistBefore(i)).^2+...
%         (strctPop.strctEyePopulationOptical.m_afMaxDistAfter(j)-strctPop.strctEyePopulationOptical.m_afMaxDistAfter(i)).^2);
%     end;
% end
% NumDuplicates = (sum(a2fTmp(:) == 0) - 187)/2;
%187-69 = 118

afBlue = [0,176,240]/255;
afGreen = [0,176,80]/255;
afOrange = [255,192,0]/255;

abChR2 = ismember(acOpsin,'ChR2');
abArch= ismember(acOpsin,'Arch');
abHalo= ismember(acOpsin,'eNpHR3.0');
fMax = 40;
figure(20);
clf;hold on;
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore,strctPop.strctEyePopulationOptical.m_afMaxDistAfter,'.','color',[0.5 0.5 0.5]);

% plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(abChR2),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(abChR2),'.','color',afBlue);
% plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(abArch),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(abArch),'.','color',afGreen);
% plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(abHalo),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(abHalo),'.','color',afOrange);

plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(aiInteresting),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(aiInteresting),'.','color',[0 0 0]);
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(aiInteresting),strctPop.strctEyePopulationOptical.m_afMaxDistAfter(aiInteresting),'o','color',[0 0 0]);
aiBeyondRange = aiInteresting(strctPop.strctEyePopulationOptical.m_afMaxDistAfter(aiInteresting)>fMax);
plot([0 fMax],[0 fMax],'k--');
box on
axis equal
axis([0 fMax 0 fMax]);


plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(aiBeyondRange), strctPop.strctEyePopulationOptical.m_afMaxDistAfter(aiBeyondRange)- 95     ,'.','color',[0 0 0]);
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBefore(aiBeyondRange), strctPop.strctEyePopulationOptical.m_afMaxDistAfter(aiBeyondRange)- 95     ,'o','color',[0 0 0]);

set(gca,'xtick',0:10:fMax);
set(gca,'ytick',0:10:40,'yticklabel',{'0','10','20','30','150'});
box on
set(gcf,'position',[ 680   853   395   245])
% axis equal


% Controls...

figure(30);
clf;hold on;
fMax = 40;
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBeforeRandSubset,strctPop.strctEyePopulationOptical.m_afMaxDistDuringRandSubset,'.','color',[0.5 0.5 0.5]);
aiSigRand = find(strctPop.strctEyePopulationOptical.m_afMaxIntervalLengthRandSubset > 100)
plot(strctPop.strctEyePopulationOptical.m_afMaxDistBeforeRandSubset(aiSigRand),strctPop.strctEyePopulationOptical.m_afMaxDistDuringRandSubset(aiSigRand),'.','color',[0 0 0]);
plot([0 fMax],[0 fMax],'k--');
box on
axis equal
axis([0 fMax 0 fMax]);
set(gcf,'position',[ 680   853   395   245])



aiRandInteresting = find(strctPop.strctEyePopulationOptical.m_afMaxDistDuringRandSubset > 20);
aiWeird = strctPop.strctEyePopulationOptical.m_aiUnitIndex(aiRandInteresting)

for k=1:length(aiWeird)
    strctData = load(strctPop.acDataEntries{aiWeird(k)}.m_strFile);
    fnPrintExampleEyeMovementDuringOpticalStimulationControl(strctData,1,400,false)
    set(gcf,'position',[ 873   736   487   181])
    
end


% plot(strctPop.strctEyePopulationOptical.m_afMaxDistBeforeRandAll,strctPop.strctEyePopulationOptical.m_afMaxDistDuringRandAll,'.','color',[0.5 0.5 0.5]);

plot([0 fMax],[0 fMax],'k--');
axis equal
% axis([0 fMax 0 fMax]);
% set(gca,'xtick',0:10:fMax);
% set(gca,'ytick',0:10:40,'yticklabel',{'0','10','20','30','150'});
% box on
% set(gcf,'position',[ 680   853   395   245])
% Look at the control with the largest increase in the median

%[fDummy,i]=max(strctPop.strctEyePopulationOptical.m_afMaxDistDuringRandAll)




function fnPrintExampleEyeMovementDuringElecricalStimulation()
global g_strRootDrive
strctData = load([g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120124\Processed\ElectricalMicrostim\Julien-24-Jan-2012_13-29-58_ElectricalMicrostim_Channel1.mat']);
afTime = strctData.strctStimStat.m_afRangeMS;
aiTimeRestricted = find(afTime >= 0 & afTime <= 500);
aiTimeBefore= find(afTime <= 0);
a2fX = strctData.strctStimStat.m_astrctStimulation(6).m_a2fXpix_nozero;
a2fY = strctData.strctStimStat.m_astrctStimulation(6).m_a2fYpix_nozero;
iNumStim = size(a2fX,1);

fFixationSpotX= mean(median(a2fX(:,1:200),2));
fFixationSpotY = mean(median(a2fY(:,1:200),2));
a2fDistFromFixationSpot = sqrt((a2fX-fFixationSpotX).^2+(a2fY-fFixationSpotY).^2);

a2fDistFromFixationSpotBaselineSub = zeros(iNumStim,length(afTime));
for j=1:iNumStim
    a2fDistFromFixationSpotBaselineSub(j,:) = a2fDistFromFixationSpot(j,:) - mean(a2fDistFromFixationSpot(j,1:200));
end
[afDummy, aiSortInd]=sort(mean(a2fDistFromFixationSpotBaselineSub(:,200+[100:300]),2),'descend');

clf;hold on;
a2fColor = gray(iNumStim);
plot(afTime,a2fDistFromFixationSpotBaselineSub,'color',[0.5 0.5 0.5]);


fThres = 5*std(median(a2fDistFromFixationSpotBaselineSub(:,1:200),1));

a2fBefore = a2fDistFromFixationSpotBaselineSub(:,1:200);


% for k=1:iNumStim
%     plot(afTime,a2fDistFromFixationSpotBaselineSub(aiSortInd(k),:),'color',a2fColor(k,:))
% end
plot(afTime, median(a2fDistFromFixationSpotBaselineSub,1),'k','LineWidth',2)
box on
plot([0 0],[ -50 800],'r','LineWidth',2);
axis([-200 500 -50 800]);
set(gca,'xtick',-200:100:500);
set(gca,'ytick',[]);%-200:200:800);
iBeforeFixationMS = 200;
iAfterFixationMS = 500;

plot([-iBeforeFixationMS iAfterFixationMS],[fThres fThres],'k--');
plot([-iBeforeFixationMS iAfterFixationMS],-[fThres fThres],'k--');

%    plot(-iBeforeFixationMS:iAfterFixationMS,  strctData.strctUnitInterval.m_astrctTrain(1).m_a2fDistToFixationSpotPixZeroBaseline(  strctData.strctUnitInterval.m_astrctTrain(1).m_abTrainsWithFixationBeforeOnset,aiZoomRange)','color',[0.5 0.5 0.5])
%    plot([0 0],[ -fRange fRange],'r','LineWidth',2);
%    plot(-iBeforeFixationMS:iAfterFixationMS, afMedian,'k','linewidth',2);
%
%    plot([-iBeforeFixationMS iAfterFixationMS],[3*std(a2fBefore(:)) 3*std(a2fBefore(:))],'k--');
%    plot([-iBeforeFixationMS iAfterFixationMS],-[3*std(a2fBefore(:)) 3*std(a2fBefore(:))],'k--');
%    box on





function fnPrintExampleEyeMovementDuringOpticalStimulation(strctData, iTrainIndex,fRange,bXTickVisible)
iOnsetIndex = find(strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_aiPeriStimulusRangeMS == 0);
iBeforeFixationMS = 200;
iAfterFixationMS = 500;
aiZoomRange = iOnsetIndex-iBeforeFixationMS:iOnsetIndex+iAfterFixationMS;
a2fBefore = strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaseline( ...
    strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_abTrainsWithFixationBeforeOnset,iOnsetIndex-iBeforeFixationMS:iOnsetIndex );
afMedian = median(strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaseline( strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_abTrainsWithFixationBeforeOnset,aiZoomRange ));
afMean= mean(strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaseline( strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_abTrainsWithFixationBeforeOnset,aiZoomRange ));

fLargeThres = 15*std( median(a2fBefore,1));

figure;
clf;hold on;
plot(-iBeforeFixationMS:iAfterFixationMS,  strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaseline(  strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_abTrainsWithFixationBeforeOnset,aiZoomRange)','color',[0.5 0.5 0.5])
plot([0 0],[ -fRange fRange],'r','LineWidth',2);
axis([-iBeforeFixationMS iAfterFixationMS -fLargeThres  fRange]);
% plot(-iBeforeFixationMS:iAfterFixationMS, afMedian,'k','linewidth',2);

box on
if bXTickVisible
    set(gca,'xtick',-200:100:500);
else
    set(gca,'xtick', []);
end;
set(gcf,'position',[ 873   736   487   130])

set(gca,'yticklabel',[]);

fThres = 3*std( median(a2fBefore,1));

figure;
clf; hold on;
plot(-iBeforeFixationMS:iAfterFixationMS, afMedian,'k','linewidth',2);
plot([-iBeforeFixationMS iAfterFixationMS],[fThres fThres],'linestyle','--','color',[0.5 0.5 0.5]);
plot([-iBeforeFixationMS iAfterFixationMS],-[fThres fThres],'linestyle','--','color',[0.5 0.5 0.5]);
plot([0 0],[ -fRange fRange],'r','LineWidth',2);

set(gcf,'position',[ 873   736   487   50])
set(gca,'ytick',[]);
set(gca,'xtick', []);
axis([-iBeforeFixationMS iAfterFixationMS -2*fThres  4*fThres]);
axis off

return;




function fnPrintExampleEyeMovementDuringOpticalStimulationControl(strctData, iTrainIndex,fRange,bXTickVisible)
iOnsetIndex = find(strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_aiPeriStimulusRangeMS == 0);
iBeforeFixationMS = 200;
iAfterFixationMS = 300;
aiZoomRange = iOnsetIndex-iBeforeFixationMS:iOnsetIndex+iAfterFixationMS;
aiSelectedRange = 1:sum(strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_abTrainsWithFixationBeforeOnset);
a2fBefore = strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents( aiSelectedRange,iOnsetIndex-iBeforeFixationMS:iOnsetIndex );
afMedian = median(strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents( aiSelectedRange,aiZoomRange ));


fLargeThres = 15*std( median(a2fBefore,1));


figure;
clf;hold on;
plot(-iBeforeFixationMS:iAfterFixationMS,  strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents(aiSelectedRange,aiZoomRange)','color',[0.5 0.5 0.5])
plot([0 0],[ -fRange fRange],'r','LineWidth',2);
axis([-iBeforeFixationMS iAfterFixationMS -fLargeThres  fRange]);
% plot(-iBeforeFixationMS:iAfterFixationMS, afMedian,'k','linewidth',2);

box on
if bXTickVisible
    set(gca,'xtick',-200:100:500);
else
    set(gca,'xtick', []);
end;
set(gcf,'position',[ 873   736   487   130])

set(gca,'yticklabel',[]);

fThres = 3*std( median(a2fBefore,1));

figure;
clf; hold on;
plot(-iBeforeFixationMS:iAfterFixationMS, afMedian,'k','linewidth',2);
plot([-iBeforeFixationMS iAfterFixationMS],[fThres fThres],'linestyle','--','color',[0.5 0.5 0.5]);
plot([-iBeforeFixationMS iAfterFixationMS],-[fThres fThres],'linestyle','--','color',[0.5 0.5 0.5]);
plot([0 0],[ -fRange fRange],'r','LineWidth',2);

set(gcf,'position',[ 873   736   487   50])
set(gca,'ytick',[]);
set(gca,'xtick', []);
axis([-iBeforeFixationMS iAfterFixationMS -2*fThres  4*fThres]);
axis off












figure;
clf;hold on;
plot(-iBeforeFixationMS:iAfterFixationMS,  strctData.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents(aiSelectedRange,aiZoomRange)','color',[0.5 0.5 0.5])
plot([0 0],[ -fRange fRange],'r','LineWidth',2);
plot(-iBeforeFixationMS:iAfterFixationMS, afMedian,'k','linewidth',2);
axis([-iBeforeFixationMS iAfterFixationMS -fLargeThres  fRange]);
plot([-iBeforeFixationMS iAfterFixationMS],[fThres fThres],'k--');
plot([-iBeforeFixationMS iAfterFixationMS],-[fThres fThres],'k--');

set(gca,'yticklabel',[]);
set(gcf,'position',[ 873   736   487   181])

figure;
strctTmp=strctData;
clf;hold on;
for k=1:length(aiSelectedRange)
    afX = strctTmp.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fEyeXRandEvents(aiSelectedRange(k),iOnsetIndex-200:iOnsetIndex+400);
    afY = strctTmp.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fEyeYRandEvents(aiSelectedRange(k),iOnsetIndex-200:iOnsetIndex+400);
    afX=(afX-afX(1))* (21/600);
    afY=(afY-afY(1) )* (30/800);
    plot(afX(1:10:end),afY(1:10:end),'color','k');
end;
axis([-300 300 -300 300]);
figure;
plot(strctTmp.strctUnitInterval.m_astrctTrain(iTrainIndex).m_a2fEyeXRandEvents(aiSelectedRange,:)')

return;

function fnPrintSaccadesBeforeInjection()
global g_strRootDrive
% ChR2 site
strctData = load([g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120124\Processed\ElectricalMicrostim\Julien-24-Jan-2012_13-29-58_ElectricalMicrostim_Channel1.mat']);
afTime = strctData.strctStimStat.m_afRangeMS;
aiTimeRestricted = find(afTime >= 0 & afTime <= 150);
fnPlotSaccade(strctData.strctStimStat.m_astrctStimulation(6),aiTimeRestricted,[])
% Halo site
strctData = load([g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120125\Processed\ElectricalMicrostim\Julien-25-Jan-2012_18-23-35_ElectricalMicrostim_Channel1.mat']);
fnPlotSaccade(strctData.strctStimStat.m_astrctStimulation(4),aiTimeRestricted,[1,12,11,14,21])

strctData = load([g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120127\RAW\..\Processed\ElectricalMicrostim\Julien-27-Jan-2012_11-26-56_ElectricalMicrostim_Channel1.mat']);
fnPlotSaccade(strctData.strctStimStat.m_astrctStimulation(15),aiTimeRestricted,[]);


strctData = load([g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120514\RAW\..\Processed\ElectricalMicrostim\Bert-14-May-2012_15-50-35_ElectricalMicrostim_Channel1.mat']);
fnPlotSaccade(strctData.strctStimStat.m_astrctStimulation(9),aiTimeRestricted,[]);


strctData = load([g_strRootDrive,':\Data\Doris\Electrophys\Bert\FEF_Control\111020\\Processed\ElectricalMicrostim\\Bert-20-Oct-2011_17-49-14_ElectricalMicrostim_Channel1.mat']);
fnPlotSaccade(strctData.strctStimStat.m_astrctStimulation(4),aiTimeRestricted,[]);

function fnPlotSaccade(strctSaccade, aiTimeRestricted, aiSelectedSaccades)
h=figure;
clf;hold on;
if isempty(aiSelectedSaccades)
    iNumStim = length(strctSaccade.m_afTrainOnset);
    aiSelectedSaccades=1:iNumStim;
end

% Discard blinks!

for k=1:length(aiSelectedSaccades)
    afX = strctSaccade.m_a2fXpix(aiSelectedSaccades(k),aiTimeRestricted);
    afY =strctSaccade.m_a2fYpix(aiSelectedSaccades(k),aiTimeRestricted);
    if max(abs(afX-afX(1))) < 2000  && max(  abs(afY-afY(1))) < 2000
        plot(afX-afX(1),afY-afY(1),'k');
    end
    %    text(afX(end)-afX(1),afY(end)-afY(1), num2str(aiSelectedSaccades(k)))
end
plot(0,0,'ro');

box on
axis equal
axis([-800 800 -800 800]);
set(gca,'xtick',[],'ytick',[]);
afPos = get(gcf,'position');
afPos(3:4) = ceil([140 105]*0.7);
set(gcf,'position',afPos);



return;



function fnPrintPopulationSaccadeMemoryTask()
global g_strRootDrive
strPopulationFile = [g_strRootDrive,':\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\MemorySaccadeTask_PopulationData'];
strctTmp =load(strPopulationFile);
strctPopulationResult=strctTmp.strctPopulationResult;

figure(10);clf;fnPrintPyschCurve(strctPopulationResult, 'Julien',30);
figure(12);clf;fnPrintPyschCurve(strctPopulationResult, 'Bert',35);
set(gca,'yticklabel',[]);
iNumSessions = length(strctPopulationResult.m_acDataEntries);
% Chi-Square Analysis!

acControlSessions = {...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120416\RAW\..\Processed\BehaviorStats\Julien-16-Apr-2012_15-22-01_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120416\RAW\..\Processed\BehaviorStats\Julien-16-Apr-2012_15-22-01_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120325\RAW\..\Processed\BehaviorStats\Bert-25-Mar-2012_16-42-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120325\RAW\..\Processed\BehaviorStats\Bert-25-Mar-2012_16-42-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120325\RAW\..\Processed\BehaviorStats\Bert-25-Mar-2012_16-42-51_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp4.mat']};

aiControlSessions = fnFindSession(strctPopulationResult, acControlSessions);

a2fChiSquareValues = zeros(iNumSessions,8);
a2fChiSquareValues2x2= zeros(iNumSessions,8);
for iSessionIter=1:iNumSessions
    for iCondition=1:8
        aiNoStim = strctPopulationResult.m_a3fNumTrialsNoStim(iCondition, :, iSessionIter);
        aiStim = strctPopulationResult.m_a3fNumTrialsStim(iCondition, :, iSessionIter);
        if sum(aiStim) < 10 || sum(aiNoStim) < 10
            continue;
        end;
        
        a2iObservedTable = [aiNoStim;aiStim];
        a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
        a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
        a2fChiSquareValues(iSessionIter,iCondition) = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
        
        
        a2iObservedTable2x2 = [aiNoStim(2), sum(aiNoStim([1,3,4]));
            aiStim(2), sum(aiStim([1,3,4]));];
        a2fExpectedTable2x2 = sum(a2iObservedTable2x2,2) * sum(a2iObservedTable2x2,1) / sum(a2iObservedTable2x2(:));
        a2fChiElements2x2 = (a2fExpectedTable2x2 - a2iObservedTable2x2 ) .^2 ./ a2fExpectedTable2x2;
        a2fChiSquareValues2x2(iSessionIter,iCondition) = sum(a2fChiElements2x2(~isinf(a2fChiElements2x2) & ~isnan(a2fChiElements2x2)));
    end
end
% max(a2fChiSquareValues(aiControlSessions,:),[],2)
% max(a2fChiSquareValues(setdiff(1: iNumSessions,aiControlSessions),:),[],2)
DegreeOfFreedom =3;
PValue = 0.05;
SignificanceThresholdChiValue = chi2inv(1-PValue,DegreeOfFreedom);

afMaxChiValues = max(a2fChiSquareValues2x2,[],2);
aiSignificantSessions = find(sum(a2fChiSquareValues2x2>SignificanceThresholdChiValue,2) > 0);
afMaxChiValues(aiSignificantSessions)
acSigSessions = fnCellStructToArray(strctPopulationResult.m_acDataEntries(aiSignificantSessions),'m_strFile');
for k=1:length(acSigSessions)
    fprintf('%s\n',acSigSessions{k});
end

iInteresting = 2;
acSigSessions{iInteresting}
a2fChiSquareValues(aiSignificantSessions(iInteresting),:)

afMaxChiValues(aiSignificantSessions(iInteresting))
afMaxChiValues(aiSignificantSessions)
% % Per Animal

%
%
% aiNumTrialsStimCorrect = squeeze(sum(a3fNumTrialsStim(:,2,:),1));
% aiNumTrialsStimIncorrect = squeeze(sum(a3fNumTrialsStim(:,3,:),1));
% afPercCorrectStim = aiNumTrialsStimCorrect./(aiNumTrialsStimCorrect+aiNumTrialsStimIncorrect);
%
% aiNumTrialsNoStim = aiNumTrialsStimCorrect+aiNumTrialsStimIncorrect;
% aiNumTrialsStim = aiNumTrialsNoStimCorrect+aiNumTrialsNoStimIncorrect;
%
% aiValid = afPercentNoStim > 0.45;
% [p,h]=ttest(afPercentNoStim(aiValid), 0.5);
%
% aiNumTrialsNoStimCorrect = squeeze(sum(a3fNumTrialsNoStim(:,2,:),1));
% aiNumTrialsNoStimIncorrect = squeeze(sum(a3fNumTrialsNoStim(:,3,:),1));
% afPercCorrectNoStim = aiNumTrialsNoStimCorrect./(aiNumTrialsNoStimCorrect+aiNumTrialsNoStimIncorrect);

strSelectedAnimal = 'Bert';
%strSelectedAnimal = 'Bert';
% iSelectedSession = fnFindSession(strctPopulationResult,[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120406\RAW\..\Processed\BehaviorStats\Julien-06-Apr-2012_09-12-26_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat');


iSelectedSession = fnFindSession(strctPopulationResult,[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120322\RAW\..\Processed\BehaviorStats\Bert-22-Mar-2012_11-20-14_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp2.mat']);
figure(4);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, iSelectedSession)

iSelectedSession = fnFindSession(strctPopulationResult,[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120402\RAW\..\Processed\BehaviorStats\Bert-02-Apr-2012_15-26-29_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp7.mat']);
figure(5);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, iSelectedSession)

iSelectedSession = fnFindSession(strctPopulationResult,[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120406\RAW\..\Processed\BehaviorStats\Julien-06-Apr-2012_09-12-26_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat']);
figure(6);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, iSelectedSession)

iSelectedSession = fnFindSession(strctPopulationResult,[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120416\RAW\..\Processed\BehaviorStats\Julien-16-Apr-2012_15-22-01_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp11.mat']);
figure(7);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, iSelectedSession)

% iSelectedSession = fnFindSession(strctPopulationResult,[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120416\RAW\..\Processed\BehaviorStats\Julien-16-Apr-2012_15-22-01_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp12y.mat');
% figure(8);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, iSelectedSession)
%
iSelectedSession = length(strctPopulationResult.m_acSubject)-2;
figure(11);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, 45)
figure(11);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, 49)

iSelectedSession = length(strctPopulationResult.m_acSubject);
figure(11);clf;fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, iSelectedSession)

return;

function fnPrintPopulationSaccadeMemoryTaskAux(strctPopulationResult, iSelectedSession)

a4iHist =strctPopulationResult.m_acHist{iSelectedSession};
a4iCumHist =strctPopulationResult.m_acCumHist{iSelectedSession};
N=20;
strctPopulationResult.m_acSig{iSelectedSession}
a2fOutcomeColors = [79,129,189;0,176,80;192,80,77;247,150,70]/255;
iNumOutcomes=4;
N=strctPopulationResult.m_strctBootstrap.N;
M=strctPopulationResult.m_strctBootstrap.M;
for i=1:8
    subplot(1,8,i);
    hold on;
    for k=1:iNumOutcomes
        
        %         plot(0:N,(k-1)+squeeze(a4iCumHist(i,1,k,:)) / M,'color',a2fOutcomeColors(k,:),'Linestyle','-','LineWidth',2);
        %         plot(0:N,(k-1)+squeeze(a4iCumHist(i,2,k,:)) / M,'color',a2fOutcomeColors(k,:),'linestyle','--','LineWidth',2);
        %
        plot([0 N],0.5*(k-1)*ones(1,2),'k-');
        plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,1,k,:)) / M ,'color',a2fOutcomeColors(k,:),'Linestyle','-','LineWidth',2);
        plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,2,k,:)) / M ,'color',a2fOutcomeColors(k,:),'linestyle','--','LineWidth',2);
    end
    % title(strctPopulationResult.m_a2cTrialNames{i,1});
    axis([0 N 0 0.5*4]);
    set(gca,'ytick',1:4,'yticklabel',[]);
    set(gca,'xticklabel',[]);
    
end
set(gcf,'position',[789   976   843   117]);

dng = 1;

function aiSelectedSession = fnFindSession(strctPopulationResult, strFile)
if ~iscell(strFile)
    acFiles = {strFile};
else
    acFiles = strFile;
end
aiSelectedSession = zeros(1,length(acFiles));
for iIter=1:length(acFiles)
    for k=1:length(strctPopulationResult.m_acDataEntries)
        if (strcmpi(strctPopulationResult.m_acDataEntries{k}.m_strFile,acFiles{iIter}))
            aiSelectedSession(iIter)  = k;
            break;
        end;
    end
end;


function fnPrintPyschCurve(strctPopulationResult, strSelectedAnimal, iIgnoreContrast)
aiNumTrials =strctPopulationResult.m_aiNumCorrect+strctPopulationResult.m_aiNumIncorrect;
afPercentCorrect = strctPopulationResult.m_aiNumCorrect./(strctPopulationResult.m_aiNumCorrect+strctPopulationResult.m_aiNumIncorrect);

abSelectedAnimal= ismember(strctPopulationResult.m_acSubject,strSelectedAnimal);
aiSelectedSessions = find(abSelectedAnimal);
afPercentCorrectSelected=afPercentCorrect(aiSelectedSessions)
aiRelevantNumTrials= aiNumTrials(aiSelectedSessions)
[afUniqueContrasts, ~, aiMapping] = unique(strctPopulationResult.m_afContrast(aiSelectedSessions));

for k=1:length(afUniqueContrasts)
    aiInd = find(strctPopulationResult.m_afContrast(aiSelectedSessions) == afUniqueContrasts(k));
    aiNumTr(k) = sum(aiRelevantNumTrials(aiInd));
    aiNumCorrect(k) = sum(strctPopulationResult.m_aiNumCorrect(aiSelectedSessions(aiInd)));
    afAvgPerf(k) = mean(afPercentCorrectSelected(aiInd));
    afStdPerf(k) = std(afPercentCorrectSelected(aiInd ));
end
abLowContrast = afUniqueContrasts<255    & afUniqueContrasts ~= iIgnoreContrast;
%  dat = [[1:10]', afAvgPerf(abLowContrast)', aiNumTr(abLowContrast)'];

StimLevels = afUniqueContrasts(abLowContrast)/255*100;

options = PAL_minimize('options');
PF = @PAL_Logistic;
NumPos =aiNumCorrect(abLowContrast);
OutOfNum = aiNumTr(abLowContrast);

searchGrid.alpha =14:0.1:20;% [-1:.01:1];    %structure defining grid to
searchGrid.beta =0.5:0.1:1; %search for initial values
searchGrid.gamma = 0.25; % Fix chance level (!)
searchGrid.lambda = [0:.01:.06];
paramsFree = [1 1 1 1];

%Fit data:
paramsValues = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, ...
    searchGrid, paramsFree, PF,'lapseLimits',[0 1],'guessLimits',...
    [0.25 0.25], 'searchOptions',options)
%
%   paramsValues = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, ...
%       searchGrid, paramsFree, PF,'lapseLimits',[0 1],'guessLimits',...
%       [0 1], 'searchOptions',options)
x = 0:0.1:30;
%
clf;hold on;
plot(afUniqueContrasts(abLowContrast)/255*100, afAvgPerf(abLowContrast),'ko');
plot(x, PAL_Logistic(paramsValues,x),'b');
set(gca,'xlim',[5 25]);


%   plot(afUniqueContrasts(abLowContrast), afAvgPerf(abLowContrast),'b');
set(gca,'ylim',[0 1]);



% When x = 1/lambda, performance is at 72% (1-(1-g)/e)
plot([x(1) x(end)],[0.25 0.25],'k:');
set(gca,'ytick',0:0.25:1);
fprintf('Threshold Parameter : %.2f\n',paramsValues(1)/100*255);

set(gcf,'position',[1052        1011         188          87]);
return;



function acAngularStat= fnPrintOpticalInducedSaccadesPlot()
global g_strRootDrive
% strAboveSite = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120613\RAW\..\Processed\ElectricalMicrostim\Bert-13-Jun-2012_10-05-14_Microstim_Channel_1_Depth_29-05_Trig_Grass2.mat'];
% strOnSiteOptical = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120613\RAW\..\Processed\ElectricalMicrostim\Bert-13-Jun-2012_10-05-14_Microstim_Channel_1_Depth_30-00_Trig_Grass2.mat'];
% OnSiteElectrical = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120613\RAW\..\Processed\ElectricalMicrostim\Bert-13-Jun-2012_10-05-14_Microstim_Channel_1_Depth_30-50_Trig_Grass1.mat'];
% OnSiteElectricalAndOptical = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120613\RAW\..\Processed\ElectricalMicrostim\Bert-13-Jun-2012_10-05-14_Microstim_Channel_1_Depth_30-50_Trig_Grass1and2.mat'];
% 
% % strAboveSite = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-00_Trig_Grass2.mat'
% %
% % OnSiteOptical = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-60_Trig_Grass2.mat'
% 
% ;
% strctGrass2=load(strOnSiteOptical)
% a2fTrace=fnGetAvgTrace(strctGrass2);
%   figure(2);clf;    plot(-200:1000,a2fTrace(1:end,:)')
%
% [a2fTrace, a2fSEM]=fnGetAvgTrace(strctGrass2);
%   figure(3);clf;    plot(-200:1000,a2fTrace(1:end,:)'); hold on;
%   plot(-200:1000,a2fTrace+a2fSEM,'r');
%   plot(-200:1000,a2fTrace-a2fSEM,'r');
%
%
%     hist(afSaccadeAmp(~abJunk),0:2:30)
%
%     figure;plot(G')
%
%strOnSiteOptical=[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-90_Trig_Grass2.mat';
 strOnSiteOptical = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-60_Trig_Grass2.mat'];
fPIX_TO_VISUAL_ANGLE_OldRig = 28.8/800;

strctGrass2=load(strOnSiteOptical);
X2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fXpix);
Y2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fYpix);
fnPrintSaccadeAux(X2,Y2,15,0,15,16);
[fSaccadeDirection2, afDistToSaccadeDirection2,afAmplitude2,abValid2, afDirections2] = fnGetSaccadeDirection(X2,Y2,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);
figure(18);set(gca,'xticklabel',[])
figure(16);set(gca,'xticklabel',[])
fPerc200Cont = sum(afAmplitude2 > 1.9 & abValid2') / sum(abValid2 )*1e2;

% OnSiteOptical = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-40_Trig_Grass2.mat'
% strctGrass2=load(strOnSiteOptical)
% X2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fXpix);
% Y2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fYpix);
% fnPrintSaccadeAux(X2,Y2,15,220,15,16);
% [fSaccadeDirection2, afDistToSaccadeDirection2,afAmplitude2,abValid2, afDirections2] = fnGetSaccadeDirection(X2,Y2,50);

% figure;
% afDistToSaccadeDirection2(abValid2)

OnSiteElectrical = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-90_Trig_Grass1.mat'];
strctGrass1=load(OnSiteElectrical)
X1=cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_a2fXpix);
Y1=cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_a2fYpix);
fnPrintSaccadeAux(X1,Y1,50,0,15,16);
figure(53);set(gca,'xticklabel',[])
figure(51);set(gca,'xticklabel',[])

[fSaccadeDirection1, afDistToSaccade1,afAmplitude1,abValid1,afDirections1] = fnGetSaccadeDirection(X1,Y1,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);


abSuccessfulSaccades = find(afAmplitude1'>1.8 & abValid1) ;
[fAngularVar s] = circ_var(afDirections1(abSuccessfulSaccades));

[fMue, fKappa]=fnVonMisesFit(afDirections1(abSuccessfulSaccades));

acAngularStat = {fKappa, fAngularVar, X1(abSuccessfulSaccades,:), Y1(abSuccessfulSaccades,:)};
      

figure(500);
clf;
fnPrintSaccadeAux2(X2,Y2,'b',100:450)
fnPrintSaccadeAux2(X1,Y1,'k')

[pval, med, P] = circ_cmtest(afDirections2,afDirections1)
(circ_median(afDirections2)-circ_median(afDirections1))/pi*180


close all
strOnSiteOptical=[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-90_Trig_Grass2.mat'];
strctGrass2=load(strOnSiteOptical)
X2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fXpix);
Y2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fYpix);
fnPrintSaccadeAux(X2,Y2,90,0,15,16);
figure(93);set(gca,'xticklabel',[])
figure(91);set(gca,'xticklabel',[])

[~, ~,afAmplitude3,abValid3] = fnGetSaccadeDirection(X2,Y2,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);
fPerc80Hz= sum(afAmplitude3 > 1.9 & abValid3') / sum(abValid3 )*1e2;



strOnSiteOptical=[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-80_Trig_Grass2.mat'];
strctGrass2=load(strOnSiteOptical);
X2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fXpix);
Y2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fYpix);
fnPrintSaccadeAux(X2,Y2,120,0,15,16);
figure(123);set(gca,'xticklabel',[])
[~, ~,afAmplitude4,abValid4] = fnGetSaccadeDirection(X2,Y2,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);
fPerc50HzShort= sum(afAmplitude4 > 1.9 & abValid4') / sum(abValid4)*1e2;



strOnSiteOptical=[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120614\RAW\..\Processed\ElectricalMicrostim\Bert-14-Jun-2012_10-45-13_Microstim_Channel_1_Depth_30-70_Trig_Grass2.mat'];
strctGrass2=load(strOnSiteOptical);
X2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fXpix);
Y2=cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fYpix);
[~, ~,afAmplitude4,abValid4] = fnGetSaccadeDirection(X2,Y2,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);
fPerc50HzLong= sum(afAmplitude4 > 1.9 & abValid4') / sum(abValid4)*1e2;

figure(500);
clf;
bar(1:4,[fPerc200Cont,fPerc50HzLong, fPerc50HzShort, fPerc80Hz],'facecolor',[127 127 127]/255)
set(gca,'xlim',[0.5 4.5])
set(gca,'fontsize',7);
set(gca,'xticklabel',[])
set(gca,'ylim',[0 100])
% set(gca,1:4,'xticklabel',{'200ms, Continuous','200 ms, 50 Hz','100 ms 50 Hz','100 ms 80 Hz'})
% xticklabel_rotate

%% Varying laser intensities
close all
strctData = load('D:\Data\Doris\Electrophys\Bert\Optogenetics\120613\RAW\..\Processed\ElectricalMicrostim\Bert-13-Jun-2012_10-05-14_Microstim_Channel_1_Depth_30-00_Trig_Grass2.mat');


X1=cat(1,strctData.strctStimStat.m_astrctStimulation.m_a2fXpix);
Y1=cat(1,strctData.strctStimStat.m_astrctStimulation.m_a2fYpix);

[fSaccadeDirection1, afDistToSaccade1,afAmplitude1,abValid1,afDirections1] = fnGetSaccadeDirection(X1,Y1,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);

afAmplitudes = cat(1,strctData.strctStimStat.m_astrctStimulation.m_fAmplitude);
iNumAmplitudes = length(afAmplitudes);
fAngleThresholdDeg = 40;
afLaserDial = [0.6,  0.7, 0.8, 0.9, 1.0, 1.2, 1.6, 1.8];
afLasermW   = [1.9, 2.35, 2.4, 2.6, 3.0, 5.0, 8, 12];
afIntensitiesmW = interp1(afLaserDial,afLasermW,afAmplitudes);

afAmplitudesmW = [1.9, 2.4, 2.6, 3,4,5,6,8,12];
clear afPercSuccessful
figure(300);
clf;
hold on;
for k=1:iNumAmplitudes 
    X3=cat(1,strctData.strctStimStat.m_astrctStimulation(k).m_a2fXpix);
    Y3=cat(1,strctData.strctStimStat.m_astrctStimulation(k).m_a2fYpix);
   [fSaccadeDirection3, afDistToSaccade3,afAmplitude3,abValid3,afDirections3] = fnGetSaccadeDirection(X3,Y3,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);
   afDistanceToSaccadeAngleDeg = acos([cos(afDirections3)*cos(fSaccadeDirection1)+...
       sin(afDirections3)*sin(fSaccadeDirection1)] )/pi*180;

  afPercSuccessful(k) = sum( abValid3' & afAmplitude3>1.8 & afDistanceToSaccadeAngleDeg < 40)/sum(abValid3)*1e2;
    
    plot(X3(abValid3' & afAmplitude3 > 1.8 & afDistanceToSaccadeAngleDeg < 40,250:400)',...
        -Y3(abValid3' & afAmplitude3 > 1.8 & afDistanceToSaccadeAngleDeg < 40,250:400)','k');
end
figure(11);
clf;
plot(afIntensitiesmW,afPercSuccessful,'k','LineWidth',2)
set(gca,'xlim',[0 12])
set(gca,'xtick',[0 2 4 6 8 10 12]);
set(gca,'fontsize',7);
set(gcf,'position',[ 945        1021         192          77]);
box off
%% Same site, electrical
strctData = load('D:\Data\Doris\Electrophys\Bert\Optogenetics\120613\RAW\..\Processed\ElectricalMicrostim\Bert-13-Jun-2012_10-05-14_Microstim_Channel_1_Depth_30-50_Trig_Grass1.mat');
X1=cat(1,strctData.strctStimStat.m_astrctStimulation.m_a2fXpix);
Y1=cat(1,strctData.strctStimStat.m_astrctStimulation.m_a2fYpix);
[fSaccadeDirection1, afDistToSaccade1,afAmplitude1,abValid1,afDirections1] = fnGetSaccadeDirection(X1,Y1,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);

afAmplitudes = cat(1,strctData.strctStimStat.m_astrctStimulation.m_fAmplitude);
iNumAmplitudes = length(afAmplitudes);
figure(300);
clear afPercSuccessful
for k=1:iNumAmplitudes 
    X3=cat(1,strctData.strctStimStat.m_astrctStimulation(k).m_a2fXpix);
    Y3=cat(1,strctData.strctStimStat.m_astrctStimulation(k).m_a2fYpix);
   [fSaccadeDirection3, afDistToSaccade3,afAmplitude3,abValid3,afDirections3] = fnGetSaccadeDirection(X3,Y3,1.8,fPIX_TO_VISUAL_ANGLE_OldRig);
   afPercSuccessful(k) = sum(afAmplitude3(abValid3)>1.8)/sum(abValid3)*1e2;
    afDistanceToSaccadeAngleDeg = acos([cos(afDirections3)*cos(fSaccadeDirection1)+...
       sin(afDirections3)*sin(fSaccadeDirection1)] )/pi*180;

  afPercSuccessful(k) = sum( abValid3' & afAmplitude3>1.8 & afDistanceToSaccadeAngleDeg < 40)/sum(abValid3)*1e2;
    
    plot(X3(abValid3' & afAmplitude3 > 1.8 & afDistanceToSaccadeAngleDeg < 40,250:400)',...
        -Y3(abValid3' & afAmplitude3 > 1.8 & afDistanceToSaccadeAngleDeg < 40,250:400)','r');

end
figure(12);
clf;
plot(afAmplitudes,afPercSuccessful,'k','LineWidth',2);
set(gca,'xlim',[10 50],'ylim',[0 110]);
set(gca,'fontsize',7);
set(gcf,'position',[ 945        1021         192          77]);
box off


 afCurrents1=[10    20    25    30    40    50  ];
afPerc1=[0    6.2500   55.5556  100.0000  100.0000  100.0000];

afCurrents2=[10    15    18    20    25    40    50];
afPerc2=[   0   10.5263   27.2727   85.1852   91.6667  100.0000  100.0000];
   
afCurrents3=[  10.0000   20.0000   22.5000   25.0000   30.0000   40.0000   50.0000   ];
afPerc3=[      0   11.1111   23.0769   16.6667   72.0000  100.0000   90.0000];
      
hold on;
plot(afCurrents1,afPerc1,'--','color',[0.5 0.5 0.5]);
plot(afCurrents2,afPerc2,'--','color',[0.5 0.5 0.5]);
plot(afCurrents3,afPerc3,'--','color',[0.5 0.5 0.5]);

return;

function [a2fTrace, a2fTraceSEM]=fnGetAvgTrace(strctGrass2)

afAmplitude2 = cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_fAmplitude);
iNumAmplitudes = length(afAmplitude2);
a2fTrace = zeros(iNumAmplitudes, 1201);
for iAmpIter=1:iNumAmplitudes
    X=cat(1,strctGrass2.strctStimStat.m_astrctStimulation(iAmpIter).m_a2fXpix);
    Y=cat(1,strctGrass2.strctStimStat.m_astrctStimulation(iAmpIter).m_a2fYpix);
    G = sqrt(X.^2+Y.^2);
    fPIX_TO_VISUAL_ANGLE = 28.8/800;
    afSaccadeAmp = mean(G(:,350:400),2)* fPIX_TO_VISUAL_ANGLE;
    abJunk = afSaccadeAmp>  15 | afSaccadeAmp < 2;
    a2fTrace(iAmpIter,:) = median(G(~abJunk,:))*fPIX_TO_VISUAL_ANGLE;
    a2fTraceSEM = mad(G(~abJunk,:))*fPIX_TO_VISUAL_ANGLE/sqrt(sum(~abJunk));
end









function fnPrintSaccadeAux2(X,Y,afColor, aiPlotRange)
if ~exist('aiPlotRange','var')
    aiPlotRange = 200:500;
end;
% Sample at 100 ms post stimulation (typically, a good place...)
afMedianX = median(X,1);
afMedianY = median(Y,1);
a2fGaze = sqrt(X.^2+Y.^2);
afBaselineDist = max(a2fGaze(:,150:250)',[],1);

aiAmplitudeInterval = 360:410;
afAmplitude = mean(a2fGaze(:,aiAmplitudeInterval),2);

abNoBlink= max(a2fGaze,[],2)' < 1000;
abStableBaseline = afBaselineDist<60;
abValid = abStableBaseline & abNoBlink ;


abLargeAmplitude = afAmplitude > 50;
aiSamplingInterval = 200+[150:200];%380:400;% 200+[120:160]
afAvgX = mean(X(abValid(:) & abLargeAmplitude,aiSamplingInterval),2);
afAvgY = mean(Y(abValid(:) & abLargeAmplitude,aiSamplingInterval),2);
% Average angle ?

fPIX_TO_VISUAL_ANGLE = 28.8/800;
plot(X(abValid,aiPlotRange)',Y(abValid,aiPlotRange)','color',afColor);    hold on;
axis equal
axis([-400 400 -400 400]);
plot(0,0,'r+');
set(gca,'xtick',[],'ytick',[]);

return;







function fnPrintArchDuringMemorySaccadeTask()
global g_strRootDrive

% acDataEntries{1}.m_strFile =[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120814\RAW\..\Processed\BehaviorStats\Julien-14-Aug-2012_17-04-18_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];
% 
% acDataEntries{2}.m_strFile =[g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120814\\Processed\BehaviorStats\\Bert-14-Aug-2012_10-04-56_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];
% acDataEntries{3}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120813\\Processed\BehaviorStats\\Bert-13-Aug-2012_10-24-42_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];
% 
% acDataEntries{4}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120625\RAW\..\Processed\BehaviorStats\Bert-25-Jun-2012_10-54-48_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];
% acDataEntries{5}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\Processed\BehaviorStats\Bert-10-Jun-2012_11-17-17_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp8.mat'];
% acDataEntries{6}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120624\RAW\..\Processed\BehaviorStats\Bert-24-Jun-2012_11-47-33_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];
% acDataEntries{7}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\BehaviorStats\Julien-26-May-2012_11-24-30_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];  % arch
% acDataEntries{8}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120625\RAW\..\Processed\BehaviorStats\Julien-25-Jun-2012_17-26-36_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];



acDataEntries{1}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\BehaviorStats\Julien-26-May-2012_11-24-30_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];
acDataEntries{2}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120625\RAW\..\Processed\BehaviorStats\Julien-25-Jun-2012_17-26-36_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];
acDataEntries{3}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120814\RAW\..\Processed\BehaviorStats\Julien-14-Aug-2012_17-04-18_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];
acDataEntries{4}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120815\RAW\..\Processed\BehaviorStats\Julien-15-Aug-2012_16-38-59_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'];

acDataEntries{5}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\BehaviorStats\Bert-10-Jun-2012_11-17-17_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp8.mat'];
%acDataEntries{6}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\BehaviorStats\Bert-10-Jun-2012_11-17-17_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];

acDataEntries{6}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120624\RAW\..\Processed\BehaviorStats\Bert-24-Jun-2012_11-47-33_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];
acDataEntries{7}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120625\RAW\..\Processed\BehaviorStats\Bert-25-Jun-2012_10-54-48_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];

acDataEntries{8}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120813\RAW\..\Processed\BehaviorStats\Bert-13-Aug-2012_10-24-42_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];
acDataEntries{9}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120814\RAW\..\Processed\BehaviorStats\Bert-14-Aug-2012_10-04-56_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];
acDataEntries{10}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120815\RAW\..\Processed\BehaviorStats\Bert-15-Aug-2012_12-34-14_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp9.mat'];



acDataEntries{11}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\121125\RAW\..\Processed\BehaviorStats\Bert-25-Nov-2012_15-56-42_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp15.mat'];
acDataEntries{12}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\121127\RAW\..\Processed\BehaviorStats\Bert-27-Nov-2012_10-37-43_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp15.mat'];


% acDataEntries{3}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120601\RAW\..\Processed\BehaviorStats\Julien-01-Jun-2012_15-57-08_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat'; % control
% acDataEntries{4}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\BehaviorStats\Julien-19-Jun-2012_12-19-15_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp29.mat'; % electrical
acDataEntryChR2{1}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120516\RAW\..\Processed\BehaviorStats\Julien-16-May-2012_10-23-37_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp21.mat']; % Chr2

acDataEntryChR2{2}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\121124\RAW\..\Processed\BehaviorStats\Bert-24-Nov-2012_10-22-44_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp11.mat']; % Chr2
acDataEntryChR2{3}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\121125\RAW\..\Processed\BehaviorStats\Bert-25-Nov-2012_10-04-37_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp14.mat']; % Chr2
acDataEntryChR2{4}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\121126\RAW\..\Processed\BehaviorStats\Bert-26-Nov-2012_09-33-43_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp15.mat'];


% acDataEntries{6}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120607\RAW\..\Processed\BehaviorStats\Bert-07-Jun-2012_15-51-42_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskBert_Exp8.mat'; % ChR2
% acDataEntries{8}.m_strFile = [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120624\RAW\..\Processed\BehaviorStats\Julien-24-Jun-2012_19-05-02_TouchForceChoice_BehaviorStat_SaccadeMemoryTaskJulien_Exp27.mat';
fnAnalyzeIncorrectTrials(acDataEntries);
fnOpticalStimulationBehaviorPopulationAnalysis(acDataEntries)













fnAnalyzeCorrectTrials(acDataEntries);

fnAnalyzeAbortedTrials(acDataEntryChR2)










A=1e2*strctPopulationResult.m_a3fNumTrialsNoStim(:,:,1)./ repmat(sum(strctPopulationResult.m_a3fNumTrialsNoStim(:,:,1),2),1,4);
B=1e2*strctPopulationResult.m_a3fNumTrialsStim(:,:,1) ./ repmat(sum(strctPopulationResult.m_a3fNumTrialsStim(:,:,1),2),1,4);
fprintf('Julien perofrmance for go right:\n');
fprintf('Correct (No stim: %.2f -> Stim: %.2f\n',A(1,2),B(1,2))
fprintf('Incorrect (No stim: %.2f -> Stim: %.2f\n',A(1,3),B(1,3))
fprintf('Timeout (No stim: %.2f -> Stim: %.2f\n',A(1,4),B(1,4))


A=1e2*strctPopulationResult.m_a3fNumTrialsNoStim(:,:,2)./ repmat(sum(strctPopulationResult.m_a3fNumTrialsNoStim(:,:,2),2),1,4);
B=1e2*strctPopulationResult.m_a3fNumTrialsStim(:,:,2) ./ repmat(sum(strctPopulationResult.m_a3fNumTrialsStim(:,:,2),2),1,4);

fprintf('Bert perofrmance for go down right:\n');
fprintf('Correct (No stim: %.2f -> Stim: %.2f\n',A(6,2),B(6,2))
fprintf('Incorrect (No stim: %.2f -> Stim: %.2f\n',A(6,3),B(6,3))
fprintf('Timeout (No stim: %.2f -> Stim: %.2f\n',A(6,4),B(6,4))



figure(100);clf;hold on;
for k=1:length( strctPopulationResult.m_a2cErrorTrialsStim{1,1})
    plot(strctPopulationResult.m_a2cErrorTrialsStim{1,1}{k}(:,1),-strctPopulationResult.m_a2cErrorTrialsStim{1,1}{k}(:,2),'k');
end
axis equal
axis([-400 400 -400 400]);
box on
set(gca,'xtick',[],'ytick',[])
plot(0,0,'r+');
set(gcf,'position',[ 1066         409         128          94]);



figure(101);clf;hold on;
for k=1:length( strctPopulationResult.m_a2cErrorTrialsStim{2,6})
    plot(strctPopulationResult.m_a2cErrorTrialsStim{2,6}{k}(:,1),-strctPopulationResult.m_a2cErrorTrialsStim{2,6}{k}(:,2),'k');
end
axis equal
axis([-400 400 -400 400]);
box on
set(gca,'xtick',[],'ytick',[])
plot(0,0,'r+');
set(gcf,'position',[ 1066        409         128          94]);




strctJulienSaccade = load([g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\ElectricalMicrostim\Julien-26-May-2012_11-24-30_Microstim_Channel_1_Depth_31-24_Trig_Grass1.mat']);
X=strctJulienSaccade.strctStimStat.m_astrctStimulation(2).m_a2fXpix;
Y=strctJulienSaccade.strctStimStat.m_astrctStimulation(2).m_a2fYpix;
fnPrintSaccadeAux(X,Y,30,800,40,40,800);

strctBertSaccade = load([g_strRootDrive,':\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\ElectricalMicrostim\Bert-10-Jun-2012_11-17-17_Microstim_Channel_1_Depth_29-17_Trig_Grass1.mat']);

X=strctBertSaccade.strctStimStat.m_astrctStimulation(5).m_a2fXpix;
Y=strctBertSaccade.strctStimStat.m_astrctStimulation(5).m_a2fYpix;
fnPrintSaccadeAux(X,Y,30,800,40,40,800);







function fnPrintArchDuringMemorySaccadeTaskAux(strctBert)
N=20;
a2fOutcomeColors = [79,129,189;0,176,80;192,80,77;247,150,70]/255;
iNumOutcomes=4;
N=strctPopulationResult.m_strctBootstrap.N;
M=strctPopulationResult.m_strctBootstrap.M;
for i=1:8
    subplot(1,8,i);
    hold on;
    for k=1:iNumOutcomes
        
        %         plot(0:N,(k-1)+squeeze(a4iCumHist(i,1,k,:)) / M,'color',a2fOutcomeColors(k,:),'Linestyle','-','LineWidth',2);
        %         plot(0:N,(k-1)+squeeze(a4iCumHist(i,2,k,:)) / M,'color',a2fOutcomeColors(k,:),'linestyle','--','LineWidth',2);
        %
        plot([0 N],0.5*(k-1)*ones(1,2),'k-');
        plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,1,k,:)) / M ,'color',a2fOutcomeColors(k,:),'Linestyle','-','LineWidth',2);
        plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,2,k,:)) / M ,'color',a2fOutcomeColors(k,:),'linestyle','--','LineWidth',2);
    end
    % title(strctPopulationResult.m_a2cTrialNames{i,1});
    axis([0 N 0 0.5*4]);
    set(gca,'ytick',1:4,'yticklabel',[]);
    set(gca,'xticklabel',[]);
    
end
set(gcf,'position',[789   976   843   117]);










%%



function acAngularStat = fnPrintNoIncreaseInSaccadeProbabilityForControls()
global g_strRootDrive
acSessionDataFiles = {...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_30-60_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_30-60_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_30-60_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_30-98_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_30-98_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_30-98_Trig_Grass2.mat']},...
    {[g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_31-20_Trig_Grass1.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_31-20_Trig_Grass1and2.mat'],...
    [g_strRootDrive,':\Data\Doris\Electrophys\Julien\Optogenetics\120619\RAW\..\Processed\ElectricalMicrostim\Julien-19-Jun-2012_12-19-15_Microstim_Channel_1_Depth_31-20_Trig_Grass2.mat']}};

iNumSessions = length(acSessionDataFiles);

% Now, plot population statistics.....
fAngleThresholdDeg=40;
fPIX_TO_VISUAL_ANGLE = 28.8/800;
fAmplitudeThreshold = 1.8/fPIX_TO_VISUAL_ANGLE; % 1.8
acAngularStat=cell(0);
for iSessionIter=1:iNumSessions
    bMonkeyJ = strncmpi(acSessionDataFiles{iSessionIter}{1},[g_strRootDrive,':\Data\Doris\Electrophys\Julien\'],33);
    
    strctGrass1 = load(acSessionDataFiles{iSessionIter}{1});
    strctGrass1and2 = load(acSessionDataFiles{iSessionIter}{2});
    strctGrass2 = load(acSessionDataFiles{iSessionIter}{3});
    
    afCurrentAmplitude1 = cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_fAmplitude);
    afCurrentAmplitude1and2 = cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation.m_fAmplitude);
    afOverlappingAmplitudes = intersect(afCurrentAmplitude1,afCurrentAmplitude1and2);
    afPercentSaccadesOnlyElectrical = zeros(1, length(afOverlappingAmplitudes));
    afPercentSaccadesElectricalandOptical = zeros(1, length(afOverlappingAmplitudes));
    afMeanSaccadeAmplitudeElectrical = zeros(1,  length(afOverlappingAmplitudes));
    afMeanSaccadeAmplitudeOpticalAndElectrical = zeros(1,  length(afOverlappingAmplitudes));
    afSigAmplitudeDifference = zeros(1,  length(afOverlappingAmplitudes));
    afBinomialTestResult = NaN*ones(1,  length(afOverlappingAmplitudes));
    aiNumElectricalTrials = zeros(1,  length(afOverlappingAmplitudes));
    aiNumBothTrials= zeros(1,  length(afOverlappingAmplitudes));
    
    afSigDirection = NaN*ones(1,  length(afOverlappingAmplitudes));
    afMedianDirection1 = NaN*ones(1,  length(afOverlappingAmplitudes));
    afMedianDirection1and2 = NaN*ones(1,  length(afOverlappingAmplitudes));
    
    
    a2fX=cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_a2fXpix);
    a2fY=cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_a2fYpix);
    [fSaccadeDirection, afDistToSaccade,afAmplitude,abValid,afDirectionsAll,afSaccadeLatencyAllMS, fMeanBaselinePix,fStdBaselinePix] = fnGetSaccadeDirection(a2fX,a2fY,fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
  
      abSuccessfulSaccades = find(afAmplitude'>1.8 & abValid) ;
      %fDirection = circ_mean(afDirections1(abSuccessfulSaccades));
      [S s] = circ_var(afDirectionsAll(abSuccessfulSaccades));
      [fMue, fKappa]=fnVonMisesFit(afDirectionsAll(abSuccessfulSaccades));
      
      acAngularStat{end+1} = {fKappa,S, a2fX(abSuccessfulSaccades,:), a2fY(abSuccessfulSaccades,:)};
    
    
    
    for iAmplitudeIter=1:length(afOverlappingAmplitudes)
        fAmplitude = afOverlappingAmplitudes(iAmplitudeIter);
        iIndex1 = find(afCurrentAmplitude1 == fAmplitude );
        iIndex2 = find(afCurrentAmplitude1and2 == fAmplitude );
        
        N = size(strctGrass1.strctStimStat.m_astrctStimulation(iIndex1).m_a2fXpix,1);
        % Find number of induced saccades
        a2fX_All=[strctGrass1.strctStimStat.m_astrctStimulation(iIndex1).m_a2fXpix
            strctGrass1and2.strctStimStat.m_astrctStimulation(iIndex2).m_a2fXpix];
        a2fY_All=[strctGrass1.strctStimStat.m_astrctStimulation(iIndex1).m_a2fYpix
            strctGrass1and2.strctStimStat.m_astrctStimulation(iIndex2).m_a2fYpix];
        
        [fSaccadeDirection, afDistToSaccade,afAmplitude,abValid,afDirections_All] = fnGetSaccadeDirection(a2fX_All,a2fY_All,fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
        afDist1 = afDistToSaccade(1:N);
        afDist1and2 = afDistToSaccade(N+1:end);
        abValid1 = abValid(1:N);
        afDirections1 = afDirections_All(1:N);
        
        afAmplitude1 = afAmplitude(1:N);
        afAmplitude1and2 = afAmplitude(N+1:end);
        abValid1and2 = abValid(N+1:end);
        afDirections1and2 = afDirections_All(N+1:end);
        
        % Count number of correct saccades....
        %            afMeanSaccadeAmplitudeElectrical(iAmplitudeIter) = mean(afAmplitude1(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1' > fAmplitudeThreshold));
        %          afMeanSaccadeAmplitudeOpticalAndElectrical(iAmplitudeIter) = mean(afAmplitude1and2(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2' > fAmplitudeThreshold));
        %            afStdSaccadeAmplitudeElectrical(iAmplitudeIter) = std(afAmplitude1(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1' > fAmplitudeThreshold))/sqrt(sum(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1' > fAmplitudeThreshold));
        %          afStdSaccadeAmplitudeOpticalAndElectrical(iAmplitudeIter) = std(afAmplitude1and2(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2' > fAmplitudeThreshold)) / sqrt(sum(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2' > fAmplitudeThreshold));
        %
        
        
        afAmplitudeElectricalValid = afAmplitude1(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1> fAmplitudeThreshold);
        afAmplitudeBothValid = afAmplitude1and2(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold);
        afDirections1Valid = afDirections1(abValid1' & afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold);
        afDirections1and2Valid = afDirections1and2(abValid1and2' &afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold);
        
        if ~isempty(afDirections1Valid) && ~isempty(afDirections1and2Valid)
            afMedianDirection1(iAmplitudeIter) = circ_median(afDirections1Valid);
            afMedianDirection1and2(iAmplitudeIter) = circ_median(afDirections1and2Valid);
            afSigDirection(iAmplitudeIter) = circ_cmtest(afDirections1Valid,afDirections1and2Valid);
        end
        
        afMeanSaccadeAmplitudeElectrical(iAmplitudeIter) = mean(afAmplitudeElectricalValid);
        afMeanSaccadeAmplitudeOpticalAndElectrical(iAmplitudeIter) = mean(afAmplitudeBothValid);
        if isempty(afAmplitudeElectricalValid) || isempty(afAmplitudeBothValid)
            afSigAmplitudeDifference(iAmplitudeIter) = 1;
        else
            afSigAmplitudeDifference(iAmplitudeIter) = ranksum(afAmplitudeElectricalValid, afAmplitudeBothValid);
        end
        
        
        
        
        afPercentSaccadesOnlyElectrical(iAmplitudeIter) = sum(abValid1' &  afDist1 < fAngleThresholdDeg & afAmplitude1 > fAmplitudeThreshold) / length(afDist1)*100;
        afPercentSaccadesElectricalandOptical(iAmplitudeIter) = sum(abValid1and2' &  afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold) / length(afDist1and2)*100;
        
        % Do a binomial test .
        % Assume probability of a saccade using electrical is known
        % ...and estimate the probability of seeing the number of
        % saccades in the joint case.
        iNumSaccadesBoth = sum( afDist1and2 < fAngleThresholdDeg & afAmplitude1and2 > fAmplitudeThreshold);
        iNumTrials = length(afDist1and2);
        if afPercentSaccadesOnlyElectrical(iAmplitudeIter) > 0
            fProbSaccade = afPercentSaccadesOnlyElectrical(iAmplitudeIter)/100;
            afBinomialTestResult(iAmplitudeIter)=fnMyBinomTest(iNumSaccadesBoth,iNumTrials,fProbSaccade,'Two') ;
            
        end
        aiNumElectricalTrials(iAmplitudeIter) =  length(afDist1);
        aiNumBothTrials(iAmplitudeIter) =  length(afDist1and2);
        
        
    end
    
    % Now compute statistics for optical only...
    
    a2fX_All=[cat(1,strctGrass1.strctStimStat.m_astrctStimulation.m_a2fXpix)
        cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation.m_a2fXpix)];
    a2fY_All=[cat(1,strctGrass1.strctStimStat.m_astrctStimulation(:).m_a2fYpix)
        cat(1,strctGrass1and2.strctStimStat.m_astrctStimulation(:).m_a2fYpix)];
    [fSaccadeDirection, afDistToSaccade,afAmplitude,abValid] = fnGetSaccadeDirection(a2fX_All,a2fY_All,fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
    
    
    [afDistanceToSaccadeAngleDeg, afAmplitudeOnly2] = fnGetSaccadesInSpecificDirection(...
        cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fXpix),...
        cat(1,strctGrass2.strctStimStat.m_astrctStimulation.m_a2fYpix), fSaccadeDirection, fAmplitudeThreshold,fPIX_TO_VISUAL_ANGLE);
    
    
    
    astrctSessionStat(iSessionIter).m_afBinomialTestResult=afBinomialTestResult;
    astrctSessionStat(iSessionIter).m_afCurrents = afOverlappingAmplitudes;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectrical = afPercentSaccadesOnlyElectrical;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOptical = afPercentSaccadesElectricalandOptical;
    
    astrctSessionStat(iSessionIter).m_afSigAmplitudeDifference= afSigAmplitudeDifference;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOptical = sum(afDistanceToSaccadeAngleDeg < fAngleThresholdDeg & afAmplitudeOnly2 > fAmplitudeThreshold) / length(afAmplitudeOnly2)*100;
    
    astrctSessionStat(iSessionIter).m_afMeanSaccadeAmplitudeElectrical = afMeanSaccadeAmplitudeElectrical;
    astrctSessionStat(iSessionIter).m_afMeanSaccadeAmplitudeOpticalAndElectrical = afMeanSaccadeAmplitudeOpticalAndElectrical;
    
    
    
    astrctSessionStat(iSessionIter).m_afSigDirection = afSigDirection;
    astrctSessionStat(iSessionIter).m_afMedianDirection1 = afMedianDirection1;
    astrctSessionStat(iSessionIter).m_afMedianDirection1and2 = afMedianDirection1and2;
    
    %     astrctSessionStat(iSessionIter).m_afSEMSaccadeAmplitudeElectrical = afStdSaccadeAmplitudeElectrical;
    %     astrctSessionStat(iSessionIter).m_afSEMSaccadeAmplitudeOpticalAndElectrical = afStdSaccadeAmplitudeOpticalAndElectrical;
    
    astrctSessionStat(iSessionIter).m_abMonkeyJ = bMonkeyJ * ones(1,length(afOverlappingAmplitudes))>0;
    
    astrctSessionStat(iSessionIter).m_afCurrents = afOverlappingAmplitudes;
    astrctSessionStat(iSessionIter).m_afCurrentsNormalized = linspace(0, 1,length(afOverlappingAmplitudes));
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectrical = afPercentSaccadesOnlyElectrical;
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOptical = afPercentSaccadesElectricalandOptical;
    
    
    astrctSessionStat(iSessionIter).m_afPercentSaccadesOnlyElectricalInterp = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesOnlyElectrical, 0:0.1:1);
    astrctSessionStat(iSessionIter).m_afPercentSaccadesElectricalandOpticalInterp = interp1(astrctSessionStat(iSessionIter).m_afCurrentsNormalized, afPercentSaccadesElectricalandOptical,0:0.1:1);
    
end
abMonkeyJ = cat(2,astrctSessionStat.m_abMonkeyJ);

fThresP=0.01;
%
% abSigDir = ~isnan(cat(2,astrctSessionStat.m_afSigDirection) ) &  cat(2,astrctSessionStat.m_afSigDirection) <  fThresP;
% % plot difference in directions?
% afDirectionElec =     cat(2,astrctSessionStat.m_afMedianDirection1)/pi*180;
% afDirectionBoth =     cat(2,astrctSessionStat.m_afMedianDirection1and2 )/pi*180;
% signtest(afDirectionElec,afDirectionBoth)
% figure(500);
% clf;hold on;
% plot([-180 180],[-180 180],'k--');
% plot(afDirectionElec(~abSigDir),afDirectionBoth(~abSigDir),'.','color',[0.5 0.5 0.5]);
% plot(afDirectionElec(abSigDir),afDirectionBoth(abSigDir),'k.');
% set(gca,'xtick',-180:60:180,'ytick',-180:60:180);
% axis([-180 180 -180 180]);
%   set(gcf,'position',[1033 925 207 173])
% mean(abs(afDirectionBoth(abSigDir)-afDirectionElec(abSigDir)))
% std(abs(afDirectionBoth(abSigDir)-afDirectionElec(abSigDir)))
%
% fThresP=0.01;
% % Plot population ?
% afAmp1 = cat(2,astrctSessionStat.m_afMeanSaccadeAmplitudeElectrical);
% afAmp12 = cat(2,astrctSessionStat.m_afMeanSaccadeAmplitudeOpticalAndElectrical);
% abAmpNotNan = ~isnan(afAmp1) & ~isnan(afAmp12)
% [p,h,stat]=signtest(afAmp1(abAmpNotNan), afAmp12(abAmpNotNan))
%
% afSigAmplitude = cat(2,astrctSessionStat.m_afSigAmplitudeDifference )
% figure(5);
% clf;hold on;
%
% plot(fPIX_TO_VISUAL_ANGLE*afAmp1(afSigAmplitude<fThresP),fPIX_TO_VISUAL_ANGLE*afAmp12(afSigAmplitude<fThresP),'k.');
% plot(fPIX_TO_VISUAL_ANGLE*afAmp1(afSigAmplitude<fThresP),fPIX_TO_VISUAL_ANGLE*afAmp12(afSigAmplitude<fThresP),'ko');
% plot(fPIX_TO_VISUAL_ANGLE*afAmp1(afSigAmplitude>fThresP),fPIX_TO_VISUAL_ANGLE*afAmp12(afSigAmplitude>fThresP),'.','color',[0.5 0.5 0.5]);
% plot([0 25],[0 25],'k--');
% axis([0 25 0 25]);
% set(gca,'xtick',0:5:25,'ytick',0:5:25)
%   set(gcf,'position',[1033 925 207 173])


afAmp1 = cat(2,astrctSessionStat.m_afMeanSaccadeAmplitudeElectrical);
afAmp12 = cat(2,astrctSessionStat.m_afMeanSaccadeAmplitudeOpticalAndElectrical);
abAmpNotNan = ~isnan(afAmp1) & ~isnan(afAmp12)
[p,h,stat]=signtest(afAmp1(abAmpNotNan), afAmp12(abAmpNotNan))

% Pool across all currents and use a sign test
afPercElectrical = cat(2, astrctSessionStat.m_afPercentSaccadesOnlyElectrical);
afPercBoth= cat(2,astrctSessionStat.m_afPercentSaccadesElectricalandOptical );
[p,h,stat]= signtest(afPercBoth,afPercElectrical);
fprintf('Pooling across all currents, sign test shows significance of %.10f\n',p);

afPValue = cat(2,astrctSessionStat.m_afBinomialTestResult);

figure(300);clf;hold on;
fThresP=0.01;

plot(afPercElectrical(afPValue<fThresP),afPercBoth(afPValue<fThresP),'k.');
plot(afPercElectrical(afPValue>fThresP),afPercBoth(afPValue>fThresP),'.','color',[0.5 0.5 0.5]);
plot([0 100],[0 100],'k--');
set(gca,'xtick',[0:25:100],'ytick',0:25:100);
set(gcf,'position',[1033 925 207 173])
%%
fprintf('%d out of %d sessions were significant in Julien\n',  sum(abMonkeyJ(afPValue<fThresP)), sum(abMonkeyJ));
fprintf('%d out of %d sessions were significant in Julien\n',  sum(~abMonkeyJ(afPValue<fThresP)), sum(~abMonkeyJ));
set(gca,'fontsize',7)
%%
afMeanElectrical = mean(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterp),1);
afSEMElectrical = std(cat(1,astrctSessionStat.m_afPercentSaccadesOnlyElectricalInterp),1);
afMeanBoth =  mean(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterp),1);
afSEMBoth=  std(cat(1,astrctSessionStat.m_afPercentSaccadesElectricalandOpticalInterp),1);
figure(121);clf;hold on;
afNormalizedCurrent = 0:0.1:1;
W=0.01;
plot(afNormalizedCurrent,afMeanElectrical,'k');
plot(afNormalizedCurrent,afMeanBoth,'b');

for k=1:length(afNormalizedCurrent)
    plot(afNormalizedCurrent(k),afMeanBoth(k),'bS');
    plot(afNormalizedCurrent(k),afMeanElectrical(k),'kS');
    
    plot(afNormalizedCurrent(k)+[-W W],[afMeanBoth(k)-afSEMBoth(k)]*ones(1,2),'b');
    plot(afNormalizedCurrent(k)+[-W W],[afMeanElectrical(k)-afSEMElectrical(k)]*ones(1,2),'k');
    
    plot(afNormalizedCurrent(k)+[-W W],[afMeanBoth(k)+afSEMBoth(k)]*ones(1,2),'b');
    plot(afNormalizedCurrent(k)+[-W W],[afMeanElectrical(k)+afSEMElectrical(k)]*ones(1,2),'k');
    
    plot(afNormalizedCurrent(k)*ones(1,2),[afMeanBoth(k)-afSEMBoth(k),afMeanBoth(k)+afSEMBoth(k)],'b');
    plot(afNormalizedCurrent(k)*ones(1,2),[afMeanElectrical(k)-afSEMElectrical(k),afMeanElectrical(k)+afSEMElectrical(k)],'k');
end
axis([0 1 0 80]);

plot([0 1],ones(1,2)*mean(cat(1,astrctSessionStat.m_afPercentSaccadesOptical)),'r');
plot([0 1],ones(1,2)*mean(cat(1,astrctSessionStat.m_afPercentSaccadesOptical)),'r');
std(cat(1,astrctSessionStat.m_afPercentSaccadesOptical))

set(gcf,'position',[   680   979   320   119]);
return


function fnGenerateLFPPlot(strPopulationFile, afColor, fTrainLengthMS, fRange)
strctTmp = load(strPopulationFile);
strctPopulationOpticalStim = strctTmp.strctPopulationOpticalStim;
aiEvents  =  find(    abs(strctPopulationOpticalStim.m_afTrainLengthMS-fTrainLengthMS) < 20);
    
iNumSessions = length(aiEvents)
fPreviousDepth = 0;
aiSessionSubset = [];
for k=1:iNumSessions
    if    strctPopulationOpticalStim.m_afRecordingDepth(aiEvents(k)) == fPreviousDepth
        continue;
    end
    aiSessionSubset = [aiSessionSubset,aiEvents(k)];
    fPreviousDepth= strctPopulationOpticalStim.m_afRecordingDepth(aiEvents(k));
end

iNumSessionsSubset = length(aiSessionSubset);
fprintf('%d Recording session for LFP averaging: \n',iNumSessionsSubset);
a2fData = zeros(iNumSessionsSubset,2001);
for k=1:iNumSessionsSubset
    iSession = aiSessionSubset(k);
    fprintf('Loading %s \n',strctPopulationOpticalStim.m_acDataEntries{iSession}.m_strFile);
    a2fData(k,:)=interp1(strctPopulationOpticalStim.m_acLFP_TS{iSession},strctPopulationOpticalStim.m_acLFP{iSession}, -500:1500);
end
afMeanLFP = mean(a2fData,1);
afSEM = std(a2fData,[],1)/sqrt(iNumSessionsSubset);
figure;clf; hold on;
plot(-500:1500,afMeanLFP,'color',afColor,'LineWidth',2)
plot(-500:1500,afMeanLFP+afSEM,'k--')
plot(-500:1500,afMeanLFP-afSEM,'k--')
axis([-500 1500 -fRange fRange]);
set(gcf,'position',[ 1045         947         195         151]);
return;

%%

function fnPrintIncreaseInSaccadeLatency(strFile, iTrialIndexToPlot)
a2cCompareTrials = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};

strctTmp = load(strFile); 
afLatencyMS = 1e3*(cat(1,strctTmp.strctDesignStat.m_astrctTrialsPostProc.m_fSaccadeTSPlexon) - cat(1,strctTmp.strctDesignStat.m_astrctTrialsPostProc.m_fChoiceOnsetTSPlexon));

iOutcomeCorrect = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Correct'));
for iTrialIter=1:size(a2cCompareTrials,1)
    fprintf('Comparing %s vs %s\n',a2cCompareTrials{iTrialIter,1},a2cCompareTrials{iTrialIter,2});
    iNoStimTrial = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cCompareTrials{iTrialIter,1})));
    iStimTrial = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cCompareTrials{iTrialIter,2})));
    
    abTrialsNoStim = strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iNoStimTrial;
    abTrialsStim = strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iStimTrial;
    abCorrectTrials = strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iOutcomeCorrect;
    
    fprintf('Mean No Stim: %.2f +- %2f\n',   mean(afLatencyMS(abTrialsNoStim & abCorrectTrials)), std(afLatencyMS(abTrialsNoStim & abCorrectTrials)));
    fprintf('Mean Stim : %.2f +- %2f\n',    mean(afLatencyMS(abTrialsStim & abCorrectTrials)), std(afLatencyMS(abTrialsStim & abCorrectTrials)));
%  
% 
    
    [h,p2]=kstest2(afLatencyMS(abTrialsNoStim & abCorrectTrials),  afLatencyMS(abTrialsStim & abCorrectTrials));
    
    p1=ranksum(afLatencyMS(abTrialsNoStim & abCorrectTrials),  afLatencyMS(abTrialsStim & abCorrectTrials));
%    p2=signtest(afLatencyMS(abTrialsNoStim & abCorrectTrials),  afLatencyMS(abTrialsNoStimMicroStim & abCorrectTrials));
    fprintf('pvalue for latency difference: %.3f %.2f \n',p1,p2);
    if iTrialIter == iTrialIndexToPlot
        
        afCent = 0:20:500;
        afHistNoStim = histc(afLatencyMS(abTrialsNoStim & abCorrectTrials), afCent);
        afHistStim = histc(afLatencyMS(abTrialsStim & abCorrectTrials), afCent);
        afCumNoStim = cumsum(afHistNoStim) /sum(afHistNoStim);
        afCumStim = cumsum(afHistStim) /sum(afHistStim);
        figure(2);
        clf;hold on;
        plot(afCent, afCumNoStim,'k');
        plot(afCent, afCumStim,'r');
        set(gcf,'position',[  947        1002         293          96]);
     figure(3);
        clf;hold on;
        plot(afCent, afHistNoStim/sum(afHistNoStim),'k');
        plot(afCent, afHistStim/sum(afHistStim),'r');
         set(gcf,'position',[  947        1002         293          96]);
       
    end
    
end





function [S,N]=fnPrintSaccadeAux3(X,Y,fRange2)
% Sample at 100 ms post stimulation (typically, a good place...)
a2fGaze = sqrt(X.^2+Y.^2);
afBaselineDist = max(a2fGaze(:,150:250)',[],1);
aiAmplitudeInterval = 360:410;
afAmplitude = mean(a2fGaze(:,aiAmplitudeInterval),2);
abNoBlink= max(a2fGaze,[],2)' < 1000;
abStableBaseline = afBaselineDist<60;
abValid = abStableBaseline & abNoBlink ;

abLargeAmplitude = afAmplitude > 50;

aiSamplingInterval = 200+[150:200];%380:400;% 200+[120:160]
afAvgX = mean(X(abValid' & abLargeAmplitude,aiSamplingInterval),2);
afAvgY = mean(Y(abValid' & abLargeAmplitude,aiSamplingInterval),2);
% Average angle ?
afAvgAngle = atan2(afAvgY,afAvgX);
N=sum(abValid' & abLargeAmplitude);
[S]=circ_var(afAvgAngle);
fPIX_TO_VISUAL_ANGLE = 28.8/800;

plot(X(abValid,200:400)',Y(abValid,200:400)','k');    hold on;
axis equal
axis([-fRange2 fRange2 -fRange2 fRange2]);
plot(0,0,'r+');
set(gca,'xtick',[],'ytick',[]);
return;