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



function [bdr_indx,bdr_indxMsk] = find_mask_bdr(mask_indx,Ms)
%if (max(max(max(mask))) >1) 
%    error('Error: Incorrect mask!') 
%end

%[X,Y,Z]=find(mask);
%Ms=size(mask);
mask=zeros(Ms); mask(mask_indx)=1;
num_nbrs=zeros(Ms);
%indx=find(mask);
[X,Y,Z]=ind2sub(Ms,mask_indx);
for ii=-1:1
  num_nbrs(mask_indx)=num_nbrs(mask_indx)+mask(sub2ind(Ms,X+ii,Y,Z));
end
for ii=-1:1
  num_nbrs(mask_indx)=num_nbrs(mask_indx)+mask(sub2ind(Ms,X,Y+ii,Z));
end
for ii=-1:1
  num_nbrs(mask_indx)=num_nbrs(mask_indx)+mask(sub2ind(Ms,X,Y,Z+ii));
end


bdr_indx=find((num_nbrs<9)&(num_nbrs>0));
bdr_indxMsk=find((num_nbrs(mask_indx)<9)&(num_nbrs(mask_indx)>0));
