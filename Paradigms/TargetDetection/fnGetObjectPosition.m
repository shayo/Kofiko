function [apt2fPos] = fnGetObjectPosition(iNumObjects)
global g_strctParadigm
%This function determines the position of the targets and non targets

% Default: spread targets and non targets equally on a circle 

if iNumObjects == 2
    fAngleOffset = 90;
else
    fAngleOffset = 0;
    
end

AngleDiff = 360/iNumObjects;

afAngles = [0:iNumObjects-1] * AngleDiff + fAngleOffset;
fObjectSeparationPix = fnTsGetVar(g_strctParadigm,'ObjectSeparationPix');
aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');

apt2fPos = [fObjectSeparationPix * sin(afAngles/180*pi) + aiScreenSize(3)/2;
               fObjectSeparationPix * cos(afAngles/180*pi) + aiScreenSize(4)/2];


return;
