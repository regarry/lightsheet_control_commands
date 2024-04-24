function I_rgb = DrawRectangle(I, LeftUpPoint, RightBottomPoint,LineWidth)
% example  I_rgb = ShowEnlargedRectangle(I, [10,20], [50,60], 1)
 
if size(I,3)==1
    I_rgb(:,:,1) = I;
    I_rgb(:,:,2) = I;
    I_rgb(:,:,3) = I;
else
    I_rgb = I;
end
 
if ~exist('LineWidth','var')
    LineWidth = 1;
end
 
UpRow = LeftUpPoint(1);
LeftColumn = LeftUpPoint(2);
BottomRow = RightBottomPoint(1);
RightColumn = RightBottomPoint(2);
 
% ???
I_rgb(UpRow:UpRow + LineWidth ,LeftColumn:RightColumn,1) = 65525;
I_rgb(UpRow:UpRow + LineWidth ,LeftColumn:RightColumn,2) = 0;
I_rgb(UpRow:UpRow + LineWidth ,LeftColumn:RightColumn,3) = 0;
% ???
I_rgb(BottomRow:BottomRow + LineWidth ,LeftColumn:RightColumn,1) = 65525;
I_rgb(BottomRow:BottomRow + LineWidth ,LeftColumn:RightColumn,2) = 0;
I_rgb(BottomRow:BottomRow + LineWidth ,LeftColumn:RightColumn,3) = 0;
% ???
I_rgb(UpRow:BottomRow,LeftColumn:LeftColumn + LineWidth ,1) = 65525;
I_rgb(UpRow:BottomRow,LeftColumn:LeftColumn + LineWidth ,2) = 0;
I_rgb(UpRow:BottomRow,LeftColumn:LeftColumn + LineWidth ,3) = 0;
% ???
I_rgb(UpRow:BottomRow,RightColumn:RightColumn + LineWidth ,1) = 65525;
I_rgb(UpRow:BottomRow,RightColumn:RightColumn + LineWidth ,2) = 0;
I_rgb(UpRow:BottomRow,RightColumn:RightColumn + LineWidth ,3) = 0;
 
end
