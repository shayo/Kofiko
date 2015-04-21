/*
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
 * // Based on Alain Trostel's code.
*/

#include <windows.h>
#include "mex.h"

/* interface between MATLAB and the C function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* declare variables */
	HWND hWnd;
	long nStyle;
	int strLength;
	char *windowname, command[256];

	/* length of the string */
	strLength = mxGetN(prhs[0])+1;
	/* allocate memory for the window name */
	/* MATLAB frees the allocated memory automatically */
	windowname = new char[strLength];
	/* copy the variable from MATLAB */
	mxGetString(prhs[0],windowname,strLength);

	mxGetString(prhs[1],command,mxGetN(prhs[1])+1);
	
	hWnd = FindWindow(NULL,windowname);
	nStyle = GetWindowLong(hWnd,GWL_STYLE);

	if (strcmpi(command,"show") == 0) {
		ShowWindow(hWnd,SW_SHOW);
	}
	if (strcmpi(command,"hide") == 0) {
		ShowWindow(hWnd,SW_HIDE);
	}

	/* redraw the menu bar */
	DrawMenuBar(hWnd);
	delete [] windowname;
}
