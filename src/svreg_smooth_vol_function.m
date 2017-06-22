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


function svreg_smooth_vol_function(infile, stdx, stdy, stdz, outfile)
% This function performs smoothing of data on surfaces
%
if (nargin < 3)
    fprintf('USAGE: svreg_smooth_vol_function.sh infile, stddev, outfile\n');
    fprintf('infile: input nifti file\n');
    fprintf('stdx: standard dev (in mm) of the kernel in x dir\n');
    fprintf('stdy: standard dev (in mm) of the kernel in y dir\n');
    fprintf('stdz: standard dev (in mm) of the kernel in z dir\n');
    fprintf('outfile: output nifti file\n');
end

stdx=str2double(stdx);stdy=str2double(stdy);stdz=str2double(stdz);

v=load_nii_BIG_Lab(infile);
res=v.hdr.dime.pixdim(2:4);

stdx=stdx+1e-4;stdy=stdy+1e-4; stdz=stdz+1e-4; % add small positive number since 0 is not supported by imgaussianfilt3


SZ=size(v.img);
if length(SZ)==4
    for jj=1:SZ(4)
        v.img(:,:,:,jj)=imgaussfilt3(double(v.img(:,:,:,jj)), [stdx/res(1),stdy/res(2),stdz/res(3)]);
    end
else
    v.img=imgaussfilt3(double(v.img), [stdx/res(1),stdy/res(2),stdz/res(3)]);
end

save_untouch_nii_gz(v,outfile);
