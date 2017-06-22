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


function [C,C_REG,C_SIM]=cost_func_int_reg(fs,ft,mask_ind,xmap,ymap,zmap,L,bdr)
Msize=size(xmap);
[X,Y,Z]=ndgrid(1:Msize(1),1:Msize(2),1:Msize(3));
wrpd=interp3(fs,ymap,xmap,zmap,'*linear',0);
imdiff=wrpd - ft;
%[J3]=myjacobian3dmap(xmap, ymap, zmap);
%indfull=[mask_ind,MS+mask_ind,2*MS+mask_ind];
C_SIM=imdiff(mask_ind).^2;
C_SIM(bdr)=0;C_SIM=sum(C_SIM);
C_REG=((L*(xmap(mask_ind)-X(mask_ind))).^2)+((L*(ymap(mask_ind)-Y(mask_ind))).^2)+((L*(zmap(mask_ind)-Z(mask_ind))).^2);C_REG(bdr)=0;C_REG=sum(C_REG);
C=C_REG+C_SIM;

