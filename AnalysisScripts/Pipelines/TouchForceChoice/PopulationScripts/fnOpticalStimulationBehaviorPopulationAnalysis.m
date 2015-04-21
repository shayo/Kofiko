function fnOpticalStimulationBehaviorPopulationAnalysis(acDataEntries)
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

% strctEyePopulationOptical=fnOpticalStimulationEyeMovementPopulationAnalysisAux(acDataEntries, false);
% strPopulationOutputfile = 'D:\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\EyeMovementDuringOpticalStimulation_PopulationControl.mat';
% fprintf('saving population data to %s',strPopulationOutputfile);
% save(strPopulationOutputfile,'strctEyePopulationOptical','acDataEntries');
% fprintf('Done!\n');

iNumSessions  = length(acDataEntries);
 a2cTrialNames = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};

a3fNumTrialsNoStim = zeros(8,4, iNumSessions );
a3fNumTrialsStim = zeros(8,4, iNumSessions );
    


a2fChiSquare = zeros(iNumSessions,8);

    % Bootstrapping.
    


% First, look at possible differences for correct responses...
%%
iSessionIter=1;
    strctTmp = load(acDataEntries{iSessionIter}.m_strFile);
    fprintf('Done!\n');

fnPlotBootstrap(strctTmp, a2cTrialNames)

%%



%% Now, run the chi-square test...
% Build the number of trials table...
iNumTrialTypes =8;
iNumOutcomes = 5;
a3iNumberOfTrialsOLD = zeros(iNumSessions, iNumTrialTypes, iNumOutcomes);
a3iNumberOfTrials = zeros(iNumSessions, iNumTrialTypes, iNumOutcomes);
a3iNumberOfTrialsStim = zeros(iNumSessions, iNumTrialTypes, iNumOutcomes);
acTrialTypes = {    'Aborted',    'Correct',    'Incorrect',    'Missing Info',    'Timeout'};

for iSessionIter=1:iNumSessions 
   fprintf('Loading %d out of %d : %s...',iSessionIter,iNumSessions, acDataEntries{iSessionIter}.m_strFile);
    strctTmp = load(acDataEntries{iSessionIter}.m_strFile);
    fprintf('Done!\n');
    
    
    iNumTrials = length(strctTmp.strctDesignStat.m_acTrials);
    acOutcomes = cell(1, iNumTrials);
    for iTrialIter=1:iNumTrials
        if isempty(strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome)
            acOutcomes{iTrialIter}= 'Unknown';
        else
            acOutcomes{iTrialIter} = strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome;
        end
    end
    
    for iTrialTypeIter=1:iNumTrialTypes
        iTrialIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,1})));
        iTrialStimIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,2})));
        
        for iOutcomeIter=1:5
            
            
            
            abOutcome = ismember(lower(acOutcomes),lower(acTrialTypes{iOutcomeIter}));

                a3iNumberOfTrials(iSessionIter,iTrialTypeIter,iOutcomeIter) = ...
                    sum(abOutcome(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialIndex));
                a3iNumberOfTrialsStim(iSessionIter,iTrialTypeIter,iOutcomeIter) = ...
                    sum(abOutcome(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialStimIndex));
            
            if 0
            iOutcomeIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueOutcomes),lower(acTrialTypes{iOutcomeIter}) ));
            if ~isempty(iOutcomeIndex)
                a3iNumberOfTrials(iSessionIter,iTrialTypeIter,iOutcomeIter) = ...
                    sum(strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialIndex) == iOutcomeIndex);
                a3iNumberOfTrialsStim(iSessionIter,iTrialTypeIter,iOutcomeIter) = ...
                    sum(strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialStimIndex) == iOutcomeIndex);
            end
            end
            
        end
    end
end

for iSessionIter=1:iNumSessions
    a2fTrials = squeeze(a3iNumberOfTrials(iSessionIter,:,:));
    a2fTrialsStim = squeeze(a3iNumberOfTrialsStim(iSessionIter,:,:));
    for iTrialTypeIter=1:iNumTrialTypes
        a2iObservedTable = [a2fTrials(iTrialTypeIter,[1,2,3,5]);a2fTrialsStim(iTrialTypeIter,[1,2,3,5])];
        a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
         a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
        a2fChiSquare(iSessionIter,iTrialTypeIter) = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
    end
end
fChiValueThres = chi2inv(1-0.05, 3);

