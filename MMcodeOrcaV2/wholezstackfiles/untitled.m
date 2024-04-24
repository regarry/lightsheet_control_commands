for i =255:255
    %image_up = imread(['adelebones_third/_adele_bone_',date,num2str(i,'%04d'),'.tiff']);
    %image_middle = imread(['adelebones_first/_adele_bone_',date,num2str(i,'%04d'),'.tiff']);
    %image_down = imread(['adelebones_second/_adele_bone_',date,num2str(i,'%04d'),'.tiff']);
    
    image_1 = imread(['adele/1-15-20-Cochlea-NBpig-PGP/1/_cochlea_','15-Jan-2020',num2str(i,'%04d'),'.tiff']);
    image_2 = imread(['adele/1-15-20-Cochlea-NBpig-PGP/2/_cochlea_','15-Jan-2020',num2str(i,'%04d'),'.tiff']);
    image_3 = imread(['adele/1-15-20-Cochlea-NBpig-PGP/3/_cochlea_','15-Jan-2020',num2str(i,'%04d'),'.tiff']);
    image_4 = imread(['adele/1-15-20-Cochlea-NBpig-PGP/4/_cochlea_','15-Jan-2020',num2str(i,'%04d'),'.tiff']);
    image_5 = imread(['adele/1-15-20-Cochlea-NBpig-PGP/5/_cochlea_','15-Jan-2020',num2str(i,'%04d'),'.tiff']);
    image_6 = imread(['adele/1-15-20-Cochlea-NBpig-PGP/6/_cochlea_','15-Jan-2020',num2str(i,'%04d'),'.tiff']);

    
    
    image_threetiles = [image_3,image_4;image_1,image_5;image_2,image_6];
    %name = ['adele/1-15-20-Cochlea-NBpig-PGP/6tiles/_cochlea_',date,num2str(i,'%04d'),'.tiff'];
    name = ['_cochlea_',date,num2str(i,'%04d'),'.avi'];
    imwrite(image_threetiles,name);
end







