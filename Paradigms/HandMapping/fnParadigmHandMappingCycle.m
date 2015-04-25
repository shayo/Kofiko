function fnParadigmHandMappingCycle(strctInputs, bParadigmPaused)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctPTB g_strctAcquisitionServer g_strctPlexon
if bParadigmPaused
    return;
end
fCurrTime = GetSecs;

if 	(fCurrTime - g_strctPlexon.m_fLastPlexonUpdate) > 1/g_strctPlexon.m_iSpikeUpdateHz
	fnGetSpikesFromPlexon();
	g_strctPlexon.m_fLastPlexonUpdate = fCurrTime;
	if g_strctPlexon.m_strctLastCheck.m_iWFCount > 0
		fnUpdatePlots({'UpdateCounts','UpdateRawSpikeCount'},1:20,squeeze(g_strctParadigm.TrialsForPlotting.Buffer(1,:,g_strctParadigm.TrialsForPlotting.BufferIdx)));
	end
end

pt2iFixationSpotPix = g_strctParadigm.FixationSpotPix.Buffer(:,:,g_strctParadigm.FixationSpotPix.BufferIdx);
iGazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(:,:,g_strctParadigm.GazeBoxPix.BufferIdx);

aiGazeRect = [pt2iFixationSpotPix-iGazeBoxPix,pt2iFixationSpotPix+iGazeBoxPix];

bFixating = strctInputs.m_pt2iEyePosScreen(1) > aiGazeRect(1) && ...
    strctInputs.m_pt2iEyePosScreen(2) > aiGazeRect(2) && ...
    strctInputs.m_pt2iEyePosScreen(1) < aiGazeRect(3) && ...
    strctInputs.m_pt2iEyePosScreen(2) < aiGazeRect(4);

if isempty(g_strctParadigm.m_strctCurrentTrial) && g_strctParadigm.m_iMachineState > 2
    g_strctParadigm.m_iMachineState = 2;
end


if ~isempty(strctInputs.m_acInputFromStimulusServer)
    if strcmp(strctInputs.m_acInputFromStimulusServer{1},'UpdateFrameCounter')
        g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter = strctInputs.m_acInputFromStimulusServer{2};
    end
end


% Update variables from the GUI
fnVariableUpdateCheck();

% Update the stimulus rectangle
currentBlockStimAreaVariable = [g_strctParadigm.m_strCurrentlySelectedBlock,'StimulusArea'];

g_strctParadigm.m_aiStimulusRect(1) = round(g_strctParadigm.m_aiCenterOfStimulus(1)-(squeeze(g_strctParadigm.(currentBlockStimAreaVariable).Buffer(1,:,g_strctParadigm.(currentBlockStimAreaVariable).BufferIdx)/2)));
g_strctParadigm.m_aiStimulusRect(2) = round((g_strctParadigm.m_aiCenterOfStimulus(2)- .75 * (squeeze(g_strctParadigm.(currentBlockStimAreaVariable).Buffer(1,:,g_strctParadigm.(currentBlockStimAreaVariable).BufferIdx)/2))));
g_strctParadigm.m_aiStimulusRect(3) = round(g_strctParadigm.m_aiCenterOfStimulus(1)+(squeeze(g_strctParadigm.(currentBlockStimAreaVariable).Buffer(1,:,g_strctParadigm.(currentBlockStimAreaVariable).BufferIdx)/2)));
g_strctParadigm.m_aiStimulusRect(4) = round((g_strctParadigm.m_aiCenterOfStimulus(2)+ .75 * (squeeze(g_strctParadigm.(currentBlockStimAreaVariable).Buffer(1,:,g_strctParadigm.(currentBlockStimAreaVariable).BufferIdx)/2))));


