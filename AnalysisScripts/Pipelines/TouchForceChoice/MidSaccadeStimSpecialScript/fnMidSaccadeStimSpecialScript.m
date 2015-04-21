function fnSaccadeMemoryTaskAnalysis(strctKofiko,strRawFolder,strSession,strctSync, strOutputFolder)
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
    
    if isempty(strfind(strDesignName,'MidSaccadeStim'))
        fprintf('Skipping design %s...\n',strDesignName);
        continue;
    end
    
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
    
    acTrials = fnExtractPostProcessingData(acTrials, strctKofiko, strctSync, strRawFolder,strSession);
    
    
    aiTrialTypes = fnCellStructToArray(strctParadigm.acTrials.Buffer(abRelevantTrials),'m_iTrialType');
    [aiUniqueTrialTypes, Dummy, aiTrialTypeToUniqueTrialType] = unique(aiTrialTypes);
    
    iNumUniqueTrialTypes = length(aiUniqueTrialTypes);
    aiNumTrialRep = histc(aiTrialTypeToUniqueTrialType,1:iNumUniqueTrialTypes);
    fnWorkerLog('Found %d trials, which belong to %d unique trial types', length(aiTrialTypes), iNumUniqueTrialTypes);
    
    % now iterate over each trial type and compute histogram of outcomes.
    acUniqueTrialNames = cell(1,iNumUniqueTrialTypes);
    clear a2cX a2cY a2cXs a2cYs
    for iUniqueTrialIter=1:iNumUniqueTrialTypes
        iTrialType = aiUniqueTrialTypes(iUniqueTrialIter);
        strctTrialType = strctDesign.m_acTrialTypes{iTrialType};
        strTrialName = strctTrialType.TrialParams.Name;
        acUniqueTrialNames{iUniqueTrialIter} =strTrialName;
        
        acTrialsOfSameType = acTrials(find(aiTrialTypeToUniqueTrialType == iUniqueTrialIter));
        abValid = zeros(1,length(acTrialsOfSameType))>0;
        abValidStim = zeros(1,length(acTrialsOfSameType))>0;
        clear a2fX a2fY  a2fXAligned_Sac a2fYAligned_Sac a2fXAligned_Stim a2fYAligned_Stim
        for iTrialIter=1:length(acTrialsOfSameType)
            if isfield(acTrialsOfSameType{iTrialIter},'m_strctPostProccessing') && ~isempty(acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_iSaccadeInitiationIndex)
                abValid(iTrialIter)=true;
                a2fX(iTrialIter,:) = acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeXpixSmooth-acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeXpixSmooth(1);
                a2fY(iTrialIter,:) = acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeYpixSmooth-acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeYpixSmooth(1);
                iSac = acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_iSaccadeInitiationIndex;
                a2fXAligned_Sac(iTrialIter,:) = interp1(1:2000,acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeXpixSmooth, iSac-200:iSac+200);
                a2fYAligned_Sac(iTrialIter,:) = interp1(1:2000,acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeYpixSmooth, iSac-200:iSac+200);
            end
            if isfield(acTrialsOfSameType{iTrialIter},'m_strctPostProccessing') && ~isempty(acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_iIndexOfStimulationStart)
                abValidStim(iTrialIter)=true;
                iStim = acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_iIndexOfStimulationStart;
                a2fXAligned_Stim(iTrialIter,:) = interp1(1:2000,acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeXpixSmooth, iStim-200:iStim+200);
                a2fYAligned_Stim(iTrialIter,:) = interp1(1:2000,acTrialsOfSameType{iTrialIter}.m_strctPostProccessing.m_afEyeYpixSmooth, iStim-200:iStim+200);
            end
            
        end
        if sum(abValid) > 0
            a2cX{iUniqueTrialIter}=a2fX(abValid,:);
            a2cY{iUniqueTrialIter}=a2fY(abValid,:);
       
        
        a2cXs{iUniqueTrialIter}=a2fXAligned_Sac(abValid,:);
        a2cYs{iUniqueTrialIter}=a2fYAligned_Sac(abValid,:);
         end
        if sum(abValidStim) > 0
            a2cXst{iUniqueTrialIter}=a2fXAligned_Stim(abValidStim,:);
            a2cYst{iUniqueTrialIter}=a2fYAligned_Stim(abValidStim,:);
        end
        
    end   

    
    figure(10);
    clf;
    for k=1:12
        subplot(3,4,k);cla;hold on;
        for j=1:size(a2cXs{k},1)
            a2fAligned(j,:) = a2cXs{k}(j,:)-a2cXs{k}(j,1);
            plot(-200:200,a2fAligned(j,:),'color',[0.5 0.5 0.5]);
        end
        if size(a2cXs{k},1) > 0
        plot(-200:200,nanmedian(a2fAligned),'k','LineWidth',2);
        clear a2fAligned
        end
        for j=1:size(a2cXst{12+k},1)
            a2fAligned(j,:) = a2cXs{12+k}(j,:)-a2cXs{12+k}(j,1);
            plot(-200:200,a2fAligned(j,:),'color',[0 0.5 0.5]);
        end
        if size(a2cXst{12+k},1)  > 0
            plot(-200:200,nanmedian(a2fAligned),'r','LineWidth',2);
        end
      
    end

    continue;
    figure(8);
    
    clf;
    for iTrial=1:12
        subplot(3,4,iTrial)
    hold on;
    for k=1:size(a2cXst{12+iTrial},1)
        plot(-200:200,a2cXst{12+iTrial}(k,:)-a2cXst{12+iTrial}(k,1),'k');
        
    end
    afMean=nanmean(a2cXst{12+iTrial});
    plot(-200:200,afMean-afMean(1),'r','LineWidth',2);
    end
    
    figure(5);
    clf;
    for k=1:12
        subplot(3,4,k);hold on;
        afMeanX = nanmean(a2cXs{k});
        afMeanY = nanmean(a2cXs{k});
        afMeanXst = nanmean(a2cXs{12+k});
        afMeanYst = nanmean(a2cXs{12+k});
        plot(-200:200,afMeanX-afMeanX(1),'k');
        plot(-200:200,afMeanXst-afMeanXst(1),'r');
        
        for j=1:401
            afSig(j)=ranksum(a2cXs{k}(:,j), a2cXs{12+k}(:,j));
        end
        aiSig = find(afSig<0.05);
        if ~isempty(aiSig)
            plot(aiSig-200,afMeanX(aiSig)-afMeanX(1),'g.');
        end
    end

        figure(6);
    clf;
    for k=1:12
        subplot(3,4,k);hold on;
        afMeanX = nanmean(a2cXs{k});
        afMeanY = nanmean(a2cXs{k});
        afMeanXst = nanmean(a2cXs{12+k});
        afMeanYst = nanmean(a2cXs{12+k});
        plot(-200:200,afMeanY-afMeanY(1),'k');
        plot(-200:200,afMeanYst-afMeanYst(1),'r');
        
       for j=1:401
            afSig(j)=ranksum(a2cYs{k}(:,j), a2cYs{12+k}(:,j));
        end
        aiSig = find(afSig<0.05);
        if ~isempty(aiSig)
            plot(aiSig-200,afMeanY(aiSig)-afMeanY(1),'g.');
        end
        
    end

    
    
    figure(4);
    clf;
    for k=1:12
        subplot(3,4,k);hold on;
        plot(a2cX{k}',a2cY{k}','k');
        plot(a2cX{k+12}',a2cY{k+12}','r');
    end
    
  
    
   strctDesignStat.m_strDisplayFunction = 'fnDisplayMidSaccadeExperiment';
   strctDesignStat.m_acTrials = acTrials;
   strctDesignStat.m_strDesignName = strDesignName;
   strctDesignStat.m_strctDesign = strctDesign;
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


