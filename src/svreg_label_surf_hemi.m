% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2015 The Regents of the University of California and the University of Southern California
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



function svreg_label_surf_hemi(subbasename,atlasbasename,hemi, varargin)
if strcmp(hemi,'left')
    pause(5); % Pause for 5 sec to avoid race with left hemi thread.
end

[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);
tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
warning off
mkdir(tmpdir);
warning on
subbasename_tmp=fullfile(tmpdir,subname);

logfname=[subbasename_tmp,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'SVREG Version 15c(build#2225) (svreg_label_surf_hemi)  \n');
fprintf(fp,'svreg_label_surf_hemi %s %s %s ',subbasename,atlasbasename,hemi);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');

fclose(fp);


curves_no=[];flags='';curves_name=[];
for jj=1:length(varargin)
    if strcmp(varargin{jj},'-cur')
        if strcmp(hemi,'left')
            curves_name=varargin{jj+1};
        else
            curves_name=varargin{jj+2};
        end
        varargin{jj+1}=[];varargin{jj+2}=[];jj=jj+2;
        if jj == length(varargin) || isempty(str2num(varargin{jj+1}))
            curves_no=1:26;curves_no=num2str(curves_no);
        else
            while(str2num(varargin{jj+1}))
                jj=jj+1;
                curves_no=[curves_no,' ',varargin{jj}];varargin{jj}=[];
                
                if jj==length(varargin)
                    break;
                end
            end
            jj=jj+1;
        end
    end
    if jj>length(varargin)
        break;
    end
    
end
flags='';
for jj=1:length(varargin)
    flags=[flags,varargin{jj}];
end

if isempty(strfind(flags,'gui'))
    disp1(sprintf('Labeling %s hemisphere',hemi),'svreg_label_surf_hemi',flags);
else
    disp1(sprintf('StartLabHemi: %s',hemi),'svreg_label_surf_hemi',flags);
end
if ~exist('atlasbasename','var')
    p=mfilename('fullpath');
    [pth,~,~]=fileparts(p);
    pth=pth(1:end-4);
    
    atlasbasename=fullfile(pth,'BrainSuiteAtlas1/mri');
    
    copyfile([atlasbasename,'.',hemi,'.mid.cortex.dfs'],[subbasename_tmp,'.target.',hemi,'.mid.cortex.dfs'],'f');
else
    copyfile([atlasbasename,'.',hemi,'.mid.cortex.dfs'],[subbasename_tmp,'.target.',hemi,'.mid.cortex.dfs'],'f');
end
copyfile([atlasbasename,'.',hemi,'.inner.cortex.dfs'],[subbasename_tmp,'.target.',hemi,'.inner.cortex.dfs'],'f');
copyfile([atlasbasename,'.',hemi,'.pial.cortex.dfs'],[subbasename_tmp,'.target.',hemi,'.pial.cortex.dfs'],'f');
copyfile([subbasename,'.',hemi,'.inner.cortex.dfs'],[subbasename_tmp,'.',hemi,'.inner.cortex.dfs'],'f');
copyfile([subbasename,'.',hemi,'.pial.cortex.dfs'],[subbasename_tmp,'.',hemi,'.pial.cortex.dfs'],'f');

pth1=fileparts(atlasbasename);pth2=fileparts(subbasename_tmp);
if exist(fullfile(pth1,'bst_atlas','brainsuite.icbm452.lpi.v08a.img'),'file')
    copyfile(fullfile(pth1,'bst_atlas','brainsuite.icbm452.lpi.v08a.img'),fullfile(pth2,'brainsuite.icbm452.lpi.v08a.img'),'f');
    copyfile(fullfile(pth1,'bst_atlas','brainsuite.icbm452.lpi.v08a.hdr'),fullfile(pth2,'brainsuite.icbm452.lpi.v08a.hdr'),'f');
end

if exist([atlasbasename,'.right.dfc'],'file')
    copyfile([atlasbasename,'.',hemi,'.dfc'],[subbasename_tmp,'.target.',hemi,'.dfc'],'f');
    [at_pth,~]=fileparts(atlasbasename);
    if strcmp(hemi,'right')
        copyfile([atlasbasename,'.warp'],[subbasename_tmp,'_atlas.warp'],'f');
        copyfile(fullfile(at_pth,'sulcal_protocol_HD.xml'),[subbasename_tmp,'.sulcal_protocol_HD.xml'],'f');
        if exist([atlasbasename,'.sulcal_protocol_all_HD.xml'],'file')
            copyfile([atlasbasename,'.sulcal_protocol_all_HD.xml'],[subbasename_tmp,'.sulcal_protocol_all_HD.xml'],'f');
        end
    end
    
end

if isempty(strfind(flags,'gui'))
    disp1('Computing mid cortical surfaces','svreg_label_surf_hemi',flags);
