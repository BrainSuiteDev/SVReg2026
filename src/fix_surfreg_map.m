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


function fix_surfreg_map(subbasename,subbasename_tmp,atlasbasename)

copyfile([subbasename_tmp,'.surfreg.map.nii.gz'],[subbasename_tmp,'.orig.surfreg.map.nii.gz'],'f');

map=load_nii_z([subbasename_tmp,'.surfreg.map.nii']);
tar_mask=load_nii_z([atlasbasename,'.bfc.nii']);

src_mask=load_nii_z([subbasename,'.bfc.nii']);
tar_mask.img=smooth3(double(tar_mask.img),'gaussian',[13,13,13],5);%tar_mask.img=smooth3(double(tar_mask.img));
src_mask.img=smooth3(double(src_mask.img),'gaussian',[13,13,13],5);%tar_mask.img=smooth3(double(tar_mask.img));

%map.img(:,:,:,1)=smooth3(map.img(:,:,:,1),'gaussian',[13,13,13],0.5);
%map.img(:,:,:,2)=smooth3(map.img(:,:,:,2),'gaussian',[13,13,13],0.5);
%map.img(:,:,:,3)=smooth3(map.img(:,:,:,3),'gaussian',[13,13,13],0.5);
tic
%[inv_map2]=invert_deformation_iterative(map,src_mask,tar_mask)
[inv_map]=invert_deformation_parallel(map,src_mask,tar_mask);

toc
[fwd_map]=invert_deformation_parallel(inv_map,tar_mask,src_mask);
toc
[inv_map]=invert_deformation_parallel(fwd_map,src_mask,tar_mask);
toc
[fwd_map]=invert_deformation_parallel(inv_map,tar_mask,src_mask);
toc
[inv_map]=invert_deformation_parallel(fwd_map,src_mask,tar_mask);
toc
[fwd_map]=invert_deformation_parallel(inv_map,tar_mask,src_mask);
toc
[inv_map]=invert_deformation_parallel(fwd_map,src_mask,tar_mask);
toc
[fwd_map]=invert_deformation_parallel(inv_map,tar_mask,src_mask);

% [inv_map]=invert_deformation_parallel(fwd_map,src_mask,tar_mask,tar_masko);
% [fwd_map]=invert_deformation_parallel(inv_map,tar_mask,src_mask,src_mask);

%save_nii(inv_map,[subbasename,'.surfreg.invmap.nii.gz']);
%fixBSheader([atlasbasename,'.bfc.nii.gz'], [subbasename,'.svreg.invmap.nii.gz'], [subbasename,'.svreg.invmap.nii.gz']);
xmap1=fwd_map.img(:,:,:,1);ymap1=fwd_map.img(:,:,:,2);zmap1=fwd_map.img(:,:,:,3);
xmap=map.img(:,:,:,1);ymap=map.img(:,:,:,2);zmap=map.img(:,:,:,3);
xmap1(src_mask.img==0)=xmap(src_mask.img==0);ymap1(src_mask.img==0)=ymap(src_mask.img==0);zmap1(src_mask.img==0)=zmap(src_mask.img==0);
fwd_map.img(:,:,:,1)=xmap1;fwd_map.img(:,:,:,2)=ymap1;fwd_map.img(:,:,:,3)=zmap1; clear xmap* ymap* zmap*;
save_nii(fwd_map,[subbasename_tmp,'.surfreg.map.nii.gz']);
fixBSheader([subbasename,'.bfc.nii.gz'], [subbasename_tmp,'.surfreg.map.nii.gz'], [subbasename_tmp,'.surfreg.map.nii.gz']);


