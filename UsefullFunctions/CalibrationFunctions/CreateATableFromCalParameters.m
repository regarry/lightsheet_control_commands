function [ tableDetPos, tableExtPos, tableXPos] = CreateATableFromCalParameters( ScanCalibrationParameters, writeFiles )
    
    if (nargin < 2)
        writeFiles = false;
    end
        
    howManyColumnsToAdd = 50;
    tableDetPos = NaN(numel(ScanCalibrationParameters),numel(ScanCalibrationParameters{1})+howManyColumnsToAdd);
    tableDetPos(:,1) = 1:numel(ScanCalibrationParameters);
    tableExtPos = NaN(numel(ScanCalibrationParameters),numel(ScanCalibrationParameters{1})+howManyColumnsToAdd);
    tableExtPos(:,1) = 1:numel(ScanCalibrationParameters);
    tableXPos = NaN(numel(ScanCalibrationParameters),numel(ScanCalibrationParameters{1})+howManyColumnsToAdd);
    tableXPos(:,1) = 1:numel(ScanCalibrationParameters);
    
    for ii = 1:numel(ScanCalibrationParameters)
        for jj = 1:numel(ScanCalibrationParameters{ii})
            if (~isempty(ScanCalibrationParameters{ii}))
                tableDetPos(ii, jj+1) = ScanCalibrationParameters{ii}(jj).posDetLens;
                tableExtPos(ii, jj+1) = ScanCalibrationParameters{ii}(jj).posExtLens;
                tableXPos(ii,jj+1) = ScanCalibrationParameters{ii}(jj).sampleXPos;
            end
        end
   end 
    
   if (writeFiles)    
    filename = 'PosDetCalibration.xlsx';
    xlswrite(filename,tableDetPos,1);
   
    filename = 'PosExtCalibration.xlsx';
    xlswrite(filename,tableExtPos,1); 
    
    filename = 'PosXCalibration.xlsx';
    xlswrite(filename,tableXPos,1); 
    
   end
end

