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


%clear all;
function extend_deformation_laplacian_hippo(subbasename,subbasename_tmp,data_fit)
%subbasename='C:\Users\ajoshi\Downloads\BSA/2523412';
%subbasename_tmp='C:\Users\ajoshi\Downloads\BSA/2523412.svreg.tmp/2523412';
if ~exist('data_fit','var')
    data_fit=5;%was .1 originally
end
brain_mask=load_nii_z([subbasename,'.cerebrum.mask.nii.gz']);
%pix = 5; [x1,y1,z1] = ndgrid(-pix:pix);
%se1 = (sqrt(x1.^2 + y1.^2 + z1.^2) <=pix);
%brain_mask.img=imdilate(brain_mask.img,se1);
SZ=size(brain_mask.img);
brain_mask.img([1,SZ(1)],:,:)=0;brain_mask.img(:,[1,SZ(2)],:)=0;brain_mask.img(:,:,[1,SZ(3)])=0;
save_untouch_nii_gz(brain_mask,[subbasename_tmp,'.dilated.mask.nii.gz']);
mask_ind=find(brain_mask.img(:)>0);
[~,bdr_indxMSK]=find_mask_bdr(mask_ind,size(brain_mask.img));
res=brain_mask.hdr.dime.pixdim(2:4);
alpha=11/sqrt(res(1)*res(2)*res(3));%alpha=alpha*0.00;
alpha=alpha*speye(length(mask_ind),length(mask_ind));
%alpha=.01;
hippo1=load_nii_z([subbasename_tmp,'.target.hippo_carved.nii.gz']);

cerebrum_mask=load_nii_z([subbasename,'.cortex.dewisp.mask.nii.gz']);
cerebrum_mask.img=double(cerebrum_mask.img);

pial1=readdfs([subbasename,'.pial.cortex.dfs']);
ind1=sub2ind(size(cerebrum_mask.img),round(pial1.vertices(:,1)/res(1)) +1,round(pial1.vertices(:,2)/res(2)) +1,round(pial1.vertices(:,3)/res(3)) +1);
cerebrum_mask.img(ind1)=200;
%pial1=readdfs([subbasename,'.mid.cortex.dfs']);
%ind1=sub2ind(size(cerebrum_mask.img),round(pial1.vertices(:,1)/res(1)) +1,round(pial1.vertices(:,2)/res(2)) +1,round(pial1.vertices(:,3)/res(3)) +1);
%cerebrum_mask.img(ind1)=200;
%pial1=readdfs([subbasename,'.inner.cortex.dfs']);
%ind1=sub2ind(size(cerebrum_mask.img),round(pial1.vertices(:,1)/res(1)) +1,round(pial1.vertices(:,2)/res(2)) +1,round(pial1.vertices(:,3)/res(3)) +1);
%cerebrum_mask.img(ind1)=200;
inner1=readdfs([subbasename,'.inner.cortex.dfs']);
ind1=sub2ind(size(cerebrum_mask.img),round(inner1.vertices(:,1)/res(1)) +1,round(inner1.vertices(:,2)/res(2)) +1,round(inner1.vertices(:,3)/res(3)) +1);
cerebrum_mask.img(ind1)=200;

midv=(pial1.vertices+inner1.vertices)/2;
ind1=sub2ind(size(cerebrum_mask.img),round(midv(:,1)/res(1)) +1,round(midv(:,2)/res(2)) +1,round(midv(:,3)/res(3)) +1);
cerebrum_mask.img(ind1)=200;


pial_ind1=find(cerebrum_mask.img(mask_ind)==200);
%alpha(ind1,ind1)=.1;
Msize=size(cerebrum_mask.img);
affine_map=load_nii_z([subbasename_tmp,'.affine.map.nii.gz']);
affine_map.img=double(affine_map.img);
v_hippo=interp3(hippo1.img,affine_map.img(:,:,:,2),affine_map.img(:,:,:,1),affine_map.img(:,:,:,3),'nearest');
warped_hippo=brain_mask;
warped_hippo.img=v_hippo;
save_untouch_nii_gz(warped_hippo,[subbasename_tmp,'.warped.hippo_carved.nii.gz'])

msk1=((double(cerebrum_mask.img)-double(v_hippo))>0);
%disp('Hippo Mask deleted');

%cerebrum_mask.img=cerebrum_mask.img.*(v_hippo>0);
%clear v_hippo
%save_untouch_nii_gz(cerebrum_mask,[subbasename_tmp,'.target.cortex.dewisp.mask.nii.gz']);
map=load_nii_z([subbasename_tmp,'.surfreg.map.nii.gz']);
diff_mapx=map.img(:,:,:,1)-affine_map.img(:,:,:,1);diff_mapx(msk1)=0;
diff_mapy=map.img(:,:,:,2)-affine_map.img(:,:,:,2);diff_mapy(msk1)=0;
diff_mapz=map.img(:,:,:,3)-affine_map.img(:,:,:,3);diff_mapz(msk1)=0;

