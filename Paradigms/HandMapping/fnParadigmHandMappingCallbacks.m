function [varargout] =  fnParadigmHandMappingCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer  g_strctGUIParams g_strctCycle g_strctPlexon g_strctPTB

switch strCallback
	%{
	case 'GenerateAFCTask'
		% Takes the current stimulus variables and creates an alternative force choice experiment config file
		
	m_fNewLength = squeeze(g_strctParadigm.Length.Buffer(1,:,g_strctParadigm.Length.BufferIdx));
	m_fNewWidth = squeeze(g_strctParadigm.Width.Buffer(1,:,g_strctParadigm.Width.BufferIdx));
	m_fNewXpos = g_strctParadigm.m_aiCenterOfStimulus(1);
    m_fNewYpos = g_strctParadigm.m_aiCenterOfStimulus(2);
	m_fNewTheta = squeeze(g_strctParadigm.Orientation.Buffer(1,:,g_strctParadigm.Orientation.BufferIdx));
	blur = 0;
	blurSteps = 0;
	expName = 'placeHolder';
	listOfConditions = {g_strctParadigm.m_strctMasterColorTableLookup{get(g_strctParadigm.m_strctControllers.m_hColorLists,'value')}};
	neuronPeakColor = fnGenerateColorTuningEstimate(g_strctParadigm, g_strctPlexon);
	fnAFCConfigGenerator(m_fNewXpos, m_fNewYpos, m_fNewTheta, m_fNewLength, m_fNewWidth, blur, blurSteps, expName, listOfConditions, neuronPeakColor, g_strctParadigm.m_strctMasterColorTable)
	
	%}
	case 'PerformOrientationTuning'
		fnShowHideWind('PTB Onscreen window [10]:','hide');
		fnPauseParadigm();
	
		%g_strctParadigm.iSelectedColorList = get(g_strctParadigm.m_strctControllers.m_hColorLists,'value');
		button = questdlg(sprintf('This will perform the orientation tuning function with the current stimulus variables and the currently selected 8 bit colors. Proceed?'));
		
		if strcmpi(button, 'yes')
			% Update the paradigm type
			%g_strctParadigm.m_strctCurrentTrial.m_strTrialType = 'Color Tuning Function';
			
			% Get the color values
			g_strctParadigm.m_afBarColor(1:3) = [squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusRed']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusRed']).BufferIdx)), ...
													squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusGreen']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusGreen']).BufferIdx)),...
													squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusBlue']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusBlue']).BufferIdx))]; 
													
			g_strctParadigm.m_afBackgroundColor(1:3) = [squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundRed']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundRed']).BufferIdx))...
												squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundGreen']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundGreen']).BufferIdx))...
												squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundBlue']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundBlue']).BufferIdx))];
			
			% Preset the selected color 
			g_strctParadigm.m_iSelectedOrientation = 1;
			
			% Prompt the user to start a plexon file
			fNow = now;
			strTmp = datestr(fNow,25);
			strDate = strTmp([1,2,4,5,7,8]);
			strTmp = datestr(fNow,13);
			strTime =  strTmp([1,2,4,5,7,8]);
			g_strctParadigm.m_strPlexonFileName = [strDate,'_',strTime,'_',g_strctParadigm.m_strctSubject.m_strName];
			h=msgbox({'Please close any Plexon recordings and start a new plexon recording file with the following name:',g_strctParadigm.m_strPlexonFileName});
			uiwait(h);
			drawnow
			% Create a backup of what variables and whatnot were used here
			% Basically just save the paradigm struct. We can extract what we need later
			
			g_strctParadigm.m_strctOrientationFunctionParams.m_fXpos = g_strctParadigm.m_aiCenterOfStimulus(1);
			g_strctParadigm.m_strctOrientationFunctionParams.m_fYpos = g_strctParadigm.m_aiCenterOfStimulus(2);
			g_strctParadigm.m_strctOrientationFunctionParams.m_fLength = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fWidth = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fTheta = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fMoveDistance = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus = g_strctParadigm.m_aiCenterOfStimulus;
			
			g_strctParadigm.m_strctOrientationFunctionParams.m_fStimulusOnTime = g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx);
			g_strctParadigm.m_strctOrientationFunctionParams.m_fStimulusOffTime = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx);
			g_strctParadigm.m_strctOrientationFunctionParams.m_fNumFrames = round(g_strctParadigm.m_strctOrientationFunctionParams.m_fStimulusOnTime / (g_strctPTB.g_strctStimulusServer.m_RefreshRateMS));
			
			
			
			
			% Find and jump to the orientation tuning function block. 
			names = {g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks.m_strBlockName};
			idx = find(strcmp(names, 'Orientation Tuning Function')); % This will always be the same, so hardcoded
			g_strctParadigm.m_iNumTimesBlockShown = 0;
			set(g_strctParadigm.m_strctControllers.m_hBlockLists,'value', idx);
			g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
			iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
			g_strctParadigm.m_iCurrentBlockIndexInOrderList = idx;
			
			% Only one media, a placeholder, but this could conceivably change at some point
			iNumMediaInBlock = numel(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
			g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
			
			g_strctParadigm.m_iNumberOfCurrentConditions = squeeze(g_strctParadigm.NumberOfOrientationsToTest.Buffer...
                                            (1,:,g_strctParadigm.NumberOfOrientationsToTest.BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_iNumberOfOrientationsToTest = g_strctParadigm.m_iNumberOfCurrentConditions;
			% Init the Plexon spike holder
			for i = 1:g_strctParadigm.m_iNumberOfCurrentConditions
				
				g_strctPlexon.m_afConditionSpikes.(['condition',num2str(i)]) = zeros(1,2);
			end
			g_strctPlexon.m_afPolarPlottingArray = zeros(g_strctParadigm.m_iNumberOfCurrentConditions,2);
			g_strctParadigm.m_bPolarPlot = 1;
			
			% save our backup
			fnCreateExperimentBackup(g_strctParadigm,'Init');
			fnShowHideWind('PTB Onscreen window [10]:','show');
        end
		%}
		
	case 'PerformPositionTuningFunction'
		fnShowHideWind('PTB Onscreen window [10]:','hide');
		fnPauseParadigm();
		button = questdlg(sprintf('This will perform the position tuning function with the current stimulus variables and the %s saturation colors. Proceed?'));
	if strcmpi(button, 'yes')
		answer = inputdlg({'rows','columns'},'Grid Size',1,{'5','7'});
		g_strctParadigm.m_strctPositionTuningFunction.m_iNumRows = str2num(answer{1,1});
		g_strctParadigm.m_strctPositionTuningFunction.m_iNumCols = str2num(answer{2,1});
		g_strctParadigm.m_strctPositionTuningFunction.m_fTheta = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).Buffer...
                                                                   (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).BufferIdx));
		g_strctParadigm.m_strctPositionTuningFunction.m_iStimulusWidth = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).Buffer...
                                                                   (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).BufferIdx));
		g_strctParadigm.m_strctPositionTuningFunction.m_iStimulusLength	 = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).Buffer...
                                                                   (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).BufferIdx));										   
		g_strctParadigm.m_strctPositionTuningFunction.m_afBarColor(1:3) = [squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusRed']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusRed']).BufferIdx)), ...
													squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusGreen']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusGreen']).BufferIdx)),...
													squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusBlue']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusBlue']).BufferIdx))]; 
													
			g_strctParadigm.m_strctPositionTuningFunction.m_afBackgroundColor(1:3) = [squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundRed']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundRed']).BufferIdx))...
												squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundGreen']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundGreen']).BufferIdx))...
												squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundBlue']).Buffer(1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundBlue']).BufferIdx))];
																	   
																   
		g_strctParadigm.m_strctPositionTuningFunction.m_iGridSize = g_strctParadigm.m_strctPositionTuningFunction.m_iNumCols *...
					g_strctParadigm.m_strctPositionTuningFunction.m_iNumRows;
			% Update the paradigm type
			%g_strctParadigm.m_strctCurrentTrial.m_strTrialType = 'Color Tuning Function';
			


			
			% Preset the selected color 
			g_strctParadigm.m_iSelectedColor = 1;
			
			% Prompt the user to start a plexon file
			fNow = now;
			strTmp = datestr(fNow,25);
			strDate = strTmp([1,2,4,5,7,8]);
			strTmp = datestr(fNow,13);
			strTime =  strTmp([1,2,4,5,7,8]);
			g_strctParadigm.m_strPlexonFileName = [strDate,'_',strTime,'_',g_strctParadigm.m_strctSubject.m_strName];
			h=msgbox({'Please close any Plexon recordings and start a new plexon recording file with the following name:',g_strctParadigm.m_strPlexonFileName});
			uiwait(h);
			drawnow
			% Create a backup of what variables and whatnot were used here
			% Basically just save the paradigm struct. We can extract what we need later
			
			%g_strctParadigm.m_strctTuningFunctionParams.m_fXpos = g_strctParadigm.m_aiCenterOfStimulus(1);
			%g_strctParadigm.m_strctTuningFunctionParams.m_fYpos = g_strctParadigm.m_aiCenterOfStimulus(2);
			g_strctParadigm.m_strctPositionTuningFunction.m_fLength = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).BufferIdx));
			g_strctParadigm.m_strctPositionTuningFunction.m_fWidth = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).BufferIdx))
			g_strctParadigm.m_strctPositionTuningFunction.m_fTheta = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).BufferIdx));
			g_strctParadigm.m_strctPositionTuningFunction.m_fMoveDistance = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).BufferIdx));
			g_strctParadigm.m_strctPositionTuningFunction.m_afCenterOfStimulus = g_strctParadigm.m_aiCenterOfStimulus;
			
			%{
			g_strctParadigm.m_strctOrientationFunctionParams.m_fLength = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fWidth = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fTheta = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fMoveDistance = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus = g_strctParadigm.m_aiCenterOfStimulus;
			
			%}
			
			
			g_strctParadigm.m_strctPositionTuningFunction.m_fStimulusOnTime = g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx);
			g_strctParadigm.m_strctPositionTuningFunction.m_fStimulusOffTime = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx);
			%g_strctParadigm.m_strctPositionTuningFunction.m_fNumFrames = round(g_strctParadigm.m_strctTuningFunctionParams.m_fStimulusOnTime / (g_strctPTB.g_strctStimulusServer.m_RefreshRateMS));
			
			
			
			
			% Find and jump to the color tuning function block. 
			names = {g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks.m_strBlockName};
			idx = find(strcmp(names, 'Position Tuning Function')); % This will always be the same, so hardcoded
			g_strctParadigm.m_iNumTimesBlockShown = 0;
			set(g_strctParadigm.m_strctControllers.m_hBlockLists,'value', idx);
			g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
			iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
			g_strctParadigm.m_iCurrentBlockIndexInOrderList = idx;
			
			% Only one media, a placeholder, but this could conceivably change at some point
			iNumMediaInBlock = numel(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
			g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
			
			%g_strctParadigm.m_iNumberOfCurrentConditions = size(g_strctParadigm.m_strctCurrentSaturation,1);
			% Init the Plexon spike holder
            %{
			for i = 1:g_strctParadigm.m_iNumberOfCurrentConditions
				
				g_strctPlexon.m_afConditionSpikes.(['condition',num2str(i)]) = zeros(1,2);
			end
            %}
			%g_strctPlexon.m_afPolarPlottingArray = zeros(g_strctParadigm.m_iNumberOfCurrentConditions,2);
			%g_strctParadigm.m_bPolarPlot = 1;
			fnCreateExperimentBackup(g_strctParadigm,'Init');
            fnShowHideWind('PTB Onscreen window [10]:','show');
		else % Do nothing and return to the current paradigm
			fnShowHideWind('PTB Onscreen window [10]:','show');
		end
		
	
	case 'PerformTuningFunction'
		fnShowHideWind('PTB Onscreen window [10]:','hide');
		fnPauseParadigm();
        
        g_strctParadigm.iSelectedColorList = get(g_strctParadigm.m_strctControllers.m_hColorLists,'value');
		button = questdlg(sprintf('This will perform the color tuning function with the current stimulus variables. Proceed?',...
		g_strctParadigm.m_strctMasterColorTableLookup{g_strctParadigm.iSelectedColorList}));
		
		if strcmpi(button, 'yes')
			% Update the paradigm type
			%g_strctParadigm.m_strctCurrentTrial.m_strTrialType = 'Color Tuning Function';
			
			% Get the color values
			g_strctParadigm.m_strctCurrentSaturation = g_strctParadigm.m_strctMasterColorTable...
						.(g_strctParadigm.m_strctMasterColorTableLookup{g_strctParadigm.iSelectedColorList}).RGB;
			
			% Preset the selected color 
			g_strctParadigm.m_iSelectedColor = 1;
			
			% Prompt the user to start a plexon file
			fNow = now;
			strTmp = datestr(fNow,25);
			strDate = strTmp([1,2,4,5,7,8]);
			strTmp = datestr(fNow,13);
			strTime =  strTmp([1,2,4,5,7,8]);
			g_strctParadigm.m_strPlexonFileName = [strDate,'_',strTime,'_',g_strctParadigm.m_strctSubject.m_strName];
			h=msgbox({'Please close any Plexon recordings and start a new plexon recording file with the following name:',g_strctParadigm.m_strPlexonFileName});
			uiwait(h);
			drawnow
			% Create a backup of what variables and whatnot were used here
			% Basically just save the paradigm struct. We can extract what we need later
			
			g_strctParadigm.m_strctTuningFunctionParams.m_fXpos = g_strctParadigm.m_aiCenterOfStimulus(1);
			g_strctParadigm.m_strctTuningFunctionParams.m_fYpos = g_strctParadigm.m_aiCenterOfStimulus(2);
			g_strctParadigm.m_strctTuningFunctionParams.m_fLength = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).BufferIdx));
			g_strctParadigm.m_strctTuningFunctionParams.m_fWidth = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).BufferIdx))
			g_strctParadigm.m_strctTuningFunctionParams.m_fTheta = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).BufferIdx));
			g_strctParadigm.m_strctTuningFunctionParams.m_fMoveDistance = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).BufferIdx));
			g_strctParadigm.m_strctTuningFunctionParams.m_afCenterOfStimulus = g_strctParadigm.m_aiCenterOfStimulus;
			
			%{
			g_strctParadigm.m_strctOrientationFunctionParams.m_fLength = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Length']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fWidth = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Width']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fTheta = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'Orientation']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_fMoveDistance = squeeze(g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).Buffer...
                                                                            (1,:,g_strctParadigm.([g_strctParadigm.m_strCurrentlySelectedBlock,'MoveDistance']).BufferIdx));
			g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus = g_strctParadigm.m_aiCenterOfStimulus;
			
			%}
			
			
			g_strctParadigm.m_strctTuningFunctionParams.m_fStimulusOnTime = g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx);
			g_strctParadigm.m_strctTuningFunctionParams.m_fStimulusOffTime = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx);
			g_strctParadigm.m_strctTuningFunctionParams.m_fNumFrames = round(g_strctParadigm.m_strctTuningFunctionParams.m_fStimulusOnTime / (g_strctPTB.g_strctStimulusServer.m_RefreshRateMS));
			
			
			
			
			% Find and jump to the color tuning function block. 
			names = {g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks.m_strBlockName};
			idx = find(strcmp(names, 'Color Tuning Function')); % This will always be the same, so hardcoded
			g_strctParadigm.m_iNumTimesBlockShown = 0;
			set(g_strctParadigm.m_strctControllers.m_hBlockLists,'value', idx);
			g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
			iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
			g_strctParadigm.m_iCurrentBlockIndexInOrderList = idx;
			
			% Only one media, a placeholder, but this could conceivably change at some point
			iNumMediaInBlock = numel(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
			g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
			
			g_strctParadigm.m_iNumberOfCurrentConditions = size(g_strctParadigm.m_strctCurrentSaturation,1);
			% Init the Plexon spike holder
			for i = 1:g_strctParadigm.m_iNumberOfCurrentConditions
				
				g_strctPlexon.m_afConditionSpikes.(['condition',num2str(i)]) = zeros(1,2);
			end
			g_strctPlexon.m_afPolarPlottingArray = zeros(g_strctParadigm.m_iNumberOfCurrentConditions,2);
			g_strctParadigm.m_bPolarPlot = 1;
			fnCreateExperimentBackup(g_strctParadigm,'Init');
            fnShowHideWind('PTB Onscreen window [10]:','show');
		else % Do nothing and return to the current paradigm
		end
	
	case 'UseCalibratedColors'
		g_strctParadigm.m_bUseCalibratedColors = ~g_strctParadigm.m_bUseCalibratedColors;
		if	g_strctParadigm.m_bUseCalibratedColors
			g_strctParadigm.iSelectedColorList = get(g_strctParadigm.m_strctControllers.m_hColorLists,'value');
		end
	case 'ResetTuningPlot'
		g_strctParadigm.m_strctTuningFunctionStats.m_afPolarPlottingHolder{1,end+1} = g_strctPlexon.m_afConditionSpikes;
		g_strctParadigm.m_strctTuningFunctionStats.m_afPolarPlottingHolder{2,end} = GetSecs();
		g_strctParadigm.m_strctTuningFunctionStats.m_afPolarPlottingHolder{3,end} = g_strctParadigm.m_strctCurrentSaturation;
		%fnCreateExperimentBackup(g_strctParadigm, g_strctParadigm.m_strPlexonFileName,iSelectedColorList);
		for i = 1:g_strctParadigm.m_iNumberOfCurrentConditions
				
			g_strctPlexon.m_afConditionSpikes.(['condition',num2str(i)]) = zeros(1,2);
		end
		%g_strctPlexon.m_afPolarPlottingArray = zeros(g_strctParadigm.m_iNumberOfCurrentConditions,2);
	case 'CycleColors'
		g_strctParadigm.m_bCycleColors = ~g_strctParadigm.m_bCycleColors;
		g_strctParadigm.m_strctCurrentSaturation = g_strctParadigm.m_strctMasterColorTable.(g_strctParadigm.m_strctMasterColorTableLookup{g_strctParadigm.m_iSelectedColorList});
        
	case 'ReverseColorOrder'
		g_strctParadigm.m_strctTuningFunctionParams.m_bReverseColorOrder = ~g_strctParadigm.m_strctTuningFunctionParams.m_bReverseColorOrder;
		
	case 'RandomColorOrder'
		g_strctParadigm.m_strctTuningFunctionParams.m_bRandomColorOrder = ~g_strctParadigm.m_strctTuningFunctionParams.m_bRandomColorOrder;
	
	case 'ReverseOrientationOrder'
		g_strctParadigm.m_strctOrientationFunctionParams.m_bReverseOrientationOrder = ~g_strctParadigm.m_strctOrientationFunctionParams.m_bReverseOrientationOrder;
		
	case 'RandomOrientationOrder'
		g_strctParadigm.m_strctOrientationFunctionParams.m_bRandomOrientation = ~g_strctParadigm.m_strctOrientationFunctionParams.m_bRandomOrientation ;
		
	case 'LoadColorList'
		
		fnParadigmToKofikoComm('JuiceOff');
        iSelectedColorList = get(g_strctParadigm.m_strctControllers.m_hColorLists,'value');
		g_strctParadigm.m_strctCurrentSaturation = [];
		g_strctParadigm.m_strctCurrentSaturation = g_strctParadigm.m_strctMasterColorTable.(g_strctParadigm.m_strctMasterColorTableLookup{iSelectedColorList});
		
	case 'RandStimulusLocation'
		g_strctParadigm.m_strctHandMappingParameters.m_bRandomStimulusPosition = ~g_strctParadigm.m_strctHandMappingParameters.m_bRandomStimulusPosition;
		
	case 'RandStimulusOrientation'
		g_strctParadigm.m_strctHandMappingParameters.m_bRandomStimulusOrientation = ~g_strctParadigm.m_strctHandMappingParameters.m_bRandomStimulusOrientation;
	
	case 'DiscRandStimulusOrientation'
		g_strctParadigm.m_strctHandMappingParameters.m_bDiscRandomStimulusOrientation = ~g_strctParadigm.m_strctHandMappingParameters.m_bDiscRandomStimulusOrientation;
	case 'GaborPhase'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'GaborPhase';
		iNewGaborPhase = g_strctParadigm.GaborPhase.Buffer(g_strctParadigm.GaborPhase.BufferIdx);
		fnTsSetVarParadigm('GaborPhase',iNewGaborPhase);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGaborPhaseSlider, iNewGaborPhase);
		set(g_strctParadigm.m_strctControllers.m_hGaborPhaseEdit,'String',num2str(iNewGaborPhase));
		varargout{1} = iNewGaborPhase;
		
	case 'GaborFreq'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'GaborFreq';
		iNewGaborFreq = g_strctParadigm.GaborFreq.Buffer(g_strctParadigm.GaborFreq.BufferIdx);
		fnTsSetVarParadigm('GaborFreq',iNewGaborFreq);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGaborFreqSlider, iNewGaborFreq);
		set(g_strctParadigm.m_strctControllers.m_hGaborFreqEdit,'String',num2str(iNewGaborFreq));
		varargout{1} = iNewGaborFreq;
		
	case 'GaborContrast'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'GaborContrast';
		iNewGaborContrast = g_strctParadigm.GaborContrast.Buffer(g_strctParadigm.GaborContrast.BufferIdx);
		fnTsSetVarParadigm('GaborContrast',iNewGaborContrast);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGaborContrastSlider, iNewGaborContrast);
		set(g_strctParadigm.m_strctControllers.m_hGaborContrastEdit,'String',num2str(iNewGaborContrast));
		varargout{1} = iNewGaborContrast;
		
	case 'GaborSigma'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'GaborSigma';
		iNewGaborSigma = g_strctParadigm.GaborSigma.Buffer(g_strctParadigm.GaborSigma.BufferIdx);
		fnTsSetVarParadigm('GaborSigma',iNewGaborSigma);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGaborSigmaSlider, iNewGaborSigma);
		set(g_strctParadigm.m_strctControllers.m_hGaborSigmaEdit,'String',num2str(iNewGaborSigma));
		varargout{1} = iNewGaborSigma;
		
	case 'ReversePhaseDirection'
		g_strctParadigm.m_strctGaborParams.m_bReversePhaseDirection = ~g_strctParadigm.m_strctGaborParams.m_bReversePhaseDirection;
		
	case 'Blur'
		g_strctParadigm.m_bBlur = ~g_strctParadigm.m_bBlur;
	
	case 'TogglePolarPlot'
		g_strctParadigm.m_bPolarPlot = ~g_strctParadigm.m_bPolarPlot;
	
	case 'ToggleHeatPlot'
		g_strctParadigm.m_bHeatPlot = ~g_strctParadigm.m_bHeatPlot;
	
	case 'ToggleRasterPlot'
		g_strctParadigm.m_bRasterPlot = ~g_strctParadigm.m_bRasterPlot;
		
	case 'BlurSteps'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'BlurSteps';
		iNewStimulusBlurSteps = g_strctParadigm.BlurSteps.Buffer(g_strctParadigm.BlurSteps.BufferIdx);
		fnTsSetVarParadigm('BlurSteps',iNewStimulusBlurSteps);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBlurStepsSlider, iNewStimulusBlurSteps);
		set(g_strctParadigm.m_strctControllers.m_hBlurStepsEdit,'String',num2str(iNewStimulusBlurSteps));
		varargout{1} = iNewStimulusBlurSteps;
	
	
	case 'Length'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'Length';
		iNewStimulusLength = g_strctParadigm.Length.Buffer(g_strctParadigm.Length.BufferIdx);
		fnTsSetVarParadigm('Length',iNewStimulusLength);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hLengthSlider, iNewStimulusLength);
		set(g_strctParadigm.m_strctControllers.m_hLengthEdit,'String',num2str(iNewStimulusLength));
		varargout{1} = iNewStimulusLength;
		 
	case 'Width'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'Width';
		iNewStimulusWidth = g_strctParadigm.Width.Buffer(g_strctParadigm.Width.BufferIdx);
		fnTsSetVarParadigm('Width',iNewStimulusWidth);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hWidthSlider, iNewStimulusWidth);
		set(g_strctParadigm.m_strctControllers.m_hWidthEdit,'String',num2str(iNewStimulusWidth));
		varargout{1} = iNewStimulusWidth;
		 
	case 'MoveDistance'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'MoveDistance';
		iNewStimulusMoveDistance = g_strctParadigm.MoveDistance.Buffer(g_strctParadigm.MoveDistance.BufferIdx);
		fnTsSetVarParadigm('MoveDistance',iNewStimulusMoveDistance);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hMoveDistanceSlider, iNewStimulusMoveDistance);
		set(g_strctParadigm.m_strctControllers.m_hMoveDistanceEdit,'String',num2str(iNewStimulusMoveDistance));
		varargout{1} = iNewStimulusMoveDistance;
		 
	case 'NumberOfBars'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'NumberOfBars';
		iNewNumberOfBars = g_strctParadigm.NumberOfBars.Buffer(g_strctParadigm.NumberOfBars.BufferIdx);
		fnTsSetVarParadigm('NumberOfBars',iNewNumberOfBars);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hNumberOfBarsSlider, iNewNumberOfBars);
		set(g_strctParadigm.m_strctControllers.m_hNumberOfBarsEdit,'String',num2str(iNewNumberOfBars));
		 varargout{1} = iNewNumberOfBars;
	case 'Orientation'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'Orientation';
		iNewStimulusOrientation = g_strctParadigm.Orientation.Buffer(g_strctParadigm.Orientation.BufferIdx);
		fnTsSetVarParadigm('Orientation',iNewStimulusOrientation);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hOrientationSlider, iNewStimulusOrientation);
		set(g_strctParadigm.m_strctControllers.m_hOrientationEdit,'String',num2str(iNewStimulusOrientation));
		varargout{1} = iNewStimulusOrientation;
		 
	case 'BarRed'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'BarRed';
		iNewBarRed = g_strctParadigm.BarRed.Buffer(g_strctParadigm.BarRed.BufferIdx);
		fnTsSetVarParadigm('BarRed',iNewBarRed);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBarRedSlider, iNewBarRed);
		set(g_strctParadigm.m_strctControllers.m_hBarRedEdit,'String',num2str(iNewBarRed));
		varargout{1} = iNewBarRed;
		 
	case 'BarGreen'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'BarGreen';
		iNewBarGreen = g_strctParadigm.BarGreen.Buffer(g_strctParadigm.BarGreen.BufferIdx);
		fnTsSetVarParadigm('BarGreen',iNewBarGreen);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBarGreenSlider, iNewBarGreen);
		set(g_strctParadigm.m_strctControllers.m_hBarGreenEdit,'String',num2str(iNewBarGreen));
		varargout{1} = iNewBarGreen;
		 
	case 'BarBlue'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'BarBlue';
		iNewBarBlue = g_strctParadigm.BarBlue.Buffer(g_strctParadigm.BarBlue.BufferIdx);
		fnTsSetVarParadigm('BarBlue',iNewBarBlue);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBarBlueSlider, iNewBarBlue);
		set(g_strctParadigm.m_strctControllers.m_hBarBlueEdit,'String',num2str(iNewBarBlue));
		varargout{1} = iNewBarBlue;
		 
	case 'BackgroundRed'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'BackgroundRed';
		iNewBackgroundRed = g_strctParadigm.BackgroundRed.Buffer(g_strctParadigm.BackgroundRed.BufferIdx);
		fnTsSetVarParadigm('BackgroundRed',iNewBackgroundRed);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBackgroundRedSlider, iNewBackgroundRed);
		set(g_strctParadigm.m_strctControllers.m_hBackgroundRedEdit,'String',num2str(iNewBackgroundRed));
		varargout{1} = iNewBackgroundRed;
		 
	case 'BackgroundGreen'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'BackgroundGreen';
		iNewBackgroundGreen = g_strctParadigm.BackgroundGreen.Buffer(g_strctParadigm.BackgroundGreen.BufferIdx);
		fnTsSetVarParadigm('BackgroundGreen',iNewBackgroundGreen);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBackgroundGreenSlider, iNewBackgroundGreen);
		set(g_strctParadigm.m_strctControllers.m_hBackgroundGreenEdit,'String',num2str(iNewBackgroundGreen));
		varargout{1} = iNewBackgroundGreen;
		 
	case 'BackgroundBlue'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'BackgroundBlue';
		iNewBackgroundBlue = g_strctParadigm.BackgroundBlue.Buffer(g_strctParadigm.BackgroundBlue.BufferIdx);
		fnTsSetVarParadigm('BackgroundBlue',iNewBackgroundBlue);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hBackgroundBlueSlider, iNewBackgroundBlue);
		set(g_strctParadigm.m_strctControllers.m_hBackgroundBlueEdit,'String',num2str(iNewBackgroundBlue));
		varargout{1} = iNewBackgroundBlue;
		
	case 'StimulusArea'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'StimulusArea';
		iNewStimulusArea = g_strctParadigm.StimulusArea.Buffer(g_strctParadigm.StimulusArea.BufferIdx);
		fnTsSetVarParadigm('StimulusArea',iNewStimulusArea);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hStimulusAreaSlider, iNewStimulusArea);
		set(g_strctParadigm.m_strctControllers.m_hStimulusAreaEdit,'String',num2str(iNewStimulusArea));
		
	case 'UpdateStimulusPosition'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'StimulusPosition';
		
    case 'BlockLoopingToggle'
        g_strctParadigm.m_bBlockLooping = get(g_strctParadigm.m_strctControllers.m_hLoopCurrentBlock,'value') > 0;
    case 'BlocksDoneAction'
        acOptions =get(g_strctParadigm.m_strctControllers.m_hBlocksDoneActionPopup,'String');
        iValue =get(g_strctParadigm.m_strctControllers.m_hBlocksDoneActionPopup,'value');
        g_strctParadigm.m_strBlockDoneAction = acOptions{iValue};
		%---------------------------------------------------------------------------------------------------------------
    case 'MicroStimFixedRateToggle'
        set(g_strctParadigm.m_strctControllers.m_hMicroStimPoissonRate,'value',0);
        bActive = get(g_strctParadigm.m_strctControllers.m_hMicroStimFixedRate,'value');
        if bActive
            % Turn on
            g_strctParadigm.m_strctMiroSctim.m_strMicroStimType = 'FixedRate';
            g_strctParadigm.m_strctMiroSctim.m_fMicroStimRateHz = 1/5;
            g_strctParadigm.m_strctMiroSctim.m_fNextStimTS = GetSecs();
            g_strctParadigm.m_strctMiroSctim.m_bActive = true;
        else
            % Turn off
            g_strctParadigm.m_strctMiroSctim.m_bActive = false;
        end
    case 'MicroStimPoissonRateToggle'
        set(g_strctParadigm.m_strctControllers.m_hMicroStimFixedRate,'value',0);
        bActive = get(g_strctParadigm.m_strctControllers.m_hMicroStimPoissonRate,'value');
        if bActive
            % Turn on
            g_strctParadigm.m_strctMiroSctim.m_strMicroStimType = 'Poisson';
            g_strctParadigm.m_strctMiroSctim.m_fMicroStimRateHz = 1/5;
            g_strctParadigm.m_strctMiroSctim.m_fNextStimTS = GetSecs();
            g_strctParadigm.m_strctMiroSctim.m_bActive = true;
            
        else
            % Turn off
            g_strctParadigm.m_strctMiroSctim.m_bActive = false;
        end
        
    case 'JumpToBlock'
        if isempty(g_strctParadigm.m_strctDesign)
            return;
        end;
		fnParadigmToStimulusServer('LoadDefaultClut');
        g_strctParadigm.m_iNumTimesBlockShown = 0;
        g_strctParadigm.m_iCurrentBlockIndexInOrderList = get(g_strctParadigm.m_strctControllers.m_hBlockLists,'value');
        g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
        iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
        iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
		
		
		% gray out the controllers for the stimuli we arent using
		set(g_strctParadigm.m_strctControllers.m_ahStimuliControllerButtons(g_strctParadigm.m_iCurrentBlockIndexInOrderList),'enable','on')
		set(g_strctParadigm.m_strctControllers.m_ahStimuliControllerButtons(g_strctParadigm.m_iCurrentBlockIndexInOrderList),'visible','on')
		set(g_strctParadigm.m_strctControllers.m_ahStimuliControllerButtons(g_strctParadigm.m_iLastStimuliControllerButtonIndex),'enable','off')
		set(g_strctParadigm.m_strctControllers.m_ahStimuliControllerButtons(g_strctParadigm.m_iLastStimuliControllerButtonIndex),'visible','off')
		g_strctParadigm.m_iLastStimuliControllerButtonIndex = g_strctParadigm.m_iCurrentBlockIndexInOrderList;
		
		
		
		% default blend functions, in case we're switching from the gabor more to something else
		fnParadigmToStimulusServer('LoadDefaultBlendFunction');
		Screen('BlendFunction', g_strctPTB.m_hWindow, GL_ONE, GL_ZERO);
		g_strctParadigm.m_strctGaborParams.m_bGaborsInitialized = 0;
		
        if g_strctParadigm.m_bRandom
            [fDummy,g_strctParadigm.m_aiCurrentRandIndices] = sort(rand(1,iNumMediaInBlock));
        else
            g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
        end
    
    case 'LocalStereoMode'
         iNewStereoMode = get(g_strctParadigm.m_strctControllers.m_hLocalStereoModePopup,'value');
         acStereoModes = get(g_strctParadigm.m_strctControllers.m_hLocalStereoModePopup,'String');
         g_strctParadigm.m_strLocalStereoMode = acStereoModes{iNewStereoMode};
    case 'RepatNonFixatedToggle'
        g_strctParadigm.m_bRepeatNonFixatedImages=~g_strctParadigm.m_bRepeatNonFixatedImages;
    case 'NoiseOverlayToggle'
    bNoiseOverlayActive = fnTsGetVar('g_strctParadigm' , 'NoiseOverlayActive');
    bNoiseOverlayActive = ~bNoiseOverlayActive;
    fnTsSetVarParadigm('NoiseOverlayActive',bNoiseOverlayActive);
    
    if bNoiseOverlayActive
        if g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns > 0
            g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex = 1;
        end
        fnParadigmToKofikoComm('DisplayMessage', 'Resetting Noise Index');
    end
    case 'NoisePatternSwitch'
        iSelectedNoiseFile = get(g_strctParadigm.m_strctControllers.m_hNoisePatternPopup,'value');
        fnTsSetVarParadigm( 'NoiseFile', g_strctParadigm.m_acNoisePatternsFiles{iSelectedNoiseFile});
        strctTmp = load(['.\NoisePatterns\',g_strctParadigm.m_acNoisePatternsFiles{iSelectedNoiseFile}]);
        g_strctParadigm.m_a3fRandPatterns = strctTmp.a3fRand;
        g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns = size(g_strctParadigm.m_a3fRandPatterns,3);
        g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex = 0;
    
	
        
    case 'MicroStim'
        strctStimulation.m_iChannel = 1;
        strctStimulation.m_fDelayToTrigMS = 0;
        fnParadigmToKofikoComm('MultiChannelStimulation', strctStimulation);
		
    case 'DesignPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','on');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','off');

		
	case 'StatisticsPanel'
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','on');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','off');
		
    case 'JuicePanel'
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','on');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','off');
		
	case 'TuningPanel'
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','on');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','off');
		
    case 'StaticBarPanel'
		g_strctParadigm.m_strCurrentlySelectedBlock = 'StaticBar';
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');        
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','on');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','off');

    case 'MovingBarPanel'
		g_strctParadigm.m_strCurrentlySelectedBlock = 'MovingBar';
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');        
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','on');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','off');

    case 'GaborPanel'
		g_strctParadigm.m_strCurrentlySelectedBlock = 'Gabor';
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');        
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','on');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','off');

    case 'DiscPanel'
		g_strctParadigm.m_strCurrentlySelectedBlock = 'Disc';
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(1),'visible','off');        
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(2),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(3),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_hSubPanels(4),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(5),'visible','off');	
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(6),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(7),'visible','off');
		set(g_strctParadigm.m_strctControllers.m_hSubPanels(8),'visible','on');
    
		
    case 'FixationSizePix'
	
	
    case 'StimulusON_MS'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'StimulusON_MS';
        ISI=1/g_strctStimulusServer.m_fRefreshRateHz*1e3;
         
        fStimulusON_MS = ISI*ceil(g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx)/ISI);
        fStimulusOFF_MS = ISI*ceil(g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx)/ISI);
        g_strctParadigm.m_strctStatServerDesign.TrialLengthSec = 1.1 * (fStimulusON_MS+fStimulusOFF_MS)/1e3; % multiple by 10% to account for possible jitter
        fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctStatServerDesign);        
        
    case 'StimulusOFF_MS'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'StimulusOFF_MS';
        ISI=1/g_strctStimulusServer.m_fRefreshRateHz*1e3;
        
        fStimulusON_MS = ISI*ceil(g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx)/ISI);
        fStimulusOFF_MS = ISI*ceil(g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx)/ISI);
        g_strctParadigm.m_strctStatServerDesign.TrialLengthSec = 1.1 * (fStimulusON_MS+fStimulusOFF_MS)/1e3; % multiple by 10% to account for possible jitter
        
        fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctStatServerDesign);
        
    case 'RotationAngle'
        if g_strctParadigm.m_bParameterSweep
            fnInitializeParameterSweep();
        end
        
    case 'GazeBoxPix'
    case 'StimulusSizePix'
        if g_strctParadigm.m_bParameterSweep
            fnInitializeParameterSweep();
        end
        
    case 'BlinkTimeMS'
    case 'PositiveIncrement'
    case 'Resuming'
        if g_strctParadigm.m_iMachineState == 6
            g_strctParadigm.m_iMachineState = 1;
        end
		
    case 'PhotoDiodeRectToggle'
        g_strctParadigm.m_bShowPhotodiodeRect = ~g_strctParadigm.m_bShowPhotodiodeRect;
    case 'Pausing'
		
	
		
    case 'LoadList'
        fnParadigmToKofikoComm('SafeCallback','LoadListSafe');
    case 'LoadListSafe'
        fnSafeLoadListAux();



