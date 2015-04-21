function strctRun = fnPrepareStimuliTimingFromBlockDesign()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  

strctBlockOrder = g_strctParadigm.m_strctDesign.m_acBlockOrders{g_strctParadigm.m_iActiveOrder};
iNumBlocks = length(strctBlockOrder.m_acBlocks);

% Do we have any microstim presets?
if isfield(g_strctParadigm.m_strctDesign.m_strctXML,'MicroStim')
   % Generate the on-the-fly information about stimulation pulses.
   acPresets = g_strctParadigm.m_strctDesign.m_strctXML.MicroStim.Preset;
   iNumPresets = length(acPresets);
   if iNumPresets == 1
       acPresets = {acPresets};
   end;
   
   acMicroStimPresets = cell(1,iNumPresets);
   for iPresetIter=1:iNumPresets
       
       strctPreset.m_strName = acPresets{iPresetIter}.Name;
       strctPreset.m_strType = acPresets{iPresetIter}.Type;
       strctPreset.m_aiChannels = str2num(acPresets{iPresetIter}.Channels);
       switch strctPreset.m_strType
           case 'FixedRate'
               strctPreset.m_fRateHz = fnParseVariable(acPresets{iPresetIter},'RateHz',1);
       end
       acMicroStimPresets{iPresetIter} = strctPreset;
   end
 else
    acMicroStimPresets = [];
end

if ~isempty(acMicroStimPresets)
    acMicrostimPresetNames = fnCellStructToArray(acMicroStimPresets,'m_strName');
else
    acMicrostimPresetNames = [];
end

