function strctDesign = fnLoadForceChoiceNewDesignFile(strDesignXML,iMaxImagesToHoldInMemory)

%% Parse XML file
try
    strctXML = fnMyXMLToStruct(strDesignXML,false);
catch
        fprintf('Error parsing XML file %s.\n',strDesignXML);
        strctDesign = [];
        return;
end

if ~isfield(strctXML,'Media') 
        fprintf('Error parsing design. Missing Media section\n');
        strctDesign = [];
        return;
end

if ~isfield(strctXML.Media,'Image')    
    iNumImages = 0;
else
    iNumImages = length(strctXML.Media.Image);
end
if iNumImages == 1
    strctXML.Media.Image = {strctXML.Media.Image};
end;

if ~isfield(strctXML.Media,'Movie')
iNumMovies= 0;
else
iNumMovies= length(strctXML.Media.Movie);
end
if iNumMovies == 1
    strctXML.Media.Image = {strctXML.Media.Movie};
end;


if ~isfield(strctXML.Media,'Audio')    
    iNumSounds = 0;
else
    iNumSounds= length(strctXML.Media.Audio);
end
if iNumSounds == 1
    strctXML.Media.Audio = {strctXML.Media.Audio};
end;


iNumMediaFiles = iNumImages+iNumMovies+iNumSounds;

if ~exist('iMaxImagesToHoldInMemory','var')
    iMaxImagesToHoldInMemory = 400;
end

if iNumImages > iMaxImagesToHoldInMemory
    bLoadOnTheFly = true;
else
    bLoadOnTheFly = false;
end

%% Make sure Images and Movies are available on the network. if possible, load images to standard memory
clear strctDesign
strctDesign.m_strDesignFileName = strDesignXML;
strctDesign.m_bLoadOnTheFly = bLoadOnTheFly;

% Verify all images/movies are available!
acMediaName = cell(1,iNumMediaFiles);
fprintf('Loading/Verifying images/movies existance, please wait...    ');
for iFileIter=1:iNumMediaFiles
    fprintf('\b\b\b\b%4d',iFileIter);
    
    bMovie = false;
    bAudio = false;
    bImage = false;
    acAttributes = cell(0);
    if iFileIter <= iNumImages
        % We are reading an image entry
        strFileName = strctXML.Media.Image{iFileIter}.FileName;
        strName = strctXML.Media.Image{iFileIter}.Name;
        if isfield(strctXML.Media.Image{iFileIter},'Attr')
            acAttributes = fnSplitString(strctXML.Media.Image{iFileIter}.Attr);
        end
        bImage = true;
    end
    if iFileIter>iNumImages && iNumMovies>0 && iFileIter < iNumImages+iNumMovies
        strFileName = strctXML.Media.Movie{iFileIter-iNumImages}.FileName;
        strName = strctXML.Media.Movie{iFileIter-iNumImages}.Name;
        if isfield(strctXML.Media.Movie{iFileIter-iNumImages},'Attr')
            acAttributes = fnSplitString(strctXML.Media.Movie{iFileIter-iNumImages}.Attr);
        end
        bMovie = true;
    end
    
    if iNumSounds > 0 && iFileIter > iNumImages+iNumMovies
        strFileName = strctXML.Media.Audio{iFileIter-iNumImages-iNumMovies}.FileName;
        strName = strctXML.Media.Audio{iFileIter-iNumImages-iNumMovies}.Name;
        if isfield(strctXML.Media.Audio{iFileIter-iNumImages},'Attr')
            acAttributes = fnSplitString(strctXML.Media.Audio{iFileIter-iNumImages-iNumMovies}.Attr);
        end
        bAudio = true;
    end
        
    
    bExist = exist(strFileName,'file');
    if ~bExist
        % exist sometimes fails for unknown reason... verify again with
        % dir...
            fprintf('\nA media file is missing from the design! : %s \n',strFileName);
            strctDesign = [];
            return;
    end
    strctDesign.m_astrctMedia(iFileIter).m_strFileName = strFileName;
    strctDesign.m_astrctMedia(iFileIter).m_strName = strName;
    strctDesign.m_astrctMedia(iFileIter).m_bImage = bImage;
    strctDesign.m_astrctMedia(iFileIter).m_bMovie = bMovie;
    strctDesign.m_astrctMedia(iFileIter).m_bAudio = bAudio;
    strctDesign.m_astrctMedia(iFileIter).m_acAttributes = acAttributes;
    acMediaName{iFileIter} =strName;