else
    disp1('ComputeMidCortex','svreg_label_surf_hemi',flags)
end
calc_mid_surf([subbasename_tmp,'.',hemi,'.inner.cortex.dfs'],[subbasename_tmp,'.',hemi,'.pial.cortex.dfs'],[subbasename_tmp,'.',hemi,'.mid.cortex.dfs']);

if isempty(strfind(flags,'gui'))
    disp1('Checking Euler Characteristic of input surfaces, it should be 1','svreg_label_surf_hemi',flags);
else
    disp1('EulerCheck','svreg_label_surf_hemi',flags);
end
El=euler_number_mesh(readdfs([subbasename_tmp,'.',hemi,'.mid.cortex.dfs']));

if isempty(strfind(flags,'gui'))
    disp1(sprintf('Euler characteristic of %s Hemi = %d ',hemi,El),'svreg_label_surf_hemi',flags);
else
    disp1(sprintf('EulerChar:%s:%d',hemi,El),'svreg_label_surf_hemi',flags);
end

if El~=1
    
    clean_surfaces(subbasename_tmp,hemi);
    El=euler_number_mesh(readdfs([subbasename_tmp,'.',hemi,'.mid.cortex.dfs']));
    if isempty(strfind(flags,'gui'))
        disp1(sprintf('New Euler characteristic of %s Hemi = %d',hemi,El),'svreg_label_surf_hemi',flags);
    else
        disp1(sprintf('EulerCorr:NewEulerChar:%s:%d',hemi,El),'svreg_label_surf_hemi',flags);
    end
end
if isempty(strfind(flags,'gui'))
    disp1('Computing Smooth cortical representation','svreg_label_surf_hemi',flags);
else
    disp1('CompSmoothRep','svreg_label_surf_hemi',flags);
end
smooth_surf_hierarchy([subbasename_tmp,'.',hemi,'.mid.cortex.dfs'],10,flags);

for smth=1:10
    copyfile(sprintf('%s.%s.mid.cortex_smooth%d.dfs',atlasbasename,hemi,smth),sprintf('%s.target.%s.mid.cortex_smooth%d.dfs',subbasename_tmp,hemi,smth),'f');
end

%copyfile([atlasbasename,'.warp'],[subbasename_tmp,'.target.warp'],'f');
if ~isempty(curves_no)
    curves_no=str2num(curves_no);
end
surf_flatten_newbs([subbasename_tmp,'.target.',hemi,'.mid.cortex.dfs'], [subbasename_tmp,'.',hemi,'.mid.cortex.dfs'],[subbasename,'.target.',hemi,'.dfc'], curves_name,[subbasename_tmp,'.target.',hemi,'.mid.cortex.curvesmatch.dfs'], [subbasename_tmp,'.',hemi,'.mid.cortex.curvesmatch.dfs'], [atlasbasename,'.warp'],[subbasename,'.warp'],curves_no,flags);