%{
g_strctParadigm.m_aiStimulusRect(1) = round(g_strctParadigm.m_aiCenterOfStimulus(1)-(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
g_strctParadigm.m_aiStimulusRect(2) = round((g_strctParadigm.m_aiCenterOfStimulus(2)- .75 * (squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2))));
g_strctParadigm.m_aiStimulusRect(3) = round(g_strctParadigm.m_aiCenterOfStimulus(1)+(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
g_strctParadigm.m_aiStimulusRect(4) = round((g_strctParadigm.m_aiCenterOfStimulus(2)+ .75 * (squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2))));
%}




% Handle micro stim events (per block mode)
if g_strctParadigm.m_strctMiroSctim.m_bActive
    if fCurrTime > g_strctParadigm.m_strctMiroSctim.m_fNextStimTS
        % Micro stim
        strctStimulation.m_iChannel = 1; % HERE!!!
        strctStimulation.m_fDelayToTrigMS = 0;
        fnParadigmToKofikoComm('MultiChannelStimulation', strctStimulation);
        
        % Set next time for stimulation
        switch g_strctParadigm.m_strctMiroSctim.m_strMicroStimType
            case 'FixedRate'
                g_strctParadigm.m_strctMiroSctim.m_fNextStimTS = g_strctParadigm.m_strctMiroSctim.m_fNextStimTS + 1/g_strctParadigm.m_strctMiroSctim.m_fMicroStimRateHz;
            case 'Poisson'
                % I hope I got this right. This should generate a poisson
                % train (actually, an exponential latency between events)
                FiringRate = g_strctParadigm.m_strctMiroSctim.m_fMicroStimRateHz;
                NumSeconds = 1;
                N=ceil(FiringRate* NumSeconds);
                a2fUniformDist=rand(1, N);
                a2fExpDist = -log(a2fUniformDist); % exponentially distributed random values.
                fNextEventLatencySec =  a2fExpDist/FiringRate;
                g_strctParadigm.m_strctMiroSctim.m_fNextStimTS = g_strctParadigm.m_strctMiroSctim.m_fNextStimTS  + fNextEventLatencySec;
                
        end
        
    end
end
            g_strctParadigm.m_strctMiroSctim.m_fMicroStimRateHz = 1/5;


% There's only 1 trial type, so we can override that here
%g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex = 1;


switch g_strctParadigm.m_iMachineState
    case 0
        fnParadigmToKofikoComm('SetParadigmState','Waiting for user to press Start');
    case 1 % Run some tests that everything is OK. Then goto 2
        if g_strctParadigm.m_iNumStimuli > 0
            g_strctParadigm.m_iMachineState = 2;
        else
            fnParadigmToKofikoComm('SetParadigmState','Cannot start machine. Please load an image list.');
        end;
    case 2
        if isempty(g_strctParadigm.m_strctDesign)
            g_strctParadigm.m_iMachineState = 1;
            return;
        end;
        % Set Next "trial" (image on->off)
         if g_strctParadigm.m_bRepeatNonFixatedImages && ~g_strctParadigm.m_bJustLoaded && ...
                 ~isempty(g_strctParadigm.m_strctCurrentTrial) && isfield(g_strctParadigm.m_strctCurrentTrial,'m_bMonkeyFixated') &&  ~g_strctParadigm.m_strctCurrentTrial.m_bMonkeyFixated
             % Keep same trial....
         else
             % This is the important call to set up all the different
             % parameters for the next trial (media, position, etc...)
            
            g_strctParadigm.m_strctCurrentTrial = fnHandMappingPrepareTrial();

         end
         
         if g_strctParadigm.m_bJustLoaded
             g_strctParadigm.m_bJustLoaded = false;
         end;


        g_strctParadigm.m_strctCurrentTrial.m_bMonkeyFixated = true;
        
        g_strctParadigm.m_bStimulusDisplayed = true;
        
       
        fnParadigmToStatServerComm('Send','TrialStart');

		if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
			% Update with color number 
			fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialStartCode);  
			fnDAQWrapper('StrobeWord', g_strctParadigm.m_iTrialStrobeID);   
			% We can get the saturation from the experiment file, 
			% we just need which color this trial was
			
			%fnGetSpikesFromPlexon();
			% We're not using the ITI spikes for anything right now, but we need to check the server
			% To clear the buffer
			%g_strctPlexon.m_afITIspikes = g_strctPlexon.m_strctLastCheck;
			

        end
        
        % SO 21 Sep 2011
        % Very important
        % This will tell the statistics server which trial type is
        % starting by sending a strobe word to plexon....
         
		 
		
        fnParadigmToKofikoComm('TrialStart',g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex);  
        
        % Instruct the stimulus server to display the trial....

        fnParadigmToStimulusServer('ShowTrial',g_strctParadigm.m_strctCurrentTrial);
        g_strctParadigm.m_strctCurrentTrial.m_fSentMessageTimer = GetSecs();
		
        g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter = 1;
		
        % Update status line
        if strcmpi(g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_strMediaType,'Movie') || strcmpi(g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_strMediaType,'StereoMovie')             
             hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
              g_strctParadigm.m_iTrialLength_MS = 1e3*g_strctParadigm.m_strctTexturesBuffer.m_afMovieLengthSec(hTexturePointer);
        else
            g_strctParadigm.m_iTrialLength_MS = g_strctParadigm.m_strctCurrentTrial.m_fStimulusON_MS+g_strctParadigm.m_strctCurrentTrial.m_fStimulusOFF_MS;
        end
          
        iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
        iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);

        strBlockName =  g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_strBlockName;
        iNumBlocks = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder);
        iNumTimesToShowBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockRepitition(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
        
        
        fnParadigmToKofikoComm('SetParadigmState', sprintf('Block %d/%d (%s), Block Rep %d/%d, Image %d (%d/%d), Block Time: (%.1f / %.1f) Sec', ...
            g_strctParadigm.m_iCurrentBlockIndexInOrderList,...
            iNumBlocks,...
            strBlockName,...
            g_strctParadigm.m_iNumTimesBlockShown,...
            iNumTimesToShowBlock,...
            g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex,...
            g_strctParadigm.m_iCurrentMediaIndexInBlockList,...
            iNumMediaInBlock,...
              (iNumMediaInBlock-g_strctParadigm.m_iCurrentMediaIndexInBlockList) * (g_strctParadigm.m_iTrialLength_MS)/1e3,...
            iNumMediaInBlock* (g_strctParadigm.m_iTrialLength_MS)/1e3 ));
			
		%if g_strctParadigm.m_strctCurrentTrial.numFrames > 1
			g_strctParadigm.m_iMachineState = 3;
		%$else
		%	g_strctParadigm.m_iMachineState = 1;
		%end
    case 3
        % Wait for message that trial started (i.e., image was displayed on
        % screen)
        if ~isempty(strctInputs.m_acInputFromStimulusServer) 
            if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'FlipON')
                g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_StimulusServer = strctInputs.m_acInputFromStimulusServer{2};
                g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_Kofiko = GetSecs();
                
            

				if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
					fnParadigmToStatServerComm('Send','TrialAlign');
					fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialAlignCode);
                    g_strctParadigm.m_strctPlexon.m_fTrialAlignTime = GetSecs();
					%{
					 fnGetSpikesFromPlexon(); %Clear the buffer
					g_strctParadigm.m_strctPlexon.m_afInterTrialSpikes = g_strctPlexon.m_strctLastCheck.m_afCounts(1);
					%}	
				end
               
                % Now, it depends if we switch stimulus off or not.
                if g_strctParadigm.m_strctCurrentTrial.m_fStimulusOFF_MS > 0
                    g_strctParadigm.m_iMachineState = 4;
                else
                    % No OFF - period. Server is not going to send another
                    % message
                    g_strctParadigm.m_strctCurrentTrial.m_fImageFlipOFF_TS_StimulusServer = g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_StimulusServer;
                    g_strctParadigm.m_iMachineState = 5;
                end
                
            end
        else
            % Message back should have arrive within 1 refresh rate
            % interval. We use 1 second, just to be sure.
            if fCurrTime-g_strctParadigm.m_strctCurrentTrial.m_fSentMessageTimer > 1
                fnParadigmToKofikoComm('DisplayMessage','Missed FlipON Event');
                g_strctParadigm.m_iMachineState = 1;
                

                fnParadigmToStatServerComm('Send',['TrialOutcome ',num2str(g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1))]);
                fnParadigmToStatServerComm('Send','TrialEnd');
                if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
					fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1));
					fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
					

					
                end  
                
            end
            
        end

    case 4
        % Trial started. Now we wait for the FlipOFF signal
		if any(g_strctParadigm.m_strctCurrentTrial.m_fStimulusOFF_MS) && ~bFixating

			if g_strctParadigm.m_fBlinkTimer == 0
				g_strctParadigm.m_fBlinkTimer = GetSecs();
				
			elseif GetSecs() - g_strctParadigm.m_fBlinkTimer>...
						(squeeze(g_strctParadigm.BlinkTimeMS.Buffer(:,1,g_strctParadigm.BlinkTimeMS.BufferIdx)) /1e3)
				g_strctParadigm.m_strctCurrentTrial.m_strctTrialOutcome.m_strResult = 'Aborted;BreakFixationDuringCue';
				g_strctParadigm.m_strctCurrentTrial.m_strctTrialOutcome.m_fTrialAbortedTS_Kofiko = GetSecs();
				
				fnParadigmToStatServerComm('Send',['TrialOutcome ',num2str(g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1))]);
				fnParadigmToStatServerComm('Send','TrialEnd');
				
				g_strctParadigm.m_strctCurrentTrial.m_bMonkeyFixated = 0;
				 if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
				fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1)); % 1 = ABORTED
				fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
			   end
				fnParadigmToStimulusServer('AbortTrial');			
				g_strctParadigm.m_iMachineState = 6;				
			end
		else 
			g_strctParadigm.m_fBlinkTimer = 0;
		end
	
        if ~isempty(strctInputs.m_acInputFromStimulusServer) 
            if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'FlipOFF')
                g_strctParadigm.m_bStimulusDisplayed = false;
                g_strctParadigm.m_strctCurrentTrial.m_fImageFlipOFF_TS_StimulusServer = strctInputs.m_acInputFromStimulusServer{2};
                g_strctParadigm.m_iMachineState = 5;
            end
        else
            if fCurrTime-g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_Kofiko > 2 * (g_strctParadigm.m_iTrialLength_MS/1e3)
                fnParadigmToKofikoComm('DisplayMessage','Missed FlipOFF Event');
                fnParadigmToKofikoComm('TrialEnd', false);
                
                fnParadigmToStatServerComm('Send',['TrialOutcome ',num2str(g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1))]);
                fnParadigmToStatServerComm('Send','TrialEnd');
                if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
					fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1));
					fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode); 
					
                end
               g_strctParadigm.m_iMachineState = 1;
            end
        end
        
    case 5
        % We are not in the "OFF" Period. Wait until trial is over

        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'TrialFinished') || ...
		 (g_strctParadigm.m_strctCurrentTrial.m_fStimulusON_MS == 0 && g_strctParadigm.m_strctCurrentTrial.m_fStimulusOFF_MS == 0 ) % this is for the plain bar case, where there is no trial timing
			
			
            if strcmpi(g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_strMediaType,'Movie') || strcmpi(g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_strMediaType,'StereoMovie')
                a2fFrameFlipTS = strctInputs.m_acInputFromStimulusServer{2};
                fLastFlipTime = strctInputs.m_acInputFromStimulusServer{3};
                g_strctParadigm.m_strctCurrentTrial.m_fImageFlipOFF_TS_StimulusServer = fLastFlipTime;
                iNumFramesDisplayed = size(a2fFrameFlipTS,2);
            else
                iNumFramesDisplayed = 1;
            end
            fnParadigmToKofikoComm('TrialEnd', g_strctParadigm.m_strctCurrentTrial.m_bMonkeyFixated);
            
    	    %if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
				%fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(3));
				
            %end

            if g_strctParadigm.m_strctCurrentTrial.m_bMonkeyFixated
                fnParadigmToStatServerComm('Send',['TrialOutcome ',num2str(g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(3))]);
				if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
					fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(3));
					
			
					
					
				end
            else
				
                fnParadigmToStatServerComm('Send',['TrialOutcome ',num2str(g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(2))]);
				if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
					fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(2));
				end
            end
           fnParadigmToStatServerComm('Send','TrialEnd');
		   if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
				fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
				
				
				
            end
               
            
            % Store only the relevant stuff. The other parameters can be
            % recovered later.
          %{ aiTrialStoreInfo = [g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex,...
           %                     g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_StimulusServer,... 
           %                     g_strctParadigm.m_strctCurrentTrial.m_fImageFlipOFF_TS_StimulusServer,... 
           %                     g_strctParadigm.m_strctCurrentTrial.m_fSentMessageTimer,... 
           %                     g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_Kofiko,...
           %                     iNumFramesDisplayed]';
             %}
           % fnTsSetVarParadigm('Trials',aiTrialStoreInfo);
             g_strctParadigm.m_iMachineState = 2;
            
		
        else
            if any(g_strctParadigm.m_strctCurrentTrial.m_fStimulusOFF_MS) && fCurrTime-g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_Kofiko > 2 * (g_strctParadigm.m_iTrialLength_MS/1e3)
            %if fCurrTime-g_strctParadigm.m_strctCurrentTrial.m_fImageFlipON_TS_Kofiko > g_strctParadigm.m_strctCurrentTrial.m_fStimulusON_MS + g_strctParadigm.m_strctCurrentTrial.m_fStimulusOFF_MS 
                fnParadigmToKofikoComm('DisplayMessage','Missed Trial End Event');
                fnParadigmToStatServerComm('Send',['TrialOutcome ',num2str(g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1))]);
                fnParadigmToStatServerComm('Send','TrialEnd');
				if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
				   fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1));
				   fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
				   
	
					
                end
                g_strctParadigm.m_iMachineState = 1;
            end
        end;
        
        
    case 6
        % Monkey is not looking
        % Wait until he is looking and then start a new trial...
        if bFixating
            g_strctParadigm.m_iMachineState = 1;
        end
        
 end;
