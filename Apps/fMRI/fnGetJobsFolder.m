function strJobFolder=fnGetJobsFolder()
[Tmp,strUserName]=system('whoami');
strUserName=strUserName(1:end-1);
strJobFolder = sprintf('/home/%s/.jobs/',strUserName);
if ~exist(strJobFolder,'dir')
    mkdir(strJobFolder);
end;
return;