[aiSessions, aiTrialTypes] = find(a2fChiSquare>fChiValueThres);
[aiSessions, aiTmp]=sort(aiSessions)
aiTrialTypes=aiTrialTypes(aiTmp);
% Compute the percent change
[aiSessions, aiTrialTypes]
a2fPercentChange = zeros(length(aiSessions), 4);
for iIter=1:length(aiSessions)
    a2fTrials = squeeze(a3iNumberOfTrials(aiSessions(iIter),:,:));
    a2fTrialsStim = squeeze(a3iNumberOfTrialsStim(aiSessions(iIter),:,:));
    afTrials = a2fTrials(aiTrialTypes(iIter),[1,2,3,5]) ./ sum(a2fTrials(aiTrialTypes(iIter),[1,2,3,5]));
    afTrialsStim = a2fTrialsStim(aiTrialTypes(iIter),[1,2,3,5]) ./ sum(a2fTrialsStim(aiTrialTypes(iIter),[1,2,3,5]));
    
    a2fPercentChange(iIter,:) = 1e2*(afTrialsStim-afTrials);
end

abMonkeyJ=zeros(1,length(acDataEntries))>0;
for i=1:length(acDataEntries)
   if ~isempty(strfind(acDataEntries{i}.m_strFile,'Julien'))
        abMonkeyJ(i) = true;
   end;
end
acPlottedTrialTypes = {    'Aborted',    'Correct',    'Incorrect',      'Timeout'};

for iPlotIter=1:2
figure(900+iPlotIter);
clf;
    
    if iPlotIter == 1
        abMonkey = abMonkeyJ;
    else
        abMonkey = ~abMonkeyJ;
    end
    
    hold on;
    for k=1:4
        plot(k, a2fPercentChange(abMonkey(aiSessions), 5-(k)),'ko');
        plot(k, mean(a2fPercentChange(abMonkey(aiSessions), 5-(k))),'r*');
    end
    plot([0 5],[0 0],'k--');
    axis([0 5 -25 25])
    set(gca,'xtick',1:4);
    set(gca,'xticklabel',[])
    P=get(gcf,'position');P(3:4)=[ 182         141];set(gcf,'position',P);
end





return;




function fnPlotBootstrap(strctTmp, a2cTrialNames)

