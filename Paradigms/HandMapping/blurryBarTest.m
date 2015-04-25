function [] = blurryBarTest()




[vars.ScreenID, vars.ScreenRect] = Screen('OpenWindow',3);
res = Screen('Resolution',3);
vars.barLength = 100;
vars.barWidth = 50;
vars.barCenter = [res.height/2, res.width/2];
vars.numberBlurSteps = 15;
vars.bgColor = [0 0 0];
vars.barColor = [255 255 255];

vars.rectangle = zeros(vars.barLength,vars.barWidth);

vars.bar_rect(1,1:4) = [(vars.barCenter(1) - vars.barLength/2), (vars.barCenter(2) - vars.barWidth/2), ...
    (vars.barCenter(1) + vars.barLength/2), (vars.barCenter(2) + vars.barWidth/2)];
[vars] = calculateBlur(vars);
	
	
	
pause(5)
Screen('CloseAll');

return;

function [vars] = calculateBlur(vars)


vars.blurLengthSize = (vars.barLength/2) / vars.numberBlurSteps;
vars.blurWidthSize = (vars.barWidth/2) / vars.numberBlurSteps;


vars.blurStepHolderR = linspace(vars.bgColor(1),vars.barColor(1),vars.numberBlurSteps);
vars.blurStepHolderG = linspace(vars.bgColor(2),vars.barColor(2),vars.numberBlurSteps);
vars.blurStepHolderB = linspace(vars.bgColor(3),vars.barColor(3),vars.numberBlurSteps);
Screen('FillRect',vars.ScreenID,vars.bgColor);

for i = vars.numberBlurSteps:-1:1
%vars.rectangle(round(vars.barWidth-vars.blurWidthSize*i):round(vars.barWidth+vars.blurWidthSize*i),round(vars.barLength-vars.blurLengthSize*i):round(vars.barLength+vars.blurLengthSize*i),1:3) =...
	%												round(vars.blurStepHolderR(16-i)),round(vars.blurStepHolderG(16-i)),round(vars.blurStepHolderB(16-i));
Screen('FillPoly',vars.ScreenID,[round(vars.blurStepHolderR(16-i)),round(vars.blurStepHolderG(16-i)),round(vars.blurStepHolderB(16-i))],...
	[round(vars.barWidth-vars.blurWidthSize*i),round(vars.barLength+vars.blurLengthSize*i);...
    round(vars.barWidth+vars.blurWidthSize*i),round(vars.barLength+vars.blurLengthSize*i);...
    round(vars.barWidth+vars.blurWidthSize*i),round(vars.barLength-vars.blurLengthSize*i);...
    round(vars.barWidth-vars.blurWidthSize*i),round(vars.barLength-vars.blurLengthSize*i)]);

end
Screen('Flip',vars.ScreenID)

return;


%{
[round(vars.barWidth-vars.blurWidthSize*i),round(vars.barLength+vars.blurLengthSize*i);...
    round(vars.barLength-vars.blurLengthSize*i),round(vars.barWidth+vars.blurWidthSize*i);...
    round(vars.barWidth+vars.blurWidthSize*i),round(vars.barLength+vars.blurLengthSize*i);...
    round(vars.barLength+vars.blurLengthSize*i),round(vars.barWidth-vars.blurWidthSize*i)])



%}