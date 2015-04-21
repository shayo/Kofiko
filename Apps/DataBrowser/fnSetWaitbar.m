function fnSetWaitbar(hAxes, fFraction)
rectangle('Position',[0 0 fFraction 1], 'Parent',hAxes,'FaceColor','r');
drawnow
return