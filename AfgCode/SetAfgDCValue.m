%This function writes a DC value to the AFG
%The input is in mv

function [dcValueAfterWrite] = SetAfgDCValue(afg, dcValue )

    %fwrite(afg, ':output1 off;');
    %query(afg, ':source1:voltage?');
    
    %Change the state to DC
    fwrite(afg, ':source1:function DC');
    fwrite(afg, [':source1:voltage:offset ',num2str(dcValue),'mv']);
    dcValueAfterWrite = query(afg, ':source1:voltage:offset?');
    fwrite(afg, ':output1 on;');    
    
    fwrite(afg, ':source2:function DC');
    fwrite(afg, [':source2:voltage:offset ',num2str(dcValue),'mv']);
    %dcValueAfterWrite = query(afg, ':source2:voltage:offset?');
    fwrite(afg, ':output2 on;');

end




