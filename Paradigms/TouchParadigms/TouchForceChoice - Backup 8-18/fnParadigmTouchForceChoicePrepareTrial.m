function [strctCurrentTrial,strWhatHappened] =  fnParadigmTouchForceChoicePrepareTrial()
global g_strctParadigm g_strctPTB
%[g_strctParadigm.m_strctDesign,g_strctParadigm.m_acImages] = fnLoadForceChoiceNewDesignFile('NewForceChoiceDesign.xml');
          
g_strctParadigm.m_bGuiOverrideParamters = false;

strWhatHappened = [];

%%   Decide on trial type
strctCurrentTrial = struct;
[strctCurrentTrial.m_iTrialType,strctCurrentTrial.m_iBlockIndex] = fnSelectTrialType();
if isnan(strctCurrentTrial.m_iTrialType)
    strWhatHappened = 'TR_Mode_FinishedAllBlocks';
    strctCurrentTrial = [];
    return;
end

strctCurrentTrial.m_bLoadOnTheFly = g_strctParadigm.m_strctDesign.m_bLoadOnTheFly;

if strcmpi(g_strctParadigm.m_strctDesign.m_strctOrder.m_strTrialOrderType,'Dynamic')
	strctCurrentTrial = fnPrepareDynamicTrial(g_strctParadigm);
	return;
end
%% Prepare Cue image(s) (if needed)
strctCurrentTrial= fnAddMultipleCuesInfoToTrial(strctCurrentTrial);
if isempty(strctCurrentTrial)
    % Trial requirement could not be fulfiled during run time due to random
    % selection...
    return;
end
%% Add Precue fixation information
strctCurrentTrial = fnAddPreCueInfo(strctCurrentTrial);
%% Add memory period information
strctCurrentTrial = fnAddMemoryPeriodInfoToTrial(strctCurrentTrial);

%% Add Choices information
strctCurrentTrial = fnAddChoicesInformation(strctCurrentTrial);

%% Add Post Trial Info
strctCurrentTrial = fnAddPostTrialInfoToCue(strctCurrentTrial);

if ~fnParadigmToKofikoComm('IsTouchMode')
    % Load Images locally to show them on the console screen...
    if g_strctParadigm.m_strctDesign.m_bLoadOnTheFly
        % First, release media, then load new media....
        if ~isempty(g_strctParadigm.m_acMedia)
            fnReleaseMedia( g_strctParadigm.m_acMedia );
        end
          g_strctParadigm.m_acMedia = fnLoadMedia(g_strctPTB.m_hWindow, strctCurrentTrial.m_astrctMedia);
    end
    
end


return;

        
function [iTrialType,iActiveBlock] = fnSelectTrialType()
global g_strctParadigm

if ~isfield(g_strctParadigm,'m_strctTrialTypeCounter')
    g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = 0;
end

if strcmpi(g_strctParadigm.m_strctDesign.m_strctOrder.m_strTrialOrderType,'random')
    % Randomly select a trial, but take into account weights....
    iNumTrialTypes = length(g_strctParadigm.m_strctDesign.m_acTrialTypes);
    afWeights = zeros(1,iNumTrialTypes);
    for iTrialTypeIter=1:iNumTrialTypes
         afWeights(iTrialTypeIter) = fnParseVariable(g_strctParadigm.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.TrialParams, 'ProbWeight', 1);
    end
    afWeightsNormalized = afWeights / sum(afWeights);
    afCumWeights = cumsum(afWeightsNormalized);
    
    fRand = rand();
   iTrialType =find(afCumWeights >= fRand,1,'first');
   iActiveBlock = 1;
elseif  strcmpi(g_strctParadigm.m_strctDesign.m_strctOrder.m_strTrialOrderType,'blocks')
    
    if isfield(g_strctParadigm.m_strctDesign.m_strctOrder,'m_acNumTRsPerBlock')
        % Special operation using Number of TRs per block....
        
        iNumBlocks = length(g_strctParadigm.m_strctDesign.m_strctOrder.m_acNumTRsPerBlock);
        % Parse the number of TRs....
        aiNumTRs = zeros(1,iNumBlocks);
        for k=1:iNumBlocks
            aiNumTRs(k) = fnParseVariable(g_strctParadigm.m_strctDesign.m_strctOrder,'m_acNumTRsPerBlock',0,k);
        end
        fTS_Sec = fnTsGetVar('g_strctParadigm', 'TR') / 1e3;
        aiCumulativeTRs = cumsum(aiNumTRs);
        
        g_strctParadigm.m_fRunLengthSec_fMRI = sum(aiNumTRs) * fTS_Sec;
         g_strctParadigm.m_aiCumulativeTRs = aiCumulativeTRs;
        % We need to know how much time passed since the first TR was
        % detected (if any...)
        if g_strctParadigm.m_iTriggerCounter == 0
            % First block....
            iActiveBlock= 1;
        elseif g_strctParadigm.m_iTriggerCounter > 0
            % How long passed since first trigger?
            fTimeElapsedSec = GetSecs()-g_strctParadigm.m_fFirstTriggerTS;
             fNumTRsPassed = fTimeElapsedSec / fTS_Sec;
            iActiveBlock = find(aiCumulativeTRs >= fNumTRsPassed ,1,'first');
            if isempty(iActiveBlock)
               % Finished going over all blocks. 
               % Go back to waiting mode until next first TR arrives....
               iTrialType = NaN;
               return;
            end
        end
    
		
	
	
    else
        % Normal operation using Number of Trials per block
        
        aiNumTrials = cumsum(g_strctParadigm.m_strctDesign.m_strctOrder.m_aiNumTrialsPerBlock);
        iCurrentBlock = find(aiNumTrials >= g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter,1,'first');
        if isempty(iCurrentBlock)
            iCurrentBlock = length(aiNumTrials);
        end;
        
        
        bIncreaseTrialCounter = true;
        if g_strctParadigm.m_strctDesign.m_strctOrder.m_abCountOnlyCorrectTrials(iCurrentBlock) && ...
                ~isempty(g_strctParadigm.m_strctCurrentTrial) && isfield(g_strctParadigm.m_strctCurrentTrial,'m_strctTrialOutcome') && ...
                isfield(g_strctParadigm.m_strctCurrentTrial.m_strctTrialOutcome,'m_strResult') && ~strcmpi(g_strctParadigm.m_strctCurrentTrial.m_strctTrialOutcome.m_strResult,'Correct')
            bIncreaseTrialCounter = false;
        end
        
        if bIncreaseTrialCounter
            g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter+1;
            if g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter > aiNumTrials(end)
                g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = 1;
            end
        end
        iActiveBlock= find(aiNumTrials >= g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter,1,'first');
        
        
    end
    
    if isfield(g_strctParadigm,'m_strctCurrentTrial') && isfield(g_strctParadigm.m_strctCurrentTrial,'m_iTrialType') && ...
            isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{g_strctParadigm.m_strctCurrentTrial.m_iTrialType},'PostChoice') && ...
            isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{g_strctParadigm.m_strctCurrentTrial.m_iTrialType}.PostChoice,'m_aiConstrainNextTrialTypes') && ...
            ~isempty(g_strctParadigm.m_strctDesign.m_acTrialTypes{g_strctParadigm.m_strctCurrentTrial.m_iTrialType}.PostChoice.m_aiConstrainNextTrialTypes)
        aiTrialTypes = intersect(g_strctParadigm.m_strctDesign.m_strctOrder.m_acTrialTypeIndex{iActiveBlock},  g_strctParadigm.m_strctDesign.m_acTrialTypes{g_strctParadigm.m_strctCurrentTrial.m_iTrialType}.PostChoice.m_aiConstrainNextTrialTypes);
        if isempty(aiTrialTypes)
            % problem in design....
                    aiTrialTypes = g_strctParadigm.m_strctDesign.m_strctOrder.m_acTrialTypeIndex{iActiveBlock};

        end
    else
        aiTrialTypes = g_strctParadigm.m_strctDesign.m_strctOrder.m_acTrialTypeIndex{iActiveBlock};
    end
    
    iNumTrialTypesInThisRandomBlock = length(aiTrialTypes);
    if iNumTrialTypesInThisRandomBlock == 1
        %East case,  this is the only option...
        iTrialType = aiTrialTypes;
    else
        
        afWeights = zeros(1,iNumTrialTypesInThisRandomBlock);
        for iTrialTypeIter=1:iNumTrialTypesInThisRandomBlock
            afWeights(iTrialTypeIter) = fnParseVariable(g_strctParadigm.m_strctDesign.m_acTrialTypes{aiTrialTypes(iTrialTypeIter)}.TrialParams,'ProbWeight',1);
        end
        afWeightsNormalized = afWeights / sum(afWeights);
        afCumWeights = cumsum(afWeightsNormalized);
        
        fRand = rand();
        iTrialType =aiTrialTypes( find(afCumWeights >= fRand,1,'first'));
    end

		
