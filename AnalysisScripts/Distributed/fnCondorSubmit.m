function fnCondorSubmit(strCondorJobFileName)
aiSlash = find(strCondorJobFileName=='\');
strJobPath = strCondorJobFileName(1:aiSlash(end));
strCurrentDir = cd;
cd(strJobPath);
system('condor_submit job.txt');
cd(strCurrentDir);
