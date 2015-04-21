////////////////////////////////////////////////////////////
//
// Name:   mscheckbuf.cpp
//
// Author: Shay Ohayon
//
// Date:   9/26/09
//
// Description:
//
//    Checks the socket recv buffer. Based on Msocket code
//
////////////////////////////////////////////////////////////

#include <mex.h>

#include <winsock2.h>

void mexFunction(int nlhs, mxArray *plhs[],
  			     int nrhs, const mxArray *prhs[])
{
	int sock = -1;
	int ret;
	double timeout = -1;
	fd_set readfds,writefds,exceptfds;

	if(nrhs < 1) {
		mexPrintf("Must input a socket\n");
		return;
	}
	if(!mxIsNumeric(prhs[0])) {
		mexPrintf("First argument must be a socket.\n");
		return;
	}
	sock = (int)mxGetScalar(prhs[0]);

	FD_ZERO(&readfds);
	FD_ZERO(&writefds);
	FD_ZERO(&exceptfds);
	FD_SET(sock,&readfds);
	FD_SET(sock,&exceptfds);

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    select(sock+1,&readfds,&writefds,&exceptfds,&tv);
    plhs[0] = mxCreateNumericMatrix(1,1,mxDOUBLE_CLASS,mxREAL);
	double *Out = (double*)mxGetPr(plhs[0]);
	
	if(FD_ISSET(sock,&readfds)==0) {
        // Nothing in buffer
		*Out = 0;
	} else {
        // Something in buffer
		*Out = 1;
    }
    
}