end

return;

function strctCurrentTrial = fnAddMemoryPeriodInfoToTrial(strctCurrentTrial)
global g_strctParadigm

if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType},'MemoryPeriod')
    
    strctCurrentTrial.m_strctMemoryPeriod.m_fMemoryPeriodMS = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'MemoryPeriodMS',...
        fnTsGetVar(g_strctParadigm, 'MemoryPeriodMS'));
      
    strctCurrentTrial.m_strctMemoryPeriod.m_bShowFixationSpot = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'ShowFixationSpot',true);
 
    strctCurrentTrial.m_strctMemoryPeriod.m_fFixationSpotSize = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'FixationSpotSize',20);
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'FixationPosition')
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            if strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod.FixationPosition,'center')
                strctCurrentTrial.m_strctMemoryPeriod.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
            elseif strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod.FixationPosition,'random')
                iXPos = 2*strctCurrentTrial.m_strctMemoryPeriod.m_fFixationSpotSize  + rand() * (aiScreenSize(3)-strctCurrentTrial.m_strctMemoryPeriod.m_fFixationSpotSize*2 );
                iYPos = 2*strctCurrentTrial.m_strctMemoryPeriod.m_fFixationSpotSize  + rand() * (aiScreenSize(4)-strctCurrentTrial.m_strctMemoryPeriod.m_fFixationSpotSize*2 );
                strctCurrentTrial.m_strctMemoryPeriod.m_pt2fFixationPosition = [iXPos;iYPos];
            else
                % assume exact position....
               aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
                X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod.FixationPosition,'%f %f');
                strctCurrentTrial.m_strctMemoryPeriod.m_pt2fFixationPosition = X + aiScreenSize(3:4)/2;
            end
    else
            % Default position is center of screen
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            strctCurrentTrial.m_strctMemoryPeriod.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'BackgroundColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod.BackgroundColor,'%f %f %f');
            strctCurrentTrial.m_strctMemoryPeriod.m_afBackgroundColor= X(:)';
    else
        strctCurrentTrial.m_strctMemoryPeriod.m_afBackgroundColor= [1 1 1];
    end
    
        if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'FixationColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod.FixationColor,'%f %f %f');
            strctCurrentTrial.m_strctMemoryPeriod.m_afFixationColor= X(:)';
    else
        strctCurrentTrial.m_strctMemoryPeriod.m_afFixationColor= [255 255 255];
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'FixationSpotType')
            strctCurrentTrial.m_strctMemoryPeriod.m_strFixationSpotType = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod.FixationSpotType;
    else
            strctCurrentTrial.m_strctMemoryPeriod.m_strFixationSpotType = 'disc';
    end
      
    strctCurrentTrial.m_strctMemoryPeriod.m_fFixationRegionPix =fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.MemoryPeriod,'FixationRegion',100);
    
%%
else
    strctCurrentTrial.m_strctMemoryPeriod = []; % No memory period
end


function strctCurrentTrial = fnAddPreCueInfo(strctCurrentTrial)
global g_strctParadigm



if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType},'PreCueFixation')
    
    strctCurrentTrial.m_strctPreCueFixation.m_fPreCueFixationPeriodMS = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'PreCueFixationPeriodMS',...
        fnTsGetVar(g_strctParadigm,'PreCueFixationPeriodMS'));
    
    
    strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationSpotSize',...
            fnTsGetVar(g_strctParadigm,'PreCueFixationSpotSize'));

        
    strctCurrentTrial.m_strctPreCueFixation.m_fPostTouchDelayMS = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'PostTouchDelayMS',...
            0);
        
        
        
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationPosition')
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            if strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationPosition,'center')
                strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
            elseif strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationPosition,'random')
                iXPos = 2*strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize  + rand() * (aiScreenSize(3)-strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize*2 );
                iYPos = 2*strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize  + rand() * (aiScreenSize(4)-strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize*2 );
                strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = [iXPos;iYPos];
            else
                % assume exact position....
               aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
                X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationPosition,'%f %f');
                strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = X(:)' + aiScreenSize(3:4)/2;
            end
    else
            % Default position is center of screen
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'BackgroundColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.BackgroundColor,'%f %f %f');
            strctCurrentTrial.m_strctPreCueFixation.m_afBackgroundColor= X(:)';
    else
        strctCurrentTrial.m_strctPreCueFixation.m_afBackgroundColor= [0 0 0];
    end
    
        if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationColor,'%f %f %f');
            strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor= X(:)';
    else
        strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor= [255 255 255];
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationSpotType')
            strctCurrentTrial.m_strctPreCueFixation.m_strFixationSpotType = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationSpotType;
    else
            strctCurrentTrial.m_strctPreCueFixation.m_strFixationSpotType = fnTsGetVar(g_strctParadigm,'PreCueFixationSpotType');
    end
      
   strctCurrentTrial.m_strctPreCueFixation.m_fFixationRegionPix = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationRegion',...
         60);

    strctCurrentTrial.m_strctPreCueFixation.m_bAbortTrialUponTouchOutsideFixation = fnParseVariable( ...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation, 'AbortTrialIfTouchOutsideCue', false);
    
    strctCurrentTrial.m_strctPreCueFixation.m_bRewardTouchFixation = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'RewardTouchCue', false);
   
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'RewardSound')
        strctCurrentTrial.m_strctPreCueFixation.m_strRewardSound= g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.RewardSound;
    else
        strctCurrentTrial.m_strctPreCueFixation.m_strRewardSound = [];
   end
   
    % Assume that if stimulation is applied on pre-fixation, its only when
    % moneky saccades OUT of the fixation region after the required
    % fixation time. This is typically useful for stimulation-mid-saccade
    % type of experiments....
        
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'Stimulation')
        % Default to no stimulation (just to be on the safe side)
         bStimulation = fnParseVariable(...
             g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'Stimulation', false);
        if bStimulation
            strctCurrentTrial.m_strctPreCueFixation.m_astrctMicroStim = ...
                fnExtractMicroStimParams(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation);
        else
            strctCurrentTrial.m_strctPreCueFixation.m_astrctMicroStim = []; % No stimulation during this cue.
        end
    end
      
    
else
    strctCurrentTrial.m_strctPreCueFixation = []; % no pre cue fixation period
end

function strctCurrentTrial = fnAddChoicesInformation(strctCurrentTrial)
global g_strctParadigm
strctCurrentTrial.m_strctChoices.m_fStimulated =false;

