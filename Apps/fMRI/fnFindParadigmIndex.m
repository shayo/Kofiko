function iParadigmIndex = fnFindParadigmIndex(strctKofiko, strParadigmName)
iParadigmIndex = [];
for k=1:length(strctKofiko.g_astrctAllParadigms)
    if strcmp(strctKofiko.g_astrctAllParadigms{k}.m_strName, strParadigmName)
        iParadigmIndex = k;
        break;
    end;
end;
%assert(iParadigmIndex ~= -1);
return;
