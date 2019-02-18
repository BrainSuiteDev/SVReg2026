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



function [x_map1,y_map1,x_map2,y_map2]=mymap_le_align_varsig_ini(surf1,surf2,pinnedVertx1,pinnedVertx2,...
    xbdrL,ybdrL,xbdrR,ybdrR,C1,C2,sigma,Pp,mu,lambda,x_map1,y_map1,x_map2,y_map2,flags)
%Tries to align C1 and C2 curves by quadratic penalty
NumVertx1=size(surf1.vertices,1);
NumVertx2=size(surf2.vertices,1);

A1=getA(surf1,Pp,mu,lambda);
A2=getA(surf2,Pp,mu,lambda);
A=[A1,sparse(size(A1,1),2*NumVertx2);
    sparse(size(A2,1),2*NumVertx1),A2];
%NumPinnedVertx=size(pinnedVertx1,1);
%NumfreeVertx=size(surf1.vertices,1)-NumPinnedVertx;
rowno=[1:length(C1),1:length(C1),length(C1)+1:2*length(C1),length(C1)+1:2*length(C1)]';
colno=[C1;2*NumVertx1+C2;NumVertx1+C1;2*NumVertx1+NumVertx2+C2];
if isempty(sigma)
    dat=[];
else
    dat=[sigma;sigma;sigma;sigma].*[ones(size(C1));-ones(size(C2));ones(size(C1));-ones(size(C2))];
end
E=sparse(rowno,colno,dat,2*length(C1),2*NumVertx1+2*NumVertx2);
A=[A;E];

pinnedVertx=[pinnedVertx1;NumVertx1+pinnedVertx1;2*NumVertx1+pinnedVertx2;2*NumVertx1+NumVertx2+pinnedVertx2];
indxFV=[1:2*NumVertx1+2*NumVertx2]';indxFV(pinnedVertx)=[];

A_f=A(:,indxFV); b1=sparse(-A(:,pinnedVertx));
pinnedval = [xbdrL;ybdrL;xbdrR;ybdrR];
b1=b1*pinnedval;%[pinnedX;pinnedY];
AtA=A_f'*A_f; M=(diag(AtA)+eps);
clear *all X Y Z i A A2 A1
%tic
%   u1u2_map=mypcg(AtA,A_f'*b1,1e-20,600,M);/********* 600 are enough***/
u1u2map_ini=[x_map1;y_map1;x_map2;y_map2]; u1u2map_ini= u1u2map_ini(indxFV);
u1u2_map=mypcg_lp(AtA,A_f'*b1,1e-112,2600,M,u1u2map_ini,flags);

%     disp('computing incomplete Cholesky decomposition of the systemmatrix after reordering');
%             ik = symamd(AtA);
%             q= A_f'*b1;
%             Q = AtA(ik,ik);
%             L = cholinc(Q,1e-3);disp('chol done');
%            qN = q(ik);
%                 [xN,flag]=pcg(Q,qN,1e-20,50,L',L);
%                 x(ik) = xN;u1u2_map = x';
% %u1u2_map=pcg(AtA,A_f'*b1,1e-20,600);
%toc
u1u2_map([indxFV;pinnedVertx])=[u1u2_map;pinnedval];
x_map1=u1u2_map(1:NumVertx1);
y_map1=u1u2_map(NumVertx1+1:2*NumVertx1);
x_map2=u1u2_map(2*NumVertx1+1:2*NumVertx1+NumVertx2);
y_map2=u1u2_map(2*NumVertx1+NumVertx2+1:2*(NumVertx1+NumVertx2));

if(Pp~=2)
    %    for jjj=1:20
    x_map=mypcgdlp(A_f,b1_x,x_map,1e-112,16000,Pp);%<----
    y_map=mypcgdlp(A_f,b1_y,y_map,1e-112,16000,Pp);%<----
    % save temppp1 x_map y_map
    % disp(sprintf('iterno=%d',jjj));
    %   end
end


function A=getA(surf,Pp,mu,lambda)
X=surf.vertices(:,1);
Y=surf.vertices(:,2);
Z=surf.vertices(:,3);
NumTri=size(surf.faces,1);
NumVertx=size(X,1);
vertx_1=surf.faces(:,1);vertx_2=surf.faces(:,2);vertx_3=surf.faces(:,3);
V1=[X(vertx_1),Y(vertx_1),Z(vertx_1)];
V2=[X(vertx_2),Y(vertx_2),Z(vertx_2)];
V3=[X(vertx_3),Y(vertx_3),Z(vertx_3)];

x1=zeros(NumTri,1); y1=zeros(NumTri,1);
v2_v1temp=V2-V1;
x2=sqrt(sum(v2_v1temp.^2,2));
y2=zeros(NumTri,1);
x3=dot((V3-V1),(v2_v1temp./[x2,x2,x2]),2);
mynorm = cross((v2_v1temp),V3-V1,2);
yunit = cross(mynorm,v2_v1temp,2);
y3 = dot(yunit,(V3-V1),2)./sqrt(sum(yunit.^2,2));
sqrt_DT= 2*(abs((x1.*y2 - y1.*x2)+(x2.*y3 - y2.*x3)+(x3.*y1 - y3.*x1))).^((Pp-1)/Pp);
y1 = y1./sqrt_DT; y2 = y2./sqrt_DT; y3 = y3./sqrt_DT;
x1 = x1./sqrt_DT; x2 = x2./sqrt_DT; x3 = x3./sqrt_DT;
tmp_A=[y2-y3;y3-y1;y1-y2]; tmp_B=[x3-x2;x1-x3;x2-x1];

rowno=[1:NumTri]';%rowno_1=rowno-1;
rowno_all=[rowno;rowno;rowno];
vertx_all=[vertx_1;vertx_2;vertx_3];
Dx=sparse(rowno_all,vertx_all,tmp_A,NumTri,size(X,1));
Dy=sparse(rowno_all,vertx_all,tmp_B,NumTri,size(X,1));

if(mu~=0 || lambda ~=0)
    A=[sqrt(lambda)*Dx, sqrt(lambda)*Dy;
        sqrt(mu)*Dy, sqrt(mu)*Dx;
        sqrt(2*mu)*Dx, 0*Dx;
        0*Dy, sqrt(2*mu)*Dy];
else
    %warning('mu and lambda both are zero! doing harmonic matching instead of elastic');
    A=[Dx,0*Dx;0*Dx,Dx;Dy,0*Dy;0*Dy,Dy];
end