switch lower(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.TrialParams.ChoicesType)
	case 'nochoices'
		strctCurrentTrial.m_astrctChoicesMedia = []; % No cue used in this trial
	case 'fixed'
		iNumChoices = length(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice);
		if isfield(strctCurrentTrial,'m_astrctMedia')
			iOffset = length(strctCurrentTrial.m_astrctMedia);
		else
			iOffset= 0;
		end;

		if iNumChoices == 1 && isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices,'Choice') && ~iscell(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice)
			g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice = {g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice};
		end
		
		for iChoiceIter=1:iNumChoices
			
			iMediaIndex = find(ismember(g_strctParadigm.m_strctDesign.m_acMediaName, g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice{iChoiceIter}.Media));
			strctCurrentTrial.m_astrctMedia(iOffset+iChoiceIter) = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex);
			
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_strName = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice{iChoiceIter}.Media;
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_strFileName =g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_iMediaIndex = iMediaIndex;
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bMovie = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_bMovie;
	
			% position
			X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice{iChoiceIter}.Position,'%f %f');
			aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
			
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_pt2fPosition = X(:)' + aiScreenSize(3:4)/2;
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bMovie = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_bMovie;
			
			 strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = fnParseVariable( ...
				g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice{iChoiceIter},'JuiceReward', false);
	   
			if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice{iChoiceIter},'RewardSound')
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_strRewardSound = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice{iChoiceIter}.RewardSound;
			else
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_strRewardSound = [];
			end
			
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_fSizePix = fnParseVariable( ...
					g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice{iChoiceIter},'SizePix', 100);
		end
	case 'random'
		
		if isfield(strctCurrentTrial,'m_astrctMedia')
			iOffset = 1;
		else
			iOffset= 0;
		end;
		
		 iNumChoices = str2num(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.NumChoices);
		if iNumChoices == 1 && isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices,'Choice') && ~iscell(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice)
			g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice = {g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.Choice};
		end
		 
		 bCueIsChoice = str2num(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.IncludeCueAsChoice) > 0;
		 
		acRequiredAttributes = fnSplitString(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.ValidAttributes);
		acNotAllowedAttributes = fnSplitString(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.InvalidAttributes);
		
		abValidAttributes = ismember(g_strctParadigm.m_strctDesign.m_acAttributes,acRequiredAttributes);
	   abInvalidAttributes = ismember(g_strctParadigm.m_strctDesign.m_acAttributes,acNotAllowedAttributes);

	   if isempty(acRequiredAttributes)
		   abMediaWithValidAttributes = ones( size(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes,1),1) > 0; % all images are OK
	   else
		   abMediaWithValidAttributes = sum(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(:, abValidAttributes),2) == length(acRequiredAttributes);
	   end
	   
	   if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'NumChoicesWithSimilarAttributesToCue')
		   iNumChoicesWithSimilarAttrToCue = str2num(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.NumChoicesWithSimilarAttributesToCue);
	   else
		   iNumChoicesWithSimilarAttrToCue = 0;
	   end
				
	   
	   % First, find all media that has the valid & invalid required
	   % attributes.
	   
		abMediaWithoutInvalidAttributes = sum(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(:, abInvalidAttributes),2) == 0;
		 if bCueIsChoice
			abValidMediaChoices = abMediaWithValidAttributes & abMediaWithoutInvalidAttributes;
			abValidMediaChoices(strctCurrentTrial.m_astrctCueMedia.m_iMediaIndex) = false;
		 else
			abValidMediaChoices = abMediaWithValidAttributes & abMediaWithoutInvalidAttributes; 
		 end
		 
		 % Now, from the subset of the valid media choices, we need to
		 % check whether there are additional constraints, like a certain
		 % number of choices with similar attributes  to the cue...
		if iNumChoicesWithSimilarAttrToCue > 0
			% Assume cue is not in this set....
			abValidMediaChoices(strctCurrentTrial.m_astrctCueMedia.m_iMediaIndex) = false;
			
			abCueAttributes = g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(strctCurrentTrial.m_astrctCueMedia.m_iMediaIndex,:);
			
			
			
			if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'IgnoreCueAttributes')
				
				acIgnoreAttributes = fnSplitString(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.IgnoreCueAttributes);
				abCueIgnoreAttributes = ismember(lower(g_strctParadigm.m_strctDesign.m_acAttributes), lower(acIgnoreAttributes)) > 0 ;
				abCueAttributes(abCueIgnoreAttributes) = false;
			end
			
			
			
			iNumMedia = size(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes,1);
			abOtherImagesWithSimilarAttributes = sum(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(:,find(abCueAttributes)),2) == sum(abCueAttributes);
			abOtherImagesWithSimilarAttributesANDvalid = abOtherImagesWithSimilarAttributes;
			abOtherImagesWithSimilarAttributesANDvalid(strctCurrentTrial.m_astrctCueMedia(1).m_iMediaIndex) = false;
			%abOtherImagesWithSimilarAttributes = all(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes == repmat(abCueAttributes,iNumMedia,1),2);
			%abOtherImagesWithSimilarAttributesANDvalid = abOtherImagesWithSimilarAttributes & abValidMediaChoices;
			
			% Pick iNumChoicesWithSimilarAttrToCue from abOtherImagesWithSimilarAttributesANDvalid 
			 iNumValidWithSimilarAttributes = sum(abOtherImagesWithSimilarAttributesANDvalid);
			aiOtherImagesWithSimilarAttributesANDvalid = find(abOtherImagesWithSimilarAttributesANDvalid);
			
			 aiSubsetMediaSelected = aiOtherImagesWithSimilarAttributesANDvalid(randi(iNumValidWithSimilarAttributes,[1,iNumChoicesWithSimilarAttrToCue]));
			 
			 % Remaining media - choose from valid attributes that do not
			 % share attributes with cue...
			 iRemainingChoicesToPick = iNumChoices - iNumChoicesWithSimilarAttrToCue;
			  abValidMediaChoices(abOtherImagesWithSimilarAttributes) = false;
			  iNumRemainingValid = sum(abValidMediaChoices);
			  aiRemainingValid = find(abValidMediaChoices);
			   aiRand = randi(iNumRemainingValid, [1,iRemainingChoicesToPick]);
			aiMediaIndices = [aiSubsetMediaSelected;aiRemainingValid(aiRand)];
		else
			aiValidMediaChoices = find(abValidMediaChoices);
			iNumValidChoices =  sum(abValidMediaChoices);
			aiRand = randi(iNumValidChoices, [1,iNumChoices]);
			% Select choices
			if bCueIsChoice
				% It is a choice, but only once!
				aiMediaIndices = [strctCurrentTrial.m_astrctCueMedia.m_iMediaIndex,aiValidMediaChoices(aiRand(1:end-1))'];
			else
				aiMediaIndices=aiValidMediaChoices(aiRand);
			end
	   
		end
		 
		 acValidAttributesForReward = fnSplitString(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.ValidAttributesForJuiceReward);
		 
		 pt2fChoicesPosition = fnSelectChoicePosition(...
			 g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.Arrangement, iNumChoices,...
			 str2num(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.SizePix));
		 
		 
				fChoiceSizePix = fnParseVariable(...
				g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'SizePix', 100);
				
				if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'RewardSound')
					strRewardSound = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.RewardSound;
				else
					strRewardSound = [];
				end
				
	   abCueAttributes = g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(strctCurrentTrial.m_astrctCueMedia.m_iMediaIndex,:);
	   if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'IgnoreCueAttributes')
		   acIgnoreAttributes = fnSplitString(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.IgnoreCueAttributes);
		   abCueIgnoreAttributes = ismember(lower(g_strctParadigm.m_strctDesign.m_acAttributes), lower(acIgnoreAttributes)) > 0 ;
		   abCueAttributes(abCueIgnoreAttributes) = false;
	   end

				
		for iChoiceIter=1:iNumChoices
			% Pick choices at random!
			iMediaIndex = aiMediaIndices(iChoiceIter);
			
		   strctCurrentTrial.m_astrctMedia(iOffset+iChoiceIter) = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex);
				 
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_strName = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_strName;
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_strFileName =g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_iMediaIndex = iMediaIndex;
			
			 strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_pt2fPosition =pt2fChoicesPosition(:,iChoiceIter);
				
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bMovie = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_bMovie;
			strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_fSizePix = fChoiceSizePix;
			   strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_strRewardSound = strRewardSound;
  
			if isempty(acValidAttributesForReward)
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = false;
			elseif ismember('cue',lower(acValidAttributesForReward)) && iMediaIndex == strctCurrentTrial.m_astrctCueMedia.m_iMediaIndex
				% Only cue gets reward
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = true;
			elseif ismember('notcue',lower(acValidAttributesForReward)) && iMediaIndex ~= strctCurrentTrial.m_astrctCueMedia.m_iMediaIndex
				% Only cue gets reward
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = true;
			elseif ismember('all',lower(acValidAttributesForReward))
				% All choices get reward
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = true;
			elseif ismember('cueattributes',lower(acValidAttributesForReward)) 
				
				%strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = ...
				%    all(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(iMediaIndex,:) == abCueAttributes );

				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = ...
					sum(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(iMediaIndex,find(abCueAttributes)),2) == sum(abCueAttributes);
				
				
			elseif ismember('notcueattributes',lower(acValidAttributesForReward)) 
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = ...
					~all(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(iMediaIndex,:) == abCueAttributes );
			else 
				% Match attributes
				strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward = ~isempty(...
					intersect(g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_acAttributes, acValidAttributesForReward));
			end
			

		end        
		
