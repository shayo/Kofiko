#define _WIN32_WINNT 0x501
#define WM_INPUT 0x00FF

#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include "raw_mouse.h"

LRESULT CALLBACK
MainWndProc (HWND hwnd, UINT nMsg, WPARAM wParam, LPARAM lParam)
{
	switch (nMsg)
        {

        case WM_DESTROY:
		  PostQuitMessage (0);
		  return 0;
		  break;
		case WM_INPUT: 
		{
		  add_to_raw_mouse_x_and_y((HRAWINPUT)lParam);
		  return 0;
		} 
        }
        return DefWindowProc (hwnd, nMsg, wParam, lParam);
}

int APIENTRY 
WinMain (HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpCmd, int nShow)
{
         HWND         hwndMain;        /* Handle for the main window. */
        MSG          msg;             /* A Win32 message structure. */
        WNDCLASSEX   wndclass;        /* A window class structure. */
        char*        szMainWndClass = "MyWind";
        memset (&wndclass, 0, sizeof(WNDCLASSEX));
        wndclass.lpszClassName = szMainWndClass;
        wndclass.cbSize = sizeof(WNDCLASSEX);
        wndclass.lpfnWndProc = MainWndProc;
        wndclass.hInstance = hInst;


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
                hInst,                      /* This program instance */
                NULL                        /* Creation parameters */
                );
       
        ShowWindow (hwndMain, SW_SHOW);
        UpdateWindow (hwndMain);

	if (!init_raw_mouse(1, 0, 1,hwndMain)) { // registers for (sysmouse=yes,  terminal services mouse=no, HID_mice=yes)
	  MessageBox(NULL, L"RawInput not supported by Operating System.  Exiting." , L"Error!" ,MB_OK);
	  return 0; 
	}
        while (GetMessage (&msg, NULL, 0, 0))
        {
                TranslateMessage (&msg);
                DispatchMessage (&msg);
        }

	/* deallocate rawmouse stuff */
	destroy_raw_mouse();

    return msg.wParam;
}
