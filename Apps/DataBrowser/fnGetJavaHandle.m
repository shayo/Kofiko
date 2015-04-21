function hJTable=fnGetJavaHandle(hTable)
drawnow
h1=findjobj(hTable);
if isempty(h1)
    tic
    
    while toc < 2
        drawnow
    end
    h1=findjobj(hTable);
    if ~isempty(h1)
        h2=get(h1(2),'viewport');
        hJTable=get(h2,'view');
    else
        hJTable = [];
    end;
else
        h2=get(h1(2),'viewport');
        hJTable=get(h2,'view');
end

return;