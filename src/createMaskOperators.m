% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2019 The Regents of the University of California and the University of Southern California
% Created by Anand A. Joshi, Chitresh Bhushan, David W. Shattuck, Richard M. Leahy 
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; version 2.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
% USA.


function [M, unM, Minv, unMinv] = createMaskOperators(msk)
% Returns masking and unmasking operators for input mask. The operators should be applied on indexed
% vectors.
%   M - Masks data 
%   unM - Unmasks the masked data. Fills in zeros outside the mask. 
%   Minv - Masks data using inverse of the input mask. 
%   unMinv - Unmasks the data masked by Minv. Fills in zeros outside the mask. 
%
% Based on createDwithMask by Justin Haldar (jhaldar@usc.edu) 11/02/2006
% Inspired by the dgrad function, written by W. C. Karl 4/98



msk = msk~=0;
sz = size(msk);

M = speye(prod(sz));
M(~msk, :) = [];

if nargout>1
   unM = speye(prod(sz));
   unM(:, ~msk) = [];
end

if nargout>2
   Minv = speye(prod(sz));
   Minv(msk, :) = [];
end

if nargout>3
   unMinv = speye(prod(sz));
   unMinv(:, msk) = [];
end

end
