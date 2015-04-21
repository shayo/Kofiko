function fnTouchForceChoiceBehaviorAnalysis(strctKofiko,strRawFolder,strSession,strctSync, strOutputFolder)
%
strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strTimeDate(strTimeDate == ':') = '-';
strTimeDate(strTimeDate == ' ') = '_';

acParadigms = fnCellStructToArray( strctKofiko.g_astrctAllParadigms,'m_strName');
iParadigmIndex = find(ismember(acParadigms,'Touch Force Choice'),1,'first');
if isempty(iParadigmIndex)
    fnWorkerLog('Session : %s does not contain force choice. Aborting!',strSession);
    return;
end;

strctParadigm = strctKofiko.g_astrctAllParadigms{iParadigmIndex};
if ~isfield(strctParadigm,'ExperimentDesigns')
    fnWorkerLog('No designs loaded. Aborting.');
    return;
end;
iNumDesigns = length(strctParadigm.ExperimentDesigns.Buffer);
acAllDesigns = {};
for iIter=1:iNumDesigns
    if ~isempty(strctParadigm.ExperimentDesigns.Buffer{iIter})
        acAllDesigns{iIter} = strctParadigm.ExperimentDesigns.Buffer{iIter}.m_strDesignFileName;
    else
        acAllDesigns{iIter} = '';
    end
end
acUniqueDesigns = unique(setdiff(acAllDesigns,{''}));
iNumUniqueDesigns = length(acUniqueDesigns);
fnWorkerLog('%d unique designs were loaded',iNumUniqueDesigns);

afDesignOnsetTimeStampsAug=  [strctParadigm.ExperimentDesigns.TimeStamp,Inf];

iNumTrials = length(strctParadigm.acTrials.TimeStamp);

iCounter = 1;
for iUniqueDesignIter=1:iNumUniqueDesigns
    strDesignName = acUniqueDesigns{iUniqueDesignIter};
    [strPath,strShortDesignName]=fileparts(strDesignName);
    fnWorkerLog('* Design: %s (%s)',strShortDesignName,strDesignName)
    
    % Find the relevant design onset and offset
    aiInd = find(ismember(acAllDesigns, strDesignName));
    strctDesign = strctParadigm.ExperimentDesigns.Buffer{aiInd(1)};
    
    abRelevantTrials = zeros(1,iNumTrials)>0;
    for iIter=1:length(aiInd)
        fOnset_TS_Kofiko = afDesignOnsetTimeStampsAug(aiInd(iIter));
        fOffset_TS_Kofiko = afDesignOnsetTimeStampsAug(aiInd(iIter)+1);
        % Find relevant trials
        abRelevantTrials(strctParadigm.acTrials.TimeStamp >=fOnset_TS_Kofiko & strctParadigm.acTrials.TimeStamp <=fOffset_TS_Kofiko) = true;
    end
    if sum(abRelevantTrials) == 0
        fnWorkerLog(' - Skipping. no trials found for this design');
        continue;
    end;
    
    % OK, now that we have collected all relevant trials, how many
    % different trial types do we have for this design?
    aiRelevantTrials = find(abRelevantTrials);
    acTrials = strctParadigm.acTrials.Buffer(abRelevantTrials);
    
    aiTrialTypes = fnCellStructToArray(strctParadigm.acTrials.Buffer(abRelevantTrials),'m_iTrialType');
    [aiUniqueTrialTypes, Dummy, aiTrialTypeToUniqueTrialType] = unique(aiTrialTypes);