%     case 'LFPStatToggle'
%         g_strctGUIParams.m_bShowLFPStat = ~g_strctGUIParams.m_bShowLFPStat;

    case 'Start'
        g_strctParadigm.m_iMachineState = 1;
        [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
        fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);

        g_strctParadigm.m_fLastFixatedTimer = GetSecs();
		% end any trials in progress, if any
		fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
		
    case 'Random'
        g_strctParadigm.m_bRandom =  get(g_strctParadigm.m_strctControllers.m_hRandomImageIndex,'value');
        
        
        iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
        iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
        if g_strctParadigm.m_bRandom
                    [fDummy,g_strctParadigm.m_aiCurrentRandIndices] = sort(rand(1,iNumMediaInBlock));
        else
            g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
        end


    case 'GazeTimeMS'
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
        iNewGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
        iGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
        if iNewGazeTimeMS < iGazeTimeLowMS
            fnTsSetVarParadigm('GazeTimeLowMS',iNewGazeTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeTimeLowMSSlider, iNewGazeTimeMS);
            set(g_strctParadigm.m_strctControllers.m_hGazeTimeLowMSEdit,'String',num2str(iNewGazeTimeMS));
        end

    case 'GazeTimeLowMS'
        iNewGazeTimeLowMS = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx);
        iGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);
        if iNewGazeTimeLowMS > iGazeTimeMS
            fnTsSetVarParadigm('GazeTimeMS',iNewGazeTimeLowMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hGazeTimeMSSlider, iNewGazeTimeLowMS);
            set(g_strctParadigm.m_strctControllers.m_hGazeTimeMSEdit,'String',num2str(iNewGazeTimeLowMS));
        end
        g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;

    case 'JuiceTimeMS'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'JuiceTimeMS';
        iNewJuiceTimeMS =  g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
        iJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
        if iNewJuiceTimeMS > iJuiceTimeHighMS
            fnTsSetVarParadigm('JuiceTimeHighMS',iNewJuiceTimeMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceTimeHighMSSlider, iNewJuiceTimeMS);
            set(g_strctParadigm.m_strctControllers.m_hJuiceTimeHighMSEdit,'String',num2str(iNewJuiceTimeMS));
        end

    case 'JuiceTimeHighMS'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'JuiceTimeHighMS';
        iNewJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);
        iJuiceTimeMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
        if iNewJuiceTimeHighMS < iJuiceTimeMS
            fnTsSetVarParadigm('JuiceTimeMS',iNewJuiceTimeHighMS);
            fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hJuiceTimeMSSlider, iNewJuiceTimeHighMS);
            set(g_strctParadigm.m_strctControllers.m_hJuiceTimeMSEdit,'String',num2str(iNewJuiceTimeHighMS));
        end

    case 'FixationSpot'
		g_strctParadigm.m_strCurrentlySelectedVariable = 'JuiceTimeHighMS';
        if g_strctParadigm.m_bUpdateFixationSpot
            g_strctParadigm.m_bUpdateFixationSpot = false;
            set( g_strctParadigm.m_strctControllers.m_hFixationSpotChange,'String','New Fixation Spot','fontweight','normal');
        else
            g_strctParadigm.m_bUpdateFixationSpot = true;
            set( g_strctParadigm.m_strctControllers.m_hFixationSpotChange,'String','Updating Fixation Spot','fontweight','bold');
        end;

    case 'StimulusPos'
        if g_strctParadigm.m_bUpdateStimulusPos
            g_strctParadigm.m_bUpdateStimulusPos = false;
            set( g_strctParadigm.m_strctControllers.m_hStimulusPosChange,'String','New Stimulus Pos','fontweight','normal');
        else
            g_strctParadigm.m_bUpdateStimulusPos = true;
            set( g_strctParadigm.m_strctControllers.m_hStimulusPosChange,'String','Updating Stimulus Pos','fontweight','bold');
        end;
        if g_strctParadigm.m_bParameterSweep
            fnInitializeParameterSweep();
        end

    case 'BackgroundColor'
        fnParadigmToKofikoComm('JuiceOff');
        bParadigmPaused = fnParadigmToKofikoComm('IsPaused');

        if ~bParadigmPaused
            bPausing = true;
            fnPauseParadigm()
        else
            bPausing = false;
        end


        fnShowHideWind('PTB Onscreen window [10]:','hide');
        aiColor  = uisetcolor();
        fnShowHideWind('PTB Onscreen window [10]:','show');
        if length(aiColor) > 1
            fnTsSetVarParadigm('BackgroundColor',round(aiColor*255));
            %            fnDAQWrapper('StrobeWord', fnFindCode('Stimulus Position Changed'));
        end;
        if bPausing
            fnResumeParadigm();
        end


    case 'ResetUnit'
        g_strctParadigm.m_strWhatToReset = 'Unit';
        set(g_strctParadigm.m_strctControllers.m_hResetUnit,'value',1);
        set(g_strctParadigm.m_strctControllers.m_hResetChannel,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetAllChannels,'value',0);
    case 'ResetChannel'
        g_strctParadigm.m_strWhatToReset = 'Channel';
        set(g_strctParadigm.m_strctControllers.m_hResetUnit,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetChannel,'value',1);
        set(g_strctParadigm.m_strctControllers.m_hResetAllChannels,'value',0);
    case 'ResetAllChannels'
        g_strctParadigm.m_strWhatToReset = 'AllChannels';
        set(g_strctParadigm.m_strctControllers.m_hResetUnit,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetChannel,'value',0);
        set(g_strctParadigm.m_strctControllers.m_hResetAllChannels,'value',1);
    case 'ResetStat'
        fnParadigmToKofikoComm('ResetStat',g_strctParadigm.m_strWhatToReset);
        
    case 'StartRecording'
        fnParadigmToKofikoComm('ResetStat');

        
