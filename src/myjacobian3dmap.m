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


function [J3,J2,J1]=myjacobian3dmap(xmap, ymap, zmap)
%vf is displacememnt field Msize is size of the volume in voxels
%mask_indx is index of the mask, res is resolution

[Dxv,Dxu,Dxw]=gradient(xmap);
[Dyv,Dyu,Dyw]=gradient(ymap);
[Dzv,Dzu,Dzw]=gradient(zmap);

J3=Dxu.*(Dyv.*Dzw-Dyw.*Dzv)-Dyu.*(Dxv.*Dzw-Dxw.*Dzv)+Dzu.*(Dxv.*Dyw-Dxw.*Dyv);
J2=(Dxu.*Dyv-Dxv.*Dyu);
J1=Dxu;
%figure;plot(J(indFree));

% J=[Dxu,Dxv,Dxw;
%    Dyu,Dyv,Dyw;
%    Dzu,Dzv,Dzw];
