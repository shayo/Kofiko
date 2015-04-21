% Remote Access
iRemoteAccessPort = 2000;
iConnectionTimeOutSec = 5;
iDataTimeOut = 1;
iSocket = msconnect('Touch', iRemoteAccessPort, iConnectionTimeOutSec); 

mssend(iSocket, {'GetParadigm'});
[strctParadigm,iCommError]  = msrecv(iSocket, iDataTimeOut);
if iCommError == 0
    fprintf('Current active paradigm is : %s\n',strctParadigm.m_strName);

    
    % Clear buffer
    while (1)
        [Dummy,iCommError]  = msrecv(iSocket, 0);
        if iCommError < 0
            break;
        end
    end
    
    mssend(iSocket, {'SwitchParadigm','Touch Screen Training'});
    
 %   mssend(iSocket, {'ParadigmCallBack','LoadList','C:\Shay\Data\StimulusSet\TargetDetection\TargetDetectionShort.txt'});
    
    mssend(iSocket, {'JuicePulse'});
      mssend(iSocket, {'StartParadigm'});
    
      figure(1);
      clf;
while(1)
 
        % Clear buffer
        while (1)
            [Dummy,iCommError]  = msrecv(iSocket, 0);
            if iCommError < 0
                break;
            end
        end
        mssend(iSocket, {'getvideoframenow'});
        [a3iImage,iCommError]  = msrecv(iSocket, iDataTimeOut);
    
        imagesc(a3iImage);
        drawnow
        tic
        while toc < 0.2
        end
        
end
    
    mssend(iSocket, {'SwitchParadigm','Target Detection Touch'});
    [bOK,iCommError]  = msrecv(iSocket, iDataTimeOut);
    if bOK
        
    end
    
elseif iCommError == -2
    fprintf('Connection to Kofiko was lost\n');
end

mssend(iSocket, {'getvideoframe'});
[a3iFrame,iCommError]  = msrecv(iSocket, iDataTimeOut);


Trials = strctParadigm.acTrials.Buffer(1:strctParadigm.acTrials.BufferIdx);


msclose(iSocket)