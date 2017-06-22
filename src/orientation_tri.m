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



function ori=orientation_tri(T,x,y)
ntri=size(T,1);
v1=[x(T(:,1)),y(T(:,1)),zeros(ntri,1)];
v2=[x(T(:,2)),y(T(:,2)),zeros(ntri,1)];
v3=[x(T(:,3)),y(T(:,3)),zeros(ntri,1)];

e1=v2-v1;e2=v3-v2;e3=v1-v3;
ori1=cross(e1,e2);ori1=ori1(:,3);
ori=zeros(ntri,1);
ori(ori1<0)=-1;ori(ori1>0)=1;


