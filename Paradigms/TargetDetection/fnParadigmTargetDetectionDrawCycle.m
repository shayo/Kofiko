function fnParadigmTargetDetectionDrawCycle(acInputFromKofiko)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)



global g_strctPTB g_strctDraw g_strctNet g_strctServerCycle

if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};
    switch strCommand

        case 'ShowFixationSpot'
            strctFixationSpot = acInputFromKofiko{2};
            fnDrawFixationSpot(strctFixationSpot,true);
 
            fFlipTime = fnFlipWrapper( g_strctPTB.m_hWindow); % Blocking !
            fnStimulusServerToKofikoParadigm('FixationAppear',fFlipTime);

        case 'LoadList'
            strListFile = acInputFromKofiko{2};
            if isfield(g_strctDraw,'m_strctObjects') &&isfield(g_strctDraw.m_strctObjects,'m_ahPTBHandles') && ~isempty(g_strctDraw.m_strctObjects.m_ahPTBHandles)
                Screen('Close',g_strctDraw.m_strctObjects.m_ahPTBHandles);
            end
            [g_strctDraw.m_strctObjects.m_ahPTBHandles, ...
                g_strctDraw.m_strctObjects.m_a2iImageSize, ...
                g_strctDraw.m_strctObjects.m_aiGroup, ...
                g_strctDraw.m_strctObjects.m_afWeights, ...
                g_strctDraw.m_strctObjects.m_acFileNamesNoPath] = fnLoadWeightedImageList(strListFile);
        case 'ClearMemory'
             if isfield(g_strctDraw,'m_strctObjects') && isfield(g_strctDraw.m_strctObjects,'m_ahPTBHandles') && ~isempty(g_strctDraw.m_strctObjects.m_ahPTBHandles)
                 Screen('Close',g_strctDraw.m_strctObjects.m_ahPTBHandles);
                 g_strctDraw.m_strctObjects.m_ahPTBHandles = [];
             end
            
        case 'ShowTrial'

            strctCurrentTrial = acInputFromKofiko{2};

            % Draw "Targets" on screen
            for k=1:length( strctCurrentTrial.m_aiSelectedObjects)
                iObjectIndex = strctCurrentTrial.m_aiSelectedObjects(k);
             

                if isfield(strctCurrentTrial,'m_acImages') && ~isempty(strctCurrentTrial.m_acImages)
               
                    aiSize = size(strctCurrentTrial.m_acImages{k});
                   aiStimulusRect = fnComputeStimulusRect(strctCurrentTrial.m_fObjectHalfSizePix,...
                        aiSize([2,1]),...
                    strctCurrentTrial.m_apt2fPos(:,k));
                    
                if strcmp(class(strctCurrentTrial.m_acImages{k}),'uint8')
                    hHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctCurrentTrial.m_acImages{k});
                else
                    hHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctCurrentTrial.m_acImages{k}*255);
                end
                    Screen('DrawTexture', g_strctPTB.m_hWindow, hHandle,[], aiStimulusRect);
                    Screen('Close',hHandle);
                else
                      aiStimulusRect = fnComputeStimulusRect(strctCurrentTrial.m_fObjectHalfSizePix,...
                    g_strctDraw.m_strctObjects.m_a2iImageSize(:,iObjectIndex),...
                    strctCurrentTrial.m_apt2fPos(:,k));
                    
                    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_strctObjects.m_ahPTBHandles(iObjectIndex),[],aiStimulusRect);
                end
            end
            
            if isfield(strctCurrentTrial,'m_strctFixationSpot') && ~isempty(strctCurrentTrial.m_strctFixationSpot)
                fnDrawFixationSpot(strctCurrentTrial.m_strctFixationSpot,false);
            end
            
           fFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % Blocking !
           fnStimulusServerToKofikoParadigm('StimulusON',fFlipTime);
            
            
    end
end;


return;




function fnDrawFixationSpot(strctFixationSpot, bClear)
global g_strctPTB
if bClear
    Screen('FillRect',g_strctPTB.m_hWindow, strctFixationSpot.m_afBackgroundColor);
end
switch strctFixationSpot.m_strShape
    case 'Circle';

        aiFixationSpot = [...
            strctFixationSpot.m_pt2fPosition(1) - strctFixationSpot.m_fFixationRadiusPix,...
            strctFixationSpot.m_pt2fPosition(2) - strctFixationSpot.m_fFixationRadiusPix,...
            strctFixationSpot.m_pt2fPosition(1) + strctFixationSpot.m_fFixationRadiusPix,...
            strctFixationSpot.m_pt2fPosition(2) + strctFixationSpot.m_fFixationRadiusPix];

        Screen(g_strctPTB.m_hWindow,'FrameArc',strctFixationSpot.m_afFixationColor, aiFixationSpot,0,360);
end
