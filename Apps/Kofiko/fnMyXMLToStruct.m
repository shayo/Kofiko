function [strctConfig,strctRAW] = fnMyXMLToStruct(strXMLFile,bWarning,bAugmentDepth)
global g_bWarning 
if ~exist('bWarning','var')
    g_bWarning = true;
end;
if ~exist('bAugmentDepth','var')
    bAugmentDepth = false;
end

strctRAW = xml2struct(strXMLFile);
strctConfig = fnRecursiveParse(strctRAW,[],'strctConfig',0,bAugmentDepth,0);
clear global g_bWarning 
return;