%% Mouse related activity 
% These events cannot be handled by the callback function since the mouse
% events are not registered as matlab events.
if g_strctParadigm.m_bUpdateFixationSpot && strctInputs.m_abMouseButtons(1) && strctInputs.m_bMouseInPTB
    % Don't mind using the slow fnTsSetVar here because it is a rare event
    fnTsSetVarParadigm('FixationSpotPix',1/g_strctPTB.m_fScale * strctInputs.m_pt2iMouse);
    fnParadigmToKofikoComm('SetFixationPosition',1/g_strctPTB.m_fScale *strctInputs.m_pt2iMouse);
	if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
		fnDAQWrapper('StrobeWord', fnFindCode('Fixation Spot Position Changed'));     
	end	
end;

if g_strctParadigm.m_bUpdateStimulusPos && strctInputs.m_abMouseButtons(1) && strctInputs.m_bMouseInPTB
    % Don't mind using the slow fnTsSetVar here because it is a rare event
    fnTsSetVarParadigm('StimulusPos',1/g_strctPTB.m_fScale * strctInputs.m_pt2iMouse);
	if g_strctParadigm.m_strctCurrentTrial.m_bUseStrobes
		fnDAQWrapper('StrobeWord', fnFindCode('Stimulus Position Changed'));  
	end
