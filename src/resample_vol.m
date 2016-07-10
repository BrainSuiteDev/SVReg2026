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


function vs=resample_vol(v,Msizes,method)
if ~exist('method','var')
    method='linear';
end
Msize=size(v);

if (length(Msize)<3)
    
    rx=(Msize(1)-1)/(Msizes(1)-1);ry=(Msize(2)-1)/(Msizes(2)-1);
    
    [xx,yy]=ndgrid(1:rx:Msize(1),1:ry:Msize(2));
    
    vs=interp2(v,yy,xx,method);
    
else
    
    rx=(Msize(1)-1)/(Msizes(1)-1);ry=(Msize(2)-1)/(Msizes(2)-1);rz=(Msize(3)-1)/(Msizes(3)-1);
    if rx==1 && ry==1 &&rz==1
        vs=v;
    else
        %[xx,yy,zz]=ndgrid(1:rx:Msize(1),1:ry:Msize(2),1:rz:Msize(3));
        [xx,yy,zz]=ndgrid(double(1:rx:Msize(1)),double(1:ry:Msize(2)),double(1:rz:Msize(3)));
        if strcmp(method,'linear')
            vs=trilinear(double(v),yy,xx,zz);
        else
            vs=interp3(double(v),yy,xx,zz,method);
        end
    end
end
