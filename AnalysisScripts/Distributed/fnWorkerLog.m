function fnWorkerLog(varargin)
global g_hLogFileID

strCurrentDateTime = datestr(now);
strCurrentDateTime(strCurrentDateTime == ':') = '.';
strFormattedMessage = [strCurrentDateTime, ' ',sprintf(varargin{:})];
if strFormattedMessage(end) == '\n'
    strFormattedMessage = strFormattedMessage(1:end-1);
end;
fprintf('%s\n',strFormattedMessage);
if ~isempty(g_hLogFileID)
    fprintf(g_hLogFileID,'%s\r\n',strFormattedMessage);
end;
return;