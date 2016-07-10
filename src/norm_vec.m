function [ v_out ] = norm_vec( v )
%NORM_VEC Returns normalized vectors, where vectors are stored in 4th
%dimesion of a matrix v (usually the eigenvectors)

v_out = zeros(size(v));
v_norm = sqrt(sum(v.^2, 4));

v_out(:,:,:,1) = v(:,:,:,1) ./ v_norm;
v_out(:,:,:,2) = v(:,:,:,2) ./ v_norm;
v_out(:,:,:,3) = v(:,:,:,3) ./ v_norm;

v_out(isnan(v_out)) = 0;

end

