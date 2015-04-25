function gabortest()



destWin = [0 0 1024 768]; 

[windowPtr, windowRect] = Screen('OpenWindow', 3,[128 128 128 0]);

%while ~KbCheck
tic
Screen('BlendFunction', windowPtr, GL_ONE, GL_ONE);
x = 100;
y = 100;
theta = 90;
length = 100;

width = 50;
si = 32;
% Contrast of grating:
contrast = 10.0;
% Aspect ratio width vs. height:
%aspectratio = 1.0;
% Size of support in pixels, derived from si:
tw = 2*si+1;
th = 2*si+1;
sc = 10.0;
% Frequency of sine grating:
freq = .05;
phase = 0;
%gabortex = CreateProceduralGabor(windowPtr, tw, th, 0);
nonsymmetric = 1;
gabortex = CreateProceduralGabor(windowPtr, tw, th, nonsymmetric);%,[.5 .5 .5 .5],1,.5);
tilt = -(theta);
contrast = .5;
%aspectratio = 0.0;
%aspectratio = 1024/768;
aspectratio = 1.0;
%tw = range([destWin(1),destWin(3)]);
%th = range([destWin(2),destWin(4)]);
[w, h] = RectSize(windowRect);
%x=tw/2;
%y=th/2;
%xTransform = xpos - x;
%yTransform = ypos - y;
texrect = Screen('Rect', gabortex);
inrect = repmat(texrect', 1, 1);
%dstRects = zeros(1, 4);
dstRects = windowRect;%[400,400,700,700];
nonsymmetric = 1;
%Scale = 1*(0.1 + 0.9 * randn);
ScaleArg = 1;
%[cX,cY] = RectCenterd(dstRects);
%dstRects = myOffsetRect(dstRects,x-cX,y-cY);
%dstRects = myCenterRectOnPointd(inrect .* repmat(ScaleArg,4,1), x, y)
 
 
 %dstRects = round(CenterRectOnPoint(texrect * scale, rand * w, rand * h))';
 

%Screen('DrawTexture', windowPtr, gabortex, [], [], [], [], [], [], [], kPsychDontDoRotation, [phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
Screen('DrawTexture', windowPtr, gabortex, [], dstRects, tilt, [], [], [], [], kPsychDontDoRotation, [phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]');

%gabortex = CreateProceduralGabor(windowPtr, tw, th, nonsymmetric,[.5 .5 .5 .5],1,.5);
%gabortex = circshift(gabortex,[xTransform, yTransform]);
%Screen('DrawTexture', windowPtr, gabortex, [], [300,300,500,500]', 90+tilt, [], [], [], [],...
 %kPsychDontDoRotation, [phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]);
toc
Screen('Flip',windowPtr);
pause( )  
%end
Screen('CloseAll')





return;

function [newRect] = myOffsetRect(oldRect,x,y)
newRect(RectTop) = oldRect(RectTop) + y;
newRect(RectBottom) = oldRect(RectBottom) + y;
newRect(RectLeft) = oldRect(RectLeft) + x;
newRect(RectRight) = oldRect(RectRight) + x;
return;


function [dstRect] = myCenterRectOnPointd(rect, x, y)
[cX,cY] = RectCenterd(rect);
dstRect = myOffsetRect(rect,x-cX,y-cY);

return;