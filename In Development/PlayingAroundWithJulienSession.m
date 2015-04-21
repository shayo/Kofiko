a2cCompareTrials = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};


acUnits = {...
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_10_SaccadeMemoryTaskJulien_Exp27.mat'
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_11_SaccadeMemoryTaskJulien_Exp27.mat'
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_12_SaccadeMemoryTaskJulien_Exp27.mat'
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_13_SaccadeMemoryTaskJulien_Exp27.mat'
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_14_SaccadeMemoryTaskJulien_Exp27.mat'
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_16_SaccadeMemoryTaskJulien_Exp27.mat'
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_6_SaccadeMemoryTaskJulien_Exp27.mat'
'D:\Data\Doris\Electrophys\Julien\Optogenetics\120526\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Julien-120526_112418_TouchForceChoiceNeuralStat_Channel_1_Interval_9_SaccadeMemoryTaskJulien_Exp27.mat'};

acUnits = {...
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_25_SaccadeMemoryTaskBert_Exp8.mat'
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_26_SaccadeMemoryTaskBert_Exp8.mat'
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_27_SaccadeMemoryTaskBert_Exp8.mat'
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_28_SaccadeMemoryTaskBert_Exp8.mat'
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_29_SaccadeMemoryTaskBert_Exp8.mat'
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_30_SaccadeMemoryTaskBert_Exp8.mat'
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_31_SaccadeMemoryTaskBert_Exp8.mat'
'D:\Data\Doris\Electrophys\Bert\Optogenetics\120610\RAW\..\Processed\TouchForceChoiceNeuralAnalysis\Bert-120610_111659_TouchForceChoiceNeuralStat_Channel_1_Interval_32_SaccadeMemoryTaskBert_Exp8.mat'};

acOutcomes = {  'Aborted;BreakFixationDuringCue'  ,  'Correct' ,   'Incorrect'    ,'Timeout'};
%%

% Show only for "Incorrect Trials"
for iUnitIter=1:length(acUnits)
     
    strctTmp = load(acUnits{iUnitIter});
    strctUnit = strctTmp.strctUnit;
    
    iOutcomeCorrect = find(ismember(strctUnit.m_acUniqueOutcomes,'Correct'));
    iOutcomeIncorrect = find(ismember(strctUnit.m_acUniqueOutcomes,'Incorrect'));

    figure(iUnitIter);
    clf;
    for iTrialIter=1:8
        
        iNoStimTrial = find(ismember(lower(strctUnit.m_acTrialNames), lower(a2cCompareTrials{iTrialIter,1})));
        iStimTrial = find(ismember(lower(strctUnit.m_acTrialNames), lower(a2cCompareTrials{iTrialIter,2})));

        

        if isempty(strctUnit.m_a2cTrialStats{iNoStimTrial,iOutcomeCorrect}) || isempty(strctUnit.m_a2cTrialStats{iStimTrial,iOutcomeCorrect})
            continue;
        end;
        afTime = strctUnit.m_a2cTrialStats{iNoStimTrial,iOutcomeCorrect}.m_strctRasterCue.m_aiRasterTimeMS;
        iNumTrials = size(strctUnit.m_a2cTrialStats{iNoStimTrial,iOutcomeCorrect}.m_strctRasterCue.m_a2bRaster,1);
        if iNumTrials == 1
            continue;
        end;
        afTimeKernel = fspecial('gaussian',[1 100],10);
        afMeanResponse = conv2(mean(strctUnit.m_a2cTrialStats{iNoStimTrial,iOutcomeCorrect}.m_strctRasterCue.m_a2fSmoothRaster), afTimeKernel,'same');
        afMeanResponseStim = conv2(mean(strctUnit.m_a2cTrialStats{iStimTrial,iOutcomeCorrect}.m_strctRasterCue.m_a2fSmoothRaster), afTimeKernel,'same');
         subplot(2,4,iTrialIter); hold on;
         
        plot(mean(strctUnit.m_a2cTrialStats{iNoStimTrial,iOutcomeCorrect}.m_strctRasterCue.m_a2fLFP),'k');
        hold on;
         plot(mean(strctUnit.m_a2cTrialStats{iStimTrial,iOutcomeCorrect}.m_strctRasterCue.m_a2fLFP),'r');
         
%         plot(afTime,afMeanResponse,'k');
%         plot(afTime,afMeanResponseStim,'r');
%         axis([0 1500 0 60]);
        title(a2cCompareTrials{iTrialIter,1});
    end
       
        
    
end


