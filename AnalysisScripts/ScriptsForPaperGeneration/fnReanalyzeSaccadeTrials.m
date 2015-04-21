function acTrials=fnReanalyzeSaccadeTrials(acTrials,strRawFolder,strSession,strctSync,strctKofiko,a2fTargetCenter,fFixationRadius,fChoiceRadius,abTrialTypesWithStimulation)
iNumTrials = length(acTrials);

pt2fScreenCenter = strctKofiko.g_strctStimulusServer.m_aiScreenSize(3:4)/2;
strSessionPrefix = [strRawFolder,filesep,strSession];
for iTrialIter=1:iNumTrials
    fprintf('Reanalyzing trial %d out of %d\n',iTrialIter,iNumTrials);
  
    
    strctTrial = acTrials{iTrialIter};
    
    % Infer which is the correct answer from the design juice rewards...
    iCorrectChoiceIndexInTrial = find(cat(1,strctTrial.m_astrctChoicesMedia.m_bJuiceReward));
    pt2fCorrectChoicePos = strctTrial.m_astrctChoicesMedia(iCorrectChoiceIndexInTrial).m_pt2fPosition-pt2fScreenCenter;
    [fDummy,iCorrectChoiceIndex] = min(sqrt((pt2fCorrectChoicePos(1) - a2fTargetCenter(:,1)).^2+(pt2fCorrectChoicePos(2) - a2fTargetCenter(:,2)).^2));
    assert(fDummy == 0);
    % Handle degenerate case in which the monkey aborted early.
    if ~isfield(strctTrial.m_strctTrialOutcome,'m_afCueOnset_TS_StimulusServer') && ...
            ~isfield(strctTrial.m_strctTrialOutcome,'m_fChoicesOnsetTS_Kofiko')
        acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome = 'Aborted';
        acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcomeRelaxed = 'Aborted';
        continue;
    end;
    
    % Handle degenreate case in which we are missing a timestamp
    fTrialLengthSec = strctTrial.m_astrctCueMedia.m_fCuePeriodMS/1e3 + strctTrial.m_astrctCueMedia.m_fCueMemoryPeriodMS/1e3  + ...
        strctTrial.m_strctMemoryPeriod.m_fMemoryPeriodMS/1e3;
    if ~isfield(strctTrial.m_strctTrialOutcome,'m_afCueOnset_TS_StimulusServer') && ...
            isfield(strctTrial.m_strctTrialOutcome,'m_fChoicesOnsetTS_Kofiko')
        % Fake cue onset time stamp (old version did not save this info)
        strctTrial.m_strctTrialOutcome.m_afCueOnset_TS_StimulusServer = strctTrial.m_strctTrialOutcome.m_fChoicesOnsetTS_StatServer - fTrialLengthSec;
    end;
    fTrialTimeoutSec=min(3,strctTrial.m_strctPostTrial.m_fTrialTimeoutMS/1e3);
    
    fTime0_Stat = strctTrial.m_strctTrialOutcome.m_afCueOnset_TS_StimulusServer;
    fTimeCueOnset_PLX = fnTimeZoneChange( fTime0_Stat, strctSync, 'StimulusServer','Plexon');
    fTime1_PLX = fTimeCueOnset_PLX + fTrialLengthSec + fTrialTimeoutSec; % Max trial length;
    
    if fTimeCueOnset_PLX < 0
        % no eye data...
        acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome = 'MissingData';
        acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcomeRelaxed = 'MissingData';
        continue;
    end
    
    [pt2fFirstFixationAfterSaccade, iSaccadeOnset, iFixationOnset,strTrialOutcome,...
        fExitAngle,fAngularAccuracy, fAmplitudeAccuracy, fReactionTimeSec,iSelectedChoice,fTimeDiff,afEyeXpixZero,afEyeYpixZero] = ... 
            fnReanalyzeEyeMovementsAux(acTrials{iTrialIter}, strctKofiko,strctSync, fTrialTimeoutSec, fTimeCueOnset_PLX,fTime1_PLX,...
              strSessionPrefix,pt2fScreenCenter,fFixationRadius,fChoiceRadius,fTrialLengthSec,a2fTargetCenter,iCorrectChoiceIndex);
    
    strctNewTrialOutcome.m_bStimulation = abTrialTypesWithStimulation(strctTrial.m_iTrialType);
    strctNewTrialOutcome.m_iTargetIndex = iCorrectChoiceIndex; % Selected choice
    
    strctNewTrialOutcome.m_iSelectedTarget = iSelectedChoice;
    strctNewTrialOutcome.m_fReactionTimeSec =fReactionTimeSec;
    strctNewTrialOutcome.m_strOutcome =strTrialOutcome;

    
     strctNewTrialOutcome.m_strOutcomeRelaxed =strTrialOutcome;
    if strcmpi(strTrialOutcome,'Incorrect') && fAngularAccuracy < 45
        strctNewTrialOutcome.m_strOutcomeRelaxed ='Correct';
    end
    
    strctNewTrialOutcome.m_iFixationOnset = iFixationOnset;
    strctNewTrialOutcome.m_iSaccadeOnset = iSaccadeOnset;
    strctNewTrialOutcome.m_fTimeDiff = fTimeDiff;
    strctNewTrialOutcome.m_afEyeXpixZero = afEyeXpixZero;
    strctNewTrialOutcome.m_afEyeYpixZero = afEyeYpixZero;
    strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade = pt2fFirstFixationAfterSaccade;
    
    strctNewTrialOutcome.m_fExitAngle = fExitAngle;
    strctNewTrialOutcome.m_fAngularAccuracy= fAngularAccuracy;
    strctNewTrialOutcome.m_fAmplitudeAccuracy = fAmplitudeAccuracy;
    
    acTrials{iTrialIter}.m_strctNewTrialOutcome = strctNewTrialOutcome;
    
    
    