%        set(g_strctParadigm.m_strctControllers.m_hLoadList,'enable','off');
%        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'enable','off');
    case 'StopRecording'
%        set(g_strctParadigm.m_strctControllers.m_hLoadList,'enable','on');
%        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'enable','on');
        [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
        fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);
    case 'LoadFavoriteList'
        fnParadigmToKofikoComm('SafeCallback','LoadFavoriteListSafe');
    case 'LoadFavoriteListSafe'
        fnParadigmToKofikoComm('JuiceOff');
        iSelectedImageList = get(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'value');
        if ~fnLoadPassiveFixationDesign(g_strctParadigm.m_acFavroiteLists{iSelectedImageList});
            return;
        end
                
        [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
        fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);
        fnResetStat();
        
        g_strctParadigm.m_iNumTimesBlockShown = 0;
        g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
        g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
        g_strctParadigm.m_iCurrentOrder = 1;
        
        g_strctParadigm.m_strctCurrentTrial = [];
        
    case 'RandFixationSpot'
        g_strctParadigm.m_bRandFixPos = ~g_strctParadigm.m_bRandFixPos;
        if g_strctParadigm.m_bRandFixPos
            set(g_strctParadigm.m_strctControllers.m_hRandomPosition,'FontWeight','bold');
        else
            set(g_strctParadigm.m_strctControllers.m_hRandomPosition,'FontWeight','normal');
            % return it to center....
            fnTsSetVarParadigm('FixationSpotPix', g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            fnParadigmToKofikoComm('SetFixationPosition',g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            if g_strctParadigm.m_bRandFixSyncStimulus
                fnTsSetVarParadigm('StimulusPos', g_strctStimulusServer.m_aiScreenSize(3:4)/2);
            end
        end;
    case 'RandFixationSpotMinEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hRandomPositionMinEdit,'string');
        iRandMin = fnMyStr2Num(strTemp);
        if ~isempty(iRandMin)
            g_strctParadigm.m_fRandFixPosMin = iRandMin;
            fnLog('Random fixation changes after at least %d images', iRandMin);
        end;
    case 'RandFixationSpotMaxEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hRandomPositionMaxEdit,'string');
        iRandMax = fnMyStr2Num(strTemp);
        if ~isempty(iRandMax)
            g_strctParadigm.m_fRandFixPosMax = iRandMax;
            fnLog('Random fixation changes after at max %d images', iRandMax);
        end;
    case 'RandFixationSpotRadiusEdit'
        strTemp = get(g_strctParadigm.m_strctControllers.m_hRandomPositionRadiusEdit,'string');
        iRandRadius = fnMyStr2Num(strTemp);
        if ~isempty(iRandRadius)
            g_strctParadigm.m_fRandFixRadius = iRandRadius;
            fnLog('Random fixation radius set to %d pixels', iRandRadius);
        end;
    case 'ParameterSweep'
        g_strctParadigm.m_bParameterSweep = get(g_strctParadigm.m_strctControllers.m_hParameterSweep,'value');
        if (g_strctParadigm.m_bParameterSweep)
            
           g_strctParadigm.m_strctSavedParam.m_pt2fStimulusPosition = fnTsGetVar('g_strctParadigm','StimulusPos');
           g_strctParadigm.m_strctSavedParam.m_fTheta = fnTsGetVar('g_strctParadigm','RotationAngle');
           g_strctParadigm.m_strctSavedParam.m_fSize = fnTsGetVar('g_strctParadigm','StimulusSizePix');
            
            fnInitializeParameterSweep();
            g_strctParadigm.m_iStimuliCounter = 1;
            g_strctParadigm.m_iMachineState = 1;
       
            
        else
            
            fnTsSetVarParadigm('StimulusPos',g_strctParadigm.m_strctSavedParam.m_pt2fStimulusPosition);
            fnTsSetVarParadigm('RotationAngle',g_strctParadigm.m_strctSavedParam.m_fTheta);
            fnTsSetVarParadigm('StimulusSizePix',g_strctParadigm.m_strctSavedParam.m_fSize);
            
        end
	% Changelog 10/21/13 josh - other components of FitToScreen setting	
	case 'FitToScreen'
		g_strctParadigm.m_bFitToScreen = get(g_strctParadigm.m_strctControllers.m_hFitToScreen, 'value');
		
	
	% End Changelog
    case 'RandFixationSync'
        g_strctParadigm.m_bRandFixSyncStimulus = ~g_strctParadigm.m_bRandFixSyncStimulus;

    case 'MotionStarted'
        g_strctParadigm.m_iMachineState = 0;
        fnParadigmToStimulusServer('PauseButRecvCommands');
        g_strctParadigm.m_bPausedDueToMotion = true;
    case 'MotionFinished'
        if ~fnParadigmToKofikoComm('IsPaused')
             g_strctParadigm.m_strctCurrentTrial = fnHandMappingPrepareTrial();
            g_strctParadigm.m_iMachineState = 1;
        end
        g_strctParadigm.m_bPausedDueToMotion = false;
    case 'HideNotLookingToggle'
        g_strctParadigm.m_bHideStimulusWhenNotLooking = ~g_strctParadigm.m_bHideStimulusWhenNotLooking;
        if ~g_strctParadigm.m_bHideStimulusWhenNotLooking
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'ParameterSweepMode'
        g_strctParadigm.m_iParameterSweepMode = get(g_strctParadigm.m_strctControllers.m_hParameterSweepPopup,'value');
        fnInitializeParameterSweep();
    case 'UpdateListFiringRate'
        [Dummy, acShortFileNames] = fnCellToCharShort(g_strctParadigm.m_acImageFileNames);
        
%         for k=1:length(acShortFileNames)
%             acShortFileNames{k} = sprintf('%.2f %s',...
%                 g_strctCycle.m_a2fAvgStimulusResponse(g_strctGUIParams.m_iSelectedChannelPSTH,k),acShortFileNames{k});
%         end
%          
%         set(g_strctParadigm.m_strctControllers.m_hImageList,'String',acShortFileNames);


    case 'PlayStimuliLocally'
        g_strctParadigm.m_bDisplayStimuliLocally = ~g_strctParadigm.m_bDisplayStimuliLocally;
    case 'ShowWhileLoading'
        g_strctParadigm.m_bShowWhileLoading = ~g_strctParadigm.m_bShowWhileLoading;
    case 'ForceStereoToggle'
         bForceStereo = fnTsGetVar('g_strctParadigm','ForceStereoOnMonocularLists') > 0;
         bForceStereo = ~bForceStereo;
         fnTsSetVarParadigm('ForceStereoOnMonocularLists',bForceStereo);
         set(g_strctParadigm.m_strctControllers.m_hForceStereoOnMonocularLists,'value',bForceStereo);
    case 'DrawAttentionEvent'
        g_strctParadigm.m_iMachineState = 1;

    otherwise
		varargout{1} = fnDynamicCallback(strCallback);
       % fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
         
end;

return;

function fnSafeLoadListAux()
global g_strctParadigm
fnParadigmToKofikoComm('JuiceOff');
fnParadigmToStimulusServer('PauseButRecvCommands');
fnHidePTB();
[strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt;*.xml']);

fnShowPTB()
if strFile(1) ~= 0
    g_strctParadigm.m_strNextImageList = [strPath,strFile];
    
    if ~fnLoadPassiveFixationDesign(g_strctParadigm.m_strNextImageList);
        return;
    end;
    
    [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
    fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);

    % If not available in the favorite list, add it!
    iIndex = -1;
    for k=1:length(g_strctParadigm.m_acFavroiteLists)
        if strcmpi(g_strctParadigm.m_acFavroiteLists{k}, g_strctParadigm.m_strNextImageList)
            iIndex = k;
            break;
        end
    end


    if iIndex == -1
        % Not found, add!
        g_strctParadigm.m_acFavroiteLists = [g_strctParadigm.m_strNextImageList,g_strctParadigm.m_acFavroiteLists];
        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'String',fnCellToCharShort(g_strctParadigm.m_acFavroiteLists),'value',1);
    else
        set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'value',iIndex);
    end
    
      

end;