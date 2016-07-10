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


function Xfilt = Remove_Curve_Defects(X)

% Find interpoint distances to 3 forward neighbors
if isempty(X)
    Xfilt=X;
    return;
end
Nbrs = 3;
[X,~,~] = RemoveDuplicatePoints(X);
[X,~] = RemoveTraceOverDefects(X);

conn = 1;
i = 1;
while(i < size(X,2))
    Nbrs = min(3,size(X,2)-i);
    diffX = repmat(X(:,i),[1,Nbrs]) - X(:,i+1:i+Nbrs);
    dist = [];
    for j = 1:Nbrs
        dist(j) = norm(diffX(:,j));
    end
    [~,idx] = min(dist);
    conn = [conn,i+idx];
    if(idx > 1)
        i = i + idx;
    else
        i = i + 1;
    end
end
if isempty(X)
Xfilt = X;
else
Xfilt = X(:,conn);
end
return;
