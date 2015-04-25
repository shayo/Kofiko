function bufferedWriteTest()

fnDAQNIBufferTest('Init',0)
tic
fnDAQNIBufferTest('DigitalBufferTest',7,[ones(40000000,1)],40000000)
toc
fnDAQNIBufferTest('Reset',0);





return;