end


return


function [pt2fFirstFixationAfterSaccade, iSaccadeOnset, iFixationOnset,strTrialOutcome,fExitAngle,fAngularAccuracy, fAmplitudeAccuracy, fReactionTimeSec,iSelectedChoice,fTimeDiff,afEyeXpixZero,afEyeYpixZero] = ...
    fnReanalyzeEyeMovementsAux(strctTrial, strctKofiko,strctSync, fTrialTimeoutSec,fTimeCueOnset_PLX,fTime1_PLX,...
    strSessionPrefix,pt2fScreenCenter,fFixationRadius,fChoiceRadius,fTrialLengthSec,a2fTargetCenter,iCorrectChoiceIndex )


strEyeXfile = [strSessionPrefix,'-EyeX.raw'];
strEyeYfile = [strSessionPrefix,'-EyeY.raw'];


% At time 0, eye coordinate should be inside the fixation window, and
% that should have been for the past 500 ms

[strctEyeX, afPlexonTime] = fnReadDumpAnalogFile(strEyeXfile,'Interval',[fTimeCueOnset_PLX,fTime1_PLX]);
[strctEyeY, afPlexonTime] = fnReadDumpAnalogFile(strEyeYfile,'Interval',[fTimeCueOnset_PLX,fTime1_PLX]);


fTimeDiff = afPlexonTime(2)-afPlexonTime(1);