curvature_registration_newbs_elastic_xyz([subbasename_tmp,'.target.',hemi,'.mid.cortex.curvesmatch.dfs'], [subbasename_tmp,'.',hemi,'.mid.cortex.curvesmatch.dfs'],[subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs'],[subbasename_tmp,'.target.',hemi,'.dfc'],curves_name,curves_no,subbasename_tmp,atlasbasename,flags,hemi);

if (exist([subbasename_tmp,'.target.',hemi,'.mid.cortex.reg.dfs'],'file'))
    delete([subbasename_tmp,'.target.',hemi,'.mid.cortex.reg.dfs']);
end
copyfile([subbasename_tmp,'.target.',hemi,'.mid.cortex.curvesmatch.dfs'],[subbasename_tmp,'.target.',hemi,'.mid.cortex.reg.dfs'],'f');

icbm=readdfs([subbasename_tmp,'.target.',hemi,'.mid.cortex.curvesmatch.dfs']);icbm.u=icbm.u';icbm.v=icbm.v';
sub=readdfs([subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs']);sub.u=sub.u';sub.v=sub.v';
vlabels=icbm.labels;
if isempty(strfind(flags,'gui'))
    disp1('Transferring Labels','svreg_label_surf_hemi',flags);
else
    disp1('LabelTransfer','svreg_label_surf_hemi',flags);
end
warning off; %#ok<WNOFF>
Ts= TriScatteredInterp(icbm.u,icbm.v,vlabels);
Ts.Method='nearest';
sub.labels=Ts(sub.u,sub.v);

Ts= TriScatteredInterp(icbm.u,icbm.v,icbm.vcolor(:,1));
Ts.Method='nearest';
sub.vcolor(:,1)=Ts(sub.u,sub.v);

Ts= TriScatteredInterp(icbm.u,icbm.v,icbm.vcolor(:,2));
Ts.Method='nearest';
sub.vcolor(:,2)=Ts(sub.u,sub.v);

Ts= TriScatteredInterp(icbm.u,icbm.v,icbm.vcolor(:,3));
Ts.Method='nearest';
sub.vcolor(:,3)=Ts(sub.u,sub.v);
warning on; clear Ts; %#ok<WNON>

writedfs([subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs'],sub);
clear sub;

if isempty(strfind(flags,'gui'))
    disp1(sprintf('%s hemisphere done',hemi),'svreg_label_surf_hemi',flags);
else
    disp1(sprintf('LabHemiDone:%s',hemi),'svreg_label_surf_hemi',flags);
end

if ~isempty(strfind(flags,'gui'))
    disp1('TransfCurves','svreg_label_surf_hemi',flags);
else
    disp1('Transferring Curves','svreg_label_surf_hemi',flags);
end
transfer_curves(subbasename_tmp,atlasbasename,hemi);

corr_topology_labels([subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs']);
recolor_by_label([subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs'],atlasbasename);
copy_attrib_colors(subbasename_tmp,hemi,'reg.dfs');
copy_attrib_colors([subbasename_tmp,'.target'],hemi,'reg.dfs');

map2atlas_thickness(subbasename_tmp,hemi);

copyfile([subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs'],[subbasename,'.',hemi,'.mid.cortex.svreg.init.dfs'],'f');


if isempty(strfind(flags,'r'))
    copyfile([subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs'],[subbasename_tmp,'.',hemi,'.mid.cortex.svreg.dfs'],'f');
    copyfile([subbasename_tmp,'.',hemi,'.pial.cortex.reg.dfs'],[subbasename_tmp,'.',hemi,'.pial.cortex.svreg.dfs'],'f');
    copyfile([subbasename_tmp,'.',hemi,'.inner.cortex.reg.dfs'],[subbasename_tmp,'.',hemi,'.inner.cortex.svreg.dfs'],'f');
end

copyfile([subbasename_tmp,'.',hemi,'.mapped.dfc'],[subbasename,'.',hemi,'.mapped.dfc'],'f');
if exist([subbasename_tmp,'.',hemi,'.mapped.all.dfc'],'file')
    copyfile([subbasename_tmp,'.',hemi,'.mapped.all.dfc'],[subbasename,'.',hemi,'.mapped.all.dfc'],'f');
end
%copyfile([subbasename_tmp,'.right.mapped.dfc'],[subbasename,'.right.mapped.dfc'],'f')


cmpt=computer;
if strcmp(cmpt(1:5),'PCWIN')
    if isempty(strfind(flags,'gui'))
        disp1('Labeling of a hemisphere is done.','svreg_label_surf_hemi',flags);
    end
else
    unix(['chmod -R 775 ''',subbasename_tmp,'''*']);
    if isempty(strfind(flags,'gui'))
        disp1('Labeling of a hemisphere is done!','svreg_label_surf_hemi',flags);
    else
        disp1('SurfLabDone!','svreg_label_surf_hemi',flags);
    end
end

if strcmp(hemi,'right')
    svreg_path=fileparts(fileparts(atlasbasename));%getcurrentdir;%ctfroot;%mfilename('fullpath');
    pth1=fileparts(subbasename_tmp);
    save(fullfile(pth1,'svreg_path.mat'),'svreg_path');    
    atlas_name_msk_fname=[subbasename_tmp '.target.cortex.dewisp.mask.nii.gz'];
    copyfile([atlasbasename, '.cortex.dewisp.mask.nii.gz'],atlas_name_msk_fname,'f');
    copyfile([atlasbasename, '.bfc.nii.gz'],[subbasename_tmp,'.target.bfc.nii.gz'],'f');%
    copyfile([atlasbasename, '.pvc.frac.nii.gz'],[subbasename_tmp,'.target.pvc.frac.nii.gz'],'f');%
    copyfile([atlasbasename,'.hippo_carved.nii.gz'],[subbasename_tmp,'.target.hippo_carved.nii.gz'],'f');
    atlas_labels_fname=[subbasename_tmp '.target.label.nii'];
    copyfile([atlasbasename, '.label.nii.gz'],[atlas_labels_fname,'.gz'],'f');
    
    a=fileparts(atlasbasename);sa=fileparts(subbasename_tmp);
    copyfile(fullfile(a,'brainsuite_labeldescription.xml'),fullfile(sa,'brainsuite_labeldescription.xml'),'f');
    
    sa=fileparts(subbasename);
    copyfile(fullfile(a,'brainsuite_labeldescription.xml'),fullfile(sa,'brainsuite_labeldescription.xml'),'f');
    %sa
    
    [at_pth,~]=fileparts(atlasbasename);
    copyfile(fullfile(at_pth,'sulcal_protocol_HD.xml'),[subbasename_tmp,'.sulcal_protocol_HD.xml'],'f');
    
end



