function fnDrawFixationSpot(hWindow, strctFixationSpot, bClear, fScale)
if bClear
    Screen('FillRect', hWindow, strctFixationSpot.m_afBackgroundColor);
end

switch lower(strctFixationSpot.m_strFixationSpotType)
    case 'circle';
        aiFixationSpot = [...
            strctFixationSpot.m_pt2fFixationPosition(1) - strctFixationSpot.m_fFixationSpotSize,...
            strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize,...
            strctFixationSpot.m_pt2fFixationPosition(1) + strctFixationSpot.m_fFixationSpotSize,...
            strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize];
        
        Screen(hWindow,'FrameArc',strctFixationSpot.m_afFixationColor, fScale*aiFixationSpot,0,360);
    case 'disc';
        aiFixationSpot = [...
            strctFixationSpot.m_pt2fFixationPosition(1) - strctFixationSpot.m_fFixationSpotSize,...
            strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize,...
            strctFixationSpot.m_pt2fFixationPosition(1) + strctFixationSpot.m_fFixationSpotSize,...
            strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize];
        
        Screen(hWindow,'FillArc',strctFixationSpot.m_afFixationColor, fScale*aiFixationSpot,0,360);
    case 'triangle'
        %: each row specifies the (x,y) coordinates of a vertex.
    aiPointList = [strctFixationSpot.m_pt2fFixationPosition(1),strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)- strctFixationSpot.m_fFixationSpotSize,strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize
                            strctFixationSpot.m_pt2fFixationPosition(1)+ strctFixationSpot.m_fFixationSpotSize,strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize];
        Screen('FillPoly',hWindow,strctFixationSpot.m_afFixationColor, fScale*aiPointList, 1); % convex
        
    case 'x'
        fWidth = 0.7;
        %: each row specifies the (x,y) coordinates of a vertex.
    aiPointList = [strctFixationSpot.m_pt2fFixationPosition(1)- strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)- fWidth*strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)+ strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)+ fWidth*strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize];
    Screen('FillPoly',hWindow,strctFixationSpot.m_afFixationColor, fScale*aiPointList, 1); % convex
    
    aiPointList2 = [strctFixationSpot.m_pt2fFixationPosition(1)+fWidth*strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)+ strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)- fWidth*strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)- strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) + strctFixationSpot.m_fFixationSpotSize];
    Screen('FillPoly',hWindow,strctFixationSpot.m_afFixationColor, fScale*aiPointList2, 1); % convex
    case 'diamond'
    aiPointList = [strctFixationSpot.m_pt2fFixationPosition(1), strctFixationSpot.m_pt2fFixationPosition(2) - strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)+ strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) ;
                            strctFixationSpot.m_pt2fFixationPosition(1), strctFixationSpot.m_pt2fFixationPosition(2)+strctFixationSpot.m_fFixationSpotSize;
                            strctFixationSpot.m_pt2fFixationPosition(1)- strctFixationSpot.m_fFixationSpotSize, strctFixationSpot.m_pt2fFixationPosition(2) ];
    Screen('FillPoly',hWindow,strctFixationSpot.m_afFixationColor, fScale*aiPointList, 1); % convex
    otherwise
        fprintf('Unknown fixation type!\n');
end
return;