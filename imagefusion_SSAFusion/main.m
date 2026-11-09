clear
clc
path(path,'analysis_methods/')
path(path,'ResNet/')
path(path,'FusionEvaluation');
addpath('./vif');
disp('----------vector_main------------');
% load matrices
load('./models/L_8_detail_mix_2000_s1000.mat');
% load('./models/L_16_detail_mix_2000_s1000.mat');
% % load('./models/L_4_detail_mix_2000_s1000.mat');
% load('./models/L_16_detail_mix_2000_s1000_0.7.mat');
load('./models/L_16_detail_mix_2000_dark150_light150_other600.mat');
set(0,'DefaultAxesFontName', 'Times New Roman');
set(0,'DefaultAxesFontSize', 18);
% 0 - without zca, 1 - use zca
isZCA = 0;
is_overlap = 1;

% parameters setting
stride_cell = {1,2,4,6,8,10,12,14}; % for 16*16. In our paper is 1.
[n_s, m_s] = size(stride_cell);
norm_cell = {'l1', 'nu'}; % l1 - l1 norm; nu - nuclear norm. In our paper is nuclear norm.
[n_norm, m_norm] = size(norm_cell);
L_cell = {'8', '16'}; % projecting matrix. In our paper is 16.
% L_cell = {'16', '8'}; % projecting matrix. In our paper is 16.
% L_cell = {'8', '4'}; % projecting matrix. In our paper is 16.
[n_L, m_L] = size(L_cell);
level_cell = {1,2,3,4,5,6,7,8}; % decomposition level. In our paper is 1 to 4.
[n_le, m_le] = size(level_cell);
save_path = 'F:/paper5/qi/imagefusion_mdlatlrr_GF_detaillayer_newrgf1_smc1_new20260407/surface';
% [imagename1, imagepath1]=uigetfile('M:\qqqqq\paper2\Qi_paper2\paper2_image\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
% x1=imread(strcat(imagepath1,imagename1));    
% [imagename2, imagepath2]=uigetfile('M:\qqqqq\paper2\Qi_paper2\paper2_image\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the second input image');
% x2=imread(strcat(imagepath2,imagename2));
[imagename1, imagepath1]=uigetfile('F:\paper5\qi\imagefusion_mdlatlrr_GF_detaillayer_newrgf1_smc1_new20260407\input_TNO50_new\IR\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
x1=imread(strcat(imagepath1,imagename1));    
[imagename2, imagepath2]=uigetfile('F:\paper5\qi\imagefusion_mdlatlrr_GF_detaillayer_newrgf1_smc1_new20260407\input_TNO50_new\VI\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the second input image');
x2=imread(strcat(imagepath2,imagename2));
[~,~,n]=size(x1);
if(n==3)
  I1=rgb2gray(x1);
  I2=rgb2gray(x2);
else
  I1=x1;
  I2=x2;
end
for s=1:1
% stride = stride_cell{s}; 
stride = stride_cell{8}; 
% l1, nu
for kk=2:m_norm
    norm = norm_cell{kk};
    %%%%% 8, 16 %%%%%%%%%%%%%%%
    for k=2:m_L
        eval(['L = L_', L_cell{k}, ';'])
        unit = str2double(L_cell{k});
        % decomposition level 1 - 8
        for jj=1:1
            de_level = level_cell{jj};
            str_t = ['L_',L_cell{k},'; level: ',num2str(de_level),'; norm: ',norm, '; stride: ', num2str(stride)];
            disp(str_t);
            t = 0;
%             for j=1:21
%                 index = j;
                index = 1;
                path1 = ['./IV_images/IV_images/IR',num2str(index),'.png'];
                path2 = ['./IV_images/IV_images/VIS',num2str(index),'.png'];
                if is_overlap == 1
                    path_temp = './fused/';
                    if exist(path_temp,'dir')==0
                        mkdir(path_temp);
                    end
                    fuse_path = [path_temp, 'fused',num2str(index), '_mdlatlrr_level_',num2str(de_level),'_',norm,'_stride_',num2str(stride),'.png'];
                end
%                 if exist(fuse_path,'file')~=0
%                     continue;
%                 end
                % Fusion
%                 img1 = x1;
                img1 = I1;
                img1 = im2double(img1);
%                 img2 = x2;
                img2 = I2;
                img2 = im2double(img2);
%                 figure,imshow(img1);
%                 figure,imshow(img2);
                [h,w] = size(img1);
                F = zeros(h,w);
                is_block = 0;
                if h>512 || w>512
                    % get image block
                    is_block = 1;
                    [img1_1, img1_2, img1_3, img1_4] = getImgBlock(img1);
                    [img2_1, img2_2, img2_3, img2_4] = getImgBlock(img2); 
                end
                if is_block == 1
                    F_1 = vector_fusion_method(img1_1, img2_1, L, unit, isZCA, de_level, norm, is_overlap, stride, save_path);
                    F_2 = vector_fusion_method(img1_2, img2_2, L, unit, isZCA, de_level, norm, is_overlap, stride, save_path);
                    F_3 = vector_fusion_method(img1_3, img2_3, L, unit, isZCA, de_level, norm, is_overlap, stride, save_path);
                    F_4 = vector_fusion_method(img1_4, img2_4, L, unit, isZCA, de_level, norm, is_overlap, stride, save_path);
                    F   = reconsFromBlock(F,F_1, F_2,F_3, F_4);
                elseif is_block == 0
                    F   = vector_fusion_method(img1, img2, L, unit, isZCA, de_level, norm, is_overlap, stride, save_path);
                end
                str_o = [str_t, '; index: ', num2str(index)];
                disp(str_o);
                imwrite(F,fuse_path,'png');
                figure,imshow(F);
%             end
        end
    end
end
end
% end




