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


function Brain=volmap2ball_bs(Brain,flags)
%This assumes that the surface map is to sphere.
[bdr_ind,bdr_indxMSK]=find_mask_bdr(Brain.mask_indx,Brain.Msize);

[bX,bY,bZ]=ind2sub(Brain.Msize,bdr_ind);
bX=(bX-1)*Brain.resolution(1);bY=(bY-1)*Brain.resolution(2);bZ=(bZ-1)*Brain.resolution(3);
%Linear Interpolation should be better here
bdrmapx=mygriddata3(Brain.surf.vertices(:,1),Brain.surf.vertices(:,2),Brain.surf.vertices(:,3),Brain.surfmap(:,1),bX,bY,bZ);
bdrmapy=mygriddata3(Brain.surf.vertices(:,1),Brain.surf.vertices(:,2),Brain.surf.vertices(:,3),Brain.surfmap(:,2),bX,bY,bZ);
bdrmapz=mygriddata3(Brain.surf.vertices(:,1),Brain.surf.vertices(:,2),Brain.surf.vertices(:,3),Brain.surfmap(:,3),bX,bY,bZ);
clear bX bY bZ

%res=double(v2.hdr.dime.pixdim(2:4));
[Brain.volmap(:,1),Brain.volmap(:,2),Brain.volmap(:,3)]=pharm_regrid2(Brain.Msize,2,Brain.mask_indx, bdr_indxMSK,[bdrmapx,bdrmapy,bdrmapz],Brain.resolution,flags);




