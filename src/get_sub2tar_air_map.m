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


function  get_sub2tar_air_map(interm_file_base,sub_file_base,sub_file_base_tmp,tar_file_base,outfile1,outfile2)
vm2=load_nii(interm_file_base);mov_sz=size(vm2.img);
m_sz=size(vm2.img);

load([outfile2,'_AIR.mat']);
movmap.img=map;

vt=load_nii_z([tar_file_base,'.bfc.nii.gz']);tar_sz=size(vt.img);vtmsk=smooth3(double(vt.img),'gaussian',[23,23,23],15);
vm2msk=smooth3(double(vm2.img),'gaussian',[23,23,23],15);
vm2ind=find(vm2msk>0);
vtind=find(vtmsk>0);

[Xm,Ym,Zm]=ind2sub(m_sz,vm2ind);
[X2,Y2,Z2]=ind2sub(tar_sz,vtind);

[X1,Y1,Z1]=meshgrid(1:mov_sz(2),1:mov_sz(1),1:mov_sz(3));

movmap.img=double(movmap.img);
xmovmap=movmap.img(:,:,:,1);ymovmap=movmap.img(:,:,:,2);zmovmap=movmap.img(:,:,:,3);
invmap=zeros([size(vm2.img),3]);invmapx=zeros(size(vm2.img));invmapy=invmapx;invmapz=invmapx;
clear movmap map vtmsk vt
tic
invmapx(vm2ind)=mygriddata3_IntNearestHack(xmovmap(vtind(1:2:end)),ymovmap(vtind(1:2:end)),zmovmap(vtind(1:2:end)),X2(1:2:end),Xm,Ym,Zm);toc; 
invmapy(vm2ind)=mygriddata3_IntNearestHack(xmovmap(vtind(1:2:end)),ymovmap(vtind(1:2:end)),zmovmap(vtind(1:2:end)),Y2(1:2:end),Xm,Ym,Zm);toc
invmapz(vm2ind)=mygriddata3_IntNearestHack(xmovmap(vtind(1:2:end)),ymovmap(vtind(1:2:end)),zmovmap(vtind(1:2:end)),Z2(1:2:end),Xm,Ym,Zm);toc
invmap(:,:,:,2)=invmapx;invmap(:,:,:,1)=invmapy;invmap(:,:,:,3)=invmapz;
%save tmp1;
load([outfile1,'_AIR.mat']);
movmap.img=map;

ymap=interp3(invmap(:,:,:,1),movmap.img(:,:,:,2),movmap.img(:,:,:,1),movmap.img(:,:,:,3));
xmap=interp3(invmap(:,:,:,2),movmap.img(:,:,:,2),movmap.img(:,:,:,1),movmap.img(:,:,:,3));
zmap=interp3(invmap(:,:,:,3),movmap.img(:,:,:,2),movmap.img(:,:,:,1),movmap.img(:,:,:,3));


% vs=load_nii_z([sub_file_base,'.bfc.nii.gz']); % read the info w/niftiinfo instead
clear map;
map.img(:,:,:,1)=xmap;map.img(:,:,:,2)=ymap;map.img(:,:,:,3)=zmap;

subjspace_info=niftiinfo([sub_file_base,'.bfc.nii.gz']);
dws_write_nii([sub_file_base_tmp,'.2Atlas_AIR.map.nii.gz'],single(map.img),subjspace_info); % dws 7/8/23 

map=load_nii_z([sub_file_base_tmp,'.2Atlas_AIR.map.nii.gz']);
vbfc=load_nii_z([tar_file_base,'.bfc.nii.gz']);
vlab=load_nii_z([tar_file_base,'.label.nii.gz']);

vw=interp3(double(vbfc.img),map.img(:,:,:,2),map.img(:,:,:,1),map.img(:,:,:,3));
vl=interp3(double(vlab.img),map.img(:,:,:,2),map.img(:,:,:,1),map.img(:,:,:,3));
vs=load_nii_z([sub_file_base,'.bfc.nii.gz']);
vs.img=vw;
save_untouch_nii_gz(vs,[sub_file_base_tmp,'.air_reg.nii.gz']);
vs.img=vl;
save_untouch_nii_gz(vs,[sub_file_base_tmp,'.air_reg.label.nii.gz']);



