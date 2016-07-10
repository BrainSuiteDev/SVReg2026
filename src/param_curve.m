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



function p = param_curve(curve)
%parameterizes a given curve from 0 to 1
%curve=curve';
if length(curve) == 0
    p=[]; return;
end
xc=curve(:,1);yc=curve(:,2);zc=curve(:,3);
xcn=xc(2:end);ycn=yc(2:end);zcn=zc(2:end);
d=sqrt((xc(1:end-1)-xcn).^2 + (yc(1:end-1)-ycn).^2 + (zc(1:end-1)-zcn).^2);
%d(end+1)=(xc(1)-xc(end))^2+(yc(1)-yc(end))^2+(zc(1)-zc(end))^2;
d=[0;d];
totd=sum(d);
for ii=2:length(d)
d(ii)=d(ii)+d(ii-1);
end
p=d/totd;