%   acTrials=fnReanalyzeSaccadeTrials(acTrials,strRawFolder,strSession,strctSync,strctKofiko);
   
    
    iNumUniqueTrialTypes = length(aiUniqueTrialTypes);
    aiNumTrialRep = histc(aiTrialTypeToUniqueTrialType,1:iNumUniqueTrialTypes);
    fnWorkerLog('Found %d trials, which belong to %d unique trial types', length(aiTrialTypes), iNumUniqueTrialTypes);
    
    acAllOutcomes = cell(1, length(aiRelevantTrials));
    for j=1:length(aiRelevantTrials)
        acAllOutcomes{j}=strctParadigm.acTrials.Buffer{aiRelevantTrials(j)}.m_strctTrialOutcome.m_strResult;
    end
    [acUniqueOutcomes,Dummy, aiOutcomeToUnique] = unique(acAllOutcomes);
    iNumUniqueOutcomes = length(acUniqueOutcomes);

    
    
    
    % now iterate over each trial type and compute histogram of outcomes.
    
    a2cTrialInd = cell(iNumUniqueTrialTypes, iNumUniqueOutcomes);
    a2fNumTrials = zeros(iNumUniqueTrialTypes, iNumUniqueOutcomes);
    acUniqueTrialNames = cell(1,iNumUniqueTrialTypes);
    for iUniqueTrialIter=1:iNumUniqueTrialTypes
        iTrialType = aiUniqueTrialTypes(iUniqueTrialIter);
        strctTrialType = strctDesign.m_acTrialTypes{iTrialType};
        strTrialName = strctTrialType.TrialParams.Name;
        
        acUniqueTrialNames{iUniqueTrialIter} =strTrialName;
        aiLocalInd = find(aiTrialTypes == iTrialType);
        aiSameTrialTypeInd = aiRelevantTrials(aiLocalInd);
        
        % Add saccade information to trial?
        acTrialsOfSameType = strctParadigm.acTrials.Buffer(aiSameTrialTypeInd);
 
        %acTrialsOfSameType = fnAnalyzeMemorySaccadeTrials(acTrialsOfSameType,strctKofiko,strctSync,strRawFolder,strSession);
           
        iNumSameTrialType = length(acTrialsOfSameType);
        fnWorkerLog('%d trials of  Trial Type : %s',iNumSameTrialType,strTrialName);drawnow
        acTrialOutcome = cell(1,iNumSameTrialType);
        for k=1:iNumSameTrialType
            acTrialOutcome{k} = acTrialsOfSameType{k}.m_strctTrialOutcome.m_strResult;
        end
        for iUniqueOutcomeIter=1:iNumUniqueOutcomes
            aiInd2 = find(ismember(acTrialOutcome, acUniqueOutcomes{iUniqueOutcomeIter}));
            %aiGlobalTrialInd = aiSameTrialTypeInd(aiInd2);
            %acSameTrialsSameOutcome = acTrialsOfSameType(aiInd2);
            a2cTrialInd{iUniqueTrialIter,iUniqueOutcomeIter} = aiLocalInd(aiInd2);
            %fprintf('Processing outcome %s (%d trials) \n',acUniqueOutcomes{iUniqueOutcomeIter}, length(acSameTrialsSameOutcome));
            a2fNumTrials(iUniqueTrialIter, iUniqueOutcomeIter) =sum(ismember(acTrialOutcome, acUniqueOutcomes{iUniqueOutcomeIter}));
        end
    end
    
    a2fNumTrialsNormalized = a2fNumTrials ./ repmat(sum(a2fNumTrials,2),1, length(acUniqueOutcomes));
   clear strctDesignStat
   strctDesignStat.m_strDisplayFunction = 'fnDefaultForceChoiceBehaviorStatistics';
   strctDesignStat.m_acTrials = acTrials;
   strctDesignStat.m_astrctTrialsPostProc = fnExtractPostProcessingData(acTrials, strctKofiko, strctSync, strRawFolder,strSession);
   
   strctDesignStat.m_strDesignName = strDesignName;
   strctDesignStat.m_strctDesign = strctDesign;
   strctDesignStat.m_acUniqueOutcomes = acUniqueOutcomes;
   strctDesignStat.m_acUniqueTrialNames = acUniqueTrialNames;
   strctDesignStat.m_aiUniqueTrialTypes = aiUniqueTrialTypes;
   strctDesignStat.m_a2cTrialsIndicesSorted = a2cTrialInd;
   strctDesignStat.m_a2fNumTrials = a2fNumTrials;
   strctDesignStat.m_a2fNumTrialsNormalized = a2fNumTrialsNormalized;
   strctDesignStat.m_aiTrialTypeMappedToUnique = aiTrialTypeToUniqueTrialType;
   strctDesignStat.m_aiTrialOutcomeMappedToUnique = aiOutcomeToUnique;

    strctDesignStat = fnAddAttribute(strctDesignStat,'Subject', strSubject);
    strctDesignStat = fnAddAttribute(strctDesignStat,'TimeDate', strctKofiko.g_strctAppConfig.m_strTimeDate);
    strctDesignStat = fnAddAttribute(strctDesignStat,'Type','Behavior Statistics');
    strctDesignStat = fnAddAttribute(strctDesignStat,'Paradigm','Touch Force Choice');
    strctDesignStat = fnAddAttribute(strctDesignStat,'Design', strShortDesignName);
    strctDesignStat = fnAddAttribute(strctDesignStat,'NumTrials',  num2str(sum(abRelevantTrials)));

    strStatFile = [strOutputFolder, filesep, strSubject,'-',strTimeDate,'_TouchForceChoice_BehaviorStat_',strShortDesignName];
    fprintf('Saving things to %s...',strStatFile);
    
    save(strStatFile,'strctDesignStat','-V6');
    fprintf('Done!\n');