clear strctRun
% Iterate over blocks and build the presentation list.
fTR_MS = fnTsGetVar(g_strctParadigm,'TR');
strctRun.m_strOrderName = strctBlockOrder.m_strName;
strctRun.m_iOrderIndex = g_strctParadigm.m_iActiveOrder;
strctRun.m_acBlockNames = cell(1,iNumBlocks);
strctRun.m_acBlockNamesWithMicroStim = cell(1,iNumBlocks);
strctRun.m_aiNumTRperBlock = zeros(1,iNumBlocks);
strctRun.m_fTR_MS = fTR_MS;
strctRun.m_aiMediaList = [];
strctRun.m_afDisplayTimeMS = [];
strctRun.m_acMicroStim = cell(1, iNumBlocks);
strctRun.m_afBlockLengthSec = zeros(1,iNumBlocks);
for iBlockIter=1:iNumBlocks
    % Which block is it ?
    iBlockIndex = strctBlockOrder.m_aiBlockIndices(iBlockIter);
    strctRun.m_acBlockNames{iBlockIter} = strctBlockOrder.m_acBlocks{iBlockIter}.m_strctXML.Name;
    strctRun.m_aiNumTRperBlock(iBlockIter) = fnParseVariable(strctBlockOrder.m_acBlocks{iBlockIter}.m_strctXML, 'LengthTR', 12);
   % Build the images in this block
   aiMediaIndices = g_strctParadigm.m_strctDesign.m_acBlocks{iBlockIndex}.m_aiMediaIndices;
   iNumMediaInBlock = length(aiMediaIndices);
   acMediaNames = g_strctParadigm.m_strctDesign.m_acMediaName(aiMediaIndices);
   
   strctRun.m_acBlockNamesWithMicroStim{iBlockIter} =  strctRun.m_acBlockNames{iBlockIter};
   % Block attributes
   % Microstim?
   [Dummy, MicrostimPresetName] = fnParseVariable(strctBlockOrder.m_acBlocks{iBlockIter}.m_strctXML,'Microstim',[]);
   if ~isempty(MicrostimPresetName)
       iPresetIndex = find(ismember(acMicrostimPresetNames,MicrostimPresetName));
       if isempty(iPresetIndex)
           fprintf('CRITICAL ERROR *** Could not find microstim preset named %s in order %s, block %s \n',MicrostimPresetName,strctRun.m_strOrderName,strctRun.m_acBlockNames{iBlockIter});
           fprintf('*** Microstim will be ignored for this block\n');
       else
           strctRun.m_acMicroStim{iBlockIter} = acMicroStimPresets{iPresetIndex};
           strctRun.m_acBlockNamesWithMicroStim{iBlockIter} = [strctRun.m_acBlockNames{iBlockIter},'+ Stimulation (',MicrostimPresetName ,')'];
       end
   end
   
   
   % Shuffle?
   bShuffle = fnParseVariable(strctBlockOrder.m_acBlocks{iBlockIter}.m_strctXML,'ShuffleImages',true);
   if bShuffle
       aiRandPerm = randperm(iNumMediaInBlock);
       aiMediaIndices = aiMediaIndices(aiRandPerm);
   end
   %
   fTimePerBlockMS = strctRun.m_aiNumTRperBlock(iBlockIter)* fTR_MS;
   strctRun.m_afBlockLengthSec(iBlockIter) = fTimePerBlockMS/1e3;
            
    fTime = 0;
    iImageCounter = 1;
    
    while fTime < fTimePerBlockMS
        
        iSelectedMedia = aiMediaIndices(iImageCounter);
        fMediaTimeMS = fnParseVariable(g_strctParadigm.m_strctDesign.m_astrctMedia(iSelectedMedia),'m_strLengthMS',500);
        if isempty(fMediaTimeMS)
            fprintf('*** CRITICAL ERROR. Cannot parse LengthMS field in media %s\n',g_strctParadigm.m_strctDesign.m_astrctMedia(iSelectedMedia).m_strName);
            fprintf('*** Unknown Global? Assuming 500 ms.\n');
            fMediaTimeMS = 500;
        end;
        strctRun.m_aiMediaList = [strctRun.m_aiMediaList, iSelectedMedia];
        strctRun.m_afDisplayTimeMS = [strctRun.m_afDisplayTimeMS,fMediaTimeMS ];
        
        iImageCounter = iImageCounter + 1;
        if iImageCounter > length(aiMediaIndices)
            % Shuffle again
            if bShuffle
                aiRandPerm = randperm(iNumMediaInBlock);
                aiMediaIndices = aiMediaIndices(aiRandPerm);
            end
            iImageCounter = 1;
        end
        fTime = fTime + fMediaTimeMS;
    end
    
    if fTime > fTimePerBlockMS
        fDiff = fTimePerBlockMS-fTime;
        strctRun.m_afDisplayTimeMS(end) = strctRun.m_afDisplayTimeMS(end) + fDiff;
    end
end
strctRun.m_afBlockOnsetTimeSec = [0,cumsum(strctRun.m_afBlockLengthSec)];
return


function [Value,ValueXML] = fnParseVariable(strctSubStructure, strFieldName, DefaultValue, iIndexInArray)
global g_strctParadigm
% First, try to match against known global variables....
if ~isfield(strctSubStructure, strFieldName)
    Value = DefaultValue;
    ValueXML = DefaultValue;
else
    ValueXML = getfield(strctSubStructure, strFieldName);
    
    if exist('iIndexInArray','var')
         % Accessing an array. Get only the relevant index.
         acEntries = fnSplitString(ValueXML,' ');
         ValueXML = acEntries{iIndexInArray};
    end
    
    
    % User specified that field. It can be either a global variable or
    % actual value.
    % First, search the known global variable list to see if there is a
    % match
    iNumGlobalVars = length(g_strctParadigm.m_strctDesign.m_astrctGlobalVars);
    for iVarIter=1:iNumGlobalVars
        if strcmp(g_strctParadigm.m_strctDesign.m_astrctGlobalVars(iVarIter).m_strName,ValueXML)
            % This is indeed a global variable!
            % We should have a time stampped variable with that name!
            Value = fnTsGetVar(g_strctParadigm, ValueXML);
            return;
        end
    end
    % If we reached here. It is not a global variable
    % Try to convert it to a numeric?
    Value = str2num(ValueXML);
end

return;