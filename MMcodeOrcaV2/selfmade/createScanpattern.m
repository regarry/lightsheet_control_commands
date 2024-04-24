function [xyzScanArray]=createScanpattern(xPos,yPos,zPos,Vertiles_num,Horztiles_num,stepSize)
    xyzScanArray = zeros(3,Vertiles_num*Horztiles_num);
    xyzScanArray(2,:)=yPos;
    xVec = (-1*floor(Vertiles_num/2)):(ceil(Vertiles_num/2)-1);
    zVec = (-1*floor(Horztiles_num/2)):(ceil(Horztiles_num/2)-1);
    
    xVec = xVec*stepSize + xPos;
    zVec = zVec*stepSize + zPos;
    
    [xx,zz] = meshgrid(xVec,zVec);
    xyzScanArray(1,:) = xx(:);
    %snake pattern
%     for ii=2:2:Horztiles_num
%         zz(:,ii) = zz(end:-1:1,ii);
%     end
    xyzScanArray(3,:) = zz(:);
end