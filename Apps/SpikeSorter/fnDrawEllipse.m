function ahHandles = fnDrawEllipse(astrctEllipse, a2fColors)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
ahHandles = [];
for k=1:length(astrctEllipse)
    % Draw latest known position
    if ~isnan(astrctEllipse(k).m_fX)
        h = fnPlotEllipse(astrctEllipse(k).m_fX,...
        astrctEllipse(k).m_fY,...
        astrctEllipse(k).m_fA,...
        astrctEllipse(k).m_fB,...
        astrctEllipse(k).m_fTheta, a2fColors(k,:),2);
       ahHandles = [ahHandles;h];
    end;
 end;

return;


function hHandle = fnPlotEllipse(fX,fY,fA,fB,fTheta, afCol, iLineWidth)
% Plots an ellipse which is represented as a 5 tuple.
%
% Inputs:
%   <fX,fY,fA,fB,fTheta> - ellipse parameters
%    afCol - 1x3 color vector (RGB)
%    iLineWidth - 1x1 line width
% Outputs:
%    hHandle - handle to the plotted ellipse
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

N = 60;

% Generate points on circle
%fTheta = fTheta + pi/2;
afTheta = linspace(0,2*pi,N);%2*pi*[0:N]/N;
apt2f = [fA * cos(afTheta); fB * sin(afTheta)];
R = [ cos(fTheta), sin(fTheta);
    -sin(fTheta), cos(fTheta)];
apt2fFinal = R*apt2f + repmat([fX;fY],1,N);
hHandle  = plot(apt2fFinal(1,:), apt2fFinal(2,:),'Color', afCol, 'LineWidth', iLineWidth);

return;

