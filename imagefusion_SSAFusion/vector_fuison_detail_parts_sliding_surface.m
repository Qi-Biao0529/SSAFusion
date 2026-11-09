function [f] = vector_fuison_detail_parts_sliding_surface(h_ir, h_vis, norm, zca_type, show_animation)
% 基于滑模控制的高频系数融合（列方向16×16块处理）
% 输入:
%   h_ir, h_vis : 待融合的高频系数矩阵，每列为一个16×16块展开的256×1向量
% 输出:
%   f : 融合后的系数矩阵，尺寸与输入相同

    [rows_h, cols_h] = size(h_ir);
    assert(rows_h == 256, '输入行数必须为256（16×16块展开）');
    assert(all(size(h_ir) == size(h_vis)), '两个输入矩阵尺寸必须相同');

    f = zeros(rows_h, cols_h);
    max_iter = 100;
    tol = 0.1;
    
    for j = 1:cols_h
        % 提取当前块
        v_ir = reshape(h_ir(:, j), 16, 16);
        v_vi = reshape(h_vis(:, j), 16, 16);

        % 初始融合块（简单平均）
        f_block = (v_ir + v_vi) / 2;

        % 计算平均梯度
        AVG_ir = AverageGradent(v_ir);
        AVG_vi = AverageGradent(v_vi);
        sum_avg = AVG_ir + AVG_vi;
        if sum_avg < eps
            a = 0.5;
            b = 0.5;
        else
            a = AVG_vi / sum_avg;
            b = AVG_ir / sum_avg;
        end
        
        iter = 0;
        s = ones(16, 16);   % 初始滑模面（非零）
        
        % 迭代融合
        while max(abs(s(:))) > tol && iter < max_iter
            % 计算滑模面 S(t)
            s = f_block - a * v_vi - b * v_ir;
            iter = iter + 1;

             % 计算融合系数矩阵 alpha（逐元素）
            alpha = (a - 0.0001) * tanh(s);

            % 加权更新融合块
            f_block = alpha .* v_vi + (1 - alpha) .* v_ir;
        end
        
        % 将最终融合块写回输出矩阵
        f(:, j) = f_block(:);
    end
end

% ---------------------------------------------------------------------
function avg_grad = AverageGradent(block)
% 计算 16×16 块的平均梯度（幅值）
    [Gx, Gy] = gradient(block);
    grad_mag = sqrt(Gx.^2 + Gy.^2);
    avg_grad = mean(grad_mag(:));
end