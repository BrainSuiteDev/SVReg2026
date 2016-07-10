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


function svreg_elastic_vol_reg_nonlin_cg(subbasename,subbasename_tmp,nit,regul_alpha)
%opengl software;clear all;close all;restoredefaultpath;
%addpath(genpath('/home/ajoshi/git_sandbox/svreg-matlab/dev'));
%addpath(genpath('/home/ajoshi/git_sandbox/svreg-matlab/src'));
%subbasename='C:\Users\ajoshi\Documents\git_sandbox\svreg-matlab\data2\brainsuite_subj1_m6';
%subbasename_tmp='C:\Users\ajoshi\Documents\git_sandbox\svreg-matlab\data2\brainsuite_subj1_m6.svreg.tmp\brainsuite_subj1_m6';

vs=load_nii_z([subbasename_tmp,'.surfreg.nii.gz']);vs.img=smooth3(double(vs.img),'gaussian',[9 9 9],1);
vt=load_nii_z([subbasename,'.pvc.frac.nii.gz']);vt.img=smooth3(double(vt.img),'gaussian',[9 9 9],1);
vs_mask=load_nii_z([subbasename,'.bfc.nii.gz']);
vs_mask.img=255*((vt.img>0)|(vs.img>0));
%vs_mask=load_nii_z([subbasename,'.cortex.dewisp.mask.nii.gz']);
res=vs.hdr.dime.pixdim(2:4);
s{1}=readdfs([subbasename,'.pial.cortex.dfs']);
s{2}=readdfs([subbasename,'.inner.cortex.dfs']);
s_mid=combine_surf(s);clear s;
s_mid.vertices(:,1)=s_mid.vertices(:,1)/res(1);
s_mid.vertices(:,2)=s_mid.vertices(:,2)/res(2);
s_mid.vertices(:,3)=s_mid.vertices(:,3)/res(3);
SZ=size(vs.img);
bdr1=sub2ind(SZ,round(s_mid.vertices(:,1)+1),round(s_mid.vertices(:,2)+1),round(s_mid.vertices(:,3)+1));
bdr1=unique(bdr1);

vs_mask.img([1,SZ(1)],:,:)=0;vs_mask.img(:,[1,SZ(2)],:)=0;vs_mask.img(:,:,[1,SZ(3)])=0;

mask_ind=find(vs_mask.img);%mask_ind2=find(vs_dewisp2.img);

%[bdr1,bdr_indxMSK2]=find_mask_bdr(mask_ind2,size(vs_dewisp2.img));
mask_ind=setdiff(mask_ind,bdr1);
[~,bdr_indxMSK]=find_mask_bdr(mask_ind,size(vs_mask.img));
%bdr_indxMSK=union(bdr_indxMSK,bdr_indxMSK2);
clear bdr_indxMSK2 vs_dewisp2;
%[DX,DY,DZ]=createDWithPeriodicBoundary3Dmsk(SZ(1),SZ(2),SZ(3),mask_ind,[]);
[L1,L2,L3]=createDDWithDBoundary3Dmsk(SZ(1),SZ(2),SZ(3),mask_ind);L=L1+L2+L3;clear L1 L2 L3;

[X,Y,Z]=ndgrid(1:SZ(1),1:SZ(2),1:SZ(3));Xo=X;Yo=Y;Zo=Z;
%WX=0*X(mask_ind);WY=0*Y(mask_ind);WZ=0*Z(mask_ind);
%warped_img=vs.img;

%alpha0=1;
if ~exist('regul_alpha','var')
    regul_alpha=0.35/sqrt(res(1)*res(2)*res(3));
end
L=regul_alpha*L;
%for jj=1:1000   
jj=1;
x=[X(mask_ind); Y(mask_ind); Z(mask_ind)];
grad=cost_func_gradient(vs.img,vt.img,mask_ind,X,Y,Z,L,bdr_indxMSK);
delta_x=-grad;
%alpha=linesearch2(.0001,.0001,delta_x,vs.img,vt.img,mask_ind,X,Y,Z,L);
%x=x+alpha*delta_x;

[x,cost1(jj),fcall]=backtrack_linesearch(x,delta_x,1e100,delta_x'*grad,.5,.8,eps,vs.img,vt.img,mask_ind,L,bdr_indxMSK);      
%nit=150;
cost1(jj)=cost_func_int_reg(vs.img,vt.img,mask_ind,X,Y,Z,L,bdr_indxMSK);fprintf('iter=%d\n',jj);
%hh=tic;
def_diff_l_inf=zeros(nit,1);
for jj=1:nit    
    X(mask_ind)=x(1:length(mask_ind));Y(mask_ind)=x(1+length(mask_ind):2*length(mask_ind));Z(mask_ind)=x(1+2*length(mask_ind):3*length(mask_ind));    
    def_diff_l_inf(jj)=max(sqrt((X(:)-Xo(:)).^2+(Y(:)-Yo(:)).^2+(Z(:)-Zo(:)).^2));
    if def_diff_l_inf(jj) && jj>5 && abs(def_diff_l_inf(jj)-def_diff_l_inf(jj-4))<1e-6
        break;
    end
    grad=cost_func_gradient(vs.img,vt.img,mask_ind,X,Y,Z,L,[]);
    delta_x_old=delta_x;
    delta_x=-grad;%/max(abs(grad(:)));alpha1=1;
    s=delta_x;
    beta=delta_x'*(delta_x-delta_x_old)/(delta_x_old'*delta_x_old);
    s=delta_x+beta*s;
    s([bdr_indxMSK;bdr_indxMSK+length(mask_ind);bdr_indxMSK+2*length(mask_ind)])=0;
    [x,cost1(jj+1),fcall]=backtrack_linesearch(x,s,cost1(jj),s'*grad,.5,.2,eps,vs.img,vt.img,mask_ind,L,bdr_indxMSK);      
    %plot(cost1);drawnow;

    disp1(sprintf('iter %d/%d f = %g, linesearch iter=%d',jj,nit,cost1(jj),fcall));
end
%aa=toc(hh)
%save grad_desc21 cost1 cost_imdiff
    X(mask_ind)=x(1:length(mask_ind));Y(mask_ind)=x(1+length(mask_ind):2*length(mask_ind));Z(mask_ind)=x(1+2*length(mask_ind):3*length(mask_ind));    
%X(mask_ind)=Xo(mask_ind)+WX;Y(mask_ind)=Yo(mask_ind)+WY;Z(mask_ind)=Zo(mask_ind)+WZ;
warped_img=interp3(vs.img,Y,X,Z,'*linear',0);

im_diff=vt.img(mask_ind)-warped_img(mask_ind);

%view_nii(vs);
%view_nii(vt);
vs.img=warped_img;
%view_nii(vs);
ymap=Y;xmap=X;zmap=Z;
vmap=load_nii_z([subbasename_tmp,'.surfreg.map.nii']);
xmap2=trilinear(double(vmap.img(:,:,:,1)),ymap,xmap,zmap);
ymap2=trilinear(double(vmap.img(:,:,:,2)),ymap,xmap,zmap);
zmap2=trilinear(double(vmap.img(:,:,:,3)),ymap,xmap,zmap);
clear xmap ymap zmap;

%[J3]=myjacobian3dmap(xmap2, ymap2, zmap2);%myjacobian3d1([xmap(src_mask.img>0);ymap(src_mask.img>0);zmap(src_mask.img>0)],size(map.img),find(src_mask.img>0),map.hdr.dime.pixdim(2:4));

vmap.img(:,:,:,1)=xmap2;vmap.img(:,:,:,2)=ymap2;vmap.img(:,:,:,3)=zmap2;

save_untouch_nii_gz(vmap,[subbasename_tmp,'.svreg.map.nii.gz']);
copyfile([subbasename_tmp,'.svreg.map.nii.gz'],[subbasename,'.svreg.map.nii.gz'],'f')

if ~exist('cbm_name','var')
    cbm_name=sprintf('%s.cerebrum.mask.nii',subbasename);
end
%gunzip(sprintf('%s.cerebrum.mask.nii.gz',subbasename));
vhemi=load_nii_z(cbm_name);
vhemi.img(vhemi.img>0)=1;


vsl=load_nii_z([subbasename_tmp,'.target.label.nii']);
vsl.img=interp3(vsl.img,(ymap2),(xmap2),(zmap2),'nearest',0);
%vsl.img=vsl.img.*int16(vhemi.img);

%vsl.img(vsl.img==344|vsl.img==345|vsl.img==346|vsl.img==347)=0;

vsl.hdr=vhemi.hdr;vsl.hdr.dime.datatype=4;
save_untouch_nii_gz(vsl,sprintf('%s.svreg.label.nii.gz',subbasename_tmp));

copyfile(sprintf('%s.svreg.label.nii.gz',subbasename_tmp),sprintf('%s.svreg.init.label.nii.gz',subbasename),'f');

v_atlas=load_nii_z([subbasename_tmp,'.target.pvc.frac.nii']);

v_w=trilinear(double(v_atlas.img),double(vmap.img(:,:,:,2)),double(vmap.img(:,:,:,1)),double(vmap.img(:,:,:,3)));
v_w1=interp3(double(v_atlas.img),double(vmap.img(:,:,:,2)),double(vmap.img(:,:,:,1)),double(vmap.img(:,:,:,3)),'nearest');v_atlas.img=[];

v_w=double(truncate(v_w,12));
v_w1=double(truncate(v_w1,12));

tissue1=load_nii_BIG_Lab([subbasename,'.pvc.frac.nii.gz']);
vww=tissue1;
vww.img=v_w; vww.img=vww.img.*double(tissue1.img>0);
save_untouch_nii_gz(vww,[subbasename_tmp,'.svreg.nii.gz']);
vww.img=v_w1; vww.img=vww.img.*double(tissue1.img>0);
%save_untouch_nii_gz(vww,[subbasename_tmp,'.svreg_nn.nii.gz']);

%vww.img=J3;
%save_untouch_nii_gz(vww,[subbasename_tmp,'.jacobian.svreg.nii.gz']);
disp1('Intensity registration is done')

function [C,C_REG,C_SIM]=cost_func(fs,ft,mask_ind,xmap,ymap,zmap,L)
Msize=size(xmap);
[X,Y,Z]=ndgrid(1:Mfsize(1),1:Msize(2),1:Msize(3));
wrpd=interp3(fs,ymap,xmap,zmap,'*linear',0);
imdiff=wrpd - ft;
%[J3]=myjacobian3dmap(xmap, ymap, zmap);
%indfull=[mask_ind,MS+mask_ind,2*MS+mask_ind];
C_SIM=sum(imdiff(mask_ind).^2);
C_REG=sum(L*(xmap(mask_ind)-X(mask_ind)).^2)+sum(L*(ymap(mask_ind)-Y(mask_ind)).^2)+sum(L*(zmap(mask_ind)-Z(mask_ind)).^2);
C=C_REG+C_SIM;

function [grad,grad_sim,grad_reg]=cost_func_gradient(fs,ft,mask_ind,xmap,ymap,zmap,L,bdr)
LtL=L'*L;SZ=size(xmap); clear L;
[X,Y,Z]=ndgrid(1:SZ(1),1:SZ(2),1:SZ(3));
grad_reg=[2*LtL*(xmap(mask_ind)-X(mask_ind));2*LtL*(ymap(mask_ind)-Y(mask_ind));2*LtL*(zmap(mask_ind)-Z(mask_ind))];
wrpd=interp3(fs,ymap,xmap,zmap,'*linear',0);clear X Y Z
[Gy Gx Gz]=gradient(fs);
grad_fsx=interp3(Gx,ymap,xmap,zmap,'*linear',0);grad_fsx=grad_fsx(mask_ind); clear Gx
grad_fsy=interp3(Gy,ymap,xmap,zmap,'*linear',0);grad_fsy=grad_fsy(mask_ind); clear Gy
grad_fsz=interp3(Gz,ymap,xmap,zmap,'*linear',0);grad_fsz=grad_fsz(mask_ind); clear Gz
%grad_fsx=Dx*wrpd(mask_ind);grad_fsy=Dy*wrpd(mask_ind);grad_fsz=Dz*wrpd(mask_ind);

grad_sim=[2*(wrpd(mask_ind) - ft(mask_ind));2*(wrpd(mask_ind) - ft(mask_ind));2*(wrpd(mask_ind) - ft(mask_ind))].*[grad_fsx;grad_fsy;grad_fsz];
grad_sim(bdr)=0;grad_reg(bdr)=0;
grad=grad_reg+grad_sim;


function alpha1=linesearch(step11,alpha0,d,fs,ft,mask_ind,xmap,ymap,zmap,L)
alpha=alpha0;CF=1e100;alpha1=alpha;
for jj=1:10
    xmap1=xmap; ymap1=ymap; zmap1=zmap;
    xmap1(mask_ind)=xmap1(mask_ind)+alpha*d(1:length(mask_ind));
    ymap1(mask_ind)=ymap1(mask_ind)+alpha*d(1+length(mask_ind):2*length(mask_ind));
    zmap1(mask_ind)=zmap1(mask_ind)+alpha*d(1+2*length(mask_ind):3*length(mask_ind));
    CC=cost_func(fs,ft,mask_ind,xmap1,ymap1,zmap1,L);
    if CC<CF
        CF=CC;alpha1=alpha;
    else
        
        return;
    end
    alpha=alpha+step11;jj
end



function alpha1=linesearch2(step11,alpha0,d,fs,ft,mask_ind,xmap,ymap,zmap,L)
alpha=alpha0;CF=1e100;alpha1=alpha;
for jj=1:10
    xmap1=xmap; ymap1=ymap; zmap1=zmap;
    xmap1(mask_ind)=xmap1(mask_ind)+alpha*d(1:length(mask_ind));
    ymap1(mask_ind)=ymap1(mask_ind)+alpha*d(1+length(mask_ind):2*length(mask_ind));
    zmap1(mask_ind)=zmap1(mask_ind)+alpha*d(1+2*length(mask_ind):3*length(mask_ind));
    [bdr_ind,bdr_indxMSK]=find_mask_bdr(mask_ind,size(fs));
    CC=cost_func_int_reg(fs,ft,mask_ind,xmap1,ymap1,zmap1,L,bdr_indxMSK);
    if CC<CF
        CF=CC;alpha1=alpha;
    else        
        return;
    end
    alpha=alpha+step11;jj
end


function [xn,fn,fcall]=backtrack_linesearch(xc,d,fc,DDfnc,c,gamma,eps,vs,vt,mask_ind,L,bdr_indxMSK)
if DDfnc >= 0,
        error('The backtracking subroutine has been sent a direction of nondescent. Program has been terminated.')
end
if c<= 0 | c>= 1,
        error('The slope modification parameter c in the backtracking subroutine is not in (0,1).')
end
if gamma<=0 | gamma >=1,
        error('The backtracking parameter gamma is not in (0,1).')
end
if eps <= 0,
        error('The termination criteria eps sent to the backtracking line search is not positive.')
end
if size(xc)~=size(d)
        error('The vectors sent to backtrack are not of the same dimension.')
end

xn      =   xc+d;
cDDfnc  =   c*DDfnc;
%fn      =   feval(fnc,xn);
LMind   =  length(mask_ind);Msize=size(vs);
[X,Y,Z]=ndgrid(1:Msize(1),1:Msize(2),1:Msize(3));
X(mask_ind)=xn(1:LMind);
Y(mask_ind)=xn(1+LMind:2*LMind);
Z(mask_ind)=xn(1+2*LMind:3*LMind);
fn    =    cost_func_int_reg(vs,vt,mask_ind,X,Y,Z,L,bdr_indxMSK);

fcall   =   1 ;

while fn > fc+cDDfnc,
        d       =  gamma*d;
        cDDfnc  =  gamma*cDDfnc;
        xn      =  xc+d;
        %fn      =  feval(fnc,xn);
X(mask_ind)=xn(1:LMind);
Y(mask_ind)=xn(1+LMind:2*LMind);
Z(mask_ind)=xn(1+2*LMind:3*LMind);
        
        fn    =    cost_func_int_reg(vs,vt,mask_ind,X,Y,Z,L,bdr_indxMSK);
        %fprintf('iter=%d\n',jj);

        fcall   =  fcall+1;

%Check if the step to xn is too small.
        if norm(d) <= eps,
        disp('linesearch step too small');
                if fn >= fc,
                        xn  =  xc;
                end
                break
        end
end