end


return;


strNow = datestr(now);
strNow(strNow == ':' ) = '-';
strNow(strNow == ' ' ) = '_';
strReportsFile = [strReportsFolder,strNow ,'_AnalyzedTrials.ps'];
strReportsFilePDF = [strReportsFolder,strNow,'_AnalyzedTrials.pdf'];

a2cTrialStat = cell(iNumUniqueTrialTypes, iNumUniqueOutcomes);
a2cTrialStat{iUniqueTrialIter, iUniqueOutcomeIter} = fnAnalyzeMemorySaccadeTrials(acSameTrialsSameOutcome,strctKofiko,strctSync,strRawFolder,strSession,aiGlobalTrialInd,strReportsFile,strTrialName );
ps2pdf('psfile',strReportsFile,'pdffile',strReportsFilePDF);

%  fnAnalyzeMemorySaccadeTrials({strctParadigm.acTrials.Buffer{8}},strctKofiko,strctSync,strRawFolder,strSession,8,strReportsFile,'');



figure(12);clf;
barh(1:iNumUniqueTrialTypes,a2fNumTrialsNormalized)
legend(acUniqueOutcomes)
set(gca,'ytick', 1:iNumUniqueTrialTypes,'yticklabel',acUniqueTrialNames);
xlabel('Percentage of trials');
figure(13);clf;
bar(a2fNumTrialsNormalized,'stacked');
legend(acUniqueOutcomes,'location','northoutside')
set(gca,'ylim',[0 1])
ylabel('Percentage of trials');
set(gca,'xtick', 1: iNumUniqueTrialTypes, 'xticklabel',acUniqueTrialNames);
xticklabel_rotate;

aiNewOrder = [1, 2,10,3,11,4,12,5,13,6,14,7,15,14,9,8,16];
figure(14);clf;
bar(a2fNumTrialsNormalized(aiNewOrder,:),'stacked');
legend(acUniqueOutcomes,'location','northoutside')
set(gca,'ylim',[0 1])
ylabel('Percentage of trials');
set(gca,'xtick', 1: iNumUniqueTrialTypes, 'xticklabel',acUniqueTrialNames(aiNewOrder));
xticklabel_rotate;

figure(14);clf;
bar(1:iNumUniqueTrialTypes, aiNumTrialRep)
set(gca,'xtick',1:iNumUniqueTrialTypes);
ylabel('Num Trials');
xlabel('Trial Type');
figure(15);
clf;
bar(a2fLatency)
legend(acUniqueOutcomes,'location','northoutside')
set(gca,'xtick', 1: iNumUniqueTrialTypes);%, 'xticklabel',acUniqueTrialNames);
set(gca,'ylim',[0 1.5]);
xticklabel_rotate;


[acUniqueOutcomes,Dummy,aiOutcomeToUnique] = unique(acTrialOutcome);
iNumUniqueOutcomes = length(acUniqueOutcomes);
aiUniqueTrialOutcomeCount = histc(aiOutcomeToUnique,1:iNumUniqueOutcomes);
fprintf('  + %s\n',strTrialName);
for k=1:iNumUniqueOutcomes
    fMeanLatency = nanmean(afLatency(aiOutcomeToUnique == k));
    fStdLatency = nanstd(afLatency(aiOutcomeToUnique == k));
    fprintf('         - %-3d Trials (%.2f%%) : %s,   Lateny : %.2f +- %.2f\n',...
        aiUniqueTrialOutcomeCount(k),  aiUniqueTrialOutcomeCount(k)/iNumSameTrialType*100,acUniqueOutcomes{k},fMeanLatency,fStdLatency);
end

%         figure(12);
%         clf;
%         barh(1:iNumUniqueOutcomes, aiUniqueTrialOutcomeCount)
%         set(gca,'yticklabel',acUniqueOutcomes)
%         xlabel('# Trials');
%         title(strTrialName);


