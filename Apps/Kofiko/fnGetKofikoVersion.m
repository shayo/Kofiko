function [strctVersion] = fnGetKofikoVersion()

strctVersion.m_strMajorVersion = '2.0';
strctVersion.m_strRevisionNumber= 'unknown revision';

try
    strCmd = '.\MEX\win32\svn32.exe info';
    [Dummy, strResult]=system(strCmd);
    acRes = fnSplitString(strResult, 10);
    for k=1:length(acRes)
        if strncmpi(acRes{k},'Revision',length('Revision'))
            strctVersion.m_strRevisionNumber= acRes{k};
        end
    end
catch
end
return;

