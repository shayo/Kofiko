function mouseMove (object, eventdata, Wsmall,Xtsne)
subplot(2,2,2);
C = get (gca, 'CurrentPoint');
x = C(1,1);
y = C(1,2);

[~,idx]=min((Xtsne(:,1)-x).^2+(Xtsne(:,2)-y).^2);
subplot(2,2,2);
plot(Xtsne(idx,1),Xtsne(idx,2),'k.');
subplot(2,2,4);cla;
title(num2str(idx));
plot(Wsmall(idx,:));
