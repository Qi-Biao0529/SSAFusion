function [B_detail, B_smooth, smooth_light, smooth_dark,smooth_other] = train_choose_detail(training_path, unit, ~)
% choosing image patches which contain more detail

fileFolder=fullfile(training_path);
dirOutput=dir(fullfile(fileFolder,'*'));
num = length(dirOutput);
% fileNames={dirOutput.name}'; % all names
B = [];
B_step2 = [ ] ;
for i = 3:num
    img = imread([training_path,dirOutput(i).name]);
    if size(img,3)>1
        img = rgb2gray(img);
    end

    [t1,t2] = size(img);
    img = img(1:floor(t1/unit)*unit, 1:floor(t2/unit)*unit);
    img_step2 = img;
    img = im2double(img);
    b = im2col(img, [unit, unit], 'distinct');
    B = cat(2, B, b);
    b_step2 = im2col(img_step2, [unit, unit], 'distinct');
    B_step2 = cat(2, B_step2, b_step2);
end
%% calculating SD valuee of each column B
% B_mean = mean(B,1);
% B_mean = repmat(B_mean, unit*unit, 1);
% B_sd = sqrt(sum((B - B_mean).*(B - B_mean),1));
%% EN
EN = [];
[~,col] = size(B);
for j = 1:col
    a = entropy(B(:,j));
    EN = cat(2, EN, a);
end
B_sd = EN;
mm = mean(EN);
%% choose >0.5
B_sd(find(B_sd<=mm)) = 0;
B_sd(find(B_sd>mm)) = 1;
B_mask = repmat(B_sd, unit*unit, 1);
B_mask_step2 = uint8(B_mask);
B_smooth_step2 = B_step2.*(1-B_mask_step2);
B_smooth = B.*(1-B_mask);
B_detail = B.*B_mask;
B_smooth(:,all(B_smooth==0,1))=[];
B_detail(:,all(B_detail==0,1))=[];

B_smooth_step2(:,all(B_smooth_step2==0,1))=[];
avg_value = [] ;
[~,q] = size(B_smooth_step2);
for jj = 1:q
    avg = mean(B_smooth_step2(:,jj));
    avg_value = cat(2, avg_value, avg);
end
img_bright = avg_value ;
img_dark   = avg_value ;
img_bright(find(img_bright<250)) = 0;
img_bright(find(img_bright>=250)) = 1;
img_dark(find(img_dark<=5)) = 1;
img_dark(find(img_dark>5)) = 0;
img_bright_mask = repmat(img_bright, unit*unit, 1);
img_dark_mask = repmat(img_dark, unit*unit, 1);
img_other_mask = 1 - (img_bright_mask + img_dark_mask);
B_smooth_step2 = im2double(B_smooth_step2);
smooth_light = B_smooth_step2.*img_bright_mask;
smooth_dark = B_smooth_step2.*img_dark_mask;
smooth_other = B_smooth_step2.*img_other_mask;
smooth_light(:,all(smooth_light==0,1))=[];
smooth_dark(:,all(smooth_dark==0,1))=[];
smooth_other(:,all(smooth_other==0,1))=[];

[~,~] = size(B_detail);
[~,~] = size(B_smooth);

end