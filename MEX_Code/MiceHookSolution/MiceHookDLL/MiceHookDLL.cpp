// MiceHookDLL.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "raw_mouse.h"
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <tchar.h>


extern "C"
{
    __declspec(dllexport) int DisplayHelloFromMyDLL()
    {
		return 5;
    }




#define WM_INPUT 0x00FF
#define MAX(a,b)((a)>(b)?(a):(b))

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
   PMSLLHOOKSTRUCT p = (PMSLLHOOKSTRUCT) lParam;
   return CallNextHookEx(NULL, nCode, wParam, lParam);	
}


bool fnHook()
{
	HWND         hwndMain;        /* Handle for the main window. */
	MSG          msg;             /* A Win32 message structure. */
	WNDCLASSEX   wndclass;        /* A window class structure. */
	LPCWSTR        szMainWndClass = L"MyWind";
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
//		printf("RawInput not supported by Operating System.  Exiting.\n");
		return false;
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
	return true;
}



DWORD CALLBACK Thread(LPVOID pVoid)
{
	fnHook();
	return 0;
}

__declspec(dllexport) void API_Init()
{
	if (threadId > 0) {
		printf("Init called twice before a Release was called. Trying to release first......\n");
		PostThreadMessage(threadId, WM_QUIT, 0, 0);
		Sleep(1000);
	}

	CloseHandle(CreateThread(NULL, 0, Thread, NULL, 0, &threadId));
	Sleep(200); // allow for thread to start.
	return;
}

__declspec(dllexport) void API_Hook(int iNumHooks, int *aiHookArray)
{
	for (int k=0; k < iNumHooks ;k++)
		HookMiceArray[aiHookArray[k]] = true;
}


__declspec(dllexport) void API_Release()
{
	if (threadId > 0) {
		PostThreadMessage(threadId, WM_QUIT, 0, 0);
		threadId = 0;
	}
}

__declspec(dllexport) void API_Unhook(int iNumHooks, int *aiHookArray)
{
	for (int k=0; k < iNumHooks ;k++)
		HookMiceArray[aiHookArray[k]] = false;
}


__declspec(dllexport) int API_GetNumMice()
{
	if (threadId == 0) {
		printf("Call The Init Function First!\n");
		return -1;
	}
	return raw_mouse_count();
}

	
__declspec(dllexport) int __stdcall API_GetMouseName(int k, char* lpBuffer)
{
    
  return get_raw_mouse_name(k,lpBuffer);
 

}

__declspec(dllexport) ULONG __stdcall API_GetMouseWheel(int k)
{
	if (threadId == 0) 
		return -1;

	ULONG Z = get_raw_mouse_z_delta(k);
	return Z;//(Z > 4294967295/2) ? (Z)-4294967295 : Z;
}

	/*
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
	

*/


}