end;

%% Reward related stuff
%global g_strctParadigm
if g_strctParadigm.m_iMachineState == 0
    return;
end


fGazeTimeHighSec = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx) /1000;
fGazeTimeLowSec = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx) /1000;
iStimulusOFF_MS = g_strctParadigm.StimulusOFF_MS.Buffer(:,:,g_strctParadigm.StimulusOFF_MS.BufferIdx);
iStimulusON_MS = g_strctParadigm.StimulusON_MS.Buffer(:,:,g_strctParadigm.StimulusON_MS.BufferIdx);
fCorrectTrialSec = (iStimulusON_MS+iStimulusOFF_MS)/1000;
fBlinkTimeSec = g_strctParadigm.BlinkTimeMS.Buffer(:,:,g_strctParadigm.BlinkTimeMS.BufferIdx) / 1000;
fPositiveIncrement = g_strctParadigm.PositiveIncrement.Buffer(:,:,g_strctParadigm.PositiveIncrement.BufferIdx);
fMaxFixations = 100 / fPositiveIncrement;

fJuiceTimeLowMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
fJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);

fGazeTimeSec = fGazeTimeLowSec + (fGazeTimeHighSec-fGazeTimeLowSec) * (1- g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);
fJuiceTimeMS =  fJuiceTimeLowMS + (fJuiceTimeHighMS-fJuiceTimeLowMS) * (g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);

