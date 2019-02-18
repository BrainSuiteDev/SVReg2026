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

function [L1out, L2out, L3out, V1out, V2out, V3out] = interp_dti(F, L1, L2, L3, V1, V2, V3, ifsave)
%INTERP_DTI Interpolates the diffusion data & saves the result in .nii.gz
%file
%
%   F - transformation map
%
%   ifsave - [optional] Set to false to disable saving.
%
%   Currently this function uses nearest neighborhood. To be modified.
%

L1out = L1;
L2out = L2;
L3out = L3;

V1out = V1;
V2out = V2;
V3out = V3;

% L1out.fileprefix = [L1out.fileprefix '.interp'];
% L2out.fileprefix = [L2out.fileprefix '.interp'];
% L3out.fileprefix = [L3out.fileprefix '.interp'];
% V1out.fileprefix = [V1out.fileprefix '.interp'];
% V2out.fileprefix = [V2out.fileprefix '.interp'];
% V3out.fileprefix = [V3out.fileprefix '.interp'];
% 
% L1out.hdr.hist = F.hdr.hist;
% L2out.hdr.hist = F.hdr.hist;
% L3out.hdr.hist = F.hdr.hist;
% V1out.hdr.hist = F.hdr.hist;
% V2out.hdr.hist = F.hdr.hist;
% V3out.hdr.hist = F.hdr.hist;

% Chaning the dimension to map's dimension
% L1out.hdr.dime.dim = F.hdr.dime.dim;
% L2out.hdr.dime.dim = F.hdr.dime.dim;
% L3out.hdr.dime.dim = F.hdr.dime.dim;
% V1out.hdr.dime.dim = F.hdr.dime.dim;
% V2out.hdr.dime.dim = F.hdr.dime.dim;
% V3out.hdr.dime.dim = F.hdr.dime.dim;

L1out.hdr.dime.pixdim = F.hdr.dime.pixdim;
L2out.hdr.dime.pixdim = F.hdr.dime.pixdim;
L3out.hdr.dime.pixdim = F.hdr.dime.pixdim;
V1out.hdr.dime.pixdim = F.hdr.dime.pixdim;
V2out.hdr.dime.pixdim = F.hdr.dime.pixdim;
V3out.hdr.dime.pixdim = F.hdr.dime.pixdim;

len = size(F,2);%F.hdr.dime.dim(2);
bre = size(F,3);%F.hdr.dime.dim(3);
dep = size(F,1);%F.hdr.dime.dim(4);
dim4 = size(F,4);%F.hdr.dime.dim(5);

V1out = zeros(len,bre,dep,dim4);
V2out = zeros(len,bre,dep,dim4);
V3out = zeros(len,bre,dep,dim4);

L1out = zeros(len,bre,dep);
L2out = zeros(len,bre,dep);
L3out = zeros(len,bre,dep);


% Chaning the dimension of L1out to 3-D (F is 4-D)
% L1out.hdr.dime.dim(1) = 3;
% L1out.hdr.dime.dim(5) = 1;
% L2out.hdr.dime.dim(1) = 3;
% L2out.hdr.dime.dim(5) = 1;
% L3out.hdr.dime.dim(1) = 3;
% L3out.hdr.dime.dim(5) = 1;
% 

% Applying interpolation
% L1out.img = interp3(L1.img, F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');
% L2out.img = interp3(L2.img, F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');
% L3out.img = interp3(L3.img, F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');

F.img = double(F.img);

% faster interpolation using ba_interp
L1out.img = ba_interp3(double(L1.img), F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');
L2out.img = ba_interp3(double(L2.img), F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');
L3out.img = ba_interp3(double(L3.img), F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');

for m = 1:dim4
  V1out.img(:,:,:,m) = ba_interp3(double(V1.img(:,:,:,m)), F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');
  V2out.img(:,:,:,m) = ba_interp3(double(V2.img(:,:,:,m)), F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');
  V3out.img(:,:,:,m) = ba_interp3(double(V3.img(:,:,:,m)), F.img(:,:,:,2), F.img(:,:,:,1), F.img(:,:,:,3), 'nearest');
 % fprintf('interp_dti: %2.2f %%\n',(m+1)/(1+size(V1.img,4))*100)
end

maskNaN = isnan(L1out.img);
L1out.img(maskNaN) = 0;

maskNaN = isnan(L2out.img);
L2out.img(maskNaN) = 0;

maskNaN = isnan(L3out.img);
L3out.img(maskNaN) = 0;

maskNaN = isnan(V1out.img);
V1out.img(maskNaN) = 0;

maskNaN = isnan(V2out.img);
V2out.img(maskNaN) = 0;

maskNaN = isnan(V3out.img);
V3out.img(maskNaN) = 0;

if ~exist('ifsave', 'var') || ifsave
   save_nii_gz(L1out, []);
   save_nii_gz(L2out, []);
   save_nii_gz(L3out, []);
   
   save_nii_gz(V1out, []);
   save_nii_gz(V2out, []);
   save_nii_gz(V3out, []);
end

end

