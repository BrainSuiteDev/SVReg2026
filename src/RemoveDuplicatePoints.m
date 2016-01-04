% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2015 The Regents of the University of California and the University of Southern California
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


function [p,idx,idx_rem] = RemoveDuplicatePoints(p)

[n,T] = size(p);
 idx={};
% Remove duplicate entries:
for i = 1:T
    %     vert = p(:,i);
    G = p - repmat(p(:,i),1,T);
    idx{i} = find(sum((G.^2),1) == 0);
end
idx_rem= [];
for i = 1:length(idx)
    if(length(idx{i}) == 1)
        continue;
    end
    idx_rem = [idx_rem,idx{i}(2:end)];
end
p = p(:,setdiff([1:T],idx_rem));
idx = setdiff([1:T],idx_rem);