switch g_strctParadigm.m_strctDynamicJuice.m_iState
    case 0
        % do nothing
        g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
        g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
    case 1
        if bFixating
            g_strctParadigm.m_strctDynamicJuice.m_iState = 2;
            g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime = fCurrTime;
        else
            % Monkey is not fixating. Stay in this mode until monkey fixates....
            g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime = fCurrTime;
        end

    case 2
        % Monkey was fixating last iteration
        if bFixating
            % Good. How long did it pass since the last fixation ?
            g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime + (fCurrTime-g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime);
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime = fCurrTime;
            if g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime > fGazeTimeSec
                % Reset Counters
                g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
                g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
                % Give Juice!
%                fnParadigmToKofikoComm('DisplayMessage', sprintf('Juice Time = %.2f ,Gaze Time = %.1f',fJuiceTimeMS,fGazeTimeSec*1e3 ) );
                fnParadigmToKofikoComm('Juice',fJuiceTimeMS );
                if g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter < fMaxFixations
                    g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter + 1;
                end;
            end
        else
            g_strctParadigm.m_strctDynamicJuice.m_iState = 3;
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime = fCurrTime;
        end
    case 3
	
        % Monkey was not fixating last iteration
        if bFixating
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime = fCurrTime;
            g_strctParadigm.m_strctDynamicJuice.m_iState = 2;
        else
            g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime + (fCurrTime-g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime);
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime = fCurrTime;
            if g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime > fBlinkTimeSec
                g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
                g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            end
            if g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime > fCorrectTrialSec && ~isempty(g_strctParadigm.m_strctCurrentTrial)
                g_strctParadigm.m_strctCurrentTrial.m_bMonkeyFixated = false;
            end

        end
