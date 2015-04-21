strPassword = input('Enter password:','s');
channel  =  sshfrommatlab('shayo','neurologin.caltech.edu',strPassword)
[channel, result]  =  sshfrommatlabissue(channel,'ls')
channel  =  sshfrommatlabclose(channel)