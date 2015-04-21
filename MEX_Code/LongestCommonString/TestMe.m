addpath('D:\Code\Doris\Kofiko\Kofiko Current Version\MEX\x64');


% A = rand(1,10);
% B = [1,2,3,A,5,6,7]

load('C:\tmp');
    X=fnLongestCommonString(aiPlexonWords',aiKofikoWords');
    
    X = fnLongestCommonString(A,B);
assert( all(A(X(2):X(2)+X(1)-1)  == B(X(3):X(3)+X(1)-1)))
