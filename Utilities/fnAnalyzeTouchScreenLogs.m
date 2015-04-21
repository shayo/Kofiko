% Analyze Touch Screen Statistics for DMS
strFolder = 'D:\Data\Doris\Electrophys\Houdini\Touch Screen Training\';
astrctLogFiles = dir([strFolder,'*.mat']);
iNumLogFiles = length(astrctLogFiles);
aiNumTrials = zeros(1,iNumLogFiles);
afPercCorrect = zeros(1,iNumLogFiles);

for iLogIter=1:iNumLogFiles
    fprintf('Now Analyzing %s\n',astrctLogFiles(iLogIter).name);
    strctKofiko = load([strFolder,astrctLogFiles(iLogIter).name]);
    iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Touch Force Choice');
    strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};
    iNumTrials = length(strctParadigm.acTrials.Buffer)-1;
    acDesignNames = fnCellStructToArray(strctParadigm.ExperimentDesigns.Buffer(2:end),'m_strDesignFileName');
     
    [acUniqueDesignNames, ~, aiDesignIndexToUnique] = unique(acDesignNames);
    iNumUniqueDesigns = length(acUniqueDesignNames);
    
    fprintf('  - %d Trials in %d design(s) found\n',iNumTrials,iNumUniqueDesigns);
    aiNumTrials(iLogIter) = iNumTrials;
    afTrialsTS = strctParadigm.acTrials.TimeStamp(2:end);
    afDesignOnsetTS = [strctParadigm.ExperimentDesigns.TimeStamp(2:end),Inf];
    aiTrialMappedToUniqueDesign = fnMyInterp1(afDesignOnsetTS,[aiDesignIndexToUnique,NaN],afTrialsTS);
    % Iterate over unique designs.
    for iDesignIter=1:iNumUniqueDesigns
        [strPath,strFile]=fileparts(acUniqueDesignNames{iDesignIter});
        fprintf('      * Design %s\n',strFile);
        aiRelevantTrialInd = 1+find(aiTrialMappedToUniqueDesign == iDesignIter);
        acRelevantTrials = strctParadigm.acTrials.Buffer(aiRelevantTrialInd);
        % Now compute statistics 
        iNumCorrect=0;
        iNumIncorrect = 0;
        iNumTimeout = 0;
        afReactionTimeCorrect = [];
        afReactionTimeIncorrect = [];
        a2iCuesOnCorrect = zeros(0,2);
        a2iCuesOnIncorrect = zeros(0,2);
        for k=1:length(acRelevantTrials)
            if isfield(acRelevantTrials{k}.m_strctTrialOutcome,'m_strResult')
                switch lower(acRelevantTrials{k}.m_strctTrialOutcome.m_strResult)
                    case 'correct'
                        iNumCorrect=iNumCorrect+1;
                        afReactionTimeCorrect(iNumCorrect) = acRelevantTrials{k}.m_strctTrialOutcome.m_afTouchChoiceTS-acRelevantTrials{k}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko;
                        a2iCuesOnCorrect(iNumCorrect,:) = [acRelevantTrials{k}.m_astrctCueMedia(1).m_iMediaIndex,acRelevantTrials{k}.m_astrctCueMedia(2).m_iMediaIndex];
                    case 'incorrect'
                        iNumIncorrect=iNumIncorrect+1;
                        afReactionTimeIncorrect(iNumIncorrect) = acRelevantTrials{k}.m_strctTrialOutcome.m_afTouchChoiceTS-acRelevantTrials{k}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko;
                        a2iCuesOnIncorrect(iNumIncorrect,:) = [acRelevantTrials{k}.m_astrctCueMedia(1).m_iMediaIndex,acRelevantTrials{k}.m_astrctCueMedia(2).m_iMediaIndex];
                    case 'touch fixation'
                        % Ignore
                    case 'aborted;touchoutsidefixation'
                        % Ignore
                    case 'timeout'
                        iNumTimeout = iNumTimeout+1;
                    otherwise
                        dbg = 1;
                end
            end
        end
        iNumAnswered = iNumCorrect+iNumIncorrect;
        pout=fnMyBinomTest(iNumCorrect,iNumCorrect+iNumIncorrect,0.5,'two');
        fprintf('      * Percent correct : %.2f%% (%d / %d trials), p = %.5f\n',1e2*iNumCorrect/(iNumCorrect+iNumIncorrect),iNumCorrect,iNumCorrect+iNumIncorrect,pout);
        if iDesignIter == 1
            afPercCorrect(iLogIter) = 1e2*iNumCorrect/(iNumCorrect+iNumIncorrect);
        end
        
        % how likely is it to observe this result?
         iNumSameTrialsCorrect = sum(a2iCuesOnCorrect(:,1) == a2iCuesOnCorrect(:,2));
        iNumDiffTrialsCorrect = sum(a2iCuesOnCorrect(:,1) ~= a2iCuesOnCorrect(:,2));
        iNumSameTrialsIncorrect = sum(a2iCuesOnIncorrect(:,1) == a2iCuesOnIncorrect(:,2));
        iNumDiffTrialsIncorrect = sum(a2iCuesOnIncorrect(:,1) ~= a2iCuesOnIncorrect(:,2));
        
        fprintf('      * Correct Same: %.2f%%, Correct Diff: %.2f%%, Incorrect Same: %.2f%%, Incorrect Diff: %.2f%%\n',...
            1e2*iNumSameTrialsCorrect/iNumAnswered,...
            1e2*iNumDiffTrialsCorrect/iNumAnswered,...
            1e2*iNumSameTrialsIncorrect/iNumAnswered,...
            1e2*iNumDiffTrialsIncorrect/iNumAnswered);
            
        fprintf('      * Median reaction time: %.2f (sec)\n',median([afReactionTimeCorrect,afReactionTimeIncorrect]))
        fprintf('      * Median reaction time, correct %.2f (sec), incorrect : %.2f (sec) \n',median(afReactionTimeCorrect),median(afReactionTimeIncorrect));
        
    end

end

figure(11);
clf;
[a,b]=plotyy(1:iNumLogFiles,aiNumTrials,1:iNumLogFiles,afPercCorrect);
set(get(a(1),'YLabel'),'String','Num Trials');
set(get(a(2),'YLabel'),'String','Perc Correct');
