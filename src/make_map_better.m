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


function make_map_better(subbasename,extn)

map=load_nii_z([subbasename,'.',extn,'.map.nii.gz']);

xmap=squeeze(map.img(:,:,:,1));
ymap=squeeze(map.img(:,:,:,2));
zmap=squeeze(map.img(:,:,:,3));
Msize=size(xmap);
[J3]=myjacobian3dmap(xmap, ymap, zmap);
msk=find(J3<0);
fprintf('negative jacobians %d\n',length(msk(:)));
pix = 3; [x1,y1,z1] = ndgrid(-pix:pix);
se1 = (sqrt(x1.^2 + y1.^2 + z1.^2) <=pix);

msk_dilated=imdilate((J3<0),se1);
msk_dilated(msk)=0;
msk_dilated=find(msk_dilated);

[XX,YY,ZZ]=ind2sub(Msize,(msk_dilated));
[XXn,YYn,ZZn]=ind2sub(Msize,(msk));
xmap(msk)=griddata(XX,YY,ZZ,double(xmap(msk_dilated)),XXn+.753,YYn+.352,ZZn+.551,'nearest');
ymap(msk)=griddata(XX,YY,ZZ,double(ymap(msk_dilated)),XXn+.753,YYn+.352,ZZn+.551,'nearest');
zmap(msk)=griddata(XX,YY,ZZ,double(zmap(msk_dilated)),XXn+.753,YYn+.352,ZZn+.551,'nearest');


[J3]=myjacobian3dmap(xmap, ymap, zmap);%myjacobian3d1([xmap(src_mask.img>0);ymap(src_mask.img>0);zmap(src_mask.img>0)],size(map.img),find(src_mask.img>0),map.hdr.dime.pixdim(2:4));
msk=find(J3<0);
fprintf('negative jacobians %d\n',length(msk(:)));

map.img(:,:,:,1)=xmap;map.img(:,:,:,2)=ymap;map.img(:,:,:,3)=zmap;
save_untouch_nii_gz(map,[subbasename,'.',extn,'.map2.corr.nii.gz']);
v=load_nii_z([subbasename,'.',extn,'.nii.gz']);
v.img=J3;
save_untouch_nii_gz(v,[subbasename,'.',extn,'.jacobian.nii.gz']);

% [J1,J2,J3]=myjacobian3d_pial_exclude(subbasename,map);
% %vv=view_vol((J3)-min(J3(:))+1150*(J3<0),size(J3),size(J3));
% v.img=J3;
% %vv.hdr=v.hdr;
% save_untouch_nii_gz(v,[subbasename,'.',extn,'.jacobian_pialexcluded.nii.gz']);

