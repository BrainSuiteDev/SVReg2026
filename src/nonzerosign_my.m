function y = nonzerosign_my(x)
%
y = ones(size(x));
y(x < 0) = -1;