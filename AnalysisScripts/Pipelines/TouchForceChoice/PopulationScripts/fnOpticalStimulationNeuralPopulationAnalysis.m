function fnOpticalStimulationNeuralPopulationAnalysis(acDataEntries)


iNumUnits  = length(acDataEntries);
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

%%
a2bVisualResponse = zeros(iNumUnits, iNumTrialTypes );
a2bMotorResponse = zeros(iNumUnits, iNumTrialTypes );
a2fAvgFiringRateVis = nans(iNumUnits, iNumTrialTypes );
a2fAvgFiringRateSac = nans(iNumUnits, iNumTrialTypes );
a2fAvgFiringRateSacStim = nans(iNumUnits, iNumTrialTypes );
a2fSEMFiringRateVis = nans(iNumUnits, iNumTrialTypes );
a2fSEMFiringRateSac = nans(iNumUnits, iNumTrialTypes );

aiPreMovementInterval = iOffset + [-300:-200];
aiMovementInterval = iOffset + [-100:50];
aiVisualResponseInterval = iOffset + [100:300];
aiBaselineInterval= iOffset + [-150:0];
aiStimulationInterval = iOffset + [200+50:600-50];  %Exclude spikes at onset/offset
afTime = -1000:3000;

a2fMaximalResponse = zeros(iNumUnits, 4001);
a2fMaximalResponseStim = zeros(iNumUnits, 4001);



%afSamplingIntervals = -800:100:400;
afSamplingIntervals = -200:50:1200;
iSamplingWidthMS = 50;
iNumSamplingIntervals = length(afSamplingIntervals);

a3fAvgFiringInterval = zeros(iNumUnits,iNumTrialTypes ,iNumSamplingIntervals);
a3fAvgFiringIntervalStim = zeros(iNumUnits,iNumTrialTypes ,iNumSamplingIntervals);
    iBinWidth = 50;
    afBinCenterCue = iOffset + [0:iBinWidth:1500];  iNumBinsCue = length(afBinCenterCue);    afBinTimeCue = afBinCenterCue-iOffset;
    afBinCenterSac = iOffset + [-600:iBinWidth:300];  iNumBinsSac = length(afBinCenterSac);    afBinTimeSac= afBinCenterSac-iOffset;

PThres = 0.05;
a3fResBinNormCue = nans(iNumUnits,iNumTrialTypes,iNumBinsCue);
a3fStimResBinNormCue = nans(iNumUnits,iNumTrialTypes,iNumBinsCue);
a3fPValueCue = nans(iNumUnits,iNumTrialTypes,iNumBinsCue);
a3fResBinNormSac = nans(iNumUnits,iNumTrialTypes,iNumBinsSac);
a3fStimResBinNormSac = nans(iNumUnits,iNumTrialTypes,iNumBinsSac);
a3fPValueSac = nans(iNumUnits,iNumTrialTypes,iNumBinsSac);


