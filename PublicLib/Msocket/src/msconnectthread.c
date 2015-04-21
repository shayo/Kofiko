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
	int one = 1;

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