end
fprintf('\b\b\b\bDone.\n');
[acUniqueNames,aiIndices1,aiIndices2] = unique(acMediaName);
if length(acUniqueNames) ~= length(acMediaName)
    aiHist=hist(aiIndices2, 1:length(aiIndices1));
    aiDuplicateNames = find(aiHist > 1);
    fprintf('Two images/movies have the same name:');
    for j=1:length(aiDuplicateNames)
        fprintf('DUPLICATE: %s\n',acUniqueNames{aiDuplicateNames(j)});
    end;
    
    fprintf('Aborting...\n');
    strctDesign = [];
    return;
end
strctDesign.m_acMediaName= acMediaName;

%%
[strctDesign.m_acAttributes, strctDesign.m_a2bMediaAttributes] = fnBuildImageAttributeMatrix(strctDesign.m_astrctMedia);
%% Validate Trial Type Structure!
if ~isfield(strctXML,'TrialTypes')
        fprintf('Aborting...\n');
    strctDesign = [];
    return;
end

iNumTrialTypes = length(strctXML.TrialTypes.Trial);
if iNumTrialTypes == 1
    strctXML.TrialTypes.Trial = {strctXML.TrialTypes.Trial};
end

acTrialTypeNames = cell(1,iNumTrialTypes);
strctDesign.m_acTrialTypes = cell(1,iNumTrialTypes);
for iTrialTypeIter=1:iNumTrialTypes
    % Make sure trial was defined correctly!
    strctTrialType = strctXML.TrialTypes.Trial{iTrialTypeIter};
    
    [bValidTrialType, strReason] = fnTestTrialTypeValidity(strctTrialType,  strctDesign);
     if ~bValidTrialType
            fprintf('Error in trial type %d: %s.\n',iTrialTypeIter,strReason);
            strctDesign = [];
         return;
     else
         if ~isempty(strReason)
                fprintf('Warning in trial type %d: %s.\n',iTrialTypeIter,strReason);
         end
     end
    acTrialTypeNames{iTrialTypeIter} = strctTrialType.TrialParams.Name;
    strctDesign.m_acTrialTypes{iTrialTypeIter} = strctTrialType;
end
% Build Constrained next trial information

for iTrialTypeIter=1:iNumTrialTypes
    if isfield(strctDesign.m_acTrialTypes{iTrialTypeIter},'PostChoice') && isfield(strctDesign.m_acTrialTypes{iTrialTypeIter}.PostChoice,'ConstrainNextTrialTypes')
        acPossibleNextTrialTypes = fnSplitString(strctDesign.m_acTrialTypes{iTrialTypeIter}.PostChoice.ConstrainNextTrialTypes,';');
        if ~all(ismember(acPossibleNextTrialTypes, acTrialTypeNames))
           fprintf('Unfamiliar constrained trial type in trial type %s\n',acTrialTypeNames{iTrialTypeIter} );
            strctDesign = [];
             return;
        end
        for k=1:length(acPossibleNextTrialTypes)
            strctDesign.m_acTrialTypes{iTrialTypeIter}.PostChoice.m_aiConstrainNextTrialTypes(k) = find(ismember(acTrialTypeNames,acPossibleNextTrialTypes{k} ));
        end
    end
end
%% Global Variables
if isfield(strctXML,'GlobalVars')
    % Parse global defined variables....
    if isfield(strctXML.GlobalVars,'Var')
        iNumVars = length(strctXML.GlobalVars.Var);
        if iNumVars == 1
            strctXML.GlobalVars.Var = {strctXML.GlobalVars.Var};
        end
         
        for iVarIter=1:iNumVars
            astrctVariables(iVarIter).m_strName = strctXML.GlobalVars.Var{iVarIter}.Name;
            astrctVariables(iVarIter).m_strValue = strctXML.GlobalVars.Var{iVarIter}.InitialValue;
            astrctVariables(iVarIter).m_strType = strctXML.GlobalVars.Var{iVarIter}.Type;
            if isfield(strctXML.GlobalVars.Var{iVarIter},'Panel')
                astrctVariables(iVarIter).m_strPanel = strctXML.GlobalVars.Var{iVarIter}.Panel;
            end
            
            if isfield(strctXML.GlobalVars.Var{iVarIter},'Description')
                astrctVariables(iVarIter).m_strDescription = strctXML.GlobalVars.Var{iVarIter}.Description;
            end
            
        end
        strctDesign.m_astrctGlobalVars = astrctVariables;
    end
