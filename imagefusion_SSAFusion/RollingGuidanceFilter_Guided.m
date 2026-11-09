%
%   Rolling Guidance Filter 
%
%   res = RollingGuidanceFilter(I,sigma_s,sigma_r,iteration) filters image
%   "I" by removing its small structures. The borderline between "small"
%   and "large" is determined by the parameter sigma_s. The sigma_r is
%   fixed to 0.1. The filter is an iteration process. "iteration" is used
%   to control the number of iterations.
%   
%   Paras: 
%   @I         : input image, DOUBLE image, any # of channels
%   @sigma_s   : spatial sigma (default 3.0). Controlling the spatial 
%                weight of bilateral filter and also the filtering scale of
%                rolling guidance filter.
%   @sigma_r   : range sigma (default 0.1). Controlling the range weight of
%                bilateral filter. 
%   @iteration : the iteration number of rolling guidance (default 4).
%
%
%   Example
%   ==========
%   I = im2double(imread('image.png'));
%   res = RollingGuidanceFilter(I,3,0.05,4);
%   figure, imshow(res);
%
%
%   Note
%   ==========
%   This implementation filters multi-channel/color image by separating its
%   channels, so the result of this implementation will be different with
%   that in the corresponding paper. To generate the results in the paper,
%   please refer to our executable file or C++ implementation on our
%   website.
%
%   ==========
%   The Code is created based on the method described in the following paper:
%   [1] "Rolling Guidance Filter", Qi Zhang, Li Xu, Jiaya Jia, European 
%        Conference on Computer Vision (ECCV), 2014
%
%   The code and the algorithm are for non-comercial use only.
%
%  
%   Author: Qi Zhang (zhangqi@cse.cuhk.edu.hk)
%   Date  : 08/14/2014
%   Version : 1.0 
%   Copyright 2014, The Chinese University of Hong Kong.
% 

function image = RollingGuidanceFilter_Guided(img,image)

% if ~exist('iteration','var')
    iteration = 4;
% end

% if ~exist('sigma_s','var')
    sigma_s = 4;
% end

% if ~exist('sigma_r','var')
    sigma_r = 0.1;
% end
% if ~exist('window_width','var')
    window_width = 5;
% end

% image = double(image/255);
% img= double(img/255);
image = rolling_guidance(img,image, window_width, sigma_s, sigma_r, iteration);
end


