////////////////////////////////////////////////////////////
//
// Name:   mssend.cpp
//
// Author: Steven Michael (smichael@ll.mit.edu)
//
// Date:   5/19/06
//
// Description:
//
//    This is part of the "msocket" suite of TCP/IP 
//    funcitons for MATLAB.  It is a wrapper for the
//    "send" socket function call. The data send is a serialized
//    MALTAB variable in a format described by matvar.cpp
//
// Copyright (c) 2006 MIT Lincoln Laboratory
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, 
// Boston, MA  02110-1301  USA
//
////////////////////////////////////////////////////////////
// mex mssend_nonblk.cpp matvar.obj -I. ws2_32.lib
#include <mex.h>

#include <matvar.h>

#include <winsock2.h>

void mexFunction(int nlhs, mxArray *plhs[],
								 int nrhs, const mxArray *prhs[])
{
	int *ret;
	int sock;
		fd_set readfds,writefds,exceptfds;

	if(nrhs < 2) {
		mexPrintf("Must input a socket and a variable.\n");
		return;
	}
	if(!mxIsNumeric(prhs[0])) {
		mexPrintf("First argument must be a socket.\n");
		return;
	}

	sock = (int)mxGetScalar(prhs[0]);

	plhs[0] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
	ret = (int *)mxGetPr(plhs[0]);

    FD_ZERO(&readfds);
	FD_ZERO(&writefds);
	FD_ZERO(&exceptfds);
	FD_SET(sock,&writefds);
	FD_SET(sock,&exceptfds);
    select(sock,&readfds,&writefds,&exceptfds,(struct timeval *)0);
	if(FD_ISSET(sock,&writefds)==0) {
		plhs[0] = mxCreateNumericMatrix(0,0,mxDOUBLE_CLASS,mxREAL);
		if(nlhs > 1)
			plhs[1] = mxCreateDoubleScalar(-1.0f);
		return;
	}    
    
	MatVar mv;
	mv.create(prhs[1]);
	int mvlen = mv.get_serialize_length();
	int smvlen = mvlen;
	
#ifdef _BIG_ENDIAN_
	unsigned char *tmp = (unsigned char *)&smvlen;
	unsigned char t;
	t = tmp[0];tmp[0] = tmp[3];tmp[3] = t;
	t = tmp[1];tmp[1] = tmp[2];tmp[2] = t;
#endif
	ret[0] = ::send(sock,(const char *)&smvlen,sizeof(int),0);
	if(ret[0] == -1) {
		perror("send");
		return;
	}

	int cnt = 0;
	char *cdata = new char[mvlen];
	mv.serialize(cdata);
	while(cnt < mvlen) {
        mexPrintf("Trying to send %d\n",mvlen-cnt);
		ret[0] = ::send(sock,cdata+cnt,mvlen-cnt,0);
        mexPrintf("Return value is %d\n",ret[0]);
		if(ret[0] == -1) {
			perror("send");
			delete[] cdata;
			return;
		}
		cnt += ret[0];
	}
	delete[] cdata;
	return;
} // end of mexFunction
