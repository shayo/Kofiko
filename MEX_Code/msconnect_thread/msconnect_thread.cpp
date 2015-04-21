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

void fnPrintUsage()
{
	mexPrintf("Usage:\n");
	mexPrintf("hThreadID = msconnect_thread('StartConnectThread', '192.168.50.96','8000')\n");
    mexPrintf("msconnect_thread('StoptConnect',hThreadID)\n");
    mexPrintf("[hSocket]=msconnect_thread('IsConnected(hThreadID))\n");
}

typedef struct {
    struct sockaddr_in pin;
    int sock;
    bool bConnected;
	HANDLE ThreadID;
} SocketData ;

DWORD WINAPI MyThreadFunction( LPVOID lpParam )  {
        SocketData *sd = (SocketData*) lpParam;

		
    while (1) {
        if(connect(sd->sock,(const struct sockaddr *)&sd->pin,sizeof(sd->pin)) == 0) {
            break;
        }   
    }
    // We are connected, so we the thread can die....
	sd->bConnected = true;
	return 0;
}


SocketData*   StartConnectionThread(char* hostname, int port)  {

   SocketData* sd = new SocketData;

	sd->bConnected = false;
    struct hostent *hp;
	int one = 1;

 	memset(&sd->pin,0,sizeof(sd->pin));
	sd->pin.sin_family = AF_INET;
	sd->pin.sin_port = htons(port);

	if((hp = gethostbyname(hostname))!=0) 
		sd->pin.sin_addr.s_addr = ((struct in_addr *)hp->h_addr)->s_addr;
	else 
		sd->pin.sin_addr.s_addr = inet_addr(hostname);
	
	if((sd->sock = (int)socket(AF_INET,SOCK_STREAM,0)) == -1) {
		perror("Cannot create socket?!?!?");
		return 0;
	}

     setsockopt(sd->sock,IPPROTO_TCP,TCP_NODELAY,(const char *)&one,sizeof(int));
	
     sd->ThreadID = CreateThread( 
            NULL,                   // default security attributes
            0,                      // use default stack size  
            MyThreadFunction,       // thread function name
            (void*) sd,          // argument to thread function 
            0,                      // use default creation flags 
            NULL);   // returns the thread identifier 

	return sd;
}
        
void mexFunction(int nlhs, mxArray *plhs[],
								int nrhs, const mxArray *prhs[])
{
	
	struct hostent *hp;
		char *hostname;
	int port;
	int one = 1;

   if(!initialized) initialize_sockets();
    
	if (nrhs < 1) {
		fnPrintUsage();
		return;
	}
	

	int StringLength = int(mxGetNumberOfElements(prhs[0])) + 1;
	char* Command = (char*)mxCalloc(StringLength, sizeof(char));

	if (mxGetString(prhs[0], Command, StringLength) != 0){
		mexErrMsgTxt("\nError extracting the command.\n");
		return;
	}

	if   (strcmp(Command, "StartConnectThread") == 0)  {
        	/* Get the input */
			hostname = mxArrayToString(prhs[1]);
            port = (int) mxGetScalar(prhs[2]);
            SocketData* sd=  StartConnectionThread(hostname,port);
	        plhs[0] = mxCreateNumericMatrix(1,1,mxDOUBLE_CLASS,mxREAL);
			double* Tmp= (double*)mxGetPr(plhs[0]);
			memcpy(Tmp, &sd, 8);
			//*Tmp = (void*)&sd;
    }
    
    
    if   (strcmp(Command, "IsConnected") == 0)  {
		double* Tmp= (double*)mxGetPr(prhs[1]);
		SocketData* sd;
        memcpy(&sd, Tmp, 8);
		plhs[0] = mxCreateNumericMatrix(1,1,mxDOUBLE_CLASS,mxREAL);
		double* Out= (double*)mxGetPr(plhs[0]);
		if (sd->bConnected)
			*Out = sd->sock;
		else
			*Out = -1;
		}
			
   

	if   (strcmp(Command, "StopThread") == 0)  {
		double* Tmp= (double*)mxGetPr(prhs[1]);
		SocketData* sd;
		memcpy(&sd, Tmp, 8);
		CloseHandle(sd->ThreadID);
		delete sd;
	}

	return;
} /* end of mexFunction */