else
    strctDesign.m_astrctGlobalVars = [];
end


%% Micro stimulation presets
acMicroStimPresetNames = [];
if isfield(strctXML,'MicroStimPresets')
       if ~iscell(strctXML.MicroStimPresets)
           strctXML.MicroStimPresets = {strctXML.MicroStimPresets};
       end
       
       iNumPresets = length(strctXML.MicroStimPresets);
       
       for iPresetIter=1:iNumPresets
           strctDesign.m_acMicrostimPresets{iPresetIter} = strctXML.MicroStimPresets{iPresetIter}.MicroStimPreset;
           acMicroStimPresetNames{iPresetIter} = strctXML.MicroStimPresets{iPresetIter}.MicroStimPreset.Name;
       end
end

%%
%% Trial ordering?
if isfield(strctXML,'TrialOrder')
      strctDesign.m_strctOrder.m_strTrialOrderType = 'Blocks';
      if ~isfield(strctXML.TrialOrder,'Block')
           fprintf('TrialOrder->Block is missing\n');
                 strctDesign = [];
                 return;
       end
      
      iNumBlocks = length(strctXML.TrialOrder.Block);
      if iNumBlocks == 1
          strctXML.TrialOrder.Block = {strctXML.TrialOrder.Block};
      end
      strctDesign.m_strctOrder.m_acTrialTypeIndex = cell(1,iNumBlocks);
      strctDesign.m_strctOrder.m_aiNumTrialsPerBlock = zeros(1,iNumBlocks);
      strctDesign.m_strctOrder.m_abCountOnlyCorrectTrials = zeros(1,iNumBlocks) > 0;
      strctDesign.m_strctOrder.m_abRepeatIncorrect = zeros(1,iNumBlocks) > 0;
      strctDesign.m_strctOrder.m_acBlockNames = cell(1,iNumBlocks);
      strctDesign.m_strctOrder.m_aiMicroStimEntireBlockPresetIndex = zeros(1,iNumBlocks);
      for iBlockIter=1:iNumBlocks
          
          % Validate that trial type is defined in the file
          if isfield(strctXML.TrialOrder.Block{iBlockIter},'Name')
              strctDesign.m_strctOrder.m_acBlockNames{iBlockIter} = strctXML.TrialOrder.Block{iBlockIter}.Name;
          else
              strctDesign.m_strctOrder.m_acBlockNames{iBlockIter} = sprintf('Block %d',iBlockIter);
          end
          
          
       % Validate that trial type is defined in the file
          if isfield(strctXML.TrialOrder.Block{iBlockIter},'MicroStim')
              iMicroStimPresetIndex = find(ismember(lower(acMicroStimPresetNames), lower(strctXML.TrialOrder.Block{iBlockIter}.MicroStim)));
              if isempty(iMicroStimPresetIndex)
                  fprintf('Failed to find micro stim preset\n');
                  strctDesign = [];
                  return;
              end
              strctDesign.m_strctOrder.m_aiMicroStimEntireBlockPresetIndex(iBlockIter) = iMicroStimPresetIndex;
          end          
          
          acTrialTypesInThisBlock =fnSplitString(strctXML.TrialOrder.Block{iBlockIter}.Types);
          if isfield(strctXML.TrialOrder.Block{iBlockIter},'NumTrials')
              iNumTrials = str2num(strctXML.TrialOrder.Block{iBlockIter}.NumTrials);
          elseif isfield(strctXML.TrialOrder.Block{iBlockIter},'NumCorrectTrials')
              iNumTrials = str2num(strctXML.TrialOrder.Block{iBlockIter}.NumTrials);
              strctDesign.m_strctOrder.m_abCountOnlyCorrectTrials(iBlockIter) = true;
          elseif isfield(strctXML.TrialOrder.Block{iBlockIter},'NumberTR')
              
              iNumTRs = fnParseVariableInit(strctDesign, strctXML.TrialOrder.Block{iBlockIter}, 'NumberTR', -1);
              if iNumTRs == -1
                  % Problem parsing number of TRs....
                    fprintf('TrialOrder->Order failed to parse number of TRs in block %s', strctDesign.m_strctOrder.m_acBlockNames{iBlockIter} );
                  strctDesign = [];
                  return;
              end
              strctDesign.m_strctOrder.m_acNumTRsPerBlock{iBlockIter} = strctXML.TrialOrder.Block{iBlockIter}.NumberTR;
              iNumTrials = NaN;
              
          else
              fprintf('Error in block order %d. Unspecified number of trials.\n',iBlockIter);
              strctDesign = [];
              return;
          end
           
          if  isfield(strctXML.TrialOrder.Block{iBlockIter},'RepeatIncorrect') && str2num(strctXML.TrialOrder.Block{iBlockIter}.RepeatIncorrect) > 0
              strctDesign.m_strctOrder.m_abRepeatIncorrect(iBlockIter) = true;
          end
          strctDesign.m_strctOrder.m_aiNumTrialsPerBlock(iBlockIter) = iNumTrials;
          for iTrialTypeIter=1:length(acTrialTypesInThisBlock)
              iIndex = find(ismember(lower(acTrialTypeNames),lower(acTrialTypesInThisBlock{iTrialTypeIter})));
              if isempty(iIndex)
                  fprintf('TrialOrder->Order contains an unrecognized trial type (%s)\n',acTrialTypesInThisBlock{iTrialTypeIter});
                  strctDesign = [];
                  return;
              end
              if ~isnan(iNumTrials) && iNumTrials <= 0 
                  fprintf('TrialOrder->Order contains zero trials of trial type (%s)\n',acTrialTypesInThisBlock{iTrialTypeIter});
                  strctDesign = [];
                  return;
              end
              
              strctDesign.m_strctOrder.m_acTrialTypeIndex{iBlockIter}(iTrialTypeIter) = iIndex;
          end
          
      end
