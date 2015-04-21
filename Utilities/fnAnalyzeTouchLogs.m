strctKofiko=load('D:\Data\Doris\Behavior\LogsFromTouch\RoccoHoudini\100926_110229_Houdini.mat');
strParadigm = 'Touch Screen Training';
iParadigmIndex = fnFindParadigmIndex(strctKofiko,strParadigm);

strctKofiko.g_astrctAllParadigms{iParadigmIndex}.