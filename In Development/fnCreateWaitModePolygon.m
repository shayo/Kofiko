function [xi, yi, placement_cancelled] = createWaitModePolygon(h_ax,finished_cmenu_text)
%createWaitModePolygon creates a blocking instance of impoly.
% [XI,YI,PLACEMENT_CANCELLED] =
% createWaitModePolygon(H_AX,FINISHED_CMENU_TEXT) creates a blocking
% instance of impoly parented to H_AX. The context menu description of the
% end of placement gesture receives the label FINISHED_CMENU_TEXT. Once the
% polygon is placed, it returns [XI,YI] vertices of where the polygon was
% oriented and PLACEMENT_CANCELLED which signals whether placement was
% cancelled.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:21:14 $

% initialize to "identity" mask
[xi,yi] = deal([]);

% interactively place tool
h_poly = iptui.roiPolygon(h_ax,finished_cmenu_text);
placement_cancelled = isempty(h_poly);
if placement_cancelled
    return;
end

pos = wait(h_poly);

abortedWaitMode = isempty(pos);
if abortedWaitMode
    placement_cancelled = true;
else
    xi = pos(:,1);
    yi = pos(:,2);
    delete(h_poly);
end