function acTrials = fnExtractPostProcessingData(acTrials, strctKofiko, strctSync, strRawFolder,strSession)
fprintf('Adding eye position information...');
for iTrialIndex= 1:length(acTrials)
% for iIter=1:length(aiTmp)
%     iTrialIndex = aiTmp(iIter);
     if mod(iTrialIndex,100) == 0
        fprintf('%d out of %d\n',iTrialIndex,length(acTrials));
        drawnow
     end
    
    
    if ~isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_fChoicesOnsetTS_StatServer')
        continue
    end
        fTargetTS_PLX = fnTimeZoneChange(acTrials{iTrialIndex}.m_strctTrialOutcome.m_fChoicesOnsetTS_StatServer, strctSync, 'StimulusServer','Plexon');
    
      
        strEyeXfile = [strRawFolder,filesep,strSession,'-EyeX.raw'];
        strEyeYfile = [strRawFolder,filesep,strSession,'-EyeY.raw'];
        strStimfile = [strRawFolder,filesep,strSession,'-Grass_Train2.raw'];
        fStartSamplingTS_PLX = fTargetTS_PLX;
         fEndSamplingTS_PLX = fStartSamplingTS_PLX + 0.5;        
   
        [strctEyeX, afPlexonTime] = fnReadDumpAnalogFile(strEyeXfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        [strctEyeY, afPlexonTime] = fnReadDumpAnalogFile(strEyeYfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        
        [strctStim, afPlexonTime] = fnReadDumpAnalogFile(strStimfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
            
         
        afOffsetX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afOffsetY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afEyeXpix = double((strctEyeX.m_afData+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2);
        afEyeYpix = double((strctEyeY.m_afData+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2);
        afStim = strctStim.m_afData;
        iIndexOfStimulationStart = find(afStim>50,1,'first');
        pt2fFix = acTrials{iTrialIndex}.m_strctPreCueFixation.m_pt2fFixationPosition;
        pt2fTarget = acTrials{iTrialIndex}.m_strctChoices.m_pt2fFixationPosition;
        afEyeXpixSmooth = fndllBilateral1D(medfilt1(afEyeXpix,5),70,60,30);
        afEyeYpixSmooth = fndllBilateral1D(medfilt1(afEyeYpix,5),70,60,30);
        afTimeMS = (afPlexonTime-afPlexonTime(1))*1e3;
        afDistFromFixationSpot = sqrt( (afEyeXpixSmooth-pt2fFix(1)).^2 + (afEyeYpixSmooth-pt2fFix(2)).^2);
        afDistToTarget = sqrt( (afEyeXpixSmooth-pt2fTarget(1)).^2 + (afEyeYpixSmooth-pt2fTarget(2)).^2);
        
        if (min(afDistToTarget) > 145) || max(abs(afEyeXpixSmooth)) > 3000 || max(abs(afEyeYpixSmooth)) > 3000
            % Trial did not end with a successful saccade or a blink
            continue;
        end
        afVelocity = diff(afDistToTarget);
        iSaccadeInitiationIndex  = find(abs(afVelocity) > 1,1,'first');
        
         if 0
         figure(10);clf;
         subplot(2,2,1);
        hold on;
        plot(afTimeMS,afEyeXpixSmooth-afEyeXpixSmooth(1),'b');
        plot(afTimeMS,afEyeYpixSmooth-afEyeYpixSmooth(1),'r');
        plot(afTimeMS,afStim/10,'c');
        subplot(2,2,2);hold on;
        plot(afTimeMS,afDistFromFixationSpot);
        plot(afTimeMS,afDistToTarget,'k');
        hold on;
        MinDist = min(afDistFromFixationSpot);
        MaxDist = max(afDistFromFixationSpot);
        plot(afTimeMS(iSaccadeInitiationIndex)*ones(1,2),[MinDist,MaxDist],'c');
        
       if ~isempty(iIndexOfStimulationStart)
            plot(afTimeMS(iIndexOfStimulationStart)*ones(1,2),[MinDist,MaxDist],'r');
       end
         subplot(2,2,3);
        plot(afTimeMS(1:end-1),diff(afDistFromFixationSpot));
        hold on;
        MinDist = min(diff(afDistFromFixationSpot));
        MaxDist = max(diff(afDistFromFixationSpot));
       if ~isempty(iIndexOfStimulationStart)
            plot(afTimeMS(iIndexOfStimulationStart)*ones(1,2),[MinDist,MaxDist],'r');
       end
            plot(afTimeMS(iSaccadeInitiationIndex)*ones(1,2),[MinDist,MaxDist],'c');
            
        subplot(2,2,4);
        
        hold on;
        plot(afEyeXpixSmooth,afEyeYpixSmooth,'b');
        plot(pt2fFix(1),pt2fFix(2),'k+');
        text(pt2fFix(1),pt2fFix(2),'S');
        plot(pt2fTarget(1),pt2fTarget(2),'r*');
        if ~isempty(iIndexOfStimulationStart)
            plot(afEyeXpixSmooth(iIndexOfStimulationStart),afEyeYpixSmooth(iIndexOfStimulationStart),'m*');
        end
        axis([0 1980 0 1080])
        title(num2str(iTrialIndex));
        pause;
        end
%     % median filter raw eye signal with a window of 1 ms to remove
         acTrials{iTrialIndex}.m_strctPostProccessing.m_afEyeXpixSmooth = afEyeXpixSmooth;
         acTrials{iTrialIndex}.m_strctPostProccessing.m_afEyeYpixSmooth = afEyeYpixSmooth;
         acTrials{iTrialIndex}.m_strctPostProccessing.m_iIndexOfStimulationStart = iIndexOfStimulationStart;
         acTrials{iTrialIndex}.m_strctPostProccessing.m_iSaccadeInitiationIndex= iSaccadeInitiationIndex;
         
end
fprintf('Done!\n');
return;