for iUnitIter=1:iNumUnits
    fprintf('Loading %d out of %d : %s...',iUnitIter,iNumUnits, acDataEntries{iUnitIter}.m_strFile);
    strctTmp = load(acDataEntries{iUnitIter}.m_strFile);
    fprintf('Done!\n');
    
    % Extract the four statistics used by Desimone
    
    % Use only correct responses....
    iCorrectIndex = find(ismember(strctTmp.strctUnit.m_acUniqueOutcomes,'Correct'));
    aiTrialTypeNoStim=zeros(1,iNumTrialTypes);
    aiTrialTypeStim = zeros(1,iNumTrialTypes);
    for iTrialTypeIter=1:iNumTrialTypes
        aiTrialTypeNoStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,1})));
        aiTrialTypeStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,2})));
        
            afVisResHz = sum(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeNoStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterCue.m_a2bRaster(:,aiVisualResponseInterval),2)/length(aiVisualResponseInterval)*1e3;
            afBaseResHz = sum(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeNoStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterCue.m_a2bRaster(:,aiBaselineInterval),2)/length(aiBaselineInterval)*1e3;
            afMovementResHz = sum(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeNoStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterSaccade.m_a2bRaster(:,aiMovementInterval),2)/length(aiMovementInterval)*1e3;
            afPreMovementResHz = sum(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeNoStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterSaccade.m_a2bRaster(:,aiPreMovementInterval),2)/length(aiPreMovementInterval)*1e3;
            a2bVisualResponse(iUnitIter,iTrialTypeIter) =ranksum(afVisResHz,afBaseResHz) < PThres;
            a2bMotorResponse(iUnitIter,iTrialTypeIter) =ranksum(afMovementResHz,afPreMovementResHz) < PThres;
    end
    
    [a2fResBinNormCue, a2fStimResBinNormCue, a2fPValueCue]=fnExtractsCircularBinStats(aiTrialTypeNoStim, aiTrialTypeStim, iCorrectIndex, strctTmp.strctUnit.m_a2cTrialStats, true, iBinWidth, afBinCenterCue);
    
    [a2fResBinNormSac, a2fStimResBinNormSac, a2fPValueSac]=fnExtractsCircularBinStats(aiTrialTypeNoStim, aiTrialTypeStim, iCorrectIndex, strctTmp.strctUnit.m_a2cTrialStats, false, iBinWidth, afBinCenterSac);
    
    
    a3fResBinNormCue(iUnitIter,:,:) = a2fResBinNormCue;;
    a3fStimResBinNormCue(iUnitIter,:,:) = a2fStimResBinNormCue;
    a3fPValueCue(iUnitIter,:,:) = a2fPValueCue;
    a3fResBinNormSac(iUnitIter,:,:) = a2fResBinNormSac;
    a3fStimResBinNormSac(iUnitIter,:,:) = a2fStimResBinNormSac;
    a3fPValueSac(iUnitIter,:,:) = a2fPValueSac;
    
    if 0
        figure(11);        clf;        fnAuxPolarPlot(a2fResBinNormCue,a2fStimResBinNormCue, afBinTimeCue, a2fPValueCue<PThres)
        figure(12);         clf;       fnAuxPolarPlot(a2fResBinNormSac,a2fStimResBinNormSac, afBinTimeSac, a2fPValueSac<PThres)
    end
    
end

abMotor = sum(a2bMotorResponse,2) > 1;
abVisual= sum(a2bVisualResponse,2) > 1;

abInhibited = mean(a3fStimResBinNormCue(:,:,9),2) < mean(a3fResBinNormCue(:,:,9),2) ;
abSubset = zeros(1,iNumUnits)>0;
%abSubset = abInhibited ;
abSubset(1) = true;

a2fPopulationNoStimCue = squeeze(mean(a3fResBinNormCue(abSubset,:,:),1));
a2fPopulationStimCue = squeeze(mean(a3fStimResBinNormCue(abSubset,:,:),1));
a2fPopulationNoStimSac = squeeze(mean(a3fResBinNormSac(abSubset,:,:),1));
a2fPopulationStimSac = squeeze(mean(a3fStimResBinNormSac(abSubset,:,:),1));

figure(14);
clf;
fnAuxPolarPlot(a2fPopulationNoStimCue,a2fPopulationStimCue, afBinTimeCue, [],1);

figure(15);
clf;
fnAuxPolarPlot(a2fPopulationNoStimSac,a2fPopulationStimSac, afBinTimeSac, [],1);

 
%%
fnAuxPolarPlot(a2fPopulationNoStimCue(:,1),a2fPopulationStimCue(:,1), afBinTimeCue(1), [],1);

figure(14);
clf;
fnAuxPolarPlot(a2fPopulationNoStimCue,a2fPopulationStimCue, afBinTimeCue, [],1);

figure(15);
clf;
fnAuxPolarPlot(a2fPopulationNoStimSac,a2fPopulationStimSac, afBinTimeSac, [],1);

    
    
