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

function vo=correct_bias_anand_chitresh(v,gm_pts,wm_pts,csf_pts,sm_radius)

v=load_nii_z_bfc([v.fileprefix,'.nii']);
v_label=load_nii_z_bfc([v.fileprefix(1:end-4),'.pvc.label.nii']);

vo=v;
%view_nii(v);
Msize=size(v.img);
% wm_avg=trimmean(v.img(v_label.img==2),50);
% gm_avg=trimmean(v.img(v_label.img==1),50);
% csf_avg=trimmean(v.img(v_label.img==0),50);
if(~sum(v_label.img==3))
    v_label.img=v_label.img+1;
end
% new BrainSUite labels
wm_avg=median(double(v.img(v_label.img==3)));
gm_avg=median(double(v.img(v_label.img==2)));
csf_avg=median(double(v.img(v_label.img==1)));

% old  BrainSUite labels
% wm_avg=median(double(v.img(v_label.img==2)));
% gm_avg=median(double(v.img(v_label.img==1)));
% csf_avg=median(double(v.img(v_label.img==0)));



vor=v;
Msz=size(v.img);
MX=max(Msz);
NewSz=round([64*Msz(1)/MX,64*Msz(2)/MX,64*Msz(3)/MX]);
v=resample_avw(v,NewSz);
v_label=resample_avw(v_label,NewSz,'nearest');
res=v.hdr.dime.pixdim(2:4);

Msizer=size(v.img);

%wm_pts=[];%[130,120,198];
%gm_pts=[133,93,191];
%csf_pts=[];

wm_pts=round(wm_pts);gm_pts=round(gm_pts);csf_pts=round(csf_pts);
wm_pts_or=sub2ind(Msize,wm_pts(:,1),wm_pts(:,2),wm_pts(:,3));
gm_pts_or=sub2ind(Msize,gm_pts(:,1),gm_pts(:,2),gm_pts(:,3));
csf_pts_or=sub2ind(Msize,csf_pts(:,1),csf_pts(:,2),csf_pts(:,3));



wm_pts(:,1)=wm_pts(:,1)*Msizer(1)/Msize(1);wm_pts(:,2)=wm_pts(:,2)*Msizer(2)/Msize(2);wm_pts(:,3)=wm_pts(:,3)*Msizer(3)/Msize(3);
gm_pts(:,1)=gm_pts(:,1)*Msizer(1)/Msize(1);gm_pts(:,2)=gm_pts(:,2)*Msizer(2)/Msize(2);gm_pts(:,3)=gm_pts(:,3)*Msizer(3)/Msize(3);
csf_pts(:,1)=csf_pts(:,1)*Msizer(1)/Msize(1);csf_pts(:,2)=csf_pts(:,2)*Msizer(2)/Msize(2);csf_pts(:,3)=csf_pts(:,3)*Msizer(3)/Msize(3);

wm_pts=round(wm_pts);gm_pts=round(gm_pts);csf_pts=round(csf_pts);
wm_pts=sub2ind(Msizer,wm_pts(:,1),wm_pts(:,2),wm_pts(:,3));
gm_pts=sub2ind(Msizer,gm_pts(:,1),gm_pts(:,2),gm_pts(:,3));
csf_pts=sub2ind(Msizer,csf_pts(:,1),csf_pts(:,2),csf_pts(:,3));





b=ones(length(v.img(:)),1);
b(wm_pts)=wm_avg./double(vor.img(wm_pts_or));% -1;
b(gm_pts)=gm_avg./double(vor.img(gm_pts_or));% -1;
%b(csf_pts)=csf_avg./v.img(csf_pts) -1;
vmsk=v;
vmsk.img=vmsk.img*0;
vmsk.img(gm_pts)=1;
vmsk.img(wm_pts)=1;
%vmsk.img(csf_pts)=1;


radius = 55;
r1 = (1:2*radius)-radius;
[r1, r2, r3] = ndgrid(r1, r1, r1);
r1 = sqrt(r1.^2 + r2.^2 + r3.^2);
se3d = r1<=radius;

vmsk.img=imdilate(vmsk.img, se3d);
vmsk.img(gm_pts)=0;
vmsk.img(wm_pts)=0;
%vmsk.img(csf_pts)=0;


% ind=find(vmsk.img(:));
% ind=setdiff(ind,[wm_pts]);%;gm_pts;csf_pts]);
% B=dctbasis(Msizer(1),10);
% B2=kron(B,B);B3=kron(B2,B);
% B3o=B3;
% B3(ind,:)=[];b(ind)=[];
% xx1=lsqr(B3,b,1e-230,1000);
% 
% bias_f=(B3o*xx1+1);bias_f=bias_f.*(bias_f>1)+(bias_f<=1);
% vv=v;
% vv.img(:)=bias_f;
% 

