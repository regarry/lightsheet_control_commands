function result= imgstack_pred(img)
    % input should a 2048*2048*3 stack
%      clear classes;
%      mod = py.importlib.import_module('pred_img_6nm');
%      py.importlib.reload(mod);
    
    %read three image
%     img0_name = 'Z:/Chen/imagedata/testdeeplearning3/onetile_new/0.tiff';
%     img1_name = 'Z:/Chen/imagedata/testdeeplearning3/onetile_new/1.tiff';
%     img2_name = 'Z:/Chen/imagedata/testdeeplearning3/onetile_new/2.tiff';
%     img0 = imread(img0_name);
%     img1 = imread(img1_name);
%     img2 = imread(img2_name);
%     img(:,:,1) = img0;
%     img(:,:,2) = img1;
    %img(:,:,3) = img2;
    %disp(size(img));
    res = py.pred_img_6nm.pred_whole(img);
    pred = single(res{1});
    cert = single(res{2});
    
    
    pred_withcert = pred(cert>0.3);
    result = pred_withcert;
    
    if length(result) < 20
        result = 6; % this means the ouput of network is not usefull.
        return;
    end
    %pred_withcert;
    tabulate(pred_withcert);
    tbl = tabulate(pred_withcert);
    % if there are only one element in tbl
    if length(tbl(:,3)) == 1
        result = tbl(1,1);
        return;
    end
    
    [b,i] = sort(tbl(:,3));
    b;
    i;
    max1_index = i(end);
    max2_index = i(end-1);
    result = (tbl(max1_index,1)*tbl(max1_index,2) + tbl(max2_index,1)*tbl(max2_index,2))/(tbl(max1_index,2) + tbl(max2_index,2));
    
    %     for i=1:3
%         a(i) = i;
%     end
%     disp(a);
end

%%
% img0_name = 'Z:/Chen/imagedata/test_deeplearning/testonetile/0.tiff';
% img1_name = 'Z:/Chen/imagedata/test_deeplearning/testonetile/1.tiff';
% img2_name = 'Z:/Chen/imagedata/test_deeplearning/testonetile/2.tiff';
% img0 = imread(img0_name);
% img1 = imread(img1_name);
% img2 = imread(img2_name);
% img(:,:,1) = img0;
% img(:,:,2) = img1;
% img(:,:,3) = img2;
%%
