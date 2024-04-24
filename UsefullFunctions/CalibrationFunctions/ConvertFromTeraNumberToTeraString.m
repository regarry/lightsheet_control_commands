%This function makes sure that the number is in a 5 digits format as
%required by tera stitcher
function [ teraStitcherConvensionString ] = ConvertFromTeraNumberToTeraString(teraStitcherConvensionNumber)

    teraStitcherConvensionNumberSTR = num2str(teraStitcherConvensionNumber);
    teraStitcherConvensionString = '000000';
    
               switch numel(teraStitcherConvensionNumberSTR)
                    case 1 
                        teraStitcherConvensionString(6) = teraStitcherConvensionNumberSTR;
                    case 2 
                        teraStitcherConvensionString(5:6) = teraStitcherConvensionNumberSTR;
                    case 3
                        teraStitcherConvensionString(4:6) = teraStitcherConvensionNumberSTR;
                    case 4   
                        teraStitcherConvensionString(3:6) = teraStitcherConvensionNumberSTR;
                    case 5   
                        teraStitcherConvensionString(2:6) = teraStitcherConvensionNumberSTR;
                    case 6 
                        teraStitcherConvensionString(1:6) = teraStitcherConvensionNumberSTR;
                end
            
end

