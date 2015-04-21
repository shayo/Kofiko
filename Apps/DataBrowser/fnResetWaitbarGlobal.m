function fnResetWaitbarGlobal(iLevel, NumLevels)
global g_hWaitBar
afLevels = linspace(0,1,NumLevels+1);
rectangle('Position',[0 afLevels(iLevel) 1 afLevels(iLevel+1)], 'Parent',g_hWaitBar,'FaceColor','k');
drawnow
return