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


function [inv_map]=invert_deformation_parallel(map,src_mask,tar_mask)

% map.img(:,:,:,1)=resample_vol(map1.img(:,:,:,1),[512 300 256]);
% map.img(:,:,:,2)=resample_vol(map1.img(:,:,:,2),[512 300 256]);
% map.img(:,:,:,3)=resample_vol(map1.img(:,:,:,3),[512 300 256]);
% src_mask=resample_avw(src_mask,[512,300,256]);

res_tar=tar_mask.hdr.dime.pixdim(2:4);
res_src=src_mask.hdr.dime.pixdim(2:4);
size_tar=size(tar_mask.img);
size_src=size(src_mask.img);size_src=size_src(1:3);
tar_mask_ind=find(tar_mask.img>0);src_mask_ind=find(src_mask.img>0);
%map.img=round(map.img);
mapx=squeeze(map.img(:,:,:,1));mapx=mapx(src_mask_ind);
mapy=squeeze(map.img(:,:,:,2));mapy=mapy(src_mask_ind);
mapz=squeeze(map.img(:,:,:,3));mapz=mapz(src_mask_ind);

clear map;
mapx=double(mapx);mapy=double(mapy);mapz=double(mapz);
[s{1},s{2},s{3}]=ind2sub(size_src,src_mask_ind);%sX=(sX-1)*res_src(1);sY=(sY-1)*res_src(2);sZ=(sZ-1)*res_src(3);
[tX,tY,tZ]=ind2sub(size_tar,tar_mask_ind);%tX=(tX-1)*res_tar(1);tY=(tY-1)*res_tar(2);tZ=(tZ-1)*res_tar(3);

inv_map{1}=single(zeros(size_tar(1),size_tar(2),size_tar(3)));
inv_map{2}=inv_map{1};inv_map{3}=inv_map{1};
clear src_mask src_mask_ind
for jj=1:3
    inv_map{jj}(tar_mask_ind)=mygriddata3_IntNearestHack(mapx,mapy,mapz,s{jj},tX,tY,tZ);
end
disp1('inverting map','invert_deformation');

inv_map=make_nii(single(cat(4,inv_map{1},inv_map{2},inv_map{3})),res_tar);

%inv_map.img = single(cat(4,inv_map{1},inv_map{2},inv_map{3}));