end
if ~isempty( strctCurrentTrial.m_astrctChoicesMedia)
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices,'ChoicesParam')
      
        strctCurrentTrial.m_strctChoices.m_bShowChoicesOnScreen = fnParseVariable(...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'ShowChoicesOnScreen', true);
        
        strctCurrentTrial.m_strctChoices.m_bMultipleAttemptsUntilJuice  = fnParseVariable(...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'MultipleAttemptsUntilJuice', false);

        strctCurrentTrial.m_strctChoices.m_bKeepCueOnScreen  = fnParseVariable(...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'KeepCueOnScreen', false);

        
        if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'InsideChoiceRegionType')
            strctCurrentTrial.m_strctChoices.m_strInsideChoiceRegionType  =g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.InsideChoiceRegionType;
        else
            strctCurrentTrial.m_strctChoices.m_strInsideChoiceRegionType  = 'Rect';
        end

         strctCurrentTrial.m_strctChoices.m_fInsideChoiceRegionSize  =fnParseVariable(...
           g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'InsideChoiceRegionSize', strctCurrentTrial.m_astrctChoicesMedia(1).m_fSizePix);
        
       strctCurrentTrial.m_strctChoices.m_fHoldToSelectChoiceMS  = fnParseVariable(...
               g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'HoldToSelectChoiceMS',0);
        
        if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'BackgroundColor')
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.BackgroundColor,'%f %f %f');
            strctCurrentTrial.m_strctChoices.m_afBackgroundColor= X(:)';
        else
            strctCurrentTrial.m_strctChoices.m_afBackgroundColor = [1 1 1];
        end
        
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'Stimulation')
        % Default to no stimulation (just to be on the safe side)
         bStimulation = fnParseVariable(...
             g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'Stimulation', false);
        if bStimulation
            strctCurrentTrial.m_strctChoices.m_astrctMicroStim = ...
                fnExtractMicroStimParams(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam);
        else
            strctCurrentTrial.m_strctChoices.m_astrctMicroStim = []; % No stimulation during this cue.
        end
    else
       % No stimulation during this cue.
    end        
        
       
    strctCurrentTrial.m_strctChoices.m_bShowFixationSpot = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'ShowFixationSpot',false);
 
    strctCurrentTrial.m_strctChoices.m_fFixationSpotSize = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'FixationSpotSize',0);
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'FixationPosition')
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            if strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.FixationPosition,'center')
                strctCurrentTrial.m_strctChoices.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
            elseif strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.FixationPosition,'random')
                iXPos = 2*strctCurrentTrial.m_strctChoices.m_fFixationSpotSize  + rand() * (aiScreenSize(3)-strctCurrentTrial.m_strctMemoryPeriod.m_fFixationSpotSize*2 );
                iYPos = 2*strctCurrentTrial.m_strctChoices.m_fFixationSpotSize  + rand() * (aiScreenSize(4)-strctCurrentTrial.m_strctMemoryPeriod.m_fFixationSpotSize*2 );
                strctCurrentTrial.m_strctChoices.m_pt2fFixationPosition = [iXPos;iYPos];
            else
                % assume exact position....
               aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
                X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.FixationPosition,'%f %f');
                strctCurrentTrial.m_strctChoices.m_pt2fFixationPosition = X(:)'+ aiScreenSize(3:4)/2;
            end
    else
            % Default position is center of screen
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            strctCurrentTrial.m_strctChoices.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
    end
    
    
        if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'FixationColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.FixationColor,'%f %f %f');
            strctCurrentTrial.m_strctChoices.m_afFixationColor= X(:)';
    else
        strctCurrentTrial.m_strctChoices.m_afFixationColor= [255 255 255];
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam,'FixationSpotType')
            strctCurrentTrial.m_strctChoices.m_strFixationSpotType = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Choices.ChoicesParam.FixationSpotType;
    else
            strctCurrentTrial.m_strctChoices.m_strFixationSpotType = 'disc';
    end         
         
    else
        strctCurrentTrial.m_strctChoices.m_bShowChoicesOnScreen = true;
        strctCurrentTrial.m_strctChoices.m_bMultipleAttemptsUntilJuice  = false;
        strctCurrentTrial.m_strctChoices.m_strInsideChoiceRegionType  = 'Rect';
        strctCurrentTrial.m_strctChoices.m_fInsideChoiceRegionSize  = strctCurrentTrial.m_astrctChoicesMedia(1).m_fSizePix;
        strctCurrentTrial.m_strctChoices.m_fHoldToSelectChoiceMS = 0;
        strctCurrentTrial.m_strctChoices.m_bKeepCueOnScreen  = false;
        strctCurrentTrial.m_strctChoices.m_afBackgroundColor = [1 1 1];        
         strctCurrentTrial.m_strctChoices.m_astrctMicroStim = []; 
           
         strctCurrentTrial.m_strctChoices.m_bShowFixationSpot = false;
         strctCurrentTrial.m_strctChoices.m_fFixationSpotSize = NaN;
         strctCurrentTrial.m_strctChoices.m_pt2fFixationPosition = [NaN NaN];
         strctCurrentTrial.m_strctChoices.m_afFixationColor = [NaN,NaN,NaN];
         strctCurrentTrial.m_strctChoices.m_strFixationSpotType = '';
         
    end
    
end

return;


function strctCurrentTrial = fnAddPostTrialInfoToCue(strctCurrentTrial)
global g_strctParadigm
if ~isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType},'PostChoice')
    strctCurrentTrial.m_strctPostTrial.m_fRetainSelectedChoicePeriodMS = 0;
    strctCurrentTrial.m_strctPostTrial.m_bExtinguishNonSelectedChoicesAfterChoice = false;
    strctCurrentTrial.m_strctPostTrial.m_fInterTrialInterfalSec = 0;
    strctCurrentTrial.m_strctPostTrial.m_fIncorrectTrialPunishmentDelayMS = 0;
    strctCurrentTrial.m_strctPostTrial.m_fAbortedTrialPunishmentDelayMS = 0;
    
