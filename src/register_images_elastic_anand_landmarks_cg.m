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


function [warped_img,BX,BY] = register_images_elastic_anand_landmarks_cg(mov,ref,Options,flags)

%load surf_reg_data;
sigma_diff=5;
G = fspecial('gaussian',[75 75],sigma_diff);
vs=mov;vt=ref; %vs=1./(1+exp(-vs)) -0.5;vt=1./(1+exp(-vt)) -0.5;
 hh=hist(vs(:),500); vs(:)=histeq(vs(:),hh);vt(:)=histeq(vt(:),hh);
vs = imfilter(vs,G,'replicate','same');%vs=vs*20;
vt = imfilter(vt,G,'replicate','same');%vt=vt*20;

SZ=size(vs);
lmrkWt = exp(-(Options.dist_img'.^2/((1./1)*sigma_diff^2))); lmrkWt=1-lmrkWt./max(lmrkWt(:));

G = fspecial('gaussian',[7 7],3);
lmrkWt = imfilter(lmrkWt,G,'same');
%lmrkWt=lmrkWt.*(lmrkWt>.5);
%vt=vt.*lmrkWt;
%vs=vs.*lmrkWt;
[~,~,L]=laplacian([SZ(1),SZ(2)]);

[X,Y]=meshgrid(1:SZ(1),1:SZ(2));Xo=X;Yo=Y;
%WX=0*X(mask_ind);WY=0*Y(mask_ind);WZ=0*Z(mask_ind);
%warped_img=vs.img;

%alpha0=1;
regul_alpha=3.6;
L=regul_alpha*L;
%for jj=1:1000   
jj=1;
x=[X(:); Y(:)];
grad=cost_func_gradient2d(vs,vt,Options.dist_img,X,Y,L);
delta_x=-grad;
%alpha=linesearch2(.0001,.0001,delta_x,vs.img,vt.img,mask_ind,X,Y,Z,L);
%x=x+alpha*delta_x;

[x,cost1(jj),fcall]=backtrack_linesearch(x,delta_x,1e100,delta_x'*grad,.5,.8,eps,vs,vt,L);      
nit=50;
cost1(jj)=cost_func_int_reg2d(vs,vt,X,Y,L);
SZ=size(X);def_diff_l_inf=zeros(nit,1);
for jj=1:nit    
    X(:)=x(1:SZ(1)*SZ(2));Y(:)=x(1+SZ(1)*SZ(2):2*SZ(1)*SZ(2)); 
    grad=cost_func_gradient2d(vs,vt,Options.dist_img,X,Y,L);
    delta_x_old=delta_x;
    delta_x=-grad;%/max(abs(grad(:)));alpha1=1;
    s=delta_x;
    beta=delta_x'*(delta_x-delta_x_old)/(delta_x_old'*delta_x_old);
    s=delta_x+beta*s;
    %s([bdr_indxMSK;bdr_indxMSK+length(mask_ind);bdr_indxMSK+2*length(mask_ind)])=0;
 %   s=s.*[lmrkWt(:);lmrkWt(:)];
   
    [x,cost1(jj+1),fcall(jj)]=backtrack_linesearch(x,s,cost1(jj),s'*grad,.5,.3,eps,vs,vt,L);      
 %   linsearch_time(jj)=toc(kk); 
    disp1(sprintf('iter %d/%d f = %g, linesearch iter=%d',jj,nit,cost1(jj),fcall(jj)));
    %def_diff_l2(jj)=sqrt(sum((X(:)-Xo(:)).^2+(Y(:)-Yo(:)).^2));
    def_diff_l_inf(jj)=max(sqrt((X(:)-Xo(:)).^2+(Y(:)-Yo(:)).^2));
   % plot(def_diff_l_inf);drawnow;
    if def_diff_l_inf(jj) && jj>5 &&       abs(def_diff_l_inf(jj)-def_diff_l_inf(jj-4))<1e-6
        break;
    end
   % exec_time(jj)=toc(hh);
end
    X(:)=x(1:SZ(1)*SZ(2));Y(:)=x(1+SZ(1)*SZ(2):2*SZ(1)*SZ(2)); 
warped_img=interp2(vs,X,Y,'*linear',0);
BX=X-Xo;
BY=Y-Yo;
BX=BX.*lmrkWt;X=Xo+BX;
BY=BY.*lmrkWt;Y=Yo+BY;
[Xx,Xy]=gradient(X);
[Yx,Yy]=gradient(Y);

J=Xx.*Yy-Xy.*Yx;
%figure;imagesc(J<0);
%figure;imagesc(J);drawnow;
disp1(sprintf('Negative Jacobians in surf reg step = %d/%d',sum(J(:)<0),length(J(:))),'elastic_reg',flags)



function [grad,grad_sim,grad_reg]=cost_func_gradient2d(fs,ft,WT,xmap,ymap,L)
LtL=L'*L;SZ=size(xmap); clear L
[X,Y]=meshgrid(1:SZ(1),1:SZ(2));
grad_reg=[2*LtL*(xmap(:)-X(:));2*LtL*(ymap(:)-Y(:))];
wrpd=interp2(fs,xmap,ymap,'*linear',0); 
[Gx Gy]=gradient(fs);
grad_fsx=interp2(Gx,xmap,ymap,'*linear',0);
grad_fsy=interp2(Gy,xmap,ymap,'*linear',0);
%grad_fsx=Dx*wrpd(mask_ind);grad_fsy=Dy*wrpd(mask_ind);grad_fsz=Dz*wrpd(mask_ind);

grad_sim=[2*(wrpd(:) - ft(:));2*(wrpd(:) - ft(:))].*[grad_fsx(:);grad_fsy(:)];
%grad_sim(bdr)=0;grad_reg(bdr)=0;
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
    CC=cost_func_int_reg2d(fs,ft,mask_ind,xmap1,ymap1,zmap1,L,bdr_indxMSK);
    if CC<CF
        CF=CC;alpha1=alpha;
    else        
        return;
    end
    alpha=alpha+step11;jj
end


function [xn,fn,fcall,C_REG,C_SIM]=backtrack_linesearch(xc,d,fc,DDfnc,c,gamma,eps,vs,vt,L)
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
Msize=size(vs);
LMind   =  Msize(1)*Msize(2);

[X,Y]=meshgrid(1:Msize(1),1:Msize(2));
X(:)=xn(1:LMind);
Y(:)=xn(1+LMind:2*LMind);
[fn C_REG,C_SIM]    =    cost_func_int_reg2d(vs,vt,X,Y,L);

fcall   =   1 ;

while fn > fc+cDDfnc,
        d       =  gamma*d;
        cDDfnc  =  gamma*cDDfnc;
        xn      =  xc+d;
        %fn      =  feval(fnc,xn);
X(:)=xn(1:LMind);
Y(:)=xn(1+LMind:2*LMind);
        
        [fn C_REG,C_SIM]   =    cost_func_int_reg2d(vs,vt,X,Y,L);
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


function [C,C_REG,C_SIM]=cost_func_int_reg2d(fs,ft,xmap,ymap,L)
Msize=size(xmap);
[X,Y]=meshgrid(1:Msize(1),1:Msize(2));
wrpd=interp2(fs,xmap,ymap,'*linear',0);
imdiff=wrpd - ft;
%[J3]=myjacobian3dmap(xmap, ymap, zmap);
%indfull=[mask_ind,MS+mask_ind,2*MS+mask_ind];
C_SIM=imdiff(:).^2;
%C_SIM(bdr)=0;
C_SIM=sum(C_SIM);
C_REG=((L*(xmap(:)-X(:))).^2)+((L*(ymap(:)-Y(:))).^2);
%C_REG(bdr)=0;
C_REG=sum(C_REG);
C=C_REG+C_SIM;



