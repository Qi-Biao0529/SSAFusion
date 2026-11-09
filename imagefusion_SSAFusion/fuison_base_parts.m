function f = fuison_base_parts(b1, b2, x1, x2)
I_saliency1 = x1;
I_saliency1 = max(I_saliency1,0);
I_saliency1 = min(I_saliency1,1);
sm1=(I_saliency1-min(I_saliency1(:)))./(max(I_saliency1(:))-min(I_saliency1(:)));
I_saliency2 = x2;
I_saliency2 = max(I_saliency2,0);
I_saliency2 = min(I_saliency2,1);
sm2=(I_saliency2-min(I_saliency2(:)))./(max(I_saliency2(:))-min(I_saliency2(:)));
sm5=(3.*(1+sm1-sm2)./4);
%%
% 融合低频系数
dstp=(1-sm1).*double(b2)+(sm1).*double(b1);
dstq=(1-sm2).*double(b1)+(sm2).*double(b2);
f=band_fuse(dstp, dstq, sm5, 0);
end
