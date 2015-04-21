function allFields = parseXMLstructure(node)
% make the tree "flat" and return the path to each leaf.

allFields = parseXMLstructureRecursive(node, node.Name,cell(0));

function allFields = parseXMLstructureRecursive(node, rootName,allFields)
if length(node.Children) == 1 && strcmp(node.Children.Name,'#text')
    % leaf : end of tree
    allFields = [allFields, sprintf('%s = %s',rootName,node.Children.Data)];
    return;
end
origRootName=rootName;
for childIter=1:length(node.Children)
    childNode = node.Children(childIter);
    
    nameChange = false;
    rootName = origRootName;
    for attributeIter=1:length(childNode.Attributes)
        if strcmpi(childNode.Attributes(attributeIter).Name,'name') && ~isempty(childNode.Children)
            rootName = [origRootName,'=>',childNode.Name,'=>',childNode.Attributes(attributeIter).Value];
            nameChange = true;
        end
    end
     
   for attributeIter=1:length(childNode.Attributes)
        allFields = [allFields, sprintf('%s=>%s=>%s = %s',origRootName, childNode.Name, childNode.Attributes(attributeIter).Name, childNode.Attributes(attributeIter).Value)];
    end  
    
    if ~isempty(childNode.Children)
        if (nameChange)
            allFields = parseXMLstructureRecursive(childNode, rootName,allFields);
        else
            allFields = parseXMLstructureRecursive(childNode, [rootName,'=>',childNode.Name],allFields);
        end
    end
end
return;
