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


function [znew,T]=mygriddata3(x,y,zz,z,xin,yin,zzin,T)
warning off
if exist('T','var')
    T.Method='linear';
else
    T= TriScatteredInterp(x,y,zz,z,'linear');
end
clear x y z zz

znew=T(xin,yin,zzin);

%znew=griddata3(x,y,zz,z,xin,yin,zzin,'linear');
indx=find(isnan(znew));
T.Method='nearest';
%znew(indx)=T(xin(indx),yin(indx),zzin(indx));
znew(indx)=T(xin(indx),yin(indx),zzin(indx));

%znew(indx)=griddata3(x,y,zz,z,xin(indx),yin(indx),zzin(indx),'nearest');
warning on
