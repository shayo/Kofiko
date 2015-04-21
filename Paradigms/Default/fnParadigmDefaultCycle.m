function [strctOutput] = fnParadigmDefaultCycle(strctInputs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctDAQParams g_strctSystemCodes
strctOutput = strctInputs;

switch g_strctParadigm.m_iMachineState 
    case 0
end;

return;
