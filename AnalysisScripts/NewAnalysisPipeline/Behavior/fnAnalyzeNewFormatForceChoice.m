% Script to analyze behavior from force choice paradigm.... ?
strSubject = 'Feivel';
strFolder = 'D:\Data\Doris\Behavior\LogsFromTouch\Bert And Fievel\';
astrctFiles = dir([strFolder,'*',strSubject,'.mat']);
% astrctFiles(1).name = '110822_124034_Bert.mat';

iNumLogFiles = length(astrctFiles);
fprintf('%d log files found!\n', iNumLogFiles);
astrctStat = [];
dbstop if error
figure(10);clf;
for iKofikoLogIter=iNumLogFiles:-1:1
    strctKofiko=load([strFolder, astrctFiles(iKofikoLogIter).name]);
    fprintf('Log file : %s\n',astrctFiles(iKofikoLogIter).name);
    strParadigmName =  'Touch Force Choice';
    
    iParadigmIndex = fnFindParadigmIndex(strctKofiko,strParadigmName);
    strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};
    
    %% Identify all unique designs that were run during this session
    iNumDesigns = length(strctParadigm.ExperimentDesigns.Buffer)-1;
    acDesignName = cell(1,iNumDesigns);
    for iDesignIter=1:iNumDesigns
        acDesignName{iDesignIter} = strctParadigm.ExperimentDesigns.Buffer{1+iDesignIter}.m_strDesignFileName;
    end
    [acUniqueDesigns, aiUniqueDesignToArbitraryDesignIndex, aiDesignIndexToUniqueDesignIndex] = unique(acDesignName);
    iNumUniqueDesigns = length(acUniqueDesigns);
    
    iNumTrials = length(strctParadigm.acTrials.Buffer)-1;
    aiTrialToDesignIndex= fnMyInterp1(strctParadigm.ExperimentDesigns.TimeStamp(2:end), [1:length(strctParadigm.ExperimentDesigns.TimeStamp)],...
        strctParadigm.acTrials.TimeStamp(2:end));
    aiTrialToUniqueDesignIndex  =aiDesignIndexToUniqueDesignIndex(aiTrialToDesignIndex);
    
    % Plot  precent time working...
    aiNumTrialsPerMinute = histc(strctParadigm.acTrials.TimeStamp, min(strctParadigm.acTrials.TimeStamp):60:max(strctParadigm.acTrials.TimeStamp));
    afAvgNumTrials = conv(aiNumTrialsPerMinute,1/10*ones(1,10),'same');
    afAvgNumTrialsNorm =afAvgNumTrials/max(afAvgNumTrials);
    figure(10);hold on;
    plot(afAvgNumTrials)
    xlabel('Minutes from start');
    ylabel('Number of trials per minute');
    %% Iterate over designs and collect trials
    fprintf('%d unique designs were executed in this session\n', length(acUniqueDesigns));
    for iDesignIter=1:iNumUniqueDesigns
        strctDesign =  strctParadigm.ExperimentDesigns.Buffer{1+aiUniqueDesignToArbitraryDesignIndex(iDesignIter)};
        fprintf('Design : %s\n',strctDesign.m_strDesignFileName);
        aiRelevantTrials = find(aiTrialToUniqueDesignIndex == iDesignIter);
        iNumTrials=length(aiRelevantTrials);
        if iNumTrials == 0
            continue;
        end;
        acTrialsInUniqueDesign = strctParadigm.acTrials.Buffer(1+aiRelevantTrials);
        % Now, all relevant trials belong to the same general "design".
        % However, each trial is of a different trial type.
        aiTrialTypes = fnCellStructToArray(acTrialsInUniqueDesign, 'm_iTrialType');
        
        [aiUniqueTrialTypes, Dummy, aiTrialTypeToUniqueTrialType] = unique(aiTrialTypes);
        iNumUniqueTrialTypes = length(aiUniqueTrialTypes);
        aiNumTrialsPerUniqueTrialType = histc(aiTrialTypes, aiUniqueTrialTypes);
        fprintf('%d trials were found for this design, and they belong to  %d different trial types. \n', iNumTrials,iNumUniqueTrialTypes);
        clear astrctSortedTrials
        aiNumCorrect = zeros(1,iNumUniqueTrialTypes);
        for iTrialTypeIter=1:iNumUniqueTrialTypes
            iTrialType = aiUniqueTrialTypes(iTrialTypeIter);
            strctTrialType = strctDesign.m_acTrialTypes{ aiUniqueTrialTypes(iTrialTypeIter)};
            
            aiRelevantTrialsForUniqueType = find(aiTrialTypes == iTrialType);
            astrctSortedTrials(iTrialTypeIter).m_acTrials = acTrialsInUniqueDesign(aiRelevantTrialsForUniqueType);
            
            X=fnCellStructToArray(astrctSortedTrials(iTrialTypeIter).m_acTrials,'m_strctTrialOutcome');
            Y=fnCellStructToArray(X,'m_strResult');
            aiNumCorrect(iTrialTypeIter) = sum(ismember(Y,'Correct'));
            
            astrctSortedTrials(iTrialTypeIter).m_strctTrialType = strctTrialType;
            
            fprintf('%d Trials, %d Correct (%.2f) of type %d (%s) \n', aiNumTrialsPerUniqueTrialType(iTrialTypeIter),  ...
                aiNumCorrect(iTrialTypeIter),aiNumCorrect(iTrialTypeIter)/aiNumTrialsPerUniqueTrialType(iTrialTypeIter)*1e2, iTrialType, strctTrialType.TrialParams.Name);
            
            
        end
        % Call analysis script by design ?
        strctGeneralInfo.m_strSubjectName = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
        strctGeneralInfo.m_strTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
        
        switch strctDesign.m_strDesignFileName
            case '\\touch\StimulusSet\IdentityMatching\IdentityMatchingDMS_Bert_ReducedSet.xml'
              strctStat = fnAnalyzeIdentityMatchingTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign);
            case '\\touch\StimulusSet\IdentityMatching\IdentityMatchingDMS_Fievel_ReducedSet.xml'
              strctStat = fnAnalyzeIdentityMatchingTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign);
            case '\\touch\StimulusSet\IdentityMatching\IdentityMatchingDMS_Bert.xml'
              strctStat = fnAnalyzeIdentityMatchingTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign);

            case '\\touch\StimulusSet\IdentityMatching\IdentityMatchingDMS_Fievel.xml'
        %strctStat = fnAnalyzeViewDirectionTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko);
                strctStat = fnAnalyzeIdentityMatchingTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign);
        end
        
        if ~isempty(strctStat)
            astrctStat = [astrctStat,strctStat];
        end
    end
end

%%
figure;
iNumIDs = size(strctStat.m_a2fConfusion,1);
imagesc(strctStat.m_a2fConfusion*1e2,[0 100]);colormap hot;colorbar; hold on;
for i=1:iNumIDs
    for j=1:iNumIDs
        if strctStat.m_a2fPValue(i,j) < 0.05
            plot(i,j,'*c');
        end
    end
end


%%
if 0
    
figure(1);clf;
iNumDays = length(astrctStat);
for k=1:iNumDays
    subplot(ceil(sqrt(iNumDays)),floor(sqrt(iNumDays)),k);hold on;
    plot(astrctStat(k).m_afUniqueAngles,astrctStat(k).m_afPercentCorrectAbs,'b');
    plot(astrctStat(k).m_afUniqueAngles,astrctStat(k).m_afPercentCorrectAbs,'ro');
    axis([0 90 0.2 1]);
    box on
    
    title(sprintf('Day %d',k));
end

end