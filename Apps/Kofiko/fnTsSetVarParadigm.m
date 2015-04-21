function fnTsSetVarParadigm(strVarName, NewValue)
global g_strctParadigm
eval(['iLastEntry = g_strctParadigm.',strVarName,'.BufferIdx;']);

eval(['Buf = g_strctParadigm.',strVarName,'.Buffer;']);
sz = size(Buf);
iBufferSize = sz(end);
if iLastEntry+1 > iBufferSize
    eval(['g_strctParadigm.',strVarName,' = fnIncreaseBufferSize(g_strctParadigm.',strVarName,');']);
end;
if iscell(Buf) %iscell(NewValue)
    eval(['g_strctParadigm.',strVarName,'.Buffer{iLastEntry+1} = NewValue;']);
else
    eval(['g_strctParadigm.',strVarName,'.Buffer(:,:,iLastEntry+1) = NewValue;']);
end
eval(['g_strctParadigm.',strVarName,'.TimeStamp(iLastEntry+1) = GetSecs();']);
eval(['g_strctParadigm.',strVarName,'.BufferIdx = iLastEntry+1;']);
return;

