try
    fclose(s2);
catch
end
s2 = serial('COM20','BaudRate',115200,'DataBits',7);
fopen(s2)
buf = [];
figure(1);
clf;
AllData = zeros(0,3);
while(1)
      while (s2.BytesAvailable)
        X=[buf;fread(s2,s2.BytesAvailable)];
        firstindex = find(X==10,1,'first');
        X=X(firstindex+1:end);
        
        lastindex = find(X==10,1,'last');
        if isempty(lastindex)
            buf = [buf;X];
            continue;
        end
        buf = X(lastindex:end);
        
        Y=char(X(1:lastindex)');
        z=textscan(Y,'%d %d %d'); %%d
        TimeStamp=z{1};
        Analog=z{2};
        Digital=z{3};
        n1=length(Analog);
        n2=length(TimeStamp);
        n3=length(Digital);
        
        if (n1==n2  && n2 == n3&& n1 > 0) % 
            AllData = [AllData; [TimeStamp,Analog,Digital]]; %
            if size(AllData,1) > 1000
                plot(AllData(end-1000:end,2));
                title(num2str(TimeStamp(end)));
                set(gca,'ylim',[0 1024]);
                drawnow
            end
        end
        
      end
        
end
fclose(s2);
close all