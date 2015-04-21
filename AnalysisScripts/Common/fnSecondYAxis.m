function ax2 = fnSecondYAxis(ax)
% Generate second Y axis to the right of an existing axis 
% assume X ticks are the same (!)
ax1hv = get(ax,'HandleVisibility');
ax2 = axes('HandleVisibility',ax1hv,'Units',get(ax(1),'Units'), ...
    'Position',get(ax(1),'Position'),'Parent',get(ax(1),'Parent'));
set(ax2,'YAxisLocation','right','Color','none', ...
    'XGrid','off','YGrid','off','Box','off', ...
    'HitTest','off');
hold(ax2,'on')
set(ax2,'xtick',[]);

linkprop([ax,ax2],'View');
return;