else
        strctDesign.m_strctOrder.m_strTrialOrderType = 'Random';
end


%% Real time statistics

% Default settings....
TRIAL_START_CODE = 32700;
TRIAL_END_CODE = 32699;
TRIAL_ALIGN_CODE = 32698;
TRIAL_OUTCOME_INCORRECT = 32696;
TRIAL_OUTCOME_CORRECT = 32697;
TRIAL_OUTCOME_ABORTED = 32695;
TRIAL_OUTCOME_TIMEOUT = 32694;

strctDesign.m_strctStatServerDesign.DesignName = strctDesign.m_strDesignFileName;
strctDesign.m_strctStatServerDesign.TrialStartCode = TRIAL_START_CODE;
strctDesign.m_strctStatServerDesign.TrialEndCode = TRIAL_END_CODE;
strctDesign.m_strctStatServerDesign.TrialAlignCode = TRIAL_ALIGN_CODE;
strctDesign.m_strctStatServerDesign.TrialOutcomesCodes = [TRIAL_OUTCOME_ABORTED,TRIAL_OUTCOME_INCORRECT,TRIAL_OUTCOME_CORRECT,TRIAL_OUTCOME_TIMEOUT];
strctDesign.m_strctStatServerDesign.KeepTrialOutcomeCodes = [TRIAL_OUTCOME_CORRECT,TRIAL_OUTCOME_INCORRECT];

