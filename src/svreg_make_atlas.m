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

function svreg_make_atlas(subbasename,atlasbasename,flags)
% This function prepares the subject to be used as a new atlas
if (nargin < 2)
    fprintf('USAGE: svreg_make_atlas.sh subbasename atlasbasename flags\n');
    fprintf('subbasename: fileprefix of the subject that is to be converted into atlas\n');
    fprintf('atlasbasename: atlas that was used for svreg processing of this subject\n');
    fprintf('Use -E flag is the new atlas volume is manually edited\n');
    return;
end
if ~exist('flags','var');
    flags=[];
end
[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);

% Copy the files if they are processed by svreg
if exist([subbasename,'.left.inner.cortex.svreg.dfs'],'file')
    copyfile([subbasename,'.left.inner.cortex.svreg.dfs'],[subbasename,'.left.inner.cortex.dfs'],'f');
    copyfile([subbasename,'.left.mid.cortex.svreg.dfs'],[subbasename,'.left.mid.cortex.dfs'],'f');
    copyfile([subbasename,'.left.pial.cortex.svreg.dfs'],[subbasename,'.left.pial.cortex.dfs'],'f');
    
    copyfile([subbasename,'.right.inner.cortex.svreg.dfs'],[subbasename,'.right.inner.cortex.dfs'],'f');
    copyfile([subbasename,'.right.mid.cortex.svreg.dfs'],[subbasename,'.right.mid.cortex.dfs'],'f');
    copyfile([subbasename,'.right.pial.cortex.svreg.dfs'],[subbasename,'.right.pial.cortex.dfs'],'f');
end

smooth_surf_hierarchy([subbasename,'.right.mid.cortex.dfs'],10);
smooth_surf_hierarchy([subbasename,'.left.mid.cortex.dfs'],10);


for jj=1:10
    s=readdfs(sprintf('%s.left.mid.cortex_smooth%d.dfs',subbasename,jj));
    s1.vertices=s.vertices;s1.attributes=s.attributes;s1.faces=[];
    writedfs(sprintf('%s.left.mid.cortex_smooth%d.dfs',subbasename,jj),s1);
    
    s=readdfs(sprintf('%s.right.mid.cortex_smooth%d.dfs',subbasename,jj));
    s1.vertices=s.vertices;s1.attributes=s.attributes;s1.faces=[];
    writedfs(sprintf('%s.right.mid.cortex_smooth%d.dfs',subbasename,jj),s1);
end

[atpth,atb]=fileparts(atlasbasename);
[subpth,sb]=fileparts(subbasename);


% Do not copy xml file in case of -E flag. In this case volume is edited
% and the xml file also should be edited.
if ~strfind(flags,'-E')
    copyfile([atpth,filesep,'*.xml'],subpth,'f');
end

if ~exist([subbasename,'.left.dfc'],'file')
    copyfile([subbasename,'.left.mapped.dfc'],[subbasename,'.left.dfc'],'f');
    copyfile([subbasename,'.right.mapped.dfc'],[subbasename,'.right.dfc'],'f');
end

% If the files are processed by svreg then copy the label file
if exist([subbasename,'.svreg.label.nii.gz'],'file')
    copyfile([atpth,filesep,'*.mat'],subpth,'f');
    copyfile([subbasename,'.svreg.label.nii.gz'],[subbasename,'.label.nii.gz'],'f')
    
    % get rid of subdivisions of sulci and gyri
    vl=load_nii_BIG_Lab([subbasename,'.label.nii.gz']);
    msk = (vl.img~=2000);
    vl.img(msk)=mod(vl.img(msk),1000);
    save_untouch_nii_gz(vl,[subbasename,'.label.nii.gz']);
end


pth=fileparts(subbasename);

% If the file is processed by svreg then transfer curvature maps
if exist([subbasename,'.right.mid.cortex.svreg.dfs'],'file')
    
    %right
    s=readdfs([subbasename,'.right.mid.cortex.svreg.dfs']);
    t=readdfs([pth,'/atlas.right.mid.cortex.svreg.dfs']);
    
    a=load([subpth,filesep,'curvvar.mat']);
    rightvar=map_data_flatmap(t,a.rightvar,s);
    
    %left
    s=readdfs([subbasename,'.left.mid.cortex.svreg.dfs']);
    t=readdfs([pth,'/atlas.left.mid.cortex.svreg.dfs']);
    
    a=load(fullfile(subpth,'curvvar.mat'));
    leftvar=map_data_flatmap(t,a.leftvar,s);
    
    save(fullfile(subpth,'curvvar.mat'),'leftvar','rightvar');
end


if ~exist([subbasename,'.hippo_carved.nii.gz'],'file')
    if exist([subbasename_tmp,'.warped.hippo_carved.nii.gz'],'file')
        copyfile([subbasename_tmp,'.warped.hippo_carved.nii.gz'],[subbasename,'.hippo_carved.nii.gz'],'f');
    else
        fprintf('%s.warped.hippo_carved.nii.gz doesnt exist\n',subbasename_tmp);
        fprintf('Will use dewisp mask instead of hippo_carved mask\n');
        
        copyfile([subbasename,'.cortex.dewisp.mask.nii.gz'],[subbasename,'.hippo_carved.nii.gz'],'f');
    end
end

[at_pth,~]=fileparts(atlasbasename);[sub_pth,~]=fileparts(subbasename);
if ~exist(fullfile(sub_pth,'sulcal_protocol_HD.xml'),'file')
    copyfile(fullfile(at_pth,'sulcal_protocol_HD.xml'),fullfile(sub_pth,'sulcal_protocol_HD.xml'),'f');
end

if strfind(flags,'-E')
    fprintf('-E flag found the volume is manually edited\n');
    surf_label_atlas(subbasename);
end