img_size = Msizer;
%d = createDWithPeriodicBoundary3D(img_size(1), img_size(2), img_size(3));
%d = createDNoBoundary3D(img_size(1), img_size(2), img_size(3));
d = createDDWithDBoundary3D(img_size(1), img_size(2), img_size(3));

% % make edge points zero of 1st derivative
% bdrmsk=ones(img_size(1),img_size(2),img_size(3));
% bdrmsk(2:end-1,2:end-1,2:end-1)=0;
% t = spdiags([1-bdrmsk(:);1-bdrmsk(:);1-bdrmsk(:)] ,0,3*numel(bdrmsk),3*numel(bdrmsk));
% d = t*d;
% clear t bdrmsk


% % laplacian operator - comment out for no laplacian
%  n_vox = size(d,1)/3;
%  dx = d(1:n_vox, :);
%  dy = d(n_vox+1 : n_vox*2, :);
%  dz = d(n_vox*2+1 : end, :);
%  d_l = [dx*dx; dy*dy; dz*dz];
%  d = d_l;
%  clear d_l dx dy dz
% 
% % make two edge points zero of 2nd derivative
% bdrmsk=ones(img_size(1),img_size(2),img_size(3));
% bdrmsk(3:end-2,3:end-2,3:end-2)=0;
% t = spdiags([1-bdrmsk(:);1-bdrmsk(:);1-bdrmsk(:)] ,0,3*numel(bdrmsk),3*numel(bdrmsk));
% d = t*d;
% clear t bdrmsk



% exact min-norm least sq fit
alpha = sm_radius;
d = [alpha*d;2*speye(size(d,2))];
M1 = speye(prod(img_size));
M2 = speye(prod(img_size));
mag_msk = vmsk.img==0 ;% mask of known values
M1(:, ~mag_msk) = [];
M2(:, mag_msk) = [];
M = speye(prod(img_size));
M(~mag_msk, :) = [];
b=b-1;
b2 = -1*d*M1*M*double(b);
A = d*M2;
x2 = lsqr(A, b2, 1e-16, 1500);
xx1 = M1*M*double(b) + M2*x2 +1;


% approximate weighted min-norm fit 
% alpha = 1;
% d = alpha*d;
% M = speye(prod(img_size));
% mag_msk =  vmsk.img==0; 
% M(~mag_msk, :) = [];
% 
% b2 = M*double(b);
% A = cat(1, M, d);
% b2(size(A,1)) = 0;
% xx1 = lsqr(A, b2, 1e-6, 1000);



bias_f=(xx1); %+1);
vv=v;
vv.img(:)=bias_f;



%vv.img=vv.img.*(b(gm_pts)/vv.img(gm_pts));
vv=resample_avw(vv,Msize);
% [gm_pts(:,1),gm_pts(:,2),gm_pts(:,3)]=ind2sub(Msizer,gm_pts);
% gm_pts(:,1)=gm_pts(:,1)*Msize(1)/Msizer(1);gm_pts(:,2)=gm_pts(:,2)*Msize(2)/Msizer(2);gm_pts(:,3)=gm_pts(:,3)*Msize(3)/Msizer(3);
% gm_pts=sub2ind(Msize,gm_pts(:,1),gm_pts(:,2),gm_pts(:,3));

%view_nii(vo);vo.img(gm_pts)
vo.img(:)=vv.img(:).*double(vo.img(:));
view_nii(vv);
view_nii(vo);

%vo.img=int16(vo.img);

v_write = vo;
v_write.hdr = vo.m_orig.hdr;
v_write.untouch = vo.m_orig.untouch;
v_write.filetype = vo.m_orig.filetype;
v_write = rmfield(v_write, 'm_orig');
save_untouch_nii(v_write,[v.fileprefix(1:end-4),'.corr.nii']);
gzip([v.fileprefix(1:end-4),'.corr.nii']);
delete([v.fileprefix(1:end-4),'.corr.nii']);

vv_write = vv;
vv_write.hdr = vo.m_orig.hdr;
vv_write.untouch = vo.m_orig.untouch;
vv_write.filetype = vo.m_orig.filetype;
vv_write = rmfield(vv_write, 'm_orig');
vv_write.hdr.dime.datatype=64;
save_untouch_nii_gz(vv_write,[v.fileprefix(1:end-4),'.bias.nii.gz']);
%gzip([v.fileprefix(1:end-4),'.bias.nii']);
%delete([v.fileprefix(1:end-4),'.bias.nii']);


