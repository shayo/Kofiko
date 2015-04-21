function [acParams,acStems,acPresets] = fnReadParamsFromXML(strXMLFile)
strctXML = xml2struct(strXMLFile);
acParams = {};
acStems = {};
acPresets = {};

for k=1:length(strctXML)
    if strcmpi(strctXML(k).Name,'Config')
        for j=1:length(strctXML(k).Children)
            if strcmpi(strctXML(k).Children(j).Name,'Vars')
                
                for i=1:length(strctXML(k).Children(j).Children)
                    if strcmpi(strctXML(k).Children(j).Children(i).Name,'m_strctParam')
                        strctParams = fnExtractParam(strctXML(k).Children(j).Children(i).Attributes);
                        acParams{end+1}=strctParams;
                    end
                end
            end
            
            
            if strcmpi(strctXML(k).Children(j).Name,'FunctionalStems')
                 for i=1:length(strctXML(k).Children(j).Children)
                    if strcmpi(strctXML(k).Children(j).Children(i).Name,'m_strctStem')
                        strctParams = fnExtractParam(strctXML(k).Children(j).Children(i).Attributes);
                        acStems{end+1}=strctParams;
                    end
                end
            end
            
           if strcmpi(strctXML(k).Children(j).Name,'ParamPreset')
                 for i=1:length(strctXML(k).Children(j).Children)
                    if strcmpi(strctXML(k).Children(j).Children(i).Name,'m_strctPreset')
                        strctParams = fnExtractParam(strctXML(k).Children(j).Children(i).Attributes);
                        acPresets{end+1}=strctParams;
                    end
                end
            end
            
            
        end
    end
end

return;

function strctParam = fnExtractParam(astrctAttributes)
strctParam = struct;
for k=1:length(astrctAttributes)
    strctParam=setfield(strctParam,astrctAttributes(k).Name,astrctAttributes(k).Value);
end