function astrctTrialsPostProc = fnExtractPostProcessingData(acTrials, strctKofiko, strctSync, strRawFolder,strSession)
fprintf('Adding eye position information...');
for iTrialIndex=1:length(acTrials)
    if mod(iTrialIndex,100) == 0
        fprintf('%d out of %d\n',iTrialIndex,length(acTrials));
        drawnow
    end
       if isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_afSelectedChoiceTS')
            fSaccadeTSPlexon = fnTimeZoneChange(acTrials{iTrialIndex}.m_strctTrialOutcome.m_afSelectedChoiceTS(1), strctSync,'Kofiko','Plexon');
        else
            fSaccadeTSPlexon = NaN;
        end
        
        if isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_fChoicesOnsetTS_StatServer')
            fChoiceOnsetTSPlexon = fnTimeZoneChange(acTrials{iTrialIndex}.m_strctTrialOutcome.m_fChoicesOnsetTS_StatServer, strctSync, 'StimulusServer','Plexon');
        else
            fChoiceOnsetTSPlexon = NaN;
        end
        
        if  isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_afCueOnset_TS_StimulusServer')
            fCueOnsetPlexon = fnTimeZoneChange( acTrials{iTrialIndex}.m_strctTrialOutcome.m_afCueOnset_TS_StimulusServer(1), strctSync, 'StimulusServer','Plexon');
        else
            if isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_fChoicesOnsetTS_Kofiko')
                fEstimatedCueOnsetKofikoTS = acTrials{iTrialIndex}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko-acTrials{iTrialIndex}.m_strctMemoryPeriod.m_fMemoryPeriodMS/1e3-acTrials{iTrialIndex}.m_astrctCueMedia(1).m_fCuePeriodMS/1e3;
                fCueOnsetPlexon = fnTimeZoneChange( fEstimatedCueOnsetKofikoTS, strctSync, 'Kofiko','Plexon');
            else
                fCueOnsetPlexon = NaN;
            end
        end
        
        fFixationOnsetPlexon = fnTimeZoneChange( acTrials{iTrialIndex}.m_strctTrialOutcome.m_fFixationSpotFlipTS_StimulusServer, strctSync, 'StimulusServer','Plexon');
        fFixationRequiredSec = acTrials{iTrialIndex}.m_strctPreCueFixation.m_fPreCueFixationPeriodMS/1e3;
        
        fConstantFixationOnsetPlexonTS = fCueOnsetPlexon-fFixationRequiredSec;
        
        strEyeXfile = [strRawFolder,filesep,strSession,'-EyeX.raw'];
        strEyeYfile = [strRawFolder,filesep,strSession,'-EyeY.raw'];

        fStartSamplingTS_PLX = fFixationOnsetPlexon-0.3;
        if isnan(fSaccadeTSPlexon)
            fEndSamplingTS_PLX = fFixationOnsetPlexon + 1;
        else
            fEndSamplingTS_PLX = fSaccadeTSPlexon+0.3;
        end
      if fEndSamplingTS_PLX < 0 || fStartSamplingTS_PLX < 0
          % We don't have this information in plexon...
          continue;
      end;
      
        [strctEyeX, afPlexonTime] = fnReadDumpAnalogFile(strEyeXfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        [strctEyeY, afPlexonTime] = fnReadDumpAnalogFile(strEyeYfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        % Convert the raw eye position to pixel coordinates.
      
        % Where was the fixation position?
        
        
        afOffsetX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afOffsetY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afEyeXpix = double((strctEyeX.m_afData+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2);
        afEyeYpix = double((strctEyeY.m_afData+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2);
    % median filter raw eye signal with a window of 1 ms to remove
        astrctTrialsPostProc(iTrialIndex).m_fCueOnsetTS_PLX = fCueOnsetPlexon;
        astrctTrialsPostProc(iTrialIndex).m_fChoiceOnsetTSPlexon = fChoiceOnsetTSPlexon;
        astrctTrialsPostProc(iTrialIndex).m_fSaccadeTSPlexon = fSaccadeTSPlexon;
        astrctTrialsPostProc(iTrialIndex).m_afEyeTS_PLX= afPlexonTime;
        astrctTrialsPostProc(iTrialIndex).m_afEyeXpixSmooth = fndllBilateral1D(medfilt1(afEyeXpix,5),70,60,30);
        astrctTrialsPostProc(iTrialIndex).m_afEyeYpixSmooth = fndllBilateral1D(medfilt1(afEyeYpix,5),70,60,30);
end
fprintf('Done!\n');
return;

