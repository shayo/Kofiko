



// code excerpt

int PortNumber = int(*(double*)mxGetData(prhs[1]));
double *array_ptr = mxGetPr(prhs[2]);
uInt64 numElementsToWrite = int(*(double*)mxGetData(prhs[3]));

DAQmxCfgSampClkTiming(digitalTasks[PortNumber], NULL, 10000, DAQmx_Val_Rising, DAQmx_Val_FiniteSamps, numElementsToWrite);
DAQmxCfgOutputBuffer(digitalTasks[PortNumber], numElementsToWrite);
DAQmxCfgImplicitTiming(digitalTasks[PortNumber],DAQmx_Val_FiniteSamps,numElementsToWrite);

DAQmxWriteRaw(digitalTasks[PortNumber], numElementsToWrite, false, -1, array_ptr, NULL, NULL);
DAQmxStartTask(digitalTasks[PortNumber]);
		