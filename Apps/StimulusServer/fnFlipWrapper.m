function fFlipTime = fnFlipWrapper(hWindow, varargin)
% A wrapper function to Screen('Flip')
% used to draw a small rectangle (either black or white) just prior to the flip
% to obtain the most accurate time stamp from a photodiode attached to the
% screen....
% This is to adjust for LCD lag time (which can range between 10-20 ms...)
%

global g_bPhotoDiodeToggle
iRectSizePix = 50;
if isempty(g_bPhotoDiodeToggle) || ~g_bPhotoDiodeToggle
    g_bPhotoDiodeToggle = true;
    % Draw the small white rectangle
    Screen('FillRect', hWindow, [255 255 255],[0 0 iRectSizePix iRectSizePix]);
else
    g_bPhotoDiodeToggle = false;
    % Draw the small black rectangle
    Screen('FillRect', hWindow, [0 0 0],[0 0 iRectSizePix iRectSizePix]);
end

fFlipTime = Screen('Flip', hWindow, varargin{:});

return;