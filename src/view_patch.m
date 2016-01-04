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



function h=view_patch(FV1)
%function view_patch(FV)
%FV: a tessellation to view
%
%Contribution Dimitrios Pantazis, USC

h=figure;
%camlight
%lighting gouraud
axis equal
axis off   
axis vis3d
FV.vertices=FV1.vertices;FV.faces=FV1.faces;
nVertices = size(FV.vertices,1);
hpatch = patch(FV,'FaceColor','interp','EdgeColor','none','FaceVertexCData',ones(nVertices,3)*0.9,'faceAlpha',1);%,'BackFaceLighting','unlit'); %plot surface        
lighting gouraud
set(gcf,'color','white'); light

