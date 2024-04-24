function AllImage = StitchImages(images,Vertiles_num,Horztiles_num)
    space_perimage = 40;
    AllImage = zeros(size(images,1)*Vertiles_num,size(images,2)*Horztiles_num);
%     i=1;j=1;
%     for ii = 1:size(images,3)
%         if fix(ii/Horztiles_num)
%         subplot(Vertiles_num,Horztiles_num,Vertiles_num*Horztiles_num-ii+1);
%         imshow(images(:,:,ii),[0,2500])
%     end
    start_point_H = 1;start_point_W = size(AllImage,2)-size(images,1);
    for ii = 1:size(images,3)
        
        AllImage(start_point_H:start_point_H+size(images,1)-1,start_point_W+1:start_point_W+1+size(images,1)-1) = images(:,:,ii);
        if mod(ii,Horztiles_num) == 0
            start_point_H = start_point_H + size(images,1);
            start_point_W = size(AllImage,2)-size(images,1);
        else
            start_point_W = start_point_W - size(images,1);
        end
    end
    %imshow(AllImage,[0,3000]);
end