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
function svreg_sulcal_map(subbasename,atlasbasename,xmlf,xmlc,dist_thr)
% This function generates sulcal map of cortical regions as well as brain
% areas.
% The outputs are saved in [subbasename,'.',hemi,'.mid.cortex.sulci.dfs']
% and [subbasename,'.sulci.label.nii.gz']
subbasename = remove_extn_basename(subbasename);
atlasbasename = remove_extn_basename(atlasbasename);

[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end

subname=strcat(subname,extt);


%% Check if XML file with sulci is present, if not copy it.
if ~exist('xmlf','var') || ~exist(xmlf,'file')
    xmlf=fullfile(fileparts(atlasbasename),'brainsuite_labeldescription.xml');
end

if exist('xmlc','var') && exist(xmlc,'file')
    copyfile(xmlc,[subbasename,'.sulcal_protocol_HD.xml']); 
end
xmlc=[subbasename,'.sulcal_protocol_HD.xml'];

if ~exist('dist_thr','var')
    dist_thr=10;
end
if ischar(dist_thr)
    dist_thr=str2double(dist_thr);
end

%% Mark surface regions
hemi={'left','right'};
fprintf('Generating sulcal regions on cortical surface\n');
parfor h=1:2
    sulc_map_surf(subbasename,hemi{h},xmlf,xmlc,dist_thr);
end

%% Mark Volume regions
sulc_map_vol(subbasename);