end

bRecording = fnParadigmToKofikoComm('IsRecording');
if g_strctParadigm.m_bHideStimulusWhenNotLooking && g_strctParadigm.m_iMachineState ~= 6 && ~bRecording
    if ~bFixating
        fNotLookingSec = 2;
        if fCurrTime - g_strctParadigm.m_fLastFixatedTimer > fNotLookingSec
            g_strctParadigm.m_iMachineState = 6;
            fnParadigmToKofikoComm('SetParadigmState', 'Waiting for monkey to fixate...');
        end
    else
        g_strctParadigm.m_fLastFixatedTimer = fCurrTime;
    end
    
end

return;

%{
function fnUpdateVariableWithNewPosition()
global g_strctParadigm g_strctPTB



g_strctParadigm.m_aiCenterOfStimulus(1) = g_strctPTB.m_lastStimulusPosition(1) + ...
        ((g_strctPTB.m_strctControlInputs.m_mousePosition(1)-g_strctPTB.m_lastStimulusPosition(1)) +...
        g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1)) ;
    g_strctParadigm.m_aiCenterOfStimulus(2) = g_strctPTB.m_lastStimulusPosition(2) + ...
        ((g_strctPTB.m_strctControlInputs.m_mousePosition(2)-g_strctPTB.m_lastStimulusPosition(2)) +...
        g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2)) ;
    %g_strctParadigm.m_aiCenterOfStimulus(1) = g_strctParadigm.m_aiCenterOfStimulus(1);
    %g_strctParadigm.m_aiCenterOfStimulus(2) = g_strctParadigm.m_aiCenterOfStimulus(2);
    g_strctParadigm.m_aiStimulusRect(1) = round(g_strctParadigm.m_aiCenterOfStimulus(1)-(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_aiStimulusRect(2) = round(g_strctParadigm.m_aiCenterOfStimulus(2)-(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_aiStimulusRect(3) = round(g_strctParadigm.m_aiCenterOfStimulus(1)+(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_aiStimulusRect(4) = round(g_strctParadigm.m_aiCenterOfStimulus(2)+(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    


g_strctPTB.m_strctControlInputs.m_mousePosition(1) >= g_strctParadigm.m_aiStimulusRect(1) && ...
        g_strctPTB.m_strctControlInputs.m_mousePosition(2) >= g_strctParadigm.m_aiStimulusRect(2) && ...
        g_strctPTB.m_strctControlInputs.m_mousePosition(1) <= g_strctParadigm.m_aiStimulusRect(3) && ...
        g_strctPTB.m_strctControlInputs.m_mousePosition(2) <= g_strctParadigm.m_aiStimulusRect(4) && ...
        g_strctPTB.m_strctControlInputs.m_mouseButtons(1)

g_strctPTB.m_lastStimulusPosition = g_strctParadigm.m_aiCenterOfStimulus; 

% Calculate the mouse offset (how far the mouse is from the stimulus center, so the stimulus moves proportional to the mouse starting point and not the stimulus center)
g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1) = ...
        g_strctPTB.m_lastStimulusPosition(1) - g_strctPTB.m_strctControlInputs.m_mousePosition(1);
    g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2) = ...
        g_strctPTB.m_lastStimulusPosition(2) - g_strctPTB.m_strctControlInputs.m_mousePosition(2) ;
    g_strctPTB.m_strctControlInputs.m_bLastStimulusPositionCheck = fCurrTime;

%}