if 0
% Is there significance at the population neural level? (NO)
a2fPopulationPValueCue = zeros(iNumTrialTypes,iNumBinsCue);
a2fPopulationPValueSac = zeros(iNumTrialTypes,iNumBinsSac);
for iTrialTypeIter=1:iNumTrialTypes
    for iBinIter=1:iNumBinsCue
        a2fPopulationPValueCue(iTrialTypeIter, iBinIter) = ranksum(a3fResBinNormCue(abSubset,iTrialTypeIter,iBinIter), a3fStimResBinNormCue(abSubset,iTrialTypeIter,iBinIter));
    end
    for iBinIter=1:iNumBinsSac
        a2fPopulationPValueSac(iTrialTypeIter, iBinIter) = ranksum(a3fResBinNormSac(abSubset,iTrialTypeIter,iBinIter), a3fStimResBinNormSac(abSubset,iTrialTypeIter,iBinIter));
    end
end

a2fPopulationPValueSac<0.05
a2fPopulationPValueCue<0.05
end
    
% for iSessionIter=1:iNumSessions
%     a2fTrials = squeeze(a3iNumberOfTrials(iSessionIter,:,:));
%     a2fTrialsStim = squeeze(a3iNumberOfTrialsStim(iSessionIter,:,:));
%     for iTrialTypeIter=1:iNumTrialTypes
%         a2iObservedTable = [a2fTrials(iTrialTypeIter,[1,2,3,5]);a2fTrialsStim(iTrialTypeIter,[1,2,3,5])];
%         a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
%          a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
%         a2fChiSquare(iSessionIter,iTrialTypeIter) = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
%     end
% end
% fChiValueThres = chi2inv(1-0.05, 3);
% 
% [aiSessions, aiTrialTypes] = find(a2fChiSquare>fChiValueThres);
% [aiSessions, aiTmp]=sort(aiSessions)
% aiTrialTypes=aiTrialTypes(aiTmp);
% % Compute the percent change
% 
% a2fPercentChange = zeros(length(aiSessions), 4);
% for iIter=1:length(aiSessions)
%     a2fTrials = squeeze(a3iNumberOfTrials(aiSessions(iIter),:,:));
%     a2fTrialsStim = squeeze(a3iNumberOfTrialsStim(aiSessions(iIter),:,:));
%     afTrials = a2fTrials(aiTrialTypes(iIter),[1,2,3,5]) ./ sum(a2fTrials(aiTrialTypes(iIter),[1,2,3,5]));
%     afTrialsStim = a2fTrialsStim(aiTrialTypes(iIter),[1,2,3,5]) ./ sum(a2fTrialsStim(aiTrialTypes(iIter),[1,2,3,5]));
%     
%     a2fPercentChange(iIter,:) = 1e2*(afTrialsStim-afTrials);
% end
% 
% abMonkeyJ=zeros(1,length(acDataEntries))>0;
% for i=1:length(acDataEntries)
%    if ~isempty(strfind(acDataEntries{i}.m_strFile,'Julien'))
%         abMonkeyJ(i) = true;
%    end;
% end
% acPlottedTrialTypes = {    'Aborted',    'Correct',    'Incorrect',      'Timeout'};
% 
% for iPlotIter=1:2
% figure(900+iPlotIter);
% clf;
%     
%     if iPlotIter == 1
%         abMonkey = abMonkeyJ;
%     else
%         abMonkey = ~abMonkeyJ;
%     end
%     
%     hold on;
%     for k=1:4
%         plot(k, a2fPercentChange(abMonkey(aiSessions), 5-(k)),'ko');
%         plot(k, mean(a2fPercentChange(abMonkey(aiSessions), 5-(k))),'r*');
%     end
%     plot([0 5],[0 0],'k--');
%     axis([0 5 -25 25])
%     set(gca,'xtick',1:4);
%     set(gca,'xticklabel',[])
%     P=get(gcf,'position');P(3:4)=[ 182         141];set(gcf,'position',P);
% end
% 
% 
% 
% 
% 
% 
% %     aiRelevantTrials = find(ismember(strctTmp.strctDesignStat.m_acUniqueTrialNames, a2cTrialNames(:,1)));
% %      iTimeoutIndex= find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Timeout'));
% %     iCorrectIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Correct'));
% %     iIncorrectIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Incorrect'));
% % %    assert(iCorrectIndex == 2 && iIncorrectIndex == 3 && iTimeoutIndex == 4)
% %     % Contrast level ? 
% %     for i=1:length(    strctTmp.strctDesignStat.m_strctDesign.m_acTrialTypes)
% %         acTrialNames{i} = strctTmp.strctDesignStat.m_strctDesign.m_acTrialTypes{i}.TrialParams.Name;
% %     end
% % 
% %     
% %     iRepTrialIndex = find(ismember(acTrialNames,a2cTrialNames{1,1}));
% %     
% %     strCue = strctTmp.strctDesignStat.m_strctDesign.m_acTrialTypes{iRepTrialIndex}.Cue.CueMedia;
% %     iMediaIndex = find(ismember({strctTmp.strctDesignStat.m_strctDesign.m_astrctMedia.m_strName},strCue));
% %     acCueMediaFile{iSessionIter} = strctTmp.strctDesignStat.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
% %     [~,acSubject{iSessionIter}] = fnFindAttribute(strctTmp.strctDesignStat.m_a2cAttributes,'Subject');
% %     
% %     aiNumCorrect(iSessionIter) = sum(strctTmp.strctDesignStat.m_a2fNumTrials(aiRelevantTrials,iCorrectIndex));
% %     aiNumIncorrect(iSessionIter) = sum(strctTmp.strctDesignStat.m_a2fNumTrials(aiRelevantTrials,iIncorrectIndex));
% %     
% %     % Statistics about micro stim
% %     iAbortedOutcome= find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Aborted;BreakFixationDuringCue'));
% %     iIncorrectOutcome = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Incorrect'));
% %     a2fPercentChange = zeros(8,4);
% %     for iTrialIter=1:8
% %         iIndexNoStim = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cTrialNames{iTrialIter,1})));
% %         iIndexStim = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cTrialNames{iTrialIter,2})));
% %         if ~isempty(iIndexNoStim)
% %             a3fNumTrialsNoStim(iTrialIter,:,iSessionIter) = strctTmp.strctDesignStat.m_a2fNumTrials(iIndexNoStim,:);
% %         end
% %          if ~isempty(iIndexStim)
% %             a3fNumTrialsStim(iTrialIter,:,iSessionIter) = strctTmp.strctDesignStat.m_a2fNumTrials(iIndexStim,:);
% %          end
% %          afNoStimNormalized =  1e2*a3fNumTrialsNoStim(iTrialIter,:,iSessionIter)  / sum( a3fNumTrialsNoStim(iTrialIter,:,iSessionIter) );
% %          afStimNormalized = 1e2* a3fNumTrialsStim(iTrialIter,:,iSessionIter) / sum(a3fNumTrialsStim(iTrialIter,:,iSessionIter));
% %          a2fPercentChange(iTrialIter,:) = afStimNormalized - afNoStimNormalized;
% %          
% %          
% %          aiErrorTrialsDuringStimulation = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iIndexStim & strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iIncorrectOutcome);
% % 
% %          aiAbortedTrialsDuringStimulation = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iIndexStim & strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iAbortedOutcome);
% %          
% %  
% % %          figure(100);
% % %          clf;
% % %         hold on;
% % for k=1:length(aiErrorTrialsDuringStimulation)
% %     T0 = find(strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeTS_PLX > strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_fCueOnsetTS_PLX,1,'first')-50;
% %     T1=  find(strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeTS_PLX > strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_fSaccadeTSPlexon,1,'first');
% %     afX = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeXpixSmooth-strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeXpixSmooth(T0);
% %     afY = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeYpixSmooth-strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeYpixSmooth(T0);
% %     afXCropped = afX(T0:T1) ;
% %     afYCropped = afY(T0:T1) ;
% %     afVel = [0;sqrt(diff(afXCropped).^2+diff(afYCropped).^2)];
% %     T1min = find(afXCropped > 400 |afYCropped > 400 | afXCropped < -400 |afYCropped < -400 | afVel > 25,1,'first');
% %     if ~isempty(T1min)
% %         strctPopulationResult.m_a2cErrorTrialsStim{iSessionIter,iTrialIter}{k} = [afXCropped(1:T1min),afYCropped(1:T1min),];
% %         %plot(afXCropped(1:T1min),afYCropped(1:T1min),'k');
% %     else
% %         strctPopulationResult.m_a2cErrorTrialsStim{iSessionIter,iTrialIter}{k} = [afXCropped(1:end),afYCropped(1:end),];
% %         %plot(afXCropped(1:end),afYCropped(1:end),'k');
% %     end
% % end
% % % 
% % % fCenterX=400;
% % % fCenterY=300;
% % % 
% % % for k=1:length(aiAbortedTrialsDuringStimulation)
% % %     
% % %     afX = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_afEyeXpixSmooth;
% % %     afY = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_afEyeYpixSmooth;
% % %     T0 = find( sqrt( (afX-fCenterX).^2+(afY-fCenterY).^2) <= 80,1,'first');
% % %     abTmp = zeros(1,length(afX))>0;
% % %     abTmp(T0:end)=true;
% % %     aiOutOfFixationZone = find( sqrt( (afX-fCenterX).^2+(afY-fCenterY).^2) > 70 & abTmp',1,'first')
% % %     
% % %     figure(10);clf;
% % %         plot(afX,afY);hold on;
% % %         for k=1:100:length(afX)
% % %             text(afX(k),afY(k),sprintf('%d',k))
% % %         end
% % %         
% % %     
% % %     T0 = find(strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_afEyeTS_PLX > strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_fCueOnsetTS_PLX,1,'first');
% % %     afXCropped = afX(T0:T1) ;
% % %     afYCropped = afY(T0:T1) ;
% % %     afVel = [0;sqrt(diff(afXCropped).^2+diff(afYCropped).^2)];
% % %     T1min = find(afXCropped > 400 |afYCropped > 400 | afXCropped < -400 |afYCropped < -400 | afVel > 25,1,'first');
% % %     if ~isempty(T1min)
% % %         strctPopulationResult.m_a2cErrorTrialsStim{iSessionIter,iTrialIter}{k} = [afXCropped(1:T1min),afYCropped(1:T1min),];
% % %         %plot(afXCropped(1:T1min),afYCropped(1:T1min),'k');
% % %     else
% % %         strctPopulationResult.m_a2cErrorTrialsStim{iSessionIter,iTrialIter}{k} = [afXCropped(1:end),afYCropped(1:end),];
% % %         %plot(afXCropped(1:end),afYCropped(1:end),'k');
% % %     end
% % % end
% % % 
% % %         
% % 
% % 
% % %         axis equal
% % %         axis([-400 400 -400 400]);
% % %     
% %   
% %        
% %     end
% %     % bootstrapping the mean ?
% %     a4iHist = zeros(8,2,iNumOutcomes,N+1);
% %     a4iCumSum= zeros(8,2,iNumOutcomes,N+1);
% %     a3iLower = nans(8,2, iNumOutcomes);
% %     a3iUpper = nans(8,2, iNumOutcomes);
% %     a3fMean =  zeros(8,2, iNumOutcomes);
% %     for i=1:8
% %         for j=1:2
% %             iIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cTrialNames{i,j})));
% %             if ~isempty(iIndex)
% %                 
% %                 aiRelevantTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iIndex);
% %                 aiRelevantOutcomes = strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique(aiRelevantTrials);
% %                 iNumTrials = length(aiRelevantTrials);
% %                 a2iRandom = randi(iNumTrials, [M,N]);
% %                 a2iOutcomes = aiRelevantOutcomes(a2iRandom);
% %                 % Hist outcomes.
% %                  for k=1:iNumOutcomes
% %                     aiNumSameOutcome = sum(a2iOutcomes == k,2);
% %                     afHist = histc(aiNumSameOutcome, 0:N);
% %                     a3fMean(i,j,k) = mean(aiNumSameOutcome);
% %                     afCumHist = cumsum(afHist) ;
% % 
% %                     IdxLow = find(afCumHist> P*M,1,'first');
% %                     if ~isempty(IdxLow)
% %                         a3iLower(i,j,k) = IdxLow-1; % Becuase indices start at 0
% %                     end
% %                     IdxUp = find(afCumHist< (1-P)*M,1,'last');
% %                     if ~isempty(IdxUp)
% %                         a3iUpper(i,j,k) = IdxUp-1;
% %                     end
% %                     a4iCumSum(i,j,k,:) = afCumHist;
% %                     a4iHist(i,j,k,:) = afHist;
% %                 end
% %             end
% %         end
% %     end
% %     
% %     % Bootstrapping Inference-  Does the mean correct between conditions is different?
% %     a2bSig = zeros(8,4);
% %     for i=1:8
% %         for k=1:4
% %             a2bSig(i,k) = a3fMean(i,1,k) >a3iUpper(i,2,k)  || a3fMean(i,1,k) < a3iLower(i,2,k);
% %         end
% %     end
% %     % Chi-square inference - does the number of trials deviate from
% %     % the expected ?
% %     for i=1:8
% %         a2iObservedTable = [squeeze(a3fNumTrialsNoStim(i,:,iSessionIter) ); squeeze(a3fNumTrialsStim(i,:,iSessionIter) )];
% %         a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
% %          a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
% %         a2fChiSquare(iSessionIter,i) = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
% %     end
% % 
% % %         for i=1:8
% % %             aiNoStim=a3fNumTrialsNoStim(i,:,iSessionIter);
% % %             aiStim = a3fNumTrialsStim(i,:,iSessionIter);
% % %         a2iObservedTable2x2 = [aiNoStim(2), sum(aiNoStim([1,3,4]));
% % %                                 aiStim(2), sum(aiStim([1,3,4]))];
% % %         a2fExpectedTable2x2 = sum(a2iObservedTable2x2,2) * sum(a2iObservedTable2x2,1) / sum(a2iObservedTable2x2(:));
% % %          a2fChiElements2x2 = (a2fExpectedTable2x2 - a2iObservedTable2x2 ) .^2 ./ a2iObservedTable2x2;
% % %         a2fChiSquare(iSessionIter,i) = sum(a2fChiElements2x2(~isinf(a2fChiElements2x2) & ~isnan(a2fChiElements2x2)));
% % %     end
% % if 1
% %     a2fChiSquare
% %     figure;clf;
% %     N=20;
% %     a2fOutcomeColors = [79,129,189;0,176,80;192,80,77;247,150,70]/255;
% %     iNumOutcomes=4;
% %     N=strctBootstrap.N;
% %     M=strctBootstrap.M;
% %     
% %     for i=1:8
% %         %tightsubplot(1,9,i,'Spacing',0.01);
% %         subplot(1,8,i);
% %         hold on;
% %         if a2fChiSquare(iSessionIter,i) > 7
% %             rectangle('position',[0.5 0 21 2],'facecolor',[0.9 0.9 0.9],'edgecolor','none');
% %         end
% %         for k=1:iNumOutcomes
% %             
% %             %         plot(0:N,(k-1)+squeeze(a4iCumHist(i,1,k,:)) / M,'color',a2fOutcomeColors(k,:),'Linestyle','-','LineWidth',2);
% %             %         plot(0:N,(k-1)+squeeze(a4iCumHist(i,2,k,:)) / M,'color',a2fOutcomeColors(k,:),'linestyle','--','LineWidth',2);
% %             %
% %             plot([0 N],0.5*(k-1)*ones(1,2),'k-');
% %            ahNoStim(i,k)= plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,1,k,:)) / M ,'color',a2fOutcomeColors(k,:),'Linestyle','-','LineWidth',2);
% %            ahStim(i,k)= plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,2,k,:)) / M ,'color',a2fOutcomeColors(k,:),'linestyle','--','LineWidth',2);
% % %             plot([N N]*0.25, [0 5],'k--');
% %         end
% % %          title(a2cTrialNames{i,1});
% %         axis([0 N 0 0.5*4]);
% %         set(gca,'ytick',1:4,'yticklabel',[]);
% %         set(gca,'xticklabel',[]);
% %         
% %     end
% % %     hLegend=legend([ahNoStim(1,:),ahStim(2,:)],{'Aborted - No Stim','Correct - No Stim','Incorrect - No Stim','Timeout - No Stim',...
% % %         'Aborted - Stim','Correct - Stim','Incorrect - Stim','Timeout - Stim'},'Location','NorthEastOutside')
% % %     set(hLegend,'Position',[  0.8310    0.4565    0.1116    0.4792]);
% %     set(gcf,'position',[789   976   843   117]);
% % 
% % 
% %     
% % end
% %     strctPopulationResult.m_acMean{iSessionIter} = a3fMean;
% %     strctPopulationResult.m_acHist{iSessionIter} = a4iHist;
% %     strctPopulationResult.m_acCumHist{iSessionIter} = a4iCumSum;
% %     strctPopulationResult.m_acSig{iSessionIter} = a2bSig;
% %     strctPopulationResult.m_acPercentChange{iSessionIter} = a2fPercentChange;
% % end
% % strctPopulationResult.m_acDataEntries = acDataEntries;
% % strctPopulationResult.m_a2cTrialNames= a2cTrialNames;
% % % Outcomes:   'Aborted;BreakFixationDuringCue'    'Correct'    'Incorrect'    'Timeout'
% % %%
% % 
% % 
% % % Convert text-based cue contrast to a number
% % afContrast = zeros(1,iNumSessions);
% % for k=1:length(acCueMediaFile)
% %     aiInd = strfind(acCueMediaFile{k},'RedCircleFaint');
% %     if ~isempty(aiInd)
% %         iDot = find(acCueMediaFile{k}=='.', 1,'last');
% %         afContrast(k) = str2num(acCueMediaFile{k}(aiInd(1)+14:iDot-1));
% %     else
% %         aiInd = strfind(acCueMediaFile{k},'RedCircle');
% %               iDot = find(acCueMediaFile{k}=='.', 1,'last');
% %               fNumber = str2num(acCueMediaFile{k}(aiInd(1)+9:iDot-1));
% %               if isempty(fNumber)
% %                   fNumber = 255;
% %               end;
% %           afContrast(k) = fNumber;
% % 
% %     end
% %     fprintf('%s\n',acCueMediaFile{k});
% % end
% % 
% % strctPopulationResult.m_afContrast = afContrast;
% % 
% % strctPopulationResult.m_strctBootstrap = strctBootstrap;
% % strctPopulationResult.m_a3fNumTrialsNoStim = a3fNumTrialsNoStim;
% % strctPopulationResult.m_a3fNumTrialsStim = a3fNumTrialsStim;
% % strctPopulationResult.m_a2fChiSquare = a2fChiSquare;
% % strctPopulationResult.m_aiNumCorrect = aiNumCorrect;
% % strctPopulationResult.m_aiNumIncorrect = aiNumIncorrect;
% % strctPopulationResult.m_acSubject = acSubject;
% % %strPopulationFile = 'D:\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\MemorySaccadeTask_PopulationData';
% % %fprintf('Saving things to %s...',strPopulationFile);
% % %save(strPopulationFile,'strctPopulationResult');
% % fprintf('Done!\n');
% % 