else
    
    fMin = fnParseVariable(...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PostChoice,'InterTrialIntervalMinSec', ...
         fnTsGetVar(g_strctParadigm,'InterTrialIntervalMinSec'));
    
         fMax = fnParseVariable(...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PostChoice,'InterTrialIntervalMaxSec',...
            fnTsGetVar(g_strctParadigm,'InterTrialIntervalMaxSec'));
    
    strctCurrentTrial.m_strctPostTrial.m_fInterTrialInterfalSec = rand() * (fMax-fMin) + fMin;
    
   strctCurrentTrial.m_strctPostTrial.m_fIncorrectTrialPunishmentDelayMS = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PostChoice,'IncorrectTrialPunishmentDelayMS',0);
    
    
    strctCurrentTrial.m_strctPostTrial.m_fAbortedTrialPunishmentDelayMS = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PostChoice,'AbortedTrialPunishmentDelayMS',0);
    
    strctCurrentTrial.m_strctPostTrial.m_bExtinguishNonSelectedChoicesAfterChoice = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PostChoice,'ExtinguishNonSelectedChoicesAfterChoice', false);
    
    
    strctCurrentTrial.m_strctPostTrial.m_fRetainSelectedChoicePeriodMS= fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PostChoice,'RetainSelectedChoicePeriodMS',0);
end

 strctCurrentTrial.m_strctPostTrial.m_fTrialTimeoutMS = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.TrialParams,...
        'TrialTimeoutMS', fnTsGetVar(g_strctParadigm,'TimeoutMS'));
        
        
strctCurrentTrial.m_strctPostTrial.m_fDefaultJuiceRewardMS = fnParseVariable(...
    g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PostChoice, ...
    'DefaultJuiceRewardMS', 50);

strctCurrentTrial.m_strctTrialOutcome.m_iSelectCounter = 0;
return;






function strctCurrentTrial = fnAddMultipleCuesInfoToTrial(strctCurrentTrial)
global g_strctParadigm

if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType},'Cue') && ~iscell(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue)
   g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue = {g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue};
end

if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType},'Cue')
    iNumCues = length(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue);
else
     strctCurrentTrial.m_astrctCueMedia = []; % No cue used in this trial
     return;
end

for iCueIter = 1:iNumCues
    strctCurrentTrial = fnAddCueInformationToTrial(strctCurrentTrial, iCueIter);
    if isempty(strctCurrentTrial)
        return;
    end;
end
return;

function strctCurrentTrial = fnAddCueInformationToTrial(strctCurrentTrial,iCueIter)
global g_strctParadigm
if isfield(strctCurrentTrial,'m_astrctMedia')
    iOffset = length(strctCurrentTrial.m_astrctMedia);
else
    iOffset = 0;
end

switch lower(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.TrialParams.CueType)
    case 'fixed'
        iMediaIndex = find(ismember(g_strctParadigm.m_strctDesign.m_acMediaName,   g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CueMedia));
        
        strctCurrentTrial.m_astrctMedia(1+iOffset) = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex);
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strName = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CueMedia;
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strFileName =g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_iMediaIndex = iMediaIndex;
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bMovie = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_bMovie;
        
    case 'random'
        % Random cue. Select by attributes!
        strctTrialType = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType};
        
        % Determine which cue media is valid.
        % The logic circuit is :
        % (ALL(A \ E) & OR(D)) AND  NOT [ (B) \ (C) ] 
        % Where A is "Required" Attributes (all must be present)
        % D is "at least one attribute" must be present
        % B is "Invalid Attributes"
        % C is "Ignore Attributes"
        % E is "Ignore Valid Attributes"
        
        if isfield(strctTrialType.Cue{iCueIter},'CueValidAttributesOR') && ~isempty(strctTrialType.Cue{iCueIter}.CueValidAttributesOR)
            acRequiredAttributesOR = fnSplitString(strctTrialType.Cue{iCueIter}.CueValidAttributesOR);
            [acParsedRequiredAttributesOR, bFailed] = fnParseRequiredAttributesUsingExistingInformation(acRequiredAttributesOR,strctCurrentTrial);
           if bFailed
                strctCurrentTrial = [];
                return;
            end;   
        else
            acParsedRequiredAttributesOR = g_strctParadigm.m_strctDesign.m_acAttributes;
        end
        
        if isfield(strctTrialType.Cue{iCueIter},'CueValidAttributes')
            acRequiredAttributes = fnSplitString(strctTrialType.Cue{iCueIter}.CueValidAttributes);
            [acParsedRequiredAttributes, bFailed] = fnParseRequiredAttributesUsingExistingInformation(acRequiredAttributes,strctCurrentTrial);
            if bFailed
                strctCurrentTrial = [];
                return;
            end;
        else
            acParsedRequiredAttributes = cell(0);
        end
        
        if isfield(strctTrialType.Cue{iCueIter},'CueInvalidAttributes')
            acNotAllowedAttributes = fnSplitString(strctTrialType.Cue{iCueIter}.CueInvalidAttributes);
            [acParsedNotAllowedAttributes, bFailed] = fnParseRequiredAttributesUsingExistingInformation(acNotAllowedAttributes,strctCurrentTrial);
            if bFailed
                strctCurrentTrial = [];
                return;
            end;
            
        else
            acParsedNotAllowedAttributes = cell(0);
        end
        
        if isfield(strctTrialType.Cue{iCueIter},'CueIgnoreAttributes')
            acIgnoreAttributes = fnSplitString(strctTrialType.Cue{iCueIter}.CueIgnoreAttributes);
            [acParsedIgnoreAttributes bFailed] = fnParseRequiredAttributesUsingExistingInformation(acIgnoreAttributes,strctCurrentTrial);
            if bFailed
                strctCurrentTrial = [];
                return;
            end;
            
        else
            acParsedIgnoreAttributes = cell(0);
		end
		
		
		if isfield(strctTrialType.Cue{iCueIter},'CueValidIgnoreAttributes')
            acValidIgnoreAttributes = fnSplitString(strctTrialType.Cue{iCueIter}.CueValidIgnoreAttributes);
            [acParsedValidIgnoreAttributes bFailed] = fnParseRequiredAttributesUsingExistingInformation(acValidIgnoreAttributes,strctCurrentTrial);
            if bFailed
                strctCurrentTrial = [];
                return;
            end;
            
        else
            acParsedValidIgnoreAttributes = cell(0);
        end		
		
        
         A = ismember( g_strctParadigm.m_strctDesign.m_acAttributes, acParsedRequiredAttributes);
         D = ismember( g_strctParadigm.m_strctDesign.m_acAttributes,acParsedRequiredAttributesOR);
		 E = ismember( g_strctParadigm.m_strctDesign.m_acAttributes, acParsedValidIgnoreAttributes);
		 
        if isempty(acParsedNotAllowedAttributes)
            B = ones(size(g_strctParadigm.m_strctDesign.m_acAttributes))>0;
        else
            B = ismember( g_strctParadigm.m_strctDesign.m_acAttributes, acParsedNotAllowedAttributes);
        end
        C=  ismember( g_strctParadigm.m_strctDesign.m_acAttributes, acParsedIgnoreAttributes);
        B(C)=0;
		A(E) = 0;
        
        
        abHasA =  all(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(:, A),2) & sum(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(:, D),2) > 0;
        abDoesNotHaveB = ~all(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(:, B),2);
        abValidMediaCues = abHasA & abDoesNotHaveB;
       
        aiValidMediaCues = find(abValidMediaCues);
        % Select one cue at random!
        aiRandPerm = randperm(sum(abValidMediaCues));

       iMediaIndex =aiValidMediaCues(aiRandPerm(1));
        strctCurrentTrial.m_astrctMedia(iOffset+1) = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex);
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strName = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CueMedia;
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strFileName =g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_iMediaIndex = iMediaIndex;
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bMovie = g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaIndex).m_bMovie;
        
end

