% function L = train_latent_matrix(B, B_smooth, col, col_smo)
function L = train_latent_matrix(B, B_smooth_light, B_smooth_dark, B_smooth_other, col, col_smooth_light, col_smooth_dark, col_smooth_other)
% Train the extractor of salient features 'L'
%   min_Z,L,E ||Z||_* + ||L||_* +¡¡lambda||E||_1,
%           s.t. X = XZ + LX +E.

[s1_d, s2_d] = size(B);
[s1_s_light, s2_s_light] = size(B_smooth_light);
[s1_s_dark, s2_s_dark] = size(B_smooth_dark);
[s1_s_other, s2_s_other] = size(B_smooth_other);
rng('default');
B_d = B(:,randperm(s2_d, col-col_smooth_light-col_smooth_dark-col_smooth_other));
B_s_light = B_smooth_light(:,randperm(s2_s_light, col_smooth_light));
B_s_dark = B_smooth_dark(:,randperm(s2_s_dark, col_smooth_dark));
B_s_other = B_smooth_other(:,randperm(s2_s_other, col_smooth_other));
B_rand = cat(2,B_d, B_s_light);
B_rand = cat(2,B_rand, B_s_dark);
B_rand = cat(2,B_rand, B_s_other);
B_rand = B_rand(:, randperm(col));

lambda = 0.4;
disp('Start-latent lrr');
disp('It takes almost 10 min.');
tic
[Z,L,E] = latent_lrr(B_rand,lambda);
toc
disp('Done-latent lrr');

end




