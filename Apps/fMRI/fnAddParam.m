function acParams = fnAddParam(acParams, strName,strValue)
strctNewParam.Name = strName;
strctNewParam.Value = strValue;
acParams{end+1} = strctNewParam;
return;