if isfield(strctXML,'RealTimeStatistics')
    % Were other parameters defined as well?
    if isfield(strctXML.RealTimeStatistics,'Params')
        strctDesign.m_strctStatServerDesign.NumTrialsInCircularBuffer = fnParseVariableInit(strctDesign, strctXML.RealTimeStatistics.Params, 'NumTrialsInCircularBuffer', 205);
        strctDesign.m_strctStatServerDesign.Pre_TimeSec = fnParseVariableInit(strctDesign, strctXML.RealTimeStatistics.Params, 'PreTrialTimeSec', 0.5);
        strctDesign.m_strctStatServerDesign.Post_TimeSec =fnParseVariableInit(strctDesign, strctXML.RealTimeStatistics.Params, 'PostTrialTimeSec', 0.5);
    else
        % Default to no conditions.
        strctDesign.m_strctStatServerDesign.NumTrialsInCircularBuffer = 200;
        strctDesign.m_strctStatServerDesign.Pre_TimeSec = 0.5;
        strctDesign.m_strctStatServerDesign.Post_TimeSec = 0.5;
    end
    
    if isfield(strctXML.RealTimeStatistics,'Conditions') && isfield(strctXML.RealTimeStatistics.Conditions,'Condition')
        % User defined conditions.
        iNumConditions = length(strctXML.RealTimeStatistics.Conditions.Condition);
        if iNumConditions == 1
            strctXML.RealTimeStatistics.Conditions.Condition = {strctXML.RealTimeStatistics.Conditions.Condition};
        end
         iNumTrialTypes =  length( strctDesign.m_acTrialTypes);
        strctDesign.m_strctStatServerDesign.TrialTypeToConditionMatrix = zeros(iNumTrialTypes,iNumConditions);

        strctDesign.m_strctStatServerDesign.ConditionNames = cell(1,iNumConditions);
        strctDesign.m_strctStatServerDesign.ConditionOutcomeFilter = cell(1,iNumConditions);
        strctDesign.m_strctStatServerDesign.ConditionVisibility = zeros(1,iNumConditions)>0;
        
        for iConditionIter = 1:iNumConditions
            strctCondition= strctXML.RealTimeStatistics.Conditions.Condition{iConditionIter};
            if isfield(strctCondition,'Name')
                strctDesign.m_strctStatServerDesign.ConditionNames{iConditionIter} = strctCondition.Name;
            else
                strctDesign.m_strctStatServerDesign.ConditionNames{iConditionIter} = sprintf('Condition %d',iConditionIter);
            end

            if isfield(strctCondition,'TrialOutcome')
                switch lower(strctCondition.TrialOutcome)
                    case 'correct'
                        strctDesign.m_strctStatServerDesign.ConditionOutcomeFilter{iConditionIter} = [TRIAL_OUTCOME_CORRECT];
                    case 'incorrect'
                        strctDesign.m_strctStatServerDesign.ConditionOutcomeFilter{iConditionIter} = [TRIAL_OUTCOME_INCORRECT];
                end
            else
                strctDesign.m_strctStatServerDesign.ConditionOutcomeFilter{iConditionIter} = []; % No outcome filtering
            end
            
              if ~isfield(strctCondition,'TrialTypes')
                  fprintf('Error in parsing XML: In RealTimeStatistics block, a condition (%d) was defined without trial types\n', iConditionIter);
                  strctDesign = [];
                  return;
              end
              acTrialConditionTypes = fnSplitString(strctCondition.TrialTypes,';');
              iNumTrialTypesInCondition = length(acTrialConditionTypes);
              % Make sure these trial types were defined.
              aiTrialTypesForThisCondition = zeros(1,iNumTrialTypesInCondition);
               for iTrialTypeIter=1:iNumTrialTypesInCondition
                   iTrialIndex = find(ismember(lower(acTrialTypeNames),  lower(acTrialConditionTypes{iTrialTypeIter})));
                   if isempty(iTrialIndex)
                       fprintf('Error in parsing XML: In RealTimeStatistics block, Condition (%s) is using an undefined trial type (%s)\n', strctDesign.m_strctStatServerDesign.ConditionNames{iConditionIter}, acTrialConditionTypes{iTrialTypeIter});
                       strctDesign = [];
                       return;
                   else
                       aiTrialTypesForThisCondition(iTrialTypeIter) = iTrialIndex;
                   end
               end
                
                   if isfield(strctCondition,'DefaultVisibility')
                           strctDesign.m_strctStatServerDesign.ConditionVisibility(iConditionIter) = str2num(strctCondition.DefaultVisibility);
                   end
               
               strctDesign.m_strctStatServerDesign.TrialTypeToConditionMatrix(aiTrialTypesForThisCondition,iConditionIter) = true;
        end
        strctDesign.m_strctStatServerDesign.TrialLengthSec = fnMaximumTrialLength(strctDesign);
    else
        iNumTrialTypes =  length( strctDesign.m_acTrialTypes);
        strctDesign.m_strctStatServerDesign.TrialTypeToConditionMatrix = zeros(iNumTrialTypes,0);
        strctDesign.m_strctStatServerDesign.ConditionNames = cell(0);
        strctDesign.m_strctStatServerDesign.ConditionOutcomeFilter = cell(0);
        strctDesign.m_strctStatServerDesign.ConditionVisibility = [];
        strctDesign.m_strctStatServerDesign.TrialLengthSec = fnMaximumTrialLength(strctDesign);
    end
