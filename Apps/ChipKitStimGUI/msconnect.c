/************************************************************
 *
 * Name:   msconnect.c
 *
 * Author: Steven Michael (smichael@ll.mit.edu)
 *
 * Date:   5/19/06
 *
 * Description:
 *
 *  This is part of the "msocket" suite of TCP/IP 
 *  funcitons for MATLAB.  It is a wrapper for the
 *  "connect" socket function call.
 *
 * Copyright (c) 2006 MIT Lincoln Laboratory
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, 
 * Boston, MA  02110-1301  USA
 *
 ************************************************************/



#include <mex.h>
#include <string.h>

#include <winsock2.h>

static int initialized = 0;
static void initialize_sockets(void)
{
  WSADATA data;
  WORD version = 0x101;
  WSAStartup(version,&data);
  initialized = 1;
  return;
}

void mexFunction(int nlhs, mxArray *plhs[],
								int nrhs, const mxArray *prhs[])
{
	int *sock;
	struct hostent *hp;
	struct sockaddr_in pin;
	char *hostname;
	int port;
	struct timeval tv;
	int one = 1;
        int timeout_sec = 5;
        
#if defined(WIN32)
  if(!initialized) initialize_sockets();
#endif

	/* Go ahead and create the output socket */
	plhs[0] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
	sock = (int *)mxGetPr(plhs[0]);
	sock[0] = -1;

	/* Verify the input */
	if(nrhs < 2) {
		mexPrintf("Must input a hostname and a port\n");
		return;
	}
	if(!mxIsNumeric(prhs[1])) {
		mexPrintf("Port must be numeric.\n");
		return;
	}
	if(!mxIsChar(prhs[0])) {
		mexPrintf("Hostname must be a string.\n");
		return;
	}
	if(nrhs > 2) {
        
        timeout_sec = (int) mxGetScalar(prhs[2]);
	}
    
	
	/* Get the input */
	port = (int) mxGetScalar(prhs[1]);
	hostname = mxArrayToString(prhs[0]);

	memset(&pin,0,sizeof(pin));
	pin.sin_family = AF_INET;
	pin.sin_port = htons(port);
	if((hp = gethostbyname(hostname))!=0) 
		pin.sin_addr.s_addr = 
			((struct in_addr *)hp->h_addr)->s_addr;
	else 
		pin.sin_addr.s_addr = inet_addr(hostname);
	
	if((sock[0] = (int)socket(AF_INET,SOCK_STREAM,0)) == -1) { // SOCK_DGRAM,
		perror("socket");
		return;
	}

    // Added by Shay:
    
    setsockopt(sock[0],IPPROTO_TCP,TCP_NODELAY,(const char *)&one,sizeof(int));
//     tv.tv_sec = timeout_sec;  /* 30 Secs Timeout */
//     setsockopt(sock[0], SOL_SOCKET, SO_RCVTIMEO,(char *)&tv,sizeof(struct timeval));
    
	if(connect(sock[0],(const struct sockaddr *)&pin,sizeof(pin))) {
		perror("connect");
#if !defined(WIN32)
		close(sock[0]);
#else
		closesocket(sock[0]);
#endif
		sock[0] = -1;
		return;
	}
	return;
} /* end of mexFunction */
