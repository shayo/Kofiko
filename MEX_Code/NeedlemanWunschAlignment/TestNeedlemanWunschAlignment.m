 A =randn(1,10000);%[50,30,40,20];
 B = A(200:400);
 
 addpath('Z:\MEX\x64');
fMatchWeight = 2;
fDeleteWeight = -1;
fMismatchWeight = -3;
Jitter = 0.0001;
 
[AtoB, BtoA, AlignmentA, AlignmentB] = fnNeedlemanWunschAlignment(A,B,fMatchWeight,fDeleteWeight,fMismatchWeight,Jitter ) ;

figure(11);
clf;hold on;
plot(AlignmentA,'b.');
plot(AlignmentB,'ro');