else
    % Default to no conditions.
    strctDesign.m_strctStatServerDesign.NumTrialsInCircularBuffer = 200;
    strctDesign.m_strctStatServerDesign.Pre_TimeSec = 0.5;
    strctDesign.m_strctStatServerDesign.Post_TimeSec = 0.5;
    
    iNumTrialTypes =  length( strctDesign.m_acTrialTypes);
    strctDesign.m_strctStatServerDesign.TrialTypeToConditionMatrix = zeros(iNumTrialTypes,0);
    strctDesign.m_strctStatServerDesign.ConditionNames = cell(0);
    strctDesign.m_strctStatServerDesign.ConditionOutcomeFilter = cell(0);
    strctDesign.m_strctStatServerDesign.ConditionVisibility = [];
    strctDesign.m_strctStatServerDesign.TrialLengthSec = fnMaximumTrialLength(strctDesign);
end


return;


function fTrialLengthSec = fnMaximumTrialLength(strctDesign)
iNumTrialTypes = length(strctDesign.m_acTrialTypes);
MAX_ALLOWED_TIME_SEC = 15; % 15 seconds per trial should be sufficient....
afTrialLengthSec = zeros(1,iNumTrialTypes);
for iIter=1:iNumTrialTypes
    % Trial length is determined by:
    % Length of cues + their memory period
    % Length of memory period between cues and choices
    % Maximum time allowed to answer for choices

    if ~isfield(strctDesign.m_acTrialTypes{iIter},'Cue')
        afCueLengthSec = 0;
    else
        % Cues were defined.
          iNumCues = length(strctDesign.m_acTrialTypes{iIter}.Cue);
        if iNumCues == 1
            strctDesign.m_acTrialTypes{iIter}.Cue = {strctDesign.m_acTrialTypes{iIter}.Cue};
        end
        afCueLengthSec = zeros(1,iNumCues);
        for iCueIter=1:iNumCues
             afCueLengthSec(iCueIter) = fnParseVariableInit(strctDesign, strctDesign.m_acTrialTypes{iIter}.Cue{iCueIter}, 'CuePeriodMS', 0)/1e3 + ...
                                        fnParseVariableInit(strctDesign, strctDesign.m_acTrialTypes{iIter}.Cue{iCueIter}, 'MemoryPeriodMS', 0)/1e3;
    
        end
    end

      % memory period ?
      if ~isfield(strctDesign.m_acTrialTypes{iIter},'MemoryPeriod')
          fMemoryPeriodSec = 0;
      else
          fMemoryPeriodSec = fnParseVariableInit(strctDesign, strctDesign.m_acTrialTypes{iIter}.MemoryPeriod, 'MemoryPeriodMS', 0)/1e3;
      end
  
    fChoiceTimeoutSec =  min(MAX_ALLOWED_TIME_SEC, fnParseVariableInit(strctDesign, strctDesign.m_acTrialTypes{iIter}.TrialParams, 'TrialTimeoutMS', 5)/1e3);
    afTrialLengthSec(iIter) = fChoiceTimeoutSec + sum(afCueLengthSec) + fMemoryPeriodSec;
end

fTrialLengthSec = max(afTrialLengthSec);
return;



function Value = fnParseVariableInit(strctDesign, strctSubStructure, strFieldName, DefaultValue)
% First, try to match against known global variables....
if ~isfield(strctSubStructure, strFieldName)
    Value = DefaultValue;
else
    ValueXML = getfield(strctSubStructure, strFieldName);
    % User specified that field. It can be either a global variable or
    % actual value.
    % First, search the known global variable list to see if there is a
    % match
    iNumGlobalVars = length(strctDesign.m_astrctGlobalVars);
    for iVarIter=1:iNumGlobalVars
        if strcmp(strctDesign.m_astrctGlobalVars(iVarIter).m_strName,ValueXML)
            % This is indeed a global variable!
            % We should have a time stampped variable with that name!
            Value = str2num(strctDesign.m_astrctGlobalVars(iVarIter).m_strValue);
            return;
        end
    end
    % If we reached here. It is not a global variable
    % Try to convert it to a numeric?
    Value = str2num(ValueXML);
end

return;


    
%%
function [bValidTrialType, strReason] = fnTestTrialTypeValidity(strctTrialType, strctDesign)
bValidTrialType = false;
strReason = '';

if ~isfield(strctTrialType,'TrialParams')
    strReason = 'Missing the TrialParams structure';
    return;
end
if ~isfield(strctTrialType.TrialParams,'CueType') || ~isfield(strctTrialType.TrialParams,'ChoicesType')
    strReason ='Missing the TrialParams->ChoicesType or TrialParams->CueType structures';
    return;
end

if ~strcmpi(strctTrialType.TrialParams.CueType,'fixed') && ~strcmpi(strctTrialType.TrialParams.CueType,'random')&& ~strcmpi(strctTrialType.TrialParams.CueType,'nocue')
    strReason ='Unknown TrialParams->Cue Type field';
    return;
end

if ~strcmpi(strctTrialType.TrialParams.ChoicesType,'fixed')&& ~strcmpi(strctTrialType.TrialParams.ChoicesType,'random') && ~strcmpi(strctTrialType.TrialParams.ChoicesType,'NoChoices')
    strReason ='Unknown TrialParams->ChoicesType field';
    return;
end

% check definitions of cue image
if strcmpi(strctTrialType.TrialParams.CueType,'fixed') && ~isfield(strctTrialType,'Cue')
    strReason ='Cue section is missing';
    return;
end

if strcmpi(strctTrialType.TrialParams.CueType,'fixed') 
    if length(strctTrialType.Cue) == 1
        if ~isfield(strctTrialType.Cue,'CueMedia')
            strReason = sprintf('Cue->CueMedia is missing in Cue %d',k);
            return;
        end
        if  ~ismember(lower(strctTrialType.Cue.CueMedia),lower(strctDesign.m_acMediaName))
            strReason =sprintf('Cue->CueMedia  contains image name (%s) which was not found in the image list',strctTrialType.Cue.CueMedia);
            return;
            
        end
    else
        for k=1:length(strctTrialType.Cue)
            if ~isfield(strctTrialType.Cue{k},'CueMedia')
                strReason = sprintf('Cue->CueMedia is missing in Cue %d',k);
                return;
            end
            if  ~ismember(lower(strctTrialType.Cue{k}.CueMedia),lower(strctDesign.m_acMediaName))
                strReason =sprintf('Cue->CueMedia  contains image name (%s) which was not found in the image list',strctTrialType.Cue.CueMedia);
                return;
            end
        end
    end
end
%   make sure the image is available!


if isfield(strctTrialType,'Cue') && ~iscell(strctTrialType.Cue)
    strctTrialType.Cue = {strctTrialType.Cue};
end

if isfield(strctTrialType,'Cue')
    iNumCues = length(strctTrialType.Cue);
else
    iNumCues = 0;
end

for iCueIter=1:iNumCues 

    % Make sure attribute constraints can be met for random cues
    if strcmpi(strctTrialType.TrialParams.CueType,'random')
        if isfield(strctTrialType.Cue{iCueIter},'CueValidAttributes')
            acRequiredAttributes = fnSplitString(strctTrialType.Cue{iCueIter}.CueValidAttributes);
        else
            acRequiredAttributes = cell(0);
        end
        
        if isfield(strctTrialType.Cue{iCueIter},'CueInvalidAttributes')
            acNotAllowedAttributes = fnSplitString(strctTrialType.Cue{iCueIter}.CueInvalidAttributes);
        else
            acNotAllowedAttributes = cell(0);
        end
        
        % Parse special attributes.....
        abIgnoreReqAttributes = zeros(1, length(acRequiredAttributes)) > 0;
        for k=1:length(acRequiredAttributes)
            abIgnoreReqAttributes(k) = strncmpi(acRequiredAttributes{k},'CueAttributes',13) || strncmpi(acRequiredAttributes{k},'NotCueAttributes',16) || ...
            strncmpi(acRequiredAttributes{k},'Cue(',4);
        end;
        acRequiredAttributes = acRequiredAttributes(~abIgnoreReqAttributes);

        abIgnoreNotReqAttributes = zeros(1, length(acNotAllowedAttributes)) > 0;
        for k=1:length(abIgnoreNotReqAttributes)
            abIgnoreNotReqAttributes(k) = strncmpi(acNotAllowedAttributes{k},'CueAttributes',13) || strncmpi(acNotAllowedAttributes{k},'NotCueAttributes',16) || ...
            strncmpi(acNotAllowedAttributes{k},'Cue(',4);
        end;
        acNotAllowedAttributes = acNotAllowedAttributes(~abIgnoreNotReqAttributes);
        
        
        abValidAttributes = ismember(strctDesign.m_acAttributes,acRequiredAttributes);
        abInvalidAttributes = ismember(strctDesign.m_acAttributes,acNotAllowedAttributes);
        
        if isempty(acRequiredAttributes)
            abMediaWithValidAttributes = ones( size(strctDesign.m_a2bMediaAttributes,1),1) > 0; % all images are OK
        else
            abMediaWithValidAttributes = sum(strctDesign.m_a2bMediaAttributes(:, abValidAttributes),2) == length(acRequiredAttributes);
        end
        
        abMediaWithoutInvalidAttributes = sum(strctDesign.m_a2bMediaAttributes(:, abInvalidAttributes),2) == 0;
        if sum(abMediaWithValidAttributes & abMediaWithoutInvalidAttributes) == 0
            strReason =sprintf('Cue->CueMedia  contains attribute constraints that cannot be met by the current image list');
            return;
        end
    end
    
