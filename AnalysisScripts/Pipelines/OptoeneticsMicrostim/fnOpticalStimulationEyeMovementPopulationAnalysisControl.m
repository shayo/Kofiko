function fnOpticalStimulationEyeMovementPopulationAnalysisControl(acDataEntries)
%global g_acDataCache
% This block loads the data from disk (or uses the cache if data was
% already loaded
% It is comments out because I can no longer hold all data in memory :(
% if ~isempty(g_acDataCache) && length(g_acDataCache) == length(acDataEntries)
%     fprintf('Loading Data from cache...');
%     acData = g_acDataCache;
%     fprintf('Done!\n');
% else
%     fprintf('Loading Data from disk...');
%     g_acDataCache = [];
%     acData = fnLoadDataEntries(acDataEntries); % Forget about attributes, just load everything.
%     fprintf('Done!\n');
%     g_acDataCache = acData;
% end
% acUnits=fnCellStructToArray(acData,'strctUnitInterval');

strctEyePopulationOptical=fnOpticalStimulationEyeMovementPopulationAnalysisAux(acDataEntries, false);
strPopulationOutputfile = 'D:\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\EyeMovementDuringOpticalStimulation_PopulationControl.mat';
fprintf('saving population data to %s',strPopulationOutputfile);
save(strPopulationOutputfile,'strctEyePopulationOptical','acDataEntries');
fprintf('Done!\n');



return;


function strctEyePopulationOptical=fnOpticalStimulationEyeMovementPopulationAnalysisAux(acDataEntries, bPulsed)
% iGlobalIter = 1;
% for iUnitIter= 1:length(acUnits)
%     iNumTrains = length(acUnits{iUnitIter}.m_astrctTrain);
%     for iTrainIter=1:iNumTrains
%         aiNumPulses(iGlobalIter) = acUnits{iUnitIter}.m_astrctTrain(iTrainIter).m_strctTrain.m_iPulsesPerTrain;
%         afPulseLengthMS(iGlobalIter) = round(median(acUnits{iUnitIter}.m_astrctTrain(iTrainIter).m_strctTrain.m_afPulseLengthMS));
%         aiNumPulsesPerTrain(iGlobalIter) =  acUnits{iUnitIter}.m_astrctTrain(iTrainIter).m_strctTrain.m_iPulsesPerTrain;
%         iGlobalIter=iGlobalIter+1;
%     end
% end

% Analyze only continuous pulses, and drop multiple units collected at the
% same depth....
iGlobalIter = 1;
clear strctEyePopulationOptical
fprintf('Loading 000');
for iUnitIter= 1:length(acDataEntries)
    fprintf('\b\b\b%03d',iUnitIter);
    strctTmp= load(acDataEntries{iUnitIter}.m_strFile);
    strctInterval = strctTmp.strctUnitInterval;
    iNumTrains = length(strctInterval.m_astrctTrain);
%     [~,strOpsin]=fnFindAttribute(strctInterval.m_a2cAttributes,'Opsin');
    for iTrainIter=1:iNumTrains
        bCondition = strctInterval.m_astrctTrain(iTrainIter).m_strctTrain.m_iPulsesPerTrain == 1 ;
        
        if bPulsed
            bCondition = ~bCondition;
        end
        
        if isfield(strctInterval.m_astrctTrain,'m_a2fDistToFixationSpotPixZeroBaseline') && bCondition && ...
                sum(strctInterval.m_astrctTrain(iTrainIter).m_abTrainsWithFixationBeforeOnset) > 10
            afMedianEyePos = median(strctInterval.m_astrctTrain(iTrainIter).m_a2fDistToFixationSpotPixZeroBaseline(strctInterval.m_astrctTrain(iTrainIter).m_abTrainsWithFixationBeforeOnset,:),1);
            iOnsetIndex = find(strctInterval.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS == 0);
            iBeforeFixationMS = 200;
            iAfterFixationMS = 300;
            %aiZoomRange = iOnsetIndex-iBeforeFixationMS:iOnsetIndex+iAfterFixationMS;
            
%             a2fBefore = strctInterval.m_astrctTrain(iTrainIter).m_a2fDistToFixationSpotPixZeroBaseline(strctInterval.m_astrctTrain(iTrainIter).m_abTrainsWithFixationBeforeOnset,iOnsetIndex-iBeforeFixationMS:iOnsetIndex);
            %fThres = 3*std(a2fBefore(:));
            fThres = 3*std(afMedianEyePos(iOnsetIndex-iBeforeFixationMS:iOnsetIndex));
            
            strctEyePopulationOptical.m_afStdBefore(iGlobalIter) = std(afMedianEyePos(iOnsetIndex-iBeforeFixationMS:iOnsetIndex));
            
            strctEyePopulationOptical.m_afMaxDistBefore(iGlobalIter) = max(abs(afMedianEyePos(iOnsetIndex-iBeforeFixationMS:iOnsetIndex)));
            strctEyePopulationOptical.m_afMaxDistAfter(iGlobalIter) = max(abs(afMedianEyePos(iOnsetIndex:iOnsetIndex+iAfterFixationMS )));
            
           strctEyePopulationOptical.m_afDepthMM(iGlobalIter) = mean(strctInterval.m_astrctTrain(iTrainIter).m_afIntervalDepthMM);
            iNumAbove = sum(afMedianEyePos(iOnsetIndex:iOnsetIndex+iAfterFixationMS ) > fThres);
            if iNumAbove > 0
            astrctIntervals = fnGetIntervals( afMedianEyePos(iOnsetIndex:iOnsetIndex+iAfterFixationMS ) > fThres);
                strctEyePopulationOptical.m_afMaxIntervalLength(iGlobalIter) = max(cat(1,astrctIntervals.m_iLength));
            else
                strctEyePopulationOptical.m_afMaxIntervalLength(iGlobalIter) = 0;
            end
            % Rand events
            iNumTrains = sum(strctInterval.m_astrctTrain(iTrainIter).m_abTrainsWithFixationBeforeOnset);
            iSubset = min( iNumTrains,size(strctInterval.m_astrctTrain(iTrainIter).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents,1));
            afMedianEyePosRandAll = median(strctInterval.m_astrctTrain(iTrainIter).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents,1);
            afMedianEyePosRandSubset = median(strctInterval.m_astrctTrain(iTrainIter).m_a2fDistToFixationSpotPixZeroBaselineRandomEvents(1:iSubset,:),1);
            
            strctEyePopulationOptical.m_aiOnsetIndex(iGlobalIter) = iOnsetIndex;
            strctEyePopulationOptical.m_acMedianEyePos{iGlobalIter} = afMedianEyePos;
            strctEyePopulationOptical.m_acMedianEyePosRandAll{iGlobalIter} = afMedianEyePosRandAll;
            strctEyePopulationOptical.m_acMedianEyePosRandSubset{iGlobalIter} = afMedianEyePosRandSubset;
            
            strctEyePopulationOptical.m_afMaxDistBeforeRandAll(iGlobalIter)  =  max(abs(afMedianEyePosRandAll(iOnsetIndex-iBeforeFixationMS:iOnsetIndex)));
            strctEyePopulationOptical.m_afMaxDistBeforeRandSubset(iGlobalIter)  =  max(abs(afMedianEyePosRandSubset(iOnsetIndex-iBeforeFixationMS:iOnsetIndex)));
            strctEyePopulationOptical.m_afMaxDistDuringRandAll(iGlobalIter)  =  max(abs(afMedianEyePosRandAll(iOnsetIndex:iOnsetIndex+iAfterFixationMS)));
            strctEyePopulationOptical.m_afMaxDistDuringRandSubset(iGlobalIter)  =  max(abs(afMedianEyePosRandSubset(iOnsetIndex:iOnsetIndex+iAfterFixationMS)));
            
            iNumAbove = sum(afMedianEyePosRandAll(iOnsetIndex:iOnsetIndex+iAfterFixationMS ) > fThres);
            if iNumAbove > 0
                astrctIntervals = fnGetIntervals( afMedianEyePosRandAll(iOnsetIndex:iOnsetIndex+iAfterFixationMS ) > fThres);
                strctEyePopulationOptical.m_afMaxIntervalLengthRandAll(iGlobalIter) = max(cat(1,astrctIntervals.m_iLength));
            else
                strctEyePopulationOptical.m_afMaxIntervalLengthRandAll(iGlobalIter) = 0;
            end            
 
            
            % Other attributes
            strctEyePopulationOptical.m_acAttributes{iGlobalIter} = strctInterval.m_a2cAttributes;
            strctEyePopulationOptical.m_aiUnitIndex(iGlobalIter) = iUnitIter;
            strctEyePopulationOptical.m_aiTrainIndex(iGlobalIter) = iTrainIter;
            %strctEyePopulationOptical.m_afDate(iGlobalIter) = strctInterval.m_strctChannelInfo;
            iGlobalIter = iGlobalIter + 1;
        end
    end
end
fprintf('...Done!\n');
% if 0
% iNumPotentialIntervals = iGlobalIter-1;
% % Remove data duplication (intervals from the same depth)
% [afUniqueDepths, Tmp, aiUniqueToIndex]=unique( strctEyePopulationOptical.m_afDepthMM);
% abDiscard = zeros(1,iNumPotentialIntervals)>0;
% for k=1:length(afUniqueDepths)
%     aiSame=find(strctEyePopulationOptical.m_afDepthMM == afUniqueDepths(k));
%     if length(aiSame) > 1
%     acTimeData = cell(1,length(aiSame));
%     for j=1:length(aiSame)
%         [~, acTimeData{j}]=fnFindAttribute(strctEyePopulationOptical.m_acAttributes{aiSame(j)},'TimeDate');
%     end
%     [acUniqueDates, aiExemplarsOfUnique,aiMappingToUnique]=unique(acTimeData);
%     abDiscard(setdiff( aiSame, aiSame(aiExemplarsOfUnique)))=true;
%     end
% end
% abValidIntervals = find(~abDiscard);
% 
% strctEyePopulationOptical.m_afMaxDistBefore = strctEyePopulationOptical.m_afMaxDistBefore(abValidIntervals);
% strctEyePopulationOptical.m_afMaxDistAfter = strctEyePopulationOptical.m_afMaxDistAfter(abValidIntervals);
% strctEyePopulationOptical.m_afDepthMM = strctEyePopulationOptical.m_afDepthMM(abValidIntervals);
% strctEyePopulationOptical.m_afMaxIntervalLength = strctEyePopulationOptical.m_afMaxIntervalLength(abValidIntervals);
% strctEyePopulationOptical.m_acAttributes = strctEyePopulationOptical.m_acAttributes(abValidIntervals);
% strctEyePopulationOptical.m_aiTrainIndex = strctEyePopulationOptical.m_aiTrainIndex(abValidIntervals);
% strctEyePopulationOptical.m_afDate = strctEyePopulationOptical.m_afDate(abValidIntervals);
% end
