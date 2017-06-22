% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2017 The Regents of the University of California and the University of Southern California
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


function boundary = boundary_vertices(FV,vertConn,faceConn,Ctri)
% function boundary = boundary_vertices(FV,vertConn,faceConn,Ctri)
%
% Find boundary vertices in a tessellation
%
% INPUTS:
%   FV: tessellation
%   vertConn: vertices connectivity
%   faceConn: faces connectivity
%   Ctri: faces to faces connectivity matrix
%
% OUTPUT:
%   boundary: index of boundary vertices
%
% see also: VERTICES_CONNECTIVITY FACES_CONNECTIVITY
% FACES2FACES_CONNECTIVITY
%   
% Author: Dimitrios Pantazis, November 2007

%get boundary faces

if ~exist('vertConn','var')
    vertConn=vertices_connectivity_fast(FV);
end


if ~exist('faceConn','var')
    faceConn=faces_connectivity_fast(FV);
end


if ~exist('Ctri','var')
    %surf1facesConn=faces2faces_connectivity(FV,faceConn);

    Ctri=faces2faces_connectivity(FV,faceConn);
end
boundary_faces = find(sum(Ctri)<3);
%get candidate boundary vertices
verts = FV.faces(boundary_faces,:);
verts = unique(verts(:));


%get true boundary vertices
nVerts = length(verts);
boundary = zeros(nVerts,1);
for i = 1:nVerts
    n = vertConn{verts(i)};
    for j = 1:length(n)
        if length(intersect(faceConn{verts(i)},faceConn{n(j)}))==1
            boundary(i)=1;
        end
    end
end
boundary = verts(boundary~=0);














