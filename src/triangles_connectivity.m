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



function triconn = triangles_connectivity(tri)

    numvtx=max(tri(:));
    trinums=cell(numvtx,1);
    
    for jj=1:size(tri(:,1))
        trinums{tri(jj,1)}(end+1)=jj;
        trinums{tri(jj,2)}(end+1)=jj;
        trinums{tri(jj,3)}(end+1)=jj;
    end
    
    triconn=cell(size(tri,1),1);
    
    for jj=1:size(tri,1)
        
        triconn{jj}=[setdiff(intersect(trinums{tri(jj,1)},trinums{tri(jj,2)}),jj),setdiff(intersect(trinums{tri(jj,1)},trinums{tri(jj,3)}),jj),setdiff(intersect(trinums{tri(jj,2)},trinums{tri(jj,3)}),jj)];
        %jj
        
    end
    