%     aiRelevantTrials = find(ismember(strctTmp.strctDesignStat.m_acUniqueTrialNames, a2cTrialNames(:,1)));
%      iTimeoutIndex= find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Timeout'));
%     iCorrectIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Correct'));
%     iIncorrectIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Incorrect'));
% %    assert(iCorrectIndex == 2 && iIncorrectIndex == 3 && iTimeoutIndex == 4)
%     % Contrast level ? 
%     for i=1:length(    strctTmp.strctDesignStat.m_strctDesign.m_acTrialTypes)
%         acTrialNames{i} = strctTmp.strctDesignStat.m_strctDesign.m_acTrialTypes{i}.TrialParams.Name;
%     end
% 
%     
%     iRepTrialIndex = find(ismember(acTrialNames,a2cTrialNames{1,1}));
%     
%     strCue = strctTmp.strctDesignStat.m_strctDesign.m_acTrialTypes{iRepTrialIndex}.Cue.CueMedia;
%     iMediaIndex = find(ismember({strctTmp.strctDesignStat.m_strctDesign.m_astrctMedia.m_strName},strCue));
%     acCueMediaFile{iSessionIter} = strctTmp.strctDesignStat.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
%     [~,acSubject{iSessionIter}] = fnFindAttribute(strctTmp.strctDesignStat.m_a2cAttributes,'Subject');
%     
%     aiNumCorrect(iSessionIter) = sum(strctTmp.strctDesignStat.m_a2fNumTrials(aiRelevantTrials,iCorrectIndex));
%     aiNumIncorrect(iSessionIter) = sum(strctTmp.strctDesignStat.m_a2fNumTrials(aiRelevantTrials,iIncorrectIndex));
%     
%     % Statistics about micro stim
%     iAbortedOutcome= find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Aborted;BreakFixationDuringCue'));
%     iIncorrectOutcome = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Incorrect'));
%     a2fPercentChange = zeros(8,4);
%     for iTrialIter=1:8
%         iIndexNoStim = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cTrialNames{iTrialIter,1})));
%         iIndexStim = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cTrialNames{iTrialIter,2})));
%         if ~isempty(iIndexNoStim)
%             a3fNumTrialsNoStim(iTrialIter,:,iSessionIter) = strctTmp.strctDesignStat.m_a2fNumTrials(iIndexNoStim,:);
%         end
%          if ~isempty(iIndexStim)
%             a3fNumTrialsStim(iTrialIter,:,iSessionIter) = strctTmp.strctDesignStat.m_a2fNumTrials(iIndexStim,:);
%          end
%          afNoStimNormalized =  1e2*a3fNumTrialsNoStim(iTrialIter,:,iSessionIter)  / sum( a3fNumTrialsNoStim(iTrialIter,:,iSessionIter) );
%          afStimNormalized = 1e2* a3fNumTrialsStim(iTrialIter,:,iSessionIter) / sum(a3fNumTrialsStim(iTrialIter,:,iSessionIter));
%          a2fPercentChange(iTrialIter,:) = afStimNormalized - afNoStimNormalized;
%          
%          
%          aiErrorTrialsDuringStimulation = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iIndexStim & strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iIncorrectOutcome);
% 
%          aiAbortedTrialsDuringStimulation = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iIndexStim & strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iAbortedOutcome);
%          
%  
% %          figure(100);
% %          clf;
% %         hold on;
% for k=1:length(aiErrorTrialsDuringStimulation)
%     T0 = find(strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeTS_PLX > strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_fCueOnsetTS_PLX,1,'first')-50;
%     T1=  find(strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeTS_PLX > strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_fSaccadeTSPlexon,1,'first');
%     afX = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeXpixSmooth-strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeXpixSmooth(T0);
%     afY = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeYpixSmooth-strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiErrorTrialsDuringStimulation(k)).m_afEyeYpixSmooth(T0);
%     afXCropped = afX(T0:T1) ;
%     afYCropped = afY(T0:T1) ;
%     afVel = [0;sqrt(diff(afXCropped).^2+diff(afYCropped).^2)];
%     T1min = find(afXCropped > 400 |afYCropped > 400 | afXCropped < -400 |afYCropped < -400 | afVel > 25,1,'first');
%     if ~isempty(T1min)
%         strctPopulationResult.m_a2cErrorTrialsStim{iSessionIter,iTrialIter}{k} = [afXCropped(1:T1min),afYCropped(1:T1min),];
%         %plot(afXCropped(1:T1min),afYCropped(1:T1min),'k');
%     else
%         strctPopulationResult.m_a2cErrorTrialsStim{iSessionIter,iTrialIter}{k} = [afXCropped(1:end),afYCropped(1:end),];
%         %plot(afXCropped(1:end),afYCropped(1:end),'k');
%     end
% end
% % 
% % fCenterX=400;
% % fCenterY=300;
% % 
% % for k=1:length(aiAbortedTrialsDuringStimulation)
% %     
% %     afX = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_afEyeXpixSmooth;
% %     afY = strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_afEyeYpixSmooth;
% %     T0 = find( sqrt( (afX-fCenterX).^2+(afY-fCenterY).^2) <= 80,1,'first');
% %     abTmp = zeros(1,length(afX))>0;
% %     abTmp(T0:end)=true;
% %     aiOutOfFixationZone = find( sqrt( (afX-fCenterX).^2+(afY-fCenterY).^2) > 70 & abTmp',1,'first')
% %     
% %     figure(10);clf;
% %         plot(afX,afY);hold on;
% %         for k=1:100:length(afX)
% %             text(afX(k),afY(k),sprintf('%d',k))
% %         end
% %         
% %     
% %     T0 = find(strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_afEyeTS_PLX > strctTmp.strctDesignStat.m_astrctTrialsPostProc(aiAbortedTrialsDuringStimulation(k)).m_fCueOnsetTS_PLX,1,'first');
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
% % 
% %         
% 
% 
% %         axis equal
% %         axis([-400 400 -400 400]);
% %     
%   
%        
%     end
    % bootstrapping the mean ?
     N = 20;
    M = 5000;
    P=0.05;
    iNumOutcomes = 5;
strctBootstrap.N = N;
strctBootstrap.M = M;
strctBootstrap.P = P;

a4iHist = zeros(8,2,iNumOutcomes,N+1);
a4iCumSum= zeros(8,2,iNumOutcomes,N+1);
a3iNumTrials = zeros(8,2,iNumOutcomes);
acOutcomes = {  'Aborted'    'Correct'    'Incorrect'    'Missing Info'    'Timeout'};

for i=1:8
    for j=1:2
        iIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames), lower(a2cTrialNames{i,j})));
        if ~isempty(iIndex)
            aiRelevantTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iIndex);
             
            aiRelevantOutcomesTmp = strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique(aiRelevantTrials);
            aiRelevantOutcomes=zeros(size(aiRelevantOutcomesTmp));
            for iOutcomeIter=1:iNumOutcomes
                iOutcomeIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes, acOutcomes{iOutcomeIter}));
                if ~isempty(iOutcomeIndex)
                    aiRelevantOutcomes(aiRelevantOutcomesTmp == iOutcomeIndex) = iOutcomeIter;
                end
            end
            
            a3iNumTrials(i,j,:) = histc(aiRelevantOutcomes,1:iNumOutcomes);
            iNumTrials = length(aiRelevantTrials);
            a2iRandom = randi(iNumTrials, [M,N]);
            a2iOutcomes = aiRelevantOutcomes(a2iRandom);
            % Hist outcomes.
            for k=1:iNumOutcomes
                aiNumSameOutcome = sum(a2iOutcomes == k,2);
                afHist = histc(aiNumSameOutcome, 0:N);
                 afCumHist = cumsum(afHist) ;
                a4iCumSum(i,j,k,:) = afCumHist;
                a4iHist(i,j,k,:) = afHist;
            end
        end
    end
