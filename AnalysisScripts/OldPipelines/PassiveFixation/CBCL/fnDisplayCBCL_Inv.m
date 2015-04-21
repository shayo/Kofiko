function fnDisplayCBCL_Inv(ahPanels, strctUnit)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


ahSubPlots = fnDisplayPassiveFixation(ahPanels,strctUnit);
 
h=axes('parent',ahPanels(3));
plot(0:12,strctUnit.m_strctCBCL.m_afResFace_Sinha,0:12,strctUnit.m_strctCBCL.m_afResNonFace_Sinha);
xlabel('Num of correct ratios');
ylabel('Firing Rate');

return;
