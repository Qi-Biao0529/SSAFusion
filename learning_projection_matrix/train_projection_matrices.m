%% training for deep
clear all
clc

disp('Training your own projection matrices.');

training_path = './training_data/training_data/';
col = 2000;
% col_smooth = 1000;
col_smooth_light = 50 ;
col_smooth_dark = 100 ;
col_smooth_other = 850 ;

% unit = 2;
% [B_detail1, B_smooth1] = train_choose_detail(training_path, unit);
% % display these image patches
% % display_image_patches(B_detail1, B_smooth1, unit);
% L_2 = train_latent_matrix(B_detail1, B_smooth1, col, col_smooth);
% save_path = ['../models/L_2_detail_mix_',num2str(col),'_s',num2str(col_smooth),'.mat'];
% save(save_path, 'L_2');

% unit = 4;
% [B_detail1, B_smooth1] = train_choose_detail(training_path, unit);
% % display these image patches
% % display_image_patches(B_detail1, B_smooth1, unit);
% L_4 = train_latent_matrix(B_detail1, B_smooth1, col, col_smooth);
% save_path = ['../models/L_4_detail_mix_',num2str(col),'_s',num2str(col_smooth),'.mat'];
% save(save_path, 'L_4');

% unit = 8;
% [B_detail1, B_smooth1] = train_choose_detail(training_path, unit);
% % display these image patches
% % display_image_patches(B_detail1, B_smooth1, unit);
% L_8 = train_latent_matrix(B_detail1, B_smooth1, col, col_smooth);
% save_path = ['../models/L_8_detail_mix_',num2str(col),'_s',num2str(col_smooth),'.mat'];
% save(save_path, 'L_8');

% unit = 16;
% [B_detail2, B_smooth2] = train_choose_detail(training_path, unit);
% % display these image patches
% % display_image_patches(B_detail2, B_smooth2, unit);
% L_16 = train_latent_matrix(B_detail2, B_smooth2, col, col_smooth);
% save_path = ['../models/L_16_detail_mix_',num2str(col),'_s',num2str(col_smooth),'.mat'];
% save(save_path, 'L_16');

unit = 16;
[B_detail2, B_smooth2, smooth_light, smooth_dark, smooth_other] = train_choose_detail(training_path, unit);
% display these image patches
% display_image_patches(B_detail2, B_smooth2, unit);
L_16 = train_latent_matrix(B_detail2, smooth_light, smooth_dark, smooth_other, col, col_smooth_light, col_smooth_dark, col_smooth_other);
save_path = ['../models/L_16_detail_mix_',num2str(col),'_s',num2str(col_smooth_other),'_new20260410','.mat'];
save(save_path, 'L_16');