if ~isempty(strctCurrentTrial.m_astrctCueMedia)
    % Additional parameters available? If not, take deafult from GUI
    
    
     strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bDisplayCue=  fnParseVariable(...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'DisplayCue', true);
    
    % How long will the cue be presented on the screen?
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCuePeriodMS =fnParseVariable(...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'CuePeriodMS', fnTsGetVar(g_strctParadigm, 'CuePeriodMS'));
    
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bCueHighlight =fnParseVariable(...        
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'CueHighlight', false);
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'CueHighlightColor')
        X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CueHighlightColor,'%f %f %f');
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_afCueHighlightColor = X;
    else
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_afCueHighlightColor = [255 0 0];
    end    
    
    % Is there noise on the cue image?
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCueNoiseLevel = fnParseVariable(...        
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'CueNoiseLevel', fnTsGetVar(g_strctParadigm, 'CueNoiseLevel'));
    
    % Cue size 
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCueSizePix =  fnParseVariable(...        
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'CueSizePix', fnTsGetVar(g_strctParadigm, 'CueSizePix'));
    
    % Cue Position
    
   if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'CuePosition')
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            if strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CuePosition,'center')
                strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fCuePosition = aiScreenSize(3:4)/2;
            elseif strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CuePosition,'random')
                iXPos =strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCueSizePix   + rand() * (aiScreenSize(3)-strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCueSizePix);
                iYPos = strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCueSizePix + rand() * (aiScreenSize(4)-strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCueSizePix );
                strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fCuePosition = [iXPos;iYPos];
            else
                % assume exact position....
               aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
                
                X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CuePosition,'%f %f');
               strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fCuePosition = X(:)' + aiScreenSize(3:4)/2;
            end
    else
            % Default position is center of screen
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fCuePosition = aiScreenSize(3:4)/2;
    end    
    
    
    
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bAbortTrialIfBreakFixationDuringCue = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'AbortTrialIfBreakFixationDuringCue', true);
    
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bAbortTrialIfBreakFixationOnCue = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'AbortTrialIfBreakFixationOnCue', false);
  
    
   % Cue fixation region
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'CueFixationRegion')
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strCueFixationRegion= g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.CueFixationRegion;
    else
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strCueFixationRegion = 'EntireCue';
    end    
    
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bOverlayPreCueFixation = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'OverlayFixation', true);
    
   % Cue fixation spot
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'FixationSpotType')
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strFixationSpotType= g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.FixationSpotType;
    else
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strFixationSpotType = 'Disc';
    end    
    
   % Cue fixation spot
   strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fFixationSpotSize = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'FixationSpotSize', 20);

       % Cue fixation spot threshold
       strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fFixationRegionPix=  fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'FixationRegion', 60);

    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'FixationPosition')
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            if strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.FixationPosition,'center')
                strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fFixationPosition = aiScreenSize(3:4)/2;
            elseif strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.FixationPosition,'cuecenter')
                strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fFixationPosition = strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fCuePosition;
            elseif strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.FixationPosition,'random')
                iXPos = strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize  + rand() * (aiScreenSize(3)-strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize );
                iYPos = strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize  + rand() * (aiScreenSize(4)-strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize );
                strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fFixationPosition = [iXPos;iYPos];
            else
                % assume exact position....
               aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
                X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.FixationPosition,'%f %f');
                strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fFixationPosition = X + aiScreenSize(3:4)/2;
            end
    else
            % Default position is center of screen
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_pt2fFixationPosition = aiScreenSize(3:4)/2;
    end    
       
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'FixationColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.FixationColor,'%f %f %f');
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_afFixationColor= X(:)';
    else
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_afFixationColor= [255 255 255];
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'BackgroundColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.BackgroundColor,'%f %f %f');
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_afBackgroundColor= X(:)';
    else
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_afBackgroundColor= [1 1 1];
    end
    
    % Post cue memory period?
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_fCueMemoryPeriodMS= fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'MemoryPeriodMS',0 );

    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bCueMemoryPeriodShowFixation = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'ShowFixationSpot', false);

    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bCueMemoryPeriodAbortTrialIfBreakFixation= fnParseVariable(...
    g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'AbortTrialIfBreakFixation', false);
    
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bClearBefore =  fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'ClearBefore', true);
      
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bClearAfter =  fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'ClearAfter', true);
    
    strctCurrentTrial.m_astrctCueMedia(iCueIter).m_bDontFlip =fnParseVariable(...   
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'DontFlip', false);
    
    % Micro stim parameters.....
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'Stimulation')
        % Default to no stimulation (just to be on the safe side)
         bStimulation = fnParseVariable(...
             g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'Stimulation', false);
        if bStimulation
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_astrctMicroStim = ...
                fnExtractMicroStimParams(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter});
        else
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_astrctMicroStim = []; % No stimulation during this cue.
        end
    else
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_astrctMicroStim = []; % No stimulation during this cue.
    end
    
     if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter},'AudioMedia')
        % Find the relevant audio file...
        iAudioMediaIndex = find(ismember({g_strctParadigm.m_strctDesign.m_astrctMedia.m_strName}, ...
            g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.AudioMedia));
        if isempty(iAudioMediaIndex)
            fprintf('ERROR. Failed to find audio media called : %s\n',g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.Cue{iCueIter}.AudioMedia);
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strctAudio = [];
        else
            strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strctAudio.m_iMediaIndex = iAudioMediaIndex;
        end
        
     else
        strctCurrentTrial.m_astrctCueMedia(iCueIter).m_strctAudio = [];
    end
    
end
return;



function astrctMicroStim = fnExtractMicroStimParams(strctRoot)
global g_strctParadigm g_strctDAQParams
% Check if user has microstim active
if ~g_strctParadigm.MicroStimActive.Buffer(g_strctParadigm.MicroStimActive.BufferIdx)
	astrctMicroStim = [];
	return;
end

% how many channels are we stimulating?
if isfield(strctRoot,'StimulationPreset')
    % Find the corresponding entry....
    iNumPresets = length(g_strctParadigm.m_strctDesign.m_acMicrostimPresets);
    iPresetIndex = -1;
    for k=1:iNumPresets
        if isfield(g_strctParadigm.m_strctDesign.m_acMicrostimPresets{k},'Name') && ...
                strcmpi(g_strctParadigm.m_strctDesign.m_acMicrostimPresets{k}.Name, strctRoot.StimulationPreset)
            iPresetIndex = k;
            break;
        end
    end
    if iPresetIndex == -1
        fnParadigmToKofikoComm('DisplayMessageNow','ERROR: Missing microstim preset');
        astrctMicroStim = [];
        return;
    end
    strctStimPreset = g_strctParadigm.m_strctDesign.m_acMicrostimPresets{iPresetIndex};
    
    acChannels = fnSplitString(strctStimPreset.Channels,' ');
    iNumChannels = length(acChannels);
    afAmplitudes = fnTsGetVar(g_strctDAQParams,'MicroStimAmplitude');
    acMicroStimSource = fnTsGetVar(g_strctDAQParams,'MicroStimSource');
    for iStimIter=1:iNumChannels
        astrctMicroStim(iStimIter).m_iChannel = str2num(acChannels{iStimIter});
        
        astrctMicroStim(iStimIter).m_fAmplitude = afAmplitudes(astrctMicroStim(iStimIter).m_iChannel);
        astrctMicroStim(iStimIter).m_strSource = acMicroStimSource{astrctMicroStim(iStimIter).m_iChannel};
        
        astrctMicroStim(iStimIter).m_fDelayToTrigMS =  fnParseVariable(strctStimPreset,'Delay', 0,iStimIter);
        astrctMicroStim(iStimIter).m_fPulseWidthMS =  fnParseVariable(strctStimPreset,'PulseWidth', 0,iStimIter);
        astrctMicroStim(iStimIter).m_bBiPolar =  fnParseVariable(strctStimPreset,'Bipolar', 0,iStimIter);
        astrctMicroStim(iStimIter).m_fSecondPulseWidthMS =  fnParseVariable(strctStimPreset,'SecondPulseWidth', 0,iStimIter);
        astrctMicroStim(iStimIter).m_fBiPolarDelayMS =  fnParseVariable(strctStimPreset,'BipolarDelay', 0,iStimIter);
        astrctMicroStim(iStimIter).m_fPulseRateHz =  fnParseVariable(strctStimPreset,'PulseRate', 0,iStimIter);
        astrctMicroStim(iStimIter).m_fTrainRateHz =  fnParseVariable(strctStimPreset,'TrainRate', 0,iStimIter);
        astrctMicroStim(iStimIter).m_fTrainDurationMS =  fnParseVariable(strctStimPreset,'TrainDuration', 0,iStimIter);
        astrctMicroStim(iStimIter).m_strWhenToStimulate =  fnParseVariable(strctStimPreset,'WhenToStimulate', 'OnChoice',iStimIter);
        
    end

    
