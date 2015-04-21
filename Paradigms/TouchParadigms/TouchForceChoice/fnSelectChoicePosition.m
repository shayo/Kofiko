function apt2fPositions = fnSelectChoicePosition(strArrangement, iNumChoices, iChoiceBoundingBoxSizePix)
aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
fWidth = aiScreenSize(3);
fHeight = aiScreenSize(4);

switch lower(strArrangement)
    case 'leftright'
    case 'updown'
    case 'grid2x2'
       apt2fPositions = [1*fWidth/6,  1*fWidth/6,  5*fWidth/6, 5*fWidth/6;
                                     1*fHeight/6, 5*fHeight/6, 5*fHeight/6,5*fHeight/6];
        aiRand = randperm(4);
        apt2fPositions=apt2fPositions(:,aiRand);
    case 'circular'
        if iNumChoices == 2
            fAngleOffset = 90;
        else
            fAngleOffset = 0;
        end
        AngleDiff = 360/iNumChoices;
        afAngles = [0:iNumChoices-1] * AngleDiff + fAngleOffset;
        fRadius = 200;
        apt2fPositions = [fRadius * sin(afAngles/180*pi) + aiScreenSize(3)/2;
                             fRadius * cos(afAngles/180*pi) + aiScreenSize(4)/2];
        
    case 'random'
        % Try to find a spot that has not been used....
        iNumMaxTrials = 20;
        a2bTmp = zeros(fHeight, fWidth) > 0;
        apt2fPositions = zeros(2, iNumChoices);
        for iChoiceIter=1:iNumChoices
            afOverlap = zeros(1,iNumMaxTrials);
            apt2fOptions = zeros(2,iNumMaxTrials);
            for iIter=1:iNumMaxTrials
                apt2fOptions(:,iIter) = round([rand() * (fWidth-2*iChoiceBoundingBoxSizePix) + iChoiceBoundingBoxSizePix;
                                rand() * (fHeight-2*iChoiceBoundingBoxSizePix) + iChoiceBoundingBoxSizePix]);
                            
                aiX = min(fWidth, max(1,apt2fOptions(1,iIter)-1*iChoiceBoundingBoxSizePix:apt2fOptions(1,iIter)+1*iChoiceBoundingBoxSizePix));
                aiY = min(fHeight, max(1,apt2fOptions(2,iIter)-1*iChoiceBoundingBoxSizePix:apt2fOptions(2,iIter)+1*iChoiceBoundingBoxSizePix));
                afOverlap(iIter) = sum(sum(a2bTmp(aiY,aiX)));
            end
            % find min overlap
            [fDummy, iMinOverlap] = min(afOverlap);
            apt2fPositions(:,iChoiceIter) = apt2fOptions(:,iMinOverlap);
            aiX = min(fWidth, max(1,apt2fOptions(1,iMinOverlap)-1*iChoiceBoundingBoxSizePix:apt2fOptions(1,iMinOverlap)+1*iChoiceBoundingBoxSizePix));
            aiY = min(fHeight, max(1,apt2fOptions(2,iMinOverlap)-1*iChoiceBoundingBoxSizePix:apt2fOptions(2,iMinOverlap)+1*iChoiceBoundingBoxSizePix));
            a2bTmp(aiY,aiX) = true;
        end
    case 'randomleftright'
        if rand() > 0.5
        apt2fPositions = [1*fWidth/6,5*fWidth/6;
                             fHeight/2,fHeight/2];
            
        else
        apt2fPositions = [5*fWidth/6,1*fWidth/6;
                             fHeight/2,fHeight/2];
        end
end

return;