end
    
% Chi-square inference - does the number of trials deviate from
    % the expected ?
    for i=1:8
        Tmp = squeeze(a3iNumTrials(i,:,:));
        a2iObservedTable = Tmp(:,[2,3]);
        a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
         a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
        afChiSquare(i) = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
    end

    fPThres = chi2inv(1-0.05, 1);
if 1
    figure;clf;
    N=20;
    a2fOutcomeColors = [79,129,189;0,176,80;192,80,77;247,150,70]/255;
    N=strctBootstrap.N;
    M=strctBootstrap.M;
    
    for i=1:8
        %tightsubplot(1,9,i,'Spacing',0.01);
        subplot(1,8,i);
        hold on;
        if afChiSquare(i) > fPThres
            rectangle('position',[0.5 0 21 2],'facecolor',[0.9 0.9 0.9],'edgecolor','none');
        end
        aiPlottedOutcomes = [1,2,3,5];
        for k=1:4
            plot([0 N],0.5*(k-1)*ones(1,2),'k-');
           ahNoStim(i,k)= plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,1,aiPlottedOutcomes(k),:)) / M ,'color',a2fOutcomeColors(k,:),'Linestyle','-','LineWidth',2);
           ahStim(i,k)= plot(0:N,0.5*(k-1)+squeeze(a4iHist(i,2,aiPlottedOutcomes(k),:)) / M ,'color',a2fOutcomeColors(k,:),'linestyle','--','LineWidth',2);
%             plot([N N]*0.25, [0 5],'k--');
        end
%          title(a2cTrialNames{i,1});
        axis([0 N 0 0.5*4]);
        set(gca,'ytick',1:4,'yticklabel',[]);
        set(gca,'xticklabel',[]);
        
    end
%     hLegend=legend([ahNoStim(1,:),ahStim(2,:)],{'Aborted - No Stim','Correct - No Stim','Incorrect - No Stim','Timeout - No Stim',...
%         'Aborted - Stim','Correct - Stim','Incorrect - Stim','Timeout - Stim'},'Location','NorthEastOutside')
%     set(hLegend,'Position',[  0.8310    0.4565    0.1116    0.4792]);
    set(gcf,'position',[789   976   843   117]);


    
end
%     strctPopulationResult.m_acMean{iSessionIter} = a3fMean;
%     strctPopulationResult.m_acHist{iSessionIter} = a4iHist;
%     strctPopulationResult.m_acCumHist{iSessionIter} = a4iCumSum;
%     strctPopulationResult.m_acSig{iSessionIter} = a2bSig;
%     strctPopulationResult.m_acPercentChange{iSessionIter} = a2fPercentChange;
% 
%     strctPopulationResult.m_acDataEntries = acDataEntries;
% strctPopulationResult.m_a2cTrialNames= a2cTrialNames;
% % Outcomes:   'Aborted;BreakFixationDuringCue'    'Correct'    'Incorrect'    'Timeout'
% %%
% 
% 
% % Convert text-based cue contrast to a number
afContrast = zeros(1,iNumSessions);
for k=1:length(acCueMediaFile)
    aiInd = strfind(acCueMediaFile{k},'RedCircleFaint');
    if ~isempty(aiInd)
        iDot = find(acCueMediaFile{k}=='.', 1,'last');
        afContrast(k) = str2num(acCueMediaFile{k}(aiInd(1)+14:iDot-1));
    else
        aiInd = strfind(acCueMediaFile{k},'RedCircle');
              iDot = find(acCueMediaFile{k}=='.', 1,'last');
              fNumber = str2num(acCueMediaFile{k}(aiInd(1)+9:iDot-1));
              if isempty(fNumber)
                  fNumber = 255;
              end;
          afContrast(k) = fNumber;

    end
    fprintf('%s\n',acCueMediaFile{k});
end

strctPopulationResult.m_afContrast = afContrast;
% 
% strctPopulationResult.m_strctBootstrap = strctBootstrap;
% strctPopulationResult.m_a3fNumTrialsNoStim = a3fNumTrialsNoStim;
% strctPopulationResult.m_a3fNumTrialsStim = a3fNumTrialsStim;
% strctPopulationResult.m_a2fChiSquare = a2fChiSquare;
% strctPopulationResult.m_aiNumCorrect = aiNumCorrect;
% strctPopulationResult.m_aiNumIncorrect = aiNumIncorrect;
% strctPopulationResult.m_acSubject = acSubject;
%strPopulationFile = 'D:\Data\Doris\Electrophys\Data For Papers\FEF Optogenetics\MemorySaccadeTask_PopulationData';
%fprintf('Saving things to %s...',strPopulationFile);
%save(strPopulationFile,'strctPopulationResult');
fprintf('Done!\n');
