function fnChetaOpticalStimulationNeuralPopulationAnalysis(acDataEntries)
% Data is too big to fit in memory.
% Load each entry, extract only the relevant stats, and close.

iGlobalCounter = 1;
fprintf('Loading 000');
%bIgnoreMultipleTrainsForSameCell = true;

bTakeTrainWithMostTrials = true;
aiNumPulses = zeros(1, length(acDataEntries));
iNumDataEntries = length(acDataEntries);
acAllTrains = cell(1,iNumDataEntries);
figure(11);
clf;
hold on;
for iDataIter=1:iNumDataEntries
    fprintf('\b\b\b%03d',iDataIter);
    strctTmp= load(acDataEntries{iDataIter}.m_strFile);
    strctInterval = strctTmp.strctUnitInterval;
    
    iNumTrainTypes = length(strctInterval.m_astrctTrain);
    
    afAvgFiringRateBeforeAllTrains = [];
    afX = [];
    afY = [];
    for iItrainTypeIter=1:iNumTrainTypes
        aiIndDuring = find(strctInterval.m_astrctTrain(iItrainTypeIter).m_aiPeriStimulusRangeMS >=0 & strctInterval.m_astrctTrain(iItrainTypeIter).m_aiPeriStimulusRangeMS <= 100);
        aiIndBefore = find(strctInterval.m_astrctTrain(iItrainTypeIter).m_aiPeriStimulusRangeMS <0 & strctInterval.m_astrctTrain(iItrainTypeIter).m_aiPeriStimulusRangeMS >= -100);
        afAvgFiringRateDuring = 1000*mean(strctInterval.m_astrctTrain(iItrainTypeIter).m_a2bRaster(:,aiIndDuring),2);
        afAvgFiringRateBefore = 1000*mean(strctInterval.m_astrctTrain(iItrainTypeIter).m_a2bRaster(:,aiIndBefore),2);
        if min(strctInterval.m_astrctTrain(iItrainTypeIter).m_afStatisticalTests) < 0.001
            if isnan(strctInterval.m_astrctTrain(iItrainTypeIter).m_strctTrain.m_afInterPulseMS)
                % Continuous train
                % Computing the average firing rate
                afAvgFiringRateBeforeAllTrains = [afAvgFiringRateBeforeAllTrains;afAvgFiringRateBefore];
                afX = [afX,250];
                afY = [afY,mean(afAvgFiringRateDuring)];
            else
                % Pulsed train detected.
                fPulseFreq = round(100*strctInterval.m_astrctTrain(iItrainTypeIter).m_strctTrain.m_iPulsesPerTrain / strctInterval.m_astrctTrain(iItrainTypeIter).m_strctTrain.m_fTrainLengthMS);
                iIndex = find(afX == fPulseFreq);
                if ~isempty(iIndex)
                    if mean(afAvgFiringRateDuring) > afY(iIndex)
                        afY(iIndex) = mean(afAvgFiringRateDuring); % Just replace.
                    end
                else
                    afX = [fPulseFreq,afX];
                    afY = [mean(afAvgFiringRateDuring),afY];
                end
            end
        end
    end
    if ~isempty(afX)
        afX = [0,afX];
        afY = [mean(afAvgFiringRateBeforeAllTrains), afY];
        plot(afX,afY);
        drawnow
    end
    
end