else
    % No preset, information is in the trial 
    acChannels = fnSplitString(strctRoot.StimChannels,' ');
    iNumChannels = length(acChannels);
    for iStimIter=1:iNumChannels
        astrctMicroStim(iStimIter).m_iChannel = str2num(acChannels{iStimIter});
        % Amplitude
        astrctMicroStim(iStimIter).m_fAmplitude =  fnParseVariable(...
            strctRoot,'MicroStimAmplitude', fnTsGetVar(g_strctParadigm,'MicroStimAmplitude'),iStimIter);
        % Delay to trigger
        astrctMicroStim(iStimIter).m_fDelayToTrigMS =  fnParseVariable(...
            strctRoot,'MicroStimDelayMS', fnTsGetVar(g_strctParadigm,'MicroStimDelayMS'),iStimIter);
        % Delay to trigger
        astrctMicroStim(iStimIter).m_fPulseWidthMS =  fnParseVariable(...
            strctRoot,'MicroStimPulseWidthMS', fnTsGetVar(g_strctParadigm,'MicroStimPulseWidthMS'),iStimIter);
        astrctMicroStim(iStimIter).m_bBiPolar =  fnParseVariable(...
            strctRoot,'MicroStimBiPolar', fnTsGetVar(g_strctParadigm,'MicroStimBiPolar'),iStimIter);
        astrctMicroStim(iStimIter).m_fSecondPulseWidthMS =  fnParseVariable(...
            strctRoot,'MicroStimSecondPulseWidthMS', fnTsGetVar(g_strctParadigm,'MicroStimSecondPulseWidthMS'),iStimIter);
        astrctMicroStim(iStimIter).m_fBiPolarDelayMS =  fnParseVariable(...
            strctRoot,'MicroStimBipolarDelayMS', fnTsGetVar(g_strctParadigm,'MicroStimBipolarDelayMS'),iStimIter);
        astrctMicroStim(iStimIter).m_fPulseRateHz =  fnParseVariable(...
            strctRoot,'MicroStimPulseRateHz', fnTsGetVar(g_strctParadigm,'MicroStimPulseRateHz'),iStimIter);
        astrctMicroStim(iStimIter).m_fTrainRateHz =  fnParseVariable(...
            strctRoot,'MicroStimTrainRateHz', fnTsGetVar(g_strctParadigm,'MicroStimTrainRateHz'),iStimIter);
        astrctMicroStim(iStimIter).m_fTrainDurationMS =  fnParseVariable(...
            strctRoot,'MicroStimTrainDurationMS', fnTsGetVar(g_strctParadigm,'MicroStimTrainDurationMS'),iStimIter);
		astrctMicroStim(iStimIter).m_bActive = 0;
		% Plan the spike train; in progress
		switch g_strctParadigm.m_strMicroStimType
			% Store the stimulation times from time zero, and check against them during the paradigm cycle
			case 'FixedRate'
				disp('spike train generated')
				astrctMicroStim(iStimIter).m_aSpikeTrain = linspace(0,astrctMicroStim(iStimIter).m_fTrainDurationMS,...
					round(astrctMicroStim(iStimIter).m_fTrainDurationMS/(1000/astrctMicroStim(iStimIter).m_fPulseRateHz)));
			case 'Poisson'
				% Get the parameters for generating the spike train
				times = [0:.001:astrctMicroStim(iStimIter).m_fTrainDurationMS]; %Plot for every ms
				astrctMicroStim(iStimIter).m_aSpikeTrain = zeros(numTrains, length(times));
				ClockRandSeed;
				vt = rand(size(times));
				astrctMicroStim(iStimIter).m_aSpikeTrain = (astrctMicroStim(iStimIter).m_fPulseRateHz*.001) > vt;
			case 'Pearson'
				% In progress
				%{
				mu = 80;
				sigma = 5;
				skew = 2.5;
				kurt = 10;
				samplesM = 4000;
				samplesN = 1;
				astrctMicroStim(iStimIter).m_aSpikeTrain = 
				%}
			otherwise
				% assume fixed rate
				astrctMicroStim(iStimIter).m_aSpikeTrain = linspace(0,astrctMicroStim(iStimIter).m_fTrainDurationMS,1/astrctMicroStim(iStimIter).m_fPulseRateHz);
		end
		%astrctMicroStim(iStimIter).m_aSpikeTrain = 
		
		% Not functional as far as I can tell
		%{
		%switch g_strctParadigm.m_strctMicroStim.m_strMicroStimType
         %   case 'FixedRate'
          %      g_strctParadigm.m_strctMicroStim.m_fNextStimTS = g_strctParadigm.m_strctMicroStim.m_fNextStimTS + 1/g_strctParadigm.m_strctMicroStim.m_fMicroStimRateHz;
           % case 'Poisson'
                % I hope I got this right. This should generate a poisson
                % train (actually, an exponential latency between events)
				
				
				
				
				
				
                FiringRate = g_strctParadigm.m_strctMicroStim.m_fMicroStimRateHz;
                NumSeconds = 1;
                N=ceil(FiringRate* NumSeconds);
                a2fUniformDist=rand(1, N);
                a2fExpDist = -log(a2fUniformDist); % exponentially distributed random values.
                fNextEventLatencySec =  a2fExpDist/FiringRate;
                g_strctParadigm.m_strctMicroStim.m_fNextStimTS = g_strctParadigm.m_strctMicroStim.m_fNextStimTS  + fNextEventLatencySec;
                
        end
		%}
    end
end
return;

            

function [acParsedRequiredAttributes, bFailed] = fnParseRequiredAttributesUsingExistingInformation(acAttributes,strctCurrentTrial)
global g_strctParadigm          
% Replace special attributes....
acParsedRequiredAttributes = cell(0);
bFailed = false;

for k=1:length(acAttributes)
    if strncmpi(acAttributes{k},'CueAttributes',13)
        iIndexStart = find(acAttributes{k} == '(',1,'first');
        iIndexEnd = find(acAttributes{k} == ')',1,'first');
        if isempty(iIndexStart) || isempty(iIndexEnd)
            bFailed = true;
            return;
        end;
        
        iWhichPreviousCue = str2num(acAttributes{k}(iIndexStart+1:iIndexEnd-1));
        if isfield(strctCurrentTrial,'m_astrctCueMedia')
            iNumCues = length(strctCurrentTrial.m_astrctCueMedia);
        else
            iNumCues = 0;
        end;
        
        if iWhichPreviousCue > iNumCues || iWhichPreviousCue <= 0
            bFailed = true;
            return;
        end;
            acParsedRequiredAttributes = [acParsedRequiredAttributes, ...
                g_strctParadigm.m_strctDesign.m_acAttributes(g_strctParadigm.m_strctDesign.m_a2bMediaAttributes(strctCurrentTrial.m_astrctCueMedia(iWhichPreviousCue).m_iMediaIndex,:) )];
    elseif sum(acAttributes{k} == '*')
        acAttributes{k}(acAttributes{k} == '*') = [];
        acMatches = strfind(g_strctParadigm.m_strctDesign.m_acAttributes,acAttributes{k});
        for j=1:length(acMatches)
            if ~isempty(acMatches)
                acParsedRequiredAttributes = [acParsedRequiredAttributes,g_strctParadigm.m_strctDesign.m_acAttributes{j}];
            end
        end
        
    else
        acParsedRequiredAttributes = [acParsedRequiredAttributes,acAttributes{k}];
    end