end

%% make sure choices are set correctly
if strcmpi(strctTrialType.TrialParams.ChoicesType,'fixed')
    iNumChoices = length(strctTrialType.Choices.Choice);
    if iNumChoices == 1 && ~iscell(strctTrialType.Choices.Choice)
        strctTrialType.Choices.Choice = {strctTrialType.Choices.Choice};
    end
    for iChoiceIter=1:iNumChoices
        if ~isfield(strctTrialType.Choices.Choice{iChoiceIter},'Media')
            strReason =sprintf('Choices->Choice %d is missing the media name',iChoiceIter);
            return;
        end
        if  ~ismember(lower(strctTrialType.Choices.Choice{iChoiceIter}.Media),lower(strctDesign.m_acMediaName))
            strReason =sprintf('Choices->Choice %d contains an unknown image name (%s)',iChoiceIter,strctTrialType.Choices.Choice{iChoiceIter}.Media);
            return;
        end
    end
elseif strcmpi(strctTrialType.TrialParams.ChoicesType,'random')
    if ~isfield(strctTrialType.Choices,'ChoicesParam')
            strReason =sprintf('Choices->ChoicesParam section is missing');
            return;
    end
    
    if ~isfield(strctTrialType.Choices.ChoicesParam,'ValidAttributes')
            strReason =sprintf('Choices->ChoicesParam->ValidAttributes is missing');
            return;
    end
    if ~isfield(strctTrialType.Choices.ChoicesParam,'InvalidAttributes')
            strReason =sprintf('Choices->ChoicesParam->InvalidAttributes is missing');
            return;
    end
    
    if ~isfield(strctTrialType.Choices.ChoicesParam,'NumChoices')
            strReason =sprintf('Choices->ChoicesParam->NumChoices is missing');
            return;
    end
    
    acRequiredAttributes = fnSplitString(strctTrialType.Choices.ChoicesParam.ValidAttributes);
    acNotAllowedAttributes = fnSplitString(strctTrialType.Choices.ChoicesParam.InvalidAttributes);
    
    abValidAttributes = ismember(strctDesign.m_acAttributes,acRequiredAttributes);
    abInvalidAttributes = ismember(strctDesign.m_acAttributes,acNotAllowedAttributes);
    
    if isempty(acRequiredAttributes)
        abMediaWithValidAttributes = ones( size(strctDesign.m_a2bMediaAttributes,1),1) > 0; % all images are OK
    else
        abMediaWithValidAttributes = sum(strctDesign.m_a2bMediaAttributes(:, abValidAttributes),2) == length(acRequiredAttributes);
    end
    
    abMediaWithoutInvalidAttributes = sum(strctDesign.m_a2bMediaAttributes(:, abInvalidAttributes),2) == 0;
    
    iNumMediaFulfilingDemands = sum(abMediaWithValidAttributes & abMediaWithoutInvalidAttributes) ;
    if iNumMediaFulfilingDemands == 0
        strReason =sprintf('Choices->ChoicesParam  contains attribute constraints that cannot be met by the current image list');
        return;
    end

    iNumChoices = str2num(strctTrialType.Choices.ChoicesParam.NumChoices);
    
    if iNumMediaFulfilingDemands < iNumChoices
        strReason =sprintf('Choices->ChoicesParam->NumChoices  (%d) is larger than the available choices (%d)',iNumChoices,iNumMediaFulfilingDemands);
    end    
end


bValidTrialType = true;

return;
