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


function [znew,T]=mygriddata3_IntNearestHack(x,y,zz,z,xin,yin,zzin,T)
warning off
if exist('T','var')
    T.Method='linear';
else
    T = TriScatteredInterp(x,y,zz,z,'linear');
end
clear x y z zz

znew=T(xin,yin,zzin);


indx=find(isnan(znew));
T.Method='nearest';

% hack part, add small non-equal constant to each dimension
znew(indx)=T(xin(indx)+0.0012, yin(indx)+0.0023, zzin(indx)+0.0034);

warning on
