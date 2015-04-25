function [newX, newY] = fnRotateAroundPoint(x ,y , centerX, centerY, angle_of_rotation)

% Helper function. Rotates stuff for dynamic presentations
% takes 11 microseconds
s = sin(degtorad(angle_of_rotation));
c = cos(degtorad(angle_of_rotation));
x = x - centerX;
y = y - centerY;


newX = x .* c - y .* s;
newY = x .* s + y .* c;
newX = round(newX + centerX);
newY = round(newY + centerY);

return;
