% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2016 The Regents of the University of California and the University of Southern California
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


function [pnew,status] = RemoveTraceOverDefects(p)

[n,T] = size(p);

for i = 1:n
    pdiff(i,:) = gradient(p(i,:));
end

for i = 1:T
    normpdiff(i)  = norm(pdiff(:,i));
end

% Find the point where the gradient of the norm is zero
idx = find(normpdiff == 0);
if(isempty(idx))
    status = 0;
    pnew = p;
    return;
else
    status = 1;
end

idx_to_remove = [];
for ctr = 1:length(idx)
    idx_to_remove = [idx_to_remove, idx(ctr)];
    N = min(idx(ctr)-1,T-idx(ctr)-1);
    
    % Search in the (-N:N) neighborhood around the point idx
    for i = 1:N
        if(normpdiff(idx(ctr)+i) == normpdiff(idx(ctr)-i))
            idx_to_remove = [idx_to_remove idx(ctr)+i, idx(ctr)-i];
        end
    end
end
idx_to_remove = sort(idx_to_remove);
idx_to_keep = setdiff([1:T],idx_to_remove);
pnew = p(:,idx_to_keep);

pnew = RemoveDuplicatePoints(pnew);
return;