% Convert the raw eye position to pixel coordinates.
afOffsetX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',afPlexonTime, strctSync);
afOffsetY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGainX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',afPlexonTime, strctSync);
afGainY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',afPlexonTime, strctSync);
afEyeXpix = double((strctEyeX.m_afData+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2);
afEyeYpix = double((strctEyeY.m_afData+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2);

afEyeXpixZero = afEyeXpix-pt2fScreenCenter(1);
afEyeYpixZero = afEyeYpix-pt2fScreenCenter(2);

pt2fCorrectTargetPosition =  a2fTargetCenter(iCorrectChoiceIndex,:);


[pt2fFirstFixationAfterSaccade, iSaccadeOnset, iFixationOnset] = fnEstimateFirstFixationPoint(afEyeXpixZero,afEyeYpixZero,fFixationRadius);

% Esimtate saccade accuracy in terms of distance to center of target.
if ~isempty(pt2fFirstFixationAfterSaccade)
    fAmplitudeAccuracy =  sqrt(sum((pt2fFirstFixationAfterSaccade-pt2fCorrectTargetPosition).^2));
else 
    fAmplitudeAccuracy =  NaN;
end

[strTrialOutcome,fExitAngle,fAngularAccuracy, fReactionTimeSec,iSelectedChoice] = fnEstimateResponseWithAllTargets(afEyeXpixZero,afEyeYpixZero,afPlexonTime-fTimeCueOnset_PLX,...
    fFixationRadius,fChoiceRadius,fTrialTimeoutSec,fTrialLengthSec,a2fTargetCenter,iCorrectChoiceIndex);




return


%
%
% dbg =1 ;
% abStimulation = zeros(1,iNumTrials)>0;
% abCorrect = zeros(1,iNumTrials)>0;
% abIncorrect = zeros(1,iNumTrials)>0;
% abTimeout= zeros(1,iNumTrials)>0;
% aiTargetIndex = zeros(1,iNumTrials);
% for iTrialIter=1:iNumTrials
%     if ~isempty(acTrials{iTrialIter}.m_strctNewTrialOutcome)
%         abStimulation(iTrialIter) = acTrials{iTrialIter}.m_strctNewTrialOutcome.m_bStimulation;
%     abCorrect(iTrialIter) = strcmpi(acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome,'Correct');
%     abIncorrect(iTrialIter) = strcmpi(acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome,'Incorrect');
%     abTimeout(iTrialIter) = strcmpi(acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome,'Timeout');
%
%     aiTargetIndex(iTrialIter) = acTrials{iTrialIter}.m_strctNewTrialOutcome.m_iTargetIndex;
%       end
%
% end
%
%
% a2iObservedTable = [sum(abCorrect & ~abStimulation ) sum(abCorrect & abStimulation );
%                     sum(abIncorrect & ~abStimulation ) sum(abIncorrect & abStimulation )];
% a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
% a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
% fChiSquare = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
% fPValue = 1 - chi2cdf(fChiSquare, 1);
% fprintf('Total number of trials: %d\n',iNumTrials);
% fprintf('Discarding trial type information: %.5f\n',fPValue);
%
% fprintf('Per trial:\n');
% for iTargetIter=1:8
%     a2iObservedTable = [sum(abCorrect & ~abStimulation & aiTargetIndex == iTargetIter) sum(abCorrect & abStimulation & aiTargetIndex == iTargetIter);
%         sum(abIncorrect & ~abStimulation & aiTargetIndex == iTargetIter) sum(abIncorrect & abStimulation & aiTargetIndex == iTargetIter)];
%
%     a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
%     a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
%     fChiSquare = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
%     fPValue = 1 - chi2cdf(fChiSquare, 1);
%     N = sum(abCorrect & aiTargetIndex == iTargetIter);
%     fprintf('Trial Type : %d : %.5f \n',iTargetIter,fPValue);
%     fprintf('Direction %d: No Stim %.2f%%, With Stim %.2f%% (N=%d)\n',iTargetIter,...
%         sum(abCorrect & ~abStimulation & aiTargetIndex == iTargetIter)/N*1e2,sum(abCorrect & abStimulation & aiTargetIndex == iTargetIter)/N*1e2,N)
% end
%
% dbg = 1;
%
%


function fnDebugPlot

if 0
    afTheta = linspace(0,2*pi,20);

    figure(11);
    clf;hold on;
    plot(fFixationRadius*cos(afTheta),fFixationRadius*sin(afTheta),'r');
    % plot targets
    for k=1:8
        if k == iCorrectChoiceIndex
            plot(a2fTargetCenter(k,1)+80*cos(afTheta),a2fTargetCenter(k,2)+80*sin(afTheta),'g');
        else
            plot(a2fTargetCenter(k,1)+80*cos(afTheta),a2fTargetCenter(k,2)+80*sin(afTheta),'b');
        end
        if ~isnan(iSelectedChoice) && k == iSelectedChoice
            plot(a2fTargetCenter(k,1)+50*cos(afTheta),a2fTargetCenter(k,2)+50*sin(afTheta),'g');
        end
        text(a2fTargetCenter(k,1),a2fTargetCenter(k,2),sprintf('%d',k));
    end
    iTemp = find(afPlexonTime>fTime0_PLX+fTrialLengthSec,1,'first');
    
    afEyeXpix_subsampled = afEyeXpix(1:10:end);
    afEyeYpix_subsampled= afEyeYpix(1:10:end);
    a2fJet = jet(size(afEyeXpix_subsampled,1));
    for q=1:size(afEyeXpix_subsampled,1)-1
        plot([afEyeXpix_subsampled(q) afEyeXpix_subsampled(q+1)]-pt2fScreenCenter(1),[afEyeYpix_subsampled(q) afEyeYpix_subsampled(q+1)]-pt2fScreenCenter(2),'color',a2fJet(q,:));
    end
    
    if ~isempty(pt2fFirstFixationAfterSaccade)
        plot(pt2fFirstFixationAfterSaccade(1),pt2fFirstFixationAfterSaccade(2),'ro','MarkerSize',21);
    end
    
    if ~isempty(iFirstFastIndex) && ~isnan(fFirstFixationAfterSaccadeTimePoint)
        %plot(afEyeXpixZero(iFirstFastIndex:fFirstFixationAfterSaccadeTimePoint),afEyeYpixZero(iFirstFastIndex:fFirstFixationAfterSaccadeTimePoint),'m')
        plot([0 afEyeXpixZero(fFirstFixationAfterSaccadeTimePoint)],[0 afEyeYpixZero(fFirstFixationAfterSaccadeTimePoint)],'r','LineWidth',2)
    end
    
    axis([-500 500 -500 500]);
    title(sprintf('Trial %d Outcome: %s',iTrialIter,strTrialOutcome));
    pause
end





function [pt2fFirstFixationAfterSaccade, iSaccadeOnset, iFixationOnset] = fnEstimateFirstFixationPoint(afEyeXpixZero,afEyeYpixZero,fFixationRadius )
% Try to estimate the first fixation point after the saccade outside
% the fixation region

fSaccadeVelocityThresholdHigh = 1; %1.5;
fSaccadeVelocityThresholdLow= 0.5; %0.4;
iContinuousThreshold = 12; % 3 ms continuous data   

afDistanceToFixationSpot = medfilt1(sqrt(afEyeXpixZero.^2+afEyeYpixZero.^2),5);
afVelocitySmooth=abs([0;diff(fndllBilateral1D(afDistanceToFixationSpot,20,40,180))])'; % [70,60,60]

%afVelocitySmooth=abs([0;diff(fndllBilateral1D(afDistanceToFixationSpot,70,60,60))])';
%%

%%

aiHighVelocityIndices = find(afVelocitySmooth>fSaccadeVelocityThresholdHigh);
pt2fFirstFixationAfterSaccade = [];
iFixationOnset = NaN;
iSaccadeOnset = NaN;

for k=1:length(aiHighVelocityIndices)
    iFirstFastIndex = aiHighVelocityIndices(k);
    pt2fFirstFixationAfterSaccade = [];
    
    % Look after the first threshold crossing. Do we have a continuous
    % chunk of data, or just a single outlier?
    abTemp = zeros(1,length(afVelocitySmooth))>0;
    abTemp(iFirstFastIndex:end)=true; % Don't look back
    astrctIntervals = fnGetIntervals(abTemp & afVelocitySmooth<fSaccadeVelocityThresholdLow);
    
     if ~isempty(astrctIntervals)
        aiLength = cat(1,astrctIntervals.m_iLength);
        iIndexFixation = find(aiLength> iContinuousThreshold,1,'first');
        if ~isempty(iIndexFixation)
            % The second condition of a fixation is that it is also outside
            % the fixation radius...
             
            if afDistanceToFixationSpot(astrctIntervals(iIndexFixation).m_iStart) > fFixationRadius
                % Verify there is no invalid values between start
                % and finish of saccade (i.e., this wasn't a blink)
                iSaccadeOnset = iFirstFastIndex;
                
                iFixationOnset = astrctIntervals(iIndexFixation).m_iStart;
                bOutsideRange = ~all( abs(afEyeXpixZero(iFirstFastIndex:iFixationOnset)) < 2000) || ...
                    ~all( abs(afEyeYpixZero(iFirstFastIndex:iFixationOnset)) < 2000) ;
                % Hack to handle some degenerate cases...
                if bOutsideRange
                    astrctIntervals = fnGetIntervals(abTemp & afVelocitySmooth<3);
                    for j=1:length(astrctIntervals)
                        if astrctIntervals(j).m_iLength >= 3 && afDistanceToFixationSpot(  astrctIntervals(j).m_iStart) > fFixationRadius
                            iFixationOnset = astrctIntervals(j).m_iStart;
                            break;
                        end
                    end
                end
                break;
            end
        end
    end
end

% Correct the saccade onset (slightly lower threshold and nearby....
if ~isnan(iFixationOnset)
    astrctIntervals = fnGetIntervals(afVelocitySmooth < fSaccadeVelocityThresholdLow);
    if ~isempty(astrctIntervals)
        aiLengths = cat(1,astrctIntervals.m_iLength);
        aiEnds = cat(1,astrctIntervals.m_iEnd);
        iLastInterval = find(aiEnds < iSaccadeOnset & aiLengths > iContinuousThreshold,1,'last');
        if ~isempty(iLastInterval)
            iSaccadeOnset = astrctIntervals(iLastInterval).m_iEnd;
        end
    end
    % Adjust the fixation spot to be the average of the fixation
    % interval....
    abTemp = zeros(1, length(afVelocitySmooth ));
    abTemp(iFixationOnset:end)=true;
    astrctIntervals = fnGetIntervals(abTemp & (afVelocitySmooth <fSaccadeVelocityThresholdLow));
    if ~isempty(astrctIntervals) && astrctIntervals(1).m_iStart == iFixationOnset
        iFixationEnd = astrctIntervals(1).m_iEnd;
        pt2fFirstFixationAfterSaccade = [mean(afEyeXpixZero(iFixationOnset:iFixationEnd)),mean(afEyeYpixZero(iFixationOnset:iFixationEnd))];
    else
         pt2fFirstFixationAfterSaccade = [afEyeXpixZero(iFixationOnset),afEyeYpixZero(iFixationOnset)];
    end
end
 
dbg = 1;

return;


function [strTrialOutcome,fExitAngle,fAngularAccuracy, fReactionTimeSec,iSelectedChoice] = fnEstimateResponseWithAllTargets(afEyeXpixZero,afEyeYpixZero,afTimeAlignedToCueOnset,...
    fFixationRadius,fChoiceRadius,fTrialTimeoutSec,fTrialLengthSec,a2fTargetCenter,iCorrectChoiceIndex)


fMinTimeToSpendInChoiceRegionMS = 3;

afDistanceToFixationSpot = sqrt(afEyeXpixZero.^2+afEyeYpixZero.^2);
fTargetDistance = sqrt(sum(a2fTargetCenter(iCorrectChoiceIndex,:).^2));

fReactionTimeSec=NaN;
iSelectedChoice = NaN;

iIndex=[];
% Now, estimate decision using regions outside fixation spot
astrctIntervals = fnGetIntervals(afDistanceToFixationSpot>fFixationRadius);
fFirstTimeOutsideFixationRegion = [];
fExitAngle = NaN;
fAngularAccuracy = NaN;

if ~isempty(astrctIntervals)
    aiLength = cat(1,astrctIntervals.m_iLength);
    iIndex=find(aiLength>20,1,'first');
    if ~isempty(iIndex)
        fFirstTimeOutsideFixationRegion = afTimeAlignedToCueOnset(astrctIntervals(iIndex).m_iStart);
        fExitAngle = atan2(afEyeYpixZero(astrctIntervals(iIndex).m_iStart), ...
                           afEyeXpixZero(astrctIntervals(iIndex).m_iStart));
        
    end
end


if isempty(fFirstTimeOutsideFixationRegion ) || (fFirstTimeOutsideFixationRegion > fTrialTimeoutSec+fTrialLengthSec)
    strTrialOutcome = 'Timeout';
else
    % Which choice?
    afTimeForChoice = NaN*ones(1,8);
    for iChoiceIter=1:8
        abInsideChoice = sqrt( (afEyeXpixZero-a2fTargetCenter(iChoiceIter,1)).^2+(afEyeYpixZero-a2fTargetCenter(iChoiceIter,2)).^2) <= fChoiceRadius;
        astrctIntervals = fnGetIntervals(abInsideChoice);
        % Valid intervals (larger than 5 ms) ?
        if ~isempty(astrctIntervals)
            afIntervalLengthMS = cat(1,astrctIntervals.m_iLength) * 1000/4000;
            iIndex = find(afIntervalLengthMS>=fMinTimeToSpendInChoiceRegionMS,1,'first');
            if ~isempty(iIndex)
                afTimeForChoice(iChoiceIter) = afTimeAlignedToCueOnset(astrctIntervals(iIndex).m_iStart)-fTrialLengthSec;
            end
        end
    end
    
   
    % Find first choice....
    if all(isnan(afTimeForChoice))
        % This is more like a short amplitude response....
        
        % But which direction did he go for?
        iIndex = find(afDistanceToFixationSpot>fFixationRadius,1,'first');
        afDirection = [afEyeXpixZero(iIndex ), afEyeYpixZero(iIndex )];
        afDirection =afDirection/norm(afDirection)*fTargetDistance;
        [fDummy, iSelectedChoice]=min(sqrt((afDirection(1)-a2fTargetCenter(:,1)).^2+(afDirection(2)-a2fTargetCenter(:,2)).^2));
        fReactionTimeSec = afTimeAlignedToCueOnset(iIndex)-fTrialLengthSec;
    else
        [fReactionTimeSec, iSelectedChoice] = min(afTimeForChoice);
        
    end
    fCorrectChoiceAngle = atan2(a2fTargetCenter(iCorrectChoiceIndex,2),a2fTargetCenter(iCorrectChoiceIndex,1));
    fAngularAccuracy = acos(cos(fExitAngle).*cos(fCorrectChoiceAngle) + sin(fExitAngle)*sin(fCorrectChoiceAngle))/pi*180;
    
    if fFirstTimeOutsideFixationRegion <= fTrialLengthSec
        strTrialOutcome = 'Aborted';
        % OK, but which target was selected?
    else
        % Either correct or incorrect. Depending on trial type.
        if iSelectedChoice == iCorrectChoiceIndex
            strTrialOutcome = 'Correct';
        else
            strTrialOutcome = 'Incorrect';
        end
    end
end

return

