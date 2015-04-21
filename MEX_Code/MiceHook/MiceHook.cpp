/*
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include "mex.h"

#define _WIN32_WINNT 0x501
#define WM_INPUT 0x00FF
#define MAX(a,b)((a)>(b)?(a):(b))
#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "raw_mouse.h"

int LastMouseIDEvent;
DWORD threadId = 0;

#define iMAXMICE 50

bool HookMiceArray[iMAXMICE];

LRESULT CALLBACK MainWndProc (HWND hwnd, UINT nMsg, WPARAM wParam, LPARAM lParam)
{
	switch (nMsg)
	{
	case WM_DESTROY:
		PostQuitMessage (0);
		return 0;
		break;
	case WM_INPUT: 
		{
			LastMouseIDEvent = add_to_raw_mouse_x_and_y((HRAWINPUT)lParam);
			return 0;
		} 
	}
	return DefWindowProc (hwnd, nMsg, wParam, lParam);
}


LRESULT CALLBACK mouseHookProc(int nCode, WPARAM wParam, LPARAM lParam) {
	static bool hasBeenEntered = false;
	if(hasBeenEntered)
	{
		//Prevent the mouse event being sent to other hook procs and the window procedure.
		//Might not be what you want.
		return 1;
	}
	hasBeenEntered = true;


   PMSLLHOOKSTRUCT p = (PMSLLHOOKSTRUCT) lParam;

   hasBeenEntered = false;

   if (HookMiceArray[LastMouseIDEvent]) 
	   return 1;
   
   
   return CallNextHookEx(NULL, nCode, wParam, lParam);	
}






void fnHook()
{
	HWND         hwndMain;        /* Handle for the main window. */
	MSG          msg;             /* A Win32 message structure. */
	WNDCLASSEX   wndclass;        /* A window class structure. */
	char*        szMainWndClass = "MyWind";
	memset (&wndclass, 0, sizeof(WNDCLASSEX));
	wndclass.lpszClassName = szMainWndClass;
	wndclass.cbSize = sizeof(WNDCLASSEX);
	wndclass.lpfnWndProc = MainWndProc;
	wndclass.hInstance = NULL;


	RegisterClassEx (&wndclass);
	hwndMain = CreateWindow (
		szMainWndClass,             /* Class name */
		NULL,                    /* Caption */
		NULL,        /* Style */
		CW_USEDEFAULT,              /* Initial x (use default) */
		CW_USEDEFAULT,              /* Initial y (use default) */
		CW_USEDEFAULT,              /* Initial x size (use default) */
		CW_USEDEFAULT,              /* Initial y size (use default) */
		HWND_MESSAGE,                       /* No parent window */
		NULL,                       /* No menu */
		NULL,                      /* This program instance */
		NULL                        /* Creation parameters */
		);

	ShowWindow (hwndMain, SW_SHOW);
	UpdateWindow (hwndMain);

	if (!init_raw_mouse(0, 0, 1,hwndMain)) { // registers for (sysmouse=yes,  terminal services mouse=no, HID_mice=yes)
		printf("RawInput not supported by Operating System.  Exiting.\n");
		return;
	}


   // Set mouse hook	
   HHOOK mouseHook = SetWindowsHookEx(
                  WH_MOUSE_LL,      
                  mouseHookProc,    
                  NULL,            
                  NULL);


	while (GetMessage (&msg, NULL, 0, 0))
	{
		TranslateMessage (&msg);
		DispatchMessage (&msg);
	}

	 UnhookWindowsHookEx(mouseHook);
	destroy_raw_mouse();

}



