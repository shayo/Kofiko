function fnDoubleBar(afX,afY1,afY2,strTitle, afYTick)
fWidth = (afX(2)-afX(1))/2;
fRange = max([afY1(:);afY2(:)])*1.2;

bar(afX,afY1,'facecolor','b');
hold on;
bar(afX,-afY2,'facecolor','r');
set(gca,'xlim',[afX(1)-fWidth, afX(end)+fWidth]);
set(gca,'ylim',[-fRange fRange]);
if exist('afYTick','var')
    set(gca,'ytick',afYTick);
    set(gca,'ylim',[afYTick(1),afYTick(end)]);

end;

% set(gca,'ytick',linspace(-fRange,fRange,5));
aiTicks = get(gca,'ytick');
acLabels = cell(1,length(aiTicks));
for k=1:length(aiTicks)
    acLabels{k}=sprintf('%.2f',abs(aiTicks(k)));
end
set(gca,'yticklabel',acLabels);
if exist('strTitle','var')
    title(strTitle);
end