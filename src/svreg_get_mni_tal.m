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


function svreg_get_mni_tal(subbasename,atlasbasename,sx,sy,sz)

if ~exist('sz','var')
    disp('Usage: svreg_get_mni_tal.exe subbasename atlasbasename sx sy sz');
    disp('where sx sy sz are the xyz of subject in voxel coordinates');
    return
end

sx=str2double(sx);
sy=str2double(sy);
sz=str2double(sz);
map=load_nii_BIG_Lab([subbasename,'.svreg.map.nii.gz']);

map=map.img(sx,sy,sz,:);
map=squeeze(map);
[aa,bb]=fileparts(atlasbasename);
fname=fullfile(aa,'map2mni.nii.gz');
if exist(fname,'file')
    map2=load_nii_BIG_Lab(fname);
    map=map2.img(round(map(1)),round(map(2)),round(map(3)),:);
end
map=squeeze(map);
% The origin comes from MNI atlas The origin of MNI atlas is 79 113 51 (1 starting index)
map(1)=map(1)-79;
map(2)=map(2)-113;
map(3)=map(3)-51;
fprintf('\nMNI coordinates: %g, %g, %g\n',map(1),map(2),map(3));

talmap = mni2tal(map);
fprintf('\nTalairach coordinates: %g, %g, %g\n',talmap(1),talmap(2),talmap(3));

