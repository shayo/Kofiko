function strTemplate=fnParseString(strTemplate, astrctExtraParse)
if isempty(strTemplate)
    return;
end;

astrctTable = fnGenerateStandardParsingTable();
astrctExtTable = [astrctTable,astrctExtraParse];
for k=1:length(astrctExtTable)
  strTemplate=strrep(strTemplate,  astrctExtTable(k).m_strTemplate,astrctExtTable(k).m_strValue);
end
return;


function astrctTable = fnGenerateStandardParsingTable()
astrctTable(1).m_strTemplate = '$USER';
[X,strUserName]=system('whoami');
astrctTable(1).m_strValue = strUserName(1:end-1);

astrctTable(2).m_strTemplate = '$CURR_YEAR';
astrctTable(2).m_strValue = datestr(now,'yyyy');

return;

    