diff_mapx=diff_mapx(mask_ind);
diff_mapy=diff_mapy(mask_ind);
diff_mapz=diff_mapz(mask_ind);
msk=double(cerebrum_mask.img).*double(v_hippo);
%known_pts_ind=find(msk(mask_ind));
%known_pts_ind=find(1:length(mask_ind));
known_pts_ind=unique(union(union(find(msk(mask_ind)),bdr_indxMSK),pial_ind1));
unknown_pts_ind=1:length(mask_ind);
unknown_pts_ind(known_pts_ind)=[];
%[~,gm_ind]=intersect(unknown_pts_ind,ind1,'stable');
%[L1,L2,L3] = createDDWithDBoundary3Dmsk(Msize(1), Msize(2),Msize(3),mask_ind,[]);L=L1+L2+L3; clear L1 L2 L3;L=alpha*L;
[L1,L2,L3]=createDWithPeriodicBoundary3Dmsk(Msize(1), Msize(2), Msize(3),mask_ind);L=[alpha*L1;alpha*L2;alpha*L3];

%L=L(mask_ind,mask_ind);
A=speye(length(mask_ind));
%A=sparse(length(mask_ind),length(mask_ind));%A(sub2ind(size(A),ind1,ind1))=1000;
ind1=find(msk(mask_ind)>0);
A(sub2ind([length(mask_ind),length(mask_ind)],ind1,ind1))=data_fit;
A(unknown_pts_ind,:)=[];
%[~,ind1]=intersect(known_pts_ind,ind1,'stable');
b{1}=zeros(3*length(mask_ind)+length(known_pts_ind),1);b{2}=b{1};b{3}=b{1};
b{1}(3*length(mask_ind)+1:end)=data_fit*[diff_mapx(known_pts_ind)];%b{1}(length(mask_ind)+ind1)=data_fit*b{1}(length(mask_ind)+ind1);
b{2}(3*length(mask_ind)+1:end)=data_fit*[diff_mapy(known_pts_ind)];%b{2}(length(mask_ind)+ind1)=data_fit*b{2}(length(mask_ind)+ind1);
b{3}(3*length(mask_ind)+1:end)=data_fit*[diff_mapz(known_pts_ind)];%b{3}(length(mask_ind)+ind1)=data_fit*b{3}(length(mask_ind)+ind1);

A = [L;A];clear L;
b{1}=A'*b{1};b{2}=A'*b{2};b{3}=A'*b{3};
A=A'*A;
disp1('Extending the map','extend_deformation','mt');%dtd=d'*d;
M=(diag(A)+eps);
save([subbasename_tmp,'.tmpextension.mat'], 'map', 'affine_map', 'cerebrum_mask','mask_ind','-v7.3');
clear  map affine_map cerebrum_mask mask_ind unknown_pts_ind diff_mapx diff_mapy diff_mapz brain_mask x1 y1 z1 known_pts_ind;
for jj=1:3
    %deformation{jj} = pcg(A, b{jj}, 1e-16, 300);    
    deformation{jj} = mypcg(A, b{jj}, 1e-16, 500,M);
end
load([subbasename_tmp,'.tmpextension.mat'])
disp1('Done','extend_deformation','mt');
clear A
axmap=affine_map.img(:,:,:,1);aymap=affine_map.img(:,:,:,2);azmap=affine_map.img(:,:,:,3);
xmap=axmap;ymap=aymap;zmap=azmap;
xmap(mask_ind)=deformation{1}+axmap(mask_ind);
ymap(mask_ind)=deformation{2}+aymap(mask_ind);
zmap(mask_ind)=deformation{3}+azmap(mask_ind);

map=load_nii_z([subbasename_tmp,'.surfreg.map.nii.gz']);
map.img(:,:,:,1)=xmap;map.img(:,:,:,2)=ymap;map.img(:,:,:,3)=zmap;
save_untouch_nii_gz(map,[subbasename_tmp,'.surfreg.map.nii.gz']);

v_atlas=load_nii_z([subbasename_tmp,'.target.pvc.frac.nii.gz']);

v_w=trilinear(double(v_atlas.img),double(map.img(:,:,:,2)),double(map.img(:,:,:,1)),double(map.img(:,:,:,3)));v_atlas.img=[];
%v_w=double(truncate(v_w,12));
tissue1=load_nii_z([subbasename,'.pvc.frac.nii.gz']);
vww.hdr=tissue1.hdr;
vww.img=v_w;vww.untouch=1;
save_untouch_nii_gz(vww,[subbasename_tmp,'.surfreg.nii.gz']);



