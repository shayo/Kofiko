#include <mex.h>
#include <math.h>


#include <winsock2.h>

void mexFunction(int nlhs, mxArray *plhs[],
								 int nrhs, const mxArray *prhs[])
{
	int sock = -1;
	int recvlen = -1;
	int cnt = 0;
	int ret;
	char *cdata = (char *)0;
	double timeout = -1;
	fd_set readfds,writefds,exceptfds;

	if(nrhs < 2) {
		mexPrintf("Must input a socket and a length\n");
		return;
	}
	if(!mxIsNumeric(prhs[0]) || !mxIsNumeric(prhs[1])) {
		mexPrintf("Invalid arguments.\n");
		return;
	}
	if(nrhs > 2) {
		if(!mxIsNumeric(prhs[2])) {
			mexPrintf("3rd argument (timeout in s) must be numeric.\n");
			return;
		}
		timeout = mxGetScalar(prhs[2]);
	}

	sock = (int)mxGetScalar(prhs[0]);
	recvlen = (int) mxGetScalar(prhs[1]);

	plhs[0] = mxCreateNumericMatrix(recvlen,1,mxUINT8_CLASS,mxREAL);
	cdata =  (char *)mxGetPr(plhs[0]);

	while(cnt < recvlen) {
		FD_ZERO(&readfds);
		FD_ZERO(&writefds);
		FD_ZERO(&exceptfds);
		FD_SET(sock,&readfds);
		FD_SET(sock,&exceptfds);

		if(timeout < 0)
			select(sock+1,&readfds,&writefds,&exceptfds,(struct timeval *)0);
		else {
			struct timeval tv;
			tv.tv_sec = (int) timeout;
			tv.tv_usec = (int) (fmod(timeout,1.0)*1.0E6);
			select(sock+1,&readfds,&writefds,&exceptfds,&tv);
		}
		if(FD_ISSET(sock,&readfds)==0) {
			plhs[0] = mxCreateNumericMatrix(0,0,mxCHAR_CLASS,mxREAL);
			if(nlhs > 1)
				plhs[1] = mxCreateDoubleScalar(-1.0f);
			return;
			mxFree(cdata);
		}
		
		ret = recv(sock,cdata+cnt,recvlen-cnt,0);
		if(ret == -1) {
			cdata[0] = '\0';
			if(nlhs > 1)
				plhs[1] = mxCreateDoubleScalar(-1.0);
			return;
		}
		cnt += ret;
	} /* end of while */
	
	if(nlhs > 1)
		plhs[1] = mxCreateDoubleScalar(0.0);
		
	return;
} /* end of mexFunction */
