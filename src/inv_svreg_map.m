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


function inv_svreg_map(subbasename,subbasename_tmp,atlasbasename)


map=load_nii_z([subbasename_tmp,'.svreg.map.nii']);
tar_mask=load_nii_z([atlasbasename,'.bfc.nii']);

src_mask=load_nii_z([subbasename,'.bfc.nii']);

tar_mask.img=smooth3(double(tar_mask.img),'gaussian',[13,13,13],5);
src_mask.img=smooth3(double(src_mask.img),'gaussian',[13,13,13],5);

[inv_map]=invert_deformation_parallel(map,src_mask,tar_mask);

save_nii(inv_map,[subbasename,'.svreg.inv.map.nii.gz']);
fixBSheader([atlasbasename,'.bfc.nii.gz'], [subbasename,'.svreg.inv.map.nii.gz'], [subbasename,'.svreg.inv.map.nii.gz']);

xmap=squeeze(inv_map.img(:,:,:,1));
ymap=squeeze(inv_map.img(:,:,:,2));
zmap=squeeze(inv_map.img(:,:,:,3));



srcv=load_nii_z([subbasename,'.bfc.nii']);

v_w=trilinear(double(srcv.img),double(inv_map.img(:,:,:,2)),double(inv_map.img(:,:,:,1)),double(inv_map.img(:,:,:,3)));

vww=load_nii_z([atlasbasename,'.bfc.nii']);
vtissue1=vww;
vww.img=v_w; vww.img=vww.img.*double(vtissue1.img>0);
save_untouch_nii_gz(vww,[subbasename_tmp,'.invsvreg.nii.gz']);

[J3]=myjacobian3dmap(xmap, ymap, zmap);
v=load_nii_z([subbasename_tmp,'.invsvreg.nii.gz']);
v.img=J3;
v.hdr.dime.datatype=16;v.hdr.dime.bitpix=16;
save_untouch_nii_gz(v,[subbasename,'.svreg.inv.jacobian.nii.gz']);


%%Compute and output Jacobian of the svreg map
map=load_nii_z([subbasename_tmp,'.svreg.map.nii.gz']);

xmap=squeeze(map.img(:,:,:,1));
ymap=squeeze(map.img(:,:,:,2));
zmap=squeeze(map.img(:,:,:,3));
[J3]=myjacobian3dmap(xmap, ymap, zmap);
v=load_nii_z([subbasename_tmp,'.svreg.nii.gz']);
v.img=J3;
v.hdr.dime.datatype=16;v.hdr.dime.bitpix=16;
save_untouch_nii_gz(v,[subbasename,'.svreg.jacobian.nii.gz']);


