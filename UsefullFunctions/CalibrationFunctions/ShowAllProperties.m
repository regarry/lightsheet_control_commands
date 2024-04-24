function [] = ShowAllProperties( mmc, label )
%SHOWALLPROPERTIES Summary of this function goes here
    prop = mmc.getDevicePropertyNames(label);
    for ii = 1:(prop.size-1)
        prop2 = prop.get(ii);
        cmd = ['val = mmc.getProperty(''',label,''',','''',char(prop2),''');'];
        eval(cmd);
        display(['Name = ',char(prop2),' Value = ',char(val)]);
    end
end