% 
% 
%     if 0
%     % Maximal response, according to saccade...
%     [fDummy, iMaxTrialIndex]=max( a2fAvgFiringRateSac(iUnitIter,:));
%         iMaxTrialTypeIndex = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iMaxTrialIndex,1})));
%         iMaxTrialTypeStimIndex = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iMaxTrialIndex,2})));
%     
%      a2fMaximalResponse(iUnitIter,:) = nanmean(strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeIndex,iCorrectIndex}.m_strctRasterCue.m_a2fSmoothRaster,1);
%      a2fMaximalResponseStim(iUnitIter,:) = nanmean(strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeStimIndex,iCorrectIndex}.m_strctRasterCue.m_a2fSmoothRaster,1);
%     
%     figure(12);
%     clf;
%     subplot(1,2,1);
%     hold on;
% 
%     afSig = zeros(1,4001);
%     for k=1:4001
%         afX1 = strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeIndex,iCorrectIndex}.m_strctRasterCue.m_a2fSmoothRaster(:,k);
%         afX2 = strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeStimIndex,iCorrectIndex}.m_strctRasterCue.m_a2fSmoothRaster(:,k);
%         afSig(k) = ranksum( afX1,afX2);
%     end
%     astrctIntervals = fnGetIntervals(afSig<0.01);
%     for k=1:length(astrctIntervals)
%         x=astrctIntervals(k).m_iStart-1000;
%         w=astrctIntervals(k).m_iLength;
%         rectangle('Position',[x 0 w 90],'edgecolor','none','facecolor',[0.6 0.6 0.6]);
%     end
%     
%     afNonStim = nanmean(strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeIndex,iCorrectIndex}.m_strctRasterCue.m_a2fSmoothRaster,1);
%     afStim = nanmean(strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeStimIndex,iCorrectIndex}.m_strctRasterCue.m_a2fSmoothRaster,1);
%     fRange = max([afNonStim,afStim]);
%        rectangle('Position',[200 0 400 1],'edgecolor','none','facecolor','g');
%        rectangle('Position',[0 0 50 1],'edgecolor','none','facecolor','r');
%          plot(-1000:3000,afNonStim,'color',[0 0 0],'linewidth',2);
%         plot(-1000:3000,afStim,'color',[0 0 1],'linewidth',2);
%     axis([-100 700 0 1.1*fRange]);
%     
%     subplot(1,2,2);cla
%  hold on;
% 
%     afSig = zeros(1,4001);
%     for k=1:4001
%         afX1 = strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeIndex,iCorrectIndex}.m_strctRasterSaccade.m_a2fSmoothRaster(:,k);
%         afX2 = strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeStimIndex,iCorrectIndex}.m_strctRasterSaccade.m_a2fSmoothRaster(:,k);
%         afSig(k) = ranksum( afX1,afX2);
%     end
%     astrctIntervals = fnGetIntervals(afSig<0.01);
%     for k=1:length(astrctIntervals)
%         x=astrctIntervals(k).m_iStart-1000;
%         w=astrctIntervals(k).m_iLength;
%         rectangle('Position',[x 0 w 110],'edgecolor','none','facecolor',[0.6 0.6 0.6]);
%     end
%     afNonStim = nanmean(strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeIndex,iCorrectIndex}.m_strctRasterSaccade.m_a2fSmoothRaster,1);
%     afStim = nanmean(strctTmp.strctUnit.m_a2cTrialStats{iMaxTrialTypeStimIndex,iCorrectIndex}.m_strctRasterSaccade.m_a2fSmoothRaster,1);
%     fRange = max([afNonStim,afStim]);
%     
%          plot(-1000:3000,afNonStim,'color',[0 0 0],'linewidth',2);
%         plot(-1000:3000,afStim,'color',[0 0 1],'linewidth',2);
%     axis([-700 200 0 1.1*fRange]);    
%     plot([0 0],[0 1.1*fRange],'m','linewidth',2);
%    % P=get(gcf,'position');P(3:4)=[  388         148];set(gcf,'position',P);
%     end
%     