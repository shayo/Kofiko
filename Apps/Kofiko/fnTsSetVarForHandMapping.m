function fnTsSetVar(tstrct, strVarName, Value)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctDAQParams g_strctParadigm



fCurrTime = GetSecs();
%eval(['iLastEntry = tstrct.',strVarName,'.BufferIdx;']);

%f = tstrct.(deblank(strVarName)); % deblank field name        



switch tstrct
	case 'g_strctParadigm'
		sz = size(g_strctParadigm.(strVarName).Buffer);
		if iscell(g_strctParadigm.(strVarName).Buffer)

			if g_strctParadigm.(strVarName).BufferIdx+1 > sz(end)
				g_strctParadigm.(strVarName).Buffer{sz*2} = [];
				g_strctParadigm.(strVarName).TimeStamp(sz*2) = 0;
			end
			g_strctParadigm.(strVarName).BufferIdx = g_strctParadigm.(strVarName).BufferIdx + 1;
			g_strctParadigm.(strVarName).Buffer{g_strctParadigm.(strVarName).BufferIdx} = Value;
			g_strctParadigm.(strVarName).TimeStamp(g_strctParadigm.(strVarName).BufferIdx) = fCurrTime;
		else
			if g_strctParadigm.(strVarName).BufferIdx+1 > sz(end)
				g_strctParadigm.(strVarName).Buffer(:,:,sz*2) = 0;
				g_strctParadigm.(strVarName).TimeStamp(sz*2) = 0;
			end
			g_strctParadigm.(strVarName).BufferIdx = g_strctParadigm.(strVarName).BufferIdx + 1;
			g_strctParadigm.(strVarName).Buffer(:,:,g_strctParadigm.(strVarName).BufferIdx) = Value;
			g_strctParadigm.(strVarName).TimeStamp(g_strctParadigm.(strVarName).BufferIdx) = fCurrTime;
		end
	
	case 'g_strctDAQParams'
		sz = size(g_strctDAQParams.(strVarName).Buffer);
		if iscell(g_strctDAQParams.(strVarName).Buffer)

			if g_strctDAQParams.(strVarName).BufferIdx+1 > sz(end)
				g_strctDAQParams.(strVarName).Buffer{sz*2} = [];
				g_strctDAQParams.(strVarName).TimeStamp(sz*2) = 0;
			end
			g_strctDAQParams.(strVarName).BufferIdx = g_strctDAQParams.(strVarName).BufferIdx + 1;
			g_strctDAQParams.(strVarName).Buffer{g_strctDAQParams.(strVarName).BufferIdx} = Value;
			g_strctDAQParams.(strVarName).TimeStamp(g_strctDAQParams.(strVarName).BufferIdx) = fCurrTime;
		else
			if g_strctDAQParams.(strVarName).BufferIdx+1 > sz(end)
				g_strctDAQParams.(strVarName).Buffer(:,:,sz*2) = 0;
				g_strctDAQParams.(strVarName).TimeStamp(sz*2) = 0;
			end
			g_strctDAQParams.(strVarName).BufferIdx = g_strctDAQParams.(strVarName).BufferIdx + 1;
			g_strctDAQParams.(strVarName).Buffer(:,:,g_strctDAQParams.(strVarName).BufferIdx) = Value;
			g_strctDAQParams.(strVarName).TimeStamp(g_strctDAQParams.(strVarName).BufferIdx) = fCurrTime;
		end

		

end

return;
