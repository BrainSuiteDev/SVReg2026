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


function svreg_mni2sub(subbasename,mni2bci_map, mx,my,mz)

if ~exist('mz','var')
    disp('Usage: svreg_mni2sub.exe subbasename map_or_atlasbasename mx my mz');
    disp('where mx my mz are the xyz in MNI coordinates (voxel 79, 113, 51 are center of MNI atlas)');
    return
end

sx=str2double(mx) + 79;
sy=str2double(my) + 113;
sz=str2double(mz) + 51;

% If BCI atlas was used, use map from mni to BCI
% MNI --> BCI
if ~exist(mni2bci_map,'file')
    %mni2bci_map variable is atlasbasename
    pth = fileparts(mni2bci_map);
    mni2bci_map = fullfile(pth,'mni2bci.nii.gz');
end

if exist(mni2bci_map,'file')
    inv_map=load_nii_BIG_Lab(mni2bci_map);
    atlas_cord = inv_map.img(round(sx),round(sy),round(sz),:);
    sx = round(atlas_cord(1));
    sy = round(atlas_cord(2));
    sz = round(atlas_cord(3));
end

map=load_nii_BIG_Lab([subbasename,'.svreg.inv.map.nii.gz']);

% BCI--> MNI
sub_coord=map.img(sx,sy,sz,:);

fprintf('Subject voxel coordinates: %g, %g, %g\n',sub_coord(1),sub_coord(2),sub_coord(3));