end;

return;





function strctCurrentTrial = fnPrepareDynamicTrial(g_strctParadigm)

% Override the normal operation and generate random stimulus from the selected saturations and colors

% We're going to do a poor man's sub2ind here
% Hope I did this right
strctCurrentTrial.m_strctSaturations = 	g_strctParadigm.m_strctCurrentSaturations;
strctCurrentTrial.m_strctColors = g_strctParadigm.m_strctCurrentColors;
randomColor = round(rand*(numel(strctCurrentTrial.m_strctSaturations)*numel(strctCurrentTrial.m_strctColors)));
colorIndex = round(rem(randomColor,numel(strctCurrentTrial.m_strctSaturations)));
saturationIndex = round(randomColor/numel(strctCurrentTrial.m_strctSaturations));


strctCurrentTrial.m_aiStimCoordinates = [squeeze(g_strctParadigm.StimulusX.Buffer(:,1,g_strctParadigm.StimulusX.BufferIdx)),...
										 squeeze(g_strctParadigm.StimulusY.Buffer(:,1,g_strctParadigm.StimulusY.BufferIdx))];
strctCurrentTrial.m_iTheta = squeeze(g_strctParadigm.Orientation.Buffer(:,1,g_strctParadigm.Orientation.BufferIdx));
strctCurrentTrial.m_aiStimDimensions = [squeeze(g_strctParadigm.Length.Buffer(:,1,g_strctParadigm.Length.BufferIdx)),...
										 squeeze(g_strctParadigm.Width.Buffer(:,1,g_strctParadigm.Width.BufferIdx))];
					
% Clut Stuff					
% Stimulus Colors
strctCurrentTrial.m_aiClut = g_strctParadigm.m_afMasterClut;
strctCurrentTrial.m_aiClutColors = strctCurrentTrial.m_strctSaturations{saturationIndex}.RGB(colorIndex,:);% stimulus server color
strctCurrentTrial.m_aiStimulusColors = [2,2,2]; % Setup for bits ++
strctCurrentTrial.m_aiLocalStimulusColors = round(strctCurrentTrial.m_aiClutColors/255); % Setup for bits ++
strctCurrentTrial.m_aiClut(3,:) = strctCurrentTrial.m_aiClutColors;


% Background Colors				
strctCurrentTrial.m_strctPreCueFixation.m_afBackgroundColor= [1, 1, 1]; % Setup for bits ++
strctCurrentTrial.m_strctPreCueFixation.m_afLocalBackgroundColor = round(g_strctParadigm.m_strctMasterColorTable.neutralGray.RGB/255); % Setup for local machine

if g_strctParadigm.m_bUseFixationSpotAsCue % Use the fixation point as the cue color, only use for training right now
	strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor = [2,2,2] % Setup for bits ++
	strctCurrentTrial.m_bDoNotShowCue = 1;
else
	if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationColor,'%f %f %f');
            strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor= X(:)';
    else
        strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor= [255 255 255];
    end
	strctCurrentTrial.m_bDoNotShowCue = 0;
end

% Kludge it up
strctCurrentTrial = fnDynamicTrialCueSetup(strctCurrentTrial, g_strctParadigm);
% Cue information. Pulls from config information currently, not implemented in GUI
strctCurrentTrial = fnDynamicChoicesSetup(strctCurrentTrial, g_strctParadigm);
return;



function strctCurrentTrial = fnDynamicChoicesSetup(strctCurrentTrial, g_strctParadigm)

% Parse information from GUI and config


return;

function strctCurrentTrial = fnDynamicTrialCueSetup(strctCurrentTrial, g_strctParadigm)
if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType},'PreCueFixation')

	strctCurrentTrial.m_strctPreCueFixation.m_fPreCueFixationPeriodMS = fnParseVariable(...
		g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'PreCueFixationPeriodMS',...
		fnTsGetVar(g_strctParadigm,'PreCueFixationPeriodMS'));
	
	
	strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize = fnParseVariable(...
		g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationSpotSize',...
			fnTsGetVar(g_strctParadigm,'PreCueFixationSpotSize'));

		
	strctCurrentTrial.m_strctPreCueFixation.m_fPostTouchDelayMS = fnParseVariable(...
		g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'PostTouchDelayMS',...
			0);						 
end									 
	
 if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationPosition')
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            if strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationPosition,'center')
                strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
            elseif strcmpi(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationPosition,'random')
                iXPos = 2*strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize  + rand() * (aiScreenSize(3)-strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize*2 );
                iYPos = 2*strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize  + rand() * (aiScreenSize(4)-strctCurrentTrial.m_strctPreCueFixation.m_fFixationSpotSize*2 );
                strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = [iXPos;iYPos];
            else
                % assume exact position....
               aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
                X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationPosition,'%f %f');
                strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = X(:)' + aiScreenSize(3:4)/2;
            end
    else
            % Default position is center of screen
            aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
            strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition = aiScreenSize(3:4)/2;
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'BackgroundColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.BackgroundColor,'%f %f %f');
            strctCurrentTrial.m_strctPreCueFixation.m_afBackgroundColor= X(:)';
    else
        strctCurrentTrial.m_strctPreCueFixation.m_afBackgroundColor= [0 0 0];
    end
    
        if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationColor')   
            X=sscanf(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationColor,'%f %f %f');
            strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor= X(:)';
    else
        strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor= [255 255 255];
    end
    
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationSpotType')
            strctCurrentTrial.m_strctPreCueFixation.m_strFixationSpotType = g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.FixationSpotType;
    else
            strctCurrentTrial.m_strctPreCueFixation.m_strFixationSpotType = fnTsGetVar(g_strctParadigm,'PreCueFixationSpotType');
    end
      
   strctCurrentTrial.m_strctPreCueFixation.m_fFixationRegionPix = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'FixationRegion',...
         60);

    strctCurrentTrial.m_strctPreCueFixation.m_bAbortTrialUponTouchOutsideFixation = fnParseVariable( ...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation, 'AbortTrialIfTouchOutsideCue', false);
    
    strctCurrentTrial.m_strctPreCueFixation.m_bRewardTouchFixation = fnParseVariable(...
        g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'RewardTouchCue', false);
   
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'RewardSound')
        strctCurrentTrial.m_strctPreCueFixation.m_strRewardSound= g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation.RewardSound;
    else
        strctCurrentTrial.m_strctPreCueFixation.m_strRewardSound = [];
   end
   
    % Assume that if stimulation is applied on pre-fixation, its only when
    % moneky saccades OUT of the fixation region after the required
    % fixation time. This is typically useful for stimulation-mid-saccade
    % type of experiments....
        
    if isfield(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'Stimulation')
        % Default to no stimulation (just to be on the safe side)
         bStimulation = fnParseVariable(...
             g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation,'Stimulation', false);
        if bStimulation
            strctCurrentTrial.m_strctPreCueFixation.m_astrctMicroStim = ...
                fnExtractMicroStimParams(g_strctParadigm.m_strctDesign.m_acTrialTypes{strctCurrentTrial.m_iTrialType}.PreCueFixation);
        else
            strctCurrentTrial.m_strctPreCueFixation.m_astrctMicroStim = []; % No stimulation during this cue.
        end
    end
      
    
else
    strctCurrentTrial.m_strctPreCueFixation = []; % no pre cue fixation period
end


return;