DWORD CALLBACK Thread(LPVOID pVoid)
{
	fnHook();
	return 0;
}

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

    static char buff[80+1];
    buff[0]=0;
 	mxGetString(prhs[0],buff,80);

 
	if (strcmp(buff,"Init") == 0) {

		//DWORD threadId;
		if (threadId > 0) {
			mexPrintf("Init called twice before a Release was called. Trying to release first......\n");
			PostThreadMessage(threadId, WM_QUIT, 0, 0);
			Sleep(1000);
		}

		CloseHandle(CreateThread(NULL, 0, Thread, NULL, 0, &threadId));
		
		//const unsigned int dim_array[2] = {1,1};
		//plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim_array, mxDOUBLE_CLASS, mxREAL);

		for (int k=0;k< iMAXMICE;k++) 
			HookMiceArray[k] = false;

		//double *buffer = (double*)mxGetPr(plhs[0]);
		//*buffer = threadId;
		return;
	}
	if (strcmp(buff,"Hook") == 0) {
			int iNumHooks = mxGetNumberOfElements(prhs[1]);
			double *aiHookArray = mxGetPr(prhs[1]);
			for (int k=0; k < iNumHooks ;k++)
				HookMiceArray[int(aiHookArray[k])] = true;
	}
	if (strcmp(buff,"Unhook") == 0) {
			int iNumHooks = mxGetNumberOfElements(prhs[1]);
			double *aiHookArray = mxGetPr(prhs[1]);
			for (int k=0; k < iNumHooks ;k++)
				HookMiceArray[int(aiHookArray[k])] = false;
	}


	if (strcmp(buff,"Release") == 0) {
		//DWORD threadId =  (DWORD) (*(double*)mxGetPr(prhs[1]));
		if (threadId > 0) {
			PostThreadMessage(threadId, WM_QUIT, 0, 0);
			threadId = 0;
		} else {
			mexPrintf("Nothing To Release. Init was not called...\n");
		}
		return;
	}
	
	if (strcmp(buff,"GetMiceName") == 0) {
		int NumMice = raw_mouse_count();
		mwSize Dim[2] = {1,NumMice };
		mxArray *mxNames = mxCreateCellArray(2,Dim);
		for (int k=0;k<NumMice;k++) {
			char name[5000];
			int nSize = get_raw_mouse_name(k, name);
			mxSetCell(mxNames,k, mxCreateString(name));
		}
		plhs[0] = mxNames;
	}
	

	if (strcmp(buff,"GetNumMice") == 0) {
		
		const unsigned int dim_array[2] = {1,1};
		plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim_array, mxDOUBLE_CLASS, mxREAL);
		double *buffer = (double*)mxGetPr(plhs[0]);

		if (threadId == 0) {
			mexPrintf("Call The Init Function First!\n");
			*buffer =  -1;
		} else {
			*buffer =  raw_mouse_count();
		}

		return;
	}
	
	
	if (strcmp(buff,"GetMouseData") == 0) {
		int MouseIndex=  int(*(double*)mxGetPr(prhs[1]));
	
		const unsigned int dim_array[2] = {1,3};
		plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim_array, mxDOUBLE_CLASS, mxREAL);
		double *buffer = (double*)mxGetPr(plhs[0]);
		if (threadId == 0) { 
			mexPrintf("Call The Init Function First!\n");
			buffer[0] = 0;
			buffer[1] = 0;
			buffer[2] = 0;
		} else {
			buffer[0] = get_raw_mouse_x_delta(MouseIndex);
			buffer[1] = get_raw_mouse_y_delta(MouseIndex);
			buffer[2] = get_raw_mouse_z_delta(MouseIndex);
		}
		return;
	}
	if (strcmp(buff,"GetButtons") == 0) {

		double *MouseIndex=  (double*)mxGetPr(prhs[1]);
	
		const unsigned int dim_array[2] = {1,3};
		
		plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim_array, mxDOUBLE_CLASS, mxREAL);
		double *buffer = (double*)mxGetPr(plhs[0]);
		if (threadId == 0) {
			mexPrintf("Call The Init Function First!\n");
			for (int k=0;k<3;k++) {
				buffer[k] = 0;
			}

		} else  {
			for (int k=0;k<3;k++) {
				buffer[k] = is_raw_mouse_button_pressed(int(MouseIndex[k]),k);
			}
	    }
		return;
	}
	if (strcmp(buff,"GetWheels") == 0) {
		double *MouseIndex=  (double*)mxGetPr(prhs[1]);
		if (MouseIndex == NULL) {
			mwSize dim[2] = {0,0};
			plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim, mxDOUBLE_CLASS, mxREAL);
			return;
		}

		int NumEl = mxGetNumberOfElements(prhs[1]);
		mwSize dim[2] = {1,NumEl};
		plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim, mxDOUBLE_CLASS, mxREAL);
		double *buffer = (double*)mxGetPr(plhs[0]);
		if (threadId == 0) {
			mexPrintf("Call The Init Function First!\n");
			for (int k=0;k<MAX(dim[0],dim[1]);k++) {
				buffer[k] = 0;
			}

		} else  {
			for (int k=0;k<NumEl;k++) {
				ULONG Z = get_raw_mouse_z_delta(int(MouseIndex[k]));
				buffer[k] = double((Z > 4294967295/2) ? double(Z)-4294967295 : Z);
			}
	    }
		return;
	}


}