% 
% 
% %     strctPopulationOpticalStim.m_acLFP{iGlobalCounter} = 
%     
%     afMinStat = zeros(1,length(strctInterval.m_astrctTrain));
%     for iTrainIter=1:length(strctInterval.m_astrctTrain)
%         afMinStat(iTrainIter)=min(strctInterval.m_astrctTrain(iTrainIter).m_afStatisticalTests);
%     end
%     [fDummy, iSelectedTrain] = min(afMinStat);
%     
%     iTrainIter=iSelectedTrain;
%     %for iTrainIter=1:length(strctInterval.m_astrctTrain)
%         acAllTrains{iDataIter} = strctInterval.m_astrctTrain(iTrainIter).m_strctTrain;
%         
% %         if strctInterval.m_astrctTrain(iTrainIter).m_strctTrain.m_iPulsesPerTrain == 1
%             
%             % Latency analysis similar to Ilka's 
%             
%             a2bRaster = strctInterval.m_astrctTrain(iTrainIter).m_a2bRaster;
%             
%             abBefore = strctInterval.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS <= 0;
%             abDuring = strctInterval.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS >= 0 &  strctInterval.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS  < strctInterval.m_astrctTrain(iTrainIter).m_strctTrain.m_fTrainLengthMS;
%             afAvgResponse = mean(a2bRaster,1);
%             if  mean(afAvgResponse(abDuring)) < mean(afAvgResponse(abBefore))
%                 iLatencyMS = find(afAvgResponse(abDuring) <= 0.5* min(afAvgResponse(abDuring)),1,'first');
%             else
%                 iLatencyMS = find(afAvgResponse(abDuring) >= 0.5* max(afAvgResponse(abDuring)),1,'first');
%             end
%             if isempty(iLatencyMS)
%                 iLatencyMS = NaN;
%             end
%             strctPopulationOpticalStim.m_afLatencyMS_Ilka(iGlobalCounter) = iLatencyMS;
%             
% %      figure(4);clf;hold on;
% %         afNoisy = sum(strctInterval.m_astrctTrain(1).m_a2bRaster);
% %         plot(strctInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS, afNoisy,'k')
% %         plot(strctInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS, sum(strctInterval.m_astrctTrain(1).m_a2fSmoothRaster),'r','LineWidth',2)
% %         plot(strctInterval.m_astrctTrain(1).m_fLatencyMS*ones(1,2),[min(afNoisy) max(afNoisy)],'g','LineWidth',2);
% %                
%          
%         strctPopulationOpticalStim.m_acResponse{iGlobalCounter} = [strctInterval.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS;mean(a2bRaster,1);];
%         
%         
% [fMaxHeight,iIndexMax]=max(strctInterval.m_astrctTrain(iTrainIter).m_afAvgWaveFormAll);
% [fMinHeight,iIndexMin]=min(strctInterval.m_astrctTrain(iTrainIter).m_afAvgWaveFormAll);
% strctPopulationOpticalStim.m_afSpikeHeight(iGlobalCounter) = fMaxHeight-fMinHeight;
% strctPopulationOpticalStim.m_afSpikeWidth(iGlobalCounter) = abs(iIndexMax-iIndexMin);
%         
%         
%             strctPopulationOpticalStim.m_afMeanBefore(iGlobalCounter) = mean(strctInterval.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore);
%             strctPopulationOpticalStim.m_afStdBefore(iGlobalCounter) =std(strctInterval.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore);
%             
%              strctPopulationOpticalStim.m_afLatency(iGlobalCounter) = strctInterval.m_astrctTrain(iTrainIter).m_fLatencyMS;
%             
%             strctPopulationOpticalStim.m_afMeanDuring(iGlobalCounter) = mean(strctInterval.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring);
%             strctPopulationOpticalStim.m_afStdDuring(iGlobalCounter) =std(strctInterval.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring);
%             strctPopulationOpticalStim.m_afRecordingDepth(iGlobalCounter) = mean(strctInterval.m_astrctTrain(iTrainIter).m_afIntervalDepthMM);
%             strctPopulationOpticalStim.m_aiGridHoleX(iGlobalCounter) = strctInterval.m_strctChannelInfo.m_iGridX;
%             strctPopulationOpticalStim.m_aiGridHoleY(iGlobalCounter) = strctInterval.m_strctChannelInfo.m_iGridY;
%             strctPopulationOpticalStim.m_afMUA_Contamination(iGlobalCounter) = strctInterval.m_fPercentContamination;
%             strctPopulationOpticalStim.m_afPValue(iGlobalCounter) = strctInterval.m_astrctTrain(iTrainIter).m_afStatisticalTests(1);
%             [~,strctPopulationOpticalStim.m_acSubject{iGlobalCounter}]=fnFindAttribute(strctInterval.m_a2cAttributes,'Subject');
%             
%         %N = size(strctInterval.m_astrctTrain(1).m_strctLFP.m_afData,1);
%         afMeanLFP = mean(strctInterval.m_astrctTrain(iTrainIter).m_strctLFP.m_afData,1);
%         %afSEMLFP = std(strctInterval.m_astrctTrain(1).m_strctLFP.m_afData,[],1) / sqrt(N);
%             
%         strctPopulationOpticalStim.m_acLFP_TS{iGlobalCounter} = strctInterval.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS;
%         strctPopulationOpticalStim.m_acLFP{iGlobalCounter} = afMeanLFP ;
%         
%      strctPopulationOpticalStim.m_aiNumPulses(iGlobalCounter) = size(a2bRaster,1);
%     strctPopulationOpticalStim.m_aiNumPulsesInTrain(iGlobalCounter) = strctInterval.m_astrctTrain(iTrainIter).m_strctTrain.m_iPulsesPerTrain;
%     strctPopulationOpticalStim.m_afTrainLengthMS(iGlobalCounter) = strctInterval.m_astrctTrain(iTrainIter).m_strctTrain.m_fTrainLengthMS;
%             
%             
%             iGlobalCounter=iGlobalCounter+1;
% %             if bIgnoreMultipleTrainsForSameCell 
% %                 break;
% %             end
% %         end
% %     end
% end
% strctPopulationOpticalStim.m_acDataEntries = acDataEntries;
% 
% % aiStimToUnit(find(aiNumTrains(aiRelevantStim) > 50 & strctPopulationOpticalStim.m_afMUA_Contamination < 2))
% fprintf('...Done!\n');
% [~,strOpsin]=fnFindAttribute(strctInterval.m_a2cAttributes,'Opsin');
% strOutputFile = ['D:\Data\Doris\Data For Publications\FEF Opto\',strOpsin,'_PopulationStats.mat'];
% fprintf('Saving popualtion stats to %s\n',strOutputFile);
% save(strOutputFile,'strctPopulationOpticalStim');
% 
% return;
% 
% 
% %
% %
% %     [~,acSubject{k}]=fnFindAttribute(acUnits{k}.m_a2cAttributes,'Subject');
% %     for j=1:length(acUnits{k}.m_astrctTrain)
% %         aiNumTrains(iGlobalCounter) = acUnits{k}.m_astrctTrain(j).m_strctTrain.m_iNumTrains;
% %         aiNumPulsesInTrain(iGlobalCounter) = acUnits{k}.m_astrctTrain(j).m_strctTrain.m_iPulsesPerTrain;
% %         afTrainLengthMS(iGlobalCounter) = acUnits{k}.m_astrctTrain(j).m_strctTrain.m_fTrainLengthMS;
% %         afRecordingDepthMM(iGlobalCounter) = mean(acUnits{k}.m_astrctTrain(j).m_afIntervalDepthMM);
% %         afContamination(iGlobalCounter) = acUnits{k}.m_fPercentContamination;
% %         aiStimToUnit(iGlobalCounter) = k;
% %         aiStimToTrainIndex(iGlobalCounter) = j;
% %         iGlobalCounter=iGlobalCounter+1;
% %     end
% % end
