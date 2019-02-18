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

function nifti2eig(L1, L2, L3, V1, V2, V3, outputFilebase)
% 


workDir = tempname();
tempFile = fullfile(workDir, [Random_String(10) '.nii.gz']);
if ~mkdir(workDir)
   error('Could not create temp dir: %s', workDir);
end

[~, L1] = check_nifti_file(L1, workDir);
[~, L2] = check_nifti_file(L2, workDir);
[~, L3] = check_nifti_file(L3, workDir);
[~, V1] = check_nifti_file(V1, workDir);
[~, V2] = check_nifti_file(V2, workDir);
[~, V3] = check_nifti_file(V3, workDir);

[L1, RotMat] = reorient_nifti_sform(L1, tempFile);
[L2, RotMat] = reorient_nifti_sform(L2, tempFile);
[L3, RotMat] = reorient_nifti_sform(L3, tempFile);

[V1, RotMat] = reorient_nifti_sform(V1, tempFile);
[V2] = reorient_nifti_sform(V2, tempFile);
[V3] = reorient_nifti_sform(V3, tempFile);

% rotate 
sz = size(V1.img);
if ndims(V1.img)==4 && sz(4)==3
   temp = double(reshape(V1.img, [], sz(4)));
   V1.img = reshape(temp*(RotMat'), sz);
elseif ndims(V1.img)~=4
   error('V1 is not a 4D image. It must be 4D image.')
elseif sz~=3
   error('4th dimension of V1 is not of size 3. It must be a vector with length 3.')
end

sz = size(V2.img);
if ndims(V2.img)==4 && sz(4)==3
   temp = double(reshape(V2.img, [], sz(4)));
   V2.img = reshape(temp*(RotMat'), sz);
elseif ndims(V2.img)~=4
   error('V2 is not a 4D image. It must be 4D image.')
elseif sz~=3
   error('4th dimension of V2 is not of size 3. It must be a vector with length 3.')
end

sz = size(V3.img);
if ndims(V3.img)==4 && sz(4)==3
   temp = double(reshape(V3.img, [], sz(4)));
   V3.img = reshape(temp*(RotMat'), sz);
elseif ndims(V3.img)~=4
   error('V3 is not a 4D image. It must be 4D image.')
elseif sz~=3
   error('4th dimension of V3 is not of size 3. It must be a vector with length 3.')
end

generate_eig_file(L1, L2, L3, V1, V2, V3, outputFilebase);

end
