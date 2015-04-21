%%
 a2cTrialNames = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};

iOffset = 1000;
a2fTargetCenter = [200 0;
                   -200 0;
                   0 -200;
                   0 200;
                   140 -140;
                   140 140;
                   -140 -140;
                   -140 140];
a2fTargetCenterDir=a2fTargetCenter./ repmat(sqrt(sum(a2fTargetCenter.^2,2)),1,2);
           aiOrder = [1,5,3,7,2,8,4,6,1];
    
iNumTrialTypes = size(a2cTrialNames,1);

%% First, plot Julien's sessions
% Plot a single example
strDataFile = 'D:\Data\Doris\Electrophys\Julien\Optogenetics\120814\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120814_170400_TouchForceChoiceNeuralStat_Channel_1_Interval_12_SaccadeMemoryTaskJulien_Exp27.mat';
strctTmp = load(strDataFile);
iCorrectIndex = find(ismember(strctTmp.strctUnit.m_acUniqueOutcomes,'Correct'));
aiTrialTypeNoStim=zeros(1,iNumTrialTypes);
aiTrialTypeStim = zeros(1,iNumTrialTypes);
for iTrialTypeIter=1:iNumTrialTypes
    aiTrialTypeNoStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,1})));
    aiTrialTypeStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,2})));
end
    
acIntervals = { iOffset+[-50:30]};
[a2fResBinNormSac, a2fStimResBinNormSac, a2fPValueSac,a2fResBinSac, a2fStimResBinSac]=fnExtractsCircularBinStats2(aiTrialTypeNoStim, aiTrialTypeStim, iCorrectIndex, strctTmp.strctUnit.m_a2cTrialStats, false, acIntervals);
figure(110);        clf;        fnAuxPolarPlot(a2fResBinSac,a2fStimResBinSac, 1, [],30,true)
P=get(gcf,'position');P(3:4)=[193 193];set(gcf,'position',P);
 fnAuxSaccadeArchPlot(strctTmp, a2cTrialNames, 8,10,45,true,10);
  fnAuxSaccadeArchPlot(strctTmp, a2cTrialNames, 7,20,45,true,10);
%%

strDataFile = 'D:\Data\Doris\Electrophys\Julien\Optogenetics\120814\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120814_170400_TouchForceChoiceNeuralStat_Channel_1_Interval_8_SaccadeMemoryTaskJulien_Exp27.mat';
strctTmp = load(strDataFile);

    iCorrectIndex = find(ismember(strctTmp.strctUnit.m_acUniqueOutcomes,'Correct'));
    aiTrialTypeNoStim=zeros(1,iNumTrialTypes);
    aiTrialTypeStim = zeros(1,iNumTrialTypes);
    for iTrialTypeIter=1:iNumTrialTypes
        aiTrialTypeNoStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,1})));
        aiTrialTypeStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,2})));
    end
    
    acIntervals = { iOffset+[-50:30]};
    [a2fResBinNormSac, a2fStimResBinNormSac, a2fPValueSac,a2fResBinSac, a2fStimResBinSac]=fnExtractsCircularBinStats2(aiTrialTypeNoStim, aiTrialTypeStim, iCorrectIndex, strctTmp.strctUnit.m_a2cTrialStats, false, acIntervals);
           figure(111);        clf;        fnAuxPolarPlot(a2fResBinSac,a2fStimResBinSac, 1, [],max(a2fStimResBinSac(:)),true)
           P=get(gcf,'position');P(3:4)=[193 193];set(gcf,'position',P);
   fprintf('Done!\n');
 fnAuxSaccadeArchPlot(strctTmp, a2cTrialNames, 7,1,110,false,1);
 fnAuxSaccadeArchPlot(strctTmp, a2cTrialNames, 1:8,1,110,false,1);
 
 %%
 
 strDataFile ='D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_29_SaccadeMemoryTaskBert_Exp8.mat';
 
 strctTmp = load(strDataFile);

    iCorrectIndex = find(ismember(strctTmp.strctUnit.m_acUniqueOutcomes,'Correct'));
    aiTrialTypeNoStim=zeros(1,iNumTrialTypes);
    aiTrialTypeStim = zeros(1,iNumTrialTypes);
    for iTrialTypeIter=1:iNumTrialTypes
        aiTrialTypeNoStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,1})));
        aiTrialTypeStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,2})));
    end
    
    acIntervals = { iOffset+[-50:30]};
    [a2fResBinNormSac, a2fStimResBinNormSac, a2fPValueSac,a2fResBinSac, a2fStimResBinSac]=fnExtractsCircularBinStats2(aiTrialTypeNoStim, aiTrialTypeStim, iCorrectIndex, strctTmp.strctUnit.m_a2cTrialStats, false, acIntervals);
           figure(110);        clf;        fnAuxPolarPlot(a2fResBinSac,a2fStimResBinSac, 1, [],max(a2fResBinSac(:)),true)
           P=get(gcf,'position');P(3:4)=[193 193];set(gcf,'position',P);
   fprintf('Done!\n');
 fnAuxSaccadeArchPlot(strctTmp, a2cTrialNames, 8,1,35,true,1);
 %%
 strDataFile = acDataEntries{15}.m_strFile
 
  strctTmp = load(strDataFile);

     iCorrectIndex = find(ismember(strctTmp.strctUnit.m_acUniqueOutcomes,'Correct'));
    aiTrialTypeNoStim=zeros(1,iNumTrialTypes);
    aiTrialTypeStim = zeros(1,iNumTrialTypes);
    for iTrialTypeIter=1:iNumTrialTypes
        aiTrialTypeNoStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,1})));
        aiTrialTypeStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,2})));
    end
    
    acIntervals = { iOffset+[-50:30]};
    [a2fResBinNormSac, a2fStimResBinNormSac, a2fPValueSac,a2fResBinSac, a2fStimResBinSac]=fnExtractsCircularBinStats2(aiTrialTypeNoStim, aiTrialTypeStim, iCorrectIndex, strctTmp.strctUnit.m_a2cTrialStats, false, acIntervals);
           figure(110);        clf;        fnAuxPolarPlot(a2fResBinSac,a2fStimResBinSac, 1, [],max(a2fResBinSac(:)),true)
           P=get(gcf,'position');P(3:4)=[193 193];set(gcf,'position',P);
   fprintf('Done!\n');

 
 fnAuxSaccadeArchPlot(strctTmp, a2cTrialNames, 1:8,1,50,true,1);
