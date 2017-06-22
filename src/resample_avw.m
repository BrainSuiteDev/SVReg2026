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


function vr=resample_avw(v,Msizer,method)
if ~exist('method','var')
    method='linear';
end

vr=v;
vr.img=resample_vol(double(v.img),Msizer,method);
Msize=size(v.img);
res=double(v.hdr.dime.pixdim(2:4));
XD=Msizer(1)/Msize(1);YD=Msizer(2)/Msize(2);ZD=Msizer(3)/Msize(3);
res=res./[XD,YD,ZD];
vr.hdr.dime.pixdim(2:4)=res;
vr.hdr.dime.dim(2:4)=Msizer;

