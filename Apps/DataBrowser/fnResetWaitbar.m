function fnResetWaitbar(hAxes)
cla(hAxes);
set(hAxes,'Color','k','Xlim',[0 1],'YLim',[0 1],'YTick',[],'XTick',[]);
drawnow
return;

