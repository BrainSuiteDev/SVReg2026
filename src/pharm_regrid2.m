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




function [xmap,ymap,zmap]=pharm_regrid2(Msize,p,mask_indx,bdr_indx,bdrmap,res,flags)

[D1,D2,D3]=createDWithPeriodicBoundary3Dmsk(Msize(1),Msize(2),Msize(3),mask_indx);L=[D1;D2;D3];clear D1 D2 D3;
%MS=Msize(1)*Msize(2)*Msize(3);
%L=[d(mask_indx,mask_indx);d(MS+mask_indx,mask_indx);d(2*MS+mask_indx,mask_indx)];

bdr_indx1=(bdr_indx);clear oldindx
indx=[1:length(mask_indx)]';indx(bdr_indx1)=[];%indx=oldindx(indx);
Lf=L(:,indx);%=sparse(0);
Lbdr=-L(:,bdr_indx1); clear L Lx Ly Lz 
map=zeros(length(indx),3);
parfor jj=1:3
  %  jj
b1=Lbdr*bdrmap(:,jj);
map(:,jj)=mypcg(Lf'*Lf,Lf'*b1,1e-320,16000,ones(size(Lf,2),1),[],flags);
map(:,jj)=double(single(map(:,jj)));
end

% b2=Lbdr*bdrmap(:,2);
% ymap1=mypcg(Lf'*Lf,Lf'*b2,1e-320,6000,ones(size(Lf,2),1));
% b3=Lbdr*bdrmap(:,3);
% zmap1=mypcg(Lf'*Lf,Lf'*b3,1e-320,6000,ones(size(Lf,2),1));

xmap=zeros(length(mask_indx),1);ymap=xmap;zmap=xmap;
xmap(indx)=map(:,1);xmap(bdr_indx1)=bdrmap(:,1);
ymap(indx)=map(:,2);ymap(bdr_indx1)=bdrmap(:,2);
zmap(indx)=map(:,3);zmap(bdr_indx1)=bdrmap(:,3);



%disp1(sprintf('...done in %.1f sec',t));


