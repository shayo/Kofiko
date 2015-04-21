function fnSetWaitbarGlobal(fFraction,iLevel, NumLevels)
global g_hWaitBar
afLevels = linspace(0,1,NumLevels+1);
rectangle('Position',[0 afLevels(iLevel) fFraction afLevels(iLevel+1)], 'Parent',g_hWaitBar,'FaceColor','r');
drawnow
return