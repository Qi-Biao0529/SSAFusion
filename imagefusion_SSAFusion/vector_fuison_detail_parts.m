% % % % % function f = vector_fuison_detail_parts(h_ir, h_vis, norm, zca_type)
% % % % %     N = size(h_ir, 2);
% % % % %     v_ir = single(reshape(h_ir, 16, 16, N));
% % % % %     v_vi = single(reshape(h_vis, 16, 16, N));
% % % % %     
% % % % %     % 平均梯度
% % % % %     avg_ir = (mean(mean(abs(diff(v_ir,1,2)),2) + mean(mean(abs(diff(v_ir,1,1)),2)))) / 2;
% % % % %     avg_vi = (mean(mean(abs(diff(v_vi,1,2)),2) + mean(mean(abs(diff(v_vi,1,1)),2))))/ 2;
% % % % %     
% % % % %     sum_avg = avg_ir + avg_vi;
% % % % %     sum_avg(sum_avg < eps) = 1;   % 避免除零
% % % % %     a = avg_vi ./ sum_avg;
% % % % %     b = avg_ir ./ sum_avg;
% % % % %     
% % % % %     f_blocks = (v_ir + v_vi) / 2;
% % % % %     a_minus = a - 0.0001;
% % % % %     
% % % % %     for iter = 1:2
% % % % %         s = f_blocks - a .* v_vi - b .* v_ir;
% % % % %         alpha = a_minus .* sign(s);   % 或用 tanh
% % % % %         f_blocks = alpha .* v_vi + (1 - alpha) .* v_ir;
% % % % %     end
% % % % %     
% % % % %     f = reshape(f_blocks, 256, N);
% % % % % end

% % % function [f] = vector_fuison_detail_parts(h_ir, h_vis, norm, zca_type)
% % % % 基于滑模控制的高频系数融合（分批次 + 固定迭代）
% % % % 输入:
% % % %   h_ir, h_vis : 待融合的高频系数矩阵，每列为一个16×16块展开的256×1向量
% % % % 输出:
% % % %   f : 融合后的系数矩阵，尺寸与输入相同
% % % 
% % %     [rows_h, cols_h] = size(h_ir);
% % %     assert(rows_h == 256, '输入行数必须为256（16×16块展开）');
% % %     assert(all(size(h_ir) == size(h_vis)), '两个输入矩阵尺寸必须相同');
% % % 
% % %     batch_size = 5000;               % 每批处理列数（可根据内存调整）
% % %     num_batches = ceil(cols_h / batch_size);
% % %     max_iter = 2;                    % 固定迭代次数（与原算法一致）
% % % 
% % %     f = zeros(rows_h, cols_h);       % 预分配输出矩阵
% % % 
% % %     for b = 1:num_batches
% % %         % 当前批的列范围
% % %         start_col = (b-1)*batch_size + 1;
% % %         end_col = min(b*batch_size, cols_h);
% % %         batch_cols = end_col - start_col + 1;
% % % 
% % %         % 提取当前批并重塑为三维数组 [16,16,batch_cols]
% % %         v_ir = reshape(h_ir(:, start_col:end_col), 16, 16, batch_cols);
% % %         v_vi = reshape(h_vis(:, start_col:end_col), 16, 16, batch_cols);
% % % 
% % %         % ---------- 向量化计算每个块的平均梯度 ----------
% % %         avg_ir = AverageGradient_vec(v_ir);   % [1,1,batch_cols]
% % %         avg_vi = AverageGradient_vec(v_vi);
% % % 
% % %         sum_avg = avg_ir + avg_vi;
% % %         zero_mask = (sum_avg < eps);
% % %         a = zeros(1,1,batch_cols);
% % %         b_weights = zeros(1,1,batch_cols);
% % %         a(~zero_mask) = avg_vi(~zero_mask) ./ sum_avg(~zero_mask);
% % %         b_weights(~zero_mask) = avg_ir(~zero_mask) ./ sum_avg(~zero_mask);
% % %         a(zero_mask) = 0.5;
% % %         b_weights(zero_mask) = 0.5;
% % % 
% % %         % 初始化融合块（简单平均）
% % %         f_blocks = (v_ir + v_vi) / 2;
% % % 
% % %         % ---------- 固定迭代更新 ----------
% % %         for iter = 1:max_iter
% % %             % 计算滑模面 s = f - a*v_vi - b*v_ir
% % %             s = f_blocks - a .* v_vi - b_weights .* v_ir;
% % %             % 计算融合系数 alpha
% % %             alpha = (a - 0.0001) .* tanh(1e6 * s);
% % %             % 加权融合
% % %             f_blocks = alpha .* v_vi + (1 - alpha) .* v_ir;
% % %         end
% % % 
% % %         % 将当前批的结果写回输出矩阵
% % %         f(:, start_col:end_col) = reshape(f_blocks, 256, batch_cols);
% % %     end
% % % end
% % % 
% % % % ---------------------------------------------------------------------
% % % function avg = AverageGradient_vec(v)
% % % % 向量化计算每个16×16块的平均梯度
% % % % v : [16,16,N] 三维数组
% % % % avg: [1,1,N] 每个块的平均梯度值
% % %     diff_h = diff(v, 1, 2);
% % %     grad_h = abs(diff_h);
% % %     avg_h = sum(grad_h, [1,2]) / (16*15);
% % % 
% % %     diff_v = diff(v, 1, 1);
% % %     grad_v = abs(diff_v);
% % %     avg_v = sum(grad_v, [1,2]) / (15*16);
% % % 
% % %     avg = (avg_h + avg_v) / 2;
% % % end

function [f] = vector_fuison_detail_parts(h_ir, h_vis, norm, zca_type)
% 基于滑模控制的高频系数融合（列方向16×16块处理）
% 输入:
%   h_ir, h_vis : 待融合的高频系数矩阵，每列为一个16×16块展开的256×1向量
% 输出:
%   f : 融合后的系数矩阵，尺寸与输入相同

    [rows_h, cols_h] = size(h_ir);
    % 检查输入尺寸是否匹配
    assert(rows_h == 256, '输入行数必须为256（16×16块展开）');
    assert(all(size(h_ir) == size(h_vis)), '两个输入矩阵尺寸必须相同');

    f = zeros(rows_h, cols_h);          % 预分配输出矩阵
%     max_iter = 100;                      % 最大迭代次数
    max_iter = 2;                      % 最大迭代次数
    tol = 1e-4;                          % 收敛容差

    % 参数设置（可调整）

    for j = 1:cols_h
        % 提取当前列并重塑为16×16块
        v_ir = reshape(h_ir(:, j), 16, 16);
        v_vi = reshape(h_vis(:, j), 16, 16);

        % 初始化融合块（这里取简单平均作为初值）
        f_block = (v_ir + v_vi) / 2;

        % 计算该块的平均梯度（需自定义 AverageGradent 函数）
        AVG_ir = AverageGradent(v_ir);
        AVG_vi = AverageGradent(v_vi);

        % 避免除零
        sum_avg = AVG_ir + AVG_vi;
        if sum_avg < eps
            a = 0.5;  % 退化到平均
            b = 0.5;
        else
            a = AVG_vi / sum_avg;
            b = AVG_ir / sum_avg;
        end

        iter = 0;
        s = ones(16, 16);   % 初始滑模面（非零，确保进入循环）

%         迭代过程
%         while max(abs(s(:))) > tol && iter < max_iter
%           s = a*(f_block - v_vi) + b*(f_block - v_ir);
%           f_block = f_block - s;   % 一步到位
%           iter = iter + 1;
%           break;   % 仅需一次
%         end
        while max(abs(s(:))) > tol && iter < max_iter
            % 计算滑模面 s
%             s = a * (f_block - v_vi) + b * (f_block - v_ir);
            s = f_block - a * v_vi - b * v_ir;

            % 计算融合系数矩阵 alpha（逐元素）
            alpha = (a - 0.0001) * tanh(1000000*s);   % 此处常数0.0001可根据需求调整

            % 加权融合（注意点乘 .* ）
            f_block = alpha .* v_vi + (1 - alpha) .* v_ir;

            iter = iter + 1;
        end

        if iter == max_iter
            warning('第 %d 列未在 %d 次迭代内收敛', j, max_iter);
        end
%         f_block = a * v_vi + b * v_ir + 0.001 * randn(16,16); % 模拟扰动后的解析解
        % 将融合块写回输出矩阵
        f(:, j) = f_block(:);
    end
end


% function [f] = vector_fuison_detail_parts(h_ir, h_vis, norm, zca_type)
% %%
% % 获取当前高频系数的尺寸
%     [rows_h, cols_h] = size(h_ir);
%     % 处理水平方向
%     f = zeros(rows_h, cols_h);
%     f1 = zeros(16,16);
% %     f1 = reshape(h_vis(:,1),[16 16]);
%     s = ones(16,16) ;
%     for j = 1:cols_h
% %         while s<0.5
%         while abs(s)>0.0005*ones(16,16)
%         v_ir = reshape(h_ir(:,j),[16 16]);
%         v_vi = reshape(h_vis(:,j),[16 16]);
%         AVG_ir = AverageGradent(v_ir);
%         AVG_vi = AverageGradent(v_vi);
%         a = AVG_vi / (AVG_ir + AVG_vi);
%         b = AVG_ir / (AVG_ir + AVG_vi);
%         s = a*(f1-v_vi)+b*(f1-v_ir);
%         alpha = (a-0.0001)*tanh(s);
%         % 融合系数
%         f1 = alpha * v_vi + (1 - alpha) * v_ir;
%         f(:,j) = reshape(f1,[256 1]);
%         end
%     end
% end