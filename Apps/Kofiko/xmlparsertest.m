structconfig = fnMyXMLToStruct('viewdirectionforcechocie.xml',false);
%for i=1:numel(structconfig)
    %disp(structconfig.(fields{i}))
%end
%savefile
disp(structconfig.TrialTypes.Trial{1,1}.TrialParams)
if 0
disp('getfield test')
n = getfield(structconfig.TrialTypes.Trial, {1});
disp(n)

disp(fieldnames(structconfig.TrialTypes))
disp('trialtypes')
disp(structconfig.TrialTypes.Trial(1))
disp('trialorder')
disp(structconfig.TrialOrder(1))
disp(structconfig.TrialOrder)
end
%celldisp(structconfig.TrialOrder)
%structconfig = 
%cellData = struct2cell(structconfig);         
%fprintf('%15s (%s): %d\n',cellData{:});  %# Print the data