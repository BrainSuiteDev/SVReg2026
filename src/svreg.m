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



function svreg(subbasename,atlasbasename,varargin)

subbasename = remove_extn_basename(subbasename);
atlasbasename = remove_extn_basename(atlasbasename);


[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end

subname=strcat(subname,extt);
varargin{length(varargin)+1}='-r';

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);
if exist('atlasbasename','var')
    if strcmp(atlasbasename(1),'-')
        varargin=[atlasbasename,varargin];
        clear atlasbasename
    end
end
if ~exist('atlasbasename','var')
    if isdeployed
        dir1=get_deployed_exec_dir();
    else
        dir1=fileparts(mfilename('fullpath'));
    end
    atlasbasename=[dir1(1:end-3),'BrainSuiteAtlas1',filesep,'mri'];
end
logfname=[subbasename_tmp,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'svreg %s %s ',subbasename,atlasbasename);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');
fclose(fp);

volreg_varargin=varargin;
%remove -cbm and other things after that so that file names are not
%confused
for jj=1:length(varargin)
    if strcmp(varargin{jj},'-cbm')
        varargin{jj}=[];varargin{jj+1}=[];
    end
end
surreg_varargin=varargin;
for jj=1:length(varargin)
    if strcmp(varargin{jj},'-cur')
        varargin{jj}=[];varargin{jj+1}=[];varargin{jj+2}=[];
    end
end

flags='';
for jj=1:size(varargin,2)
    flags=[flags,varargin{jj}];
end
%flags=strrep(flags,'-','');
%  a=strfind(flags,'v');
if ~contains(flags,'-v')
    verbosity=2;
else
    a=strfind(flags,'-v');
    verbosity=flags(a(1)+1);
    verbosity= str2double(verbosity);
end


if exist('atlas_name','var')
    if atlas_name(1)=='-'
        flags=atlas_name;
        clear atlas_name;
    end
end

if ~exist('flags','var')
    flags='';
end

if ~exist('atlasbasename','var')
    disp1('Incorrect syntax','main',flags );
    disp1('USAGE:','svreg',flags);
    disp1('svreg $subbasename $atlas_basename flags','svreg',flags);
    disp1('-v#     Controls the verbosity of output messages (# is 0, 1, or 2)',flags);
    disp1('-s flag Checks if all files necessary for volume registration are present; if so, skip the surface registration and perform only volume registration.','main',flags);
    disp1('-S surface registration only','svreg',flags);
    disp1('-k flag keep the intermediate files after the svreg sequence is complete','svreg',flags);
    disp1('-t display timestamps along with output messages','svreg',flags);
    disp1('-U single threaded mode','svreg',flags);
    disp1(' ','svreg',flags);
    disp1('For the full list, please check http://brainsuite.org/processing/svreg/usage/.','svreg',flags);
    return;
end

if ~contains(flags,'-gui')
    disp1('The whole surface volume registration and labeling sequence takes about 90-100 min.','main',flags);
else
    disp1('StartSVREG:SVREG  (svreg)','main',flags);
end

fn={[subbasename,'.left.inner.cortex.dfs'],...%[subbasename,'.left.mid.cortex.dfs'],...
    [subbasename,'.left.pial.cortex.dfs'],...
    [subbasename,'.right.inner.cortex.dfs'],...%[subbasename,'.right.mid.cortex.dfs'],...
    [subbasename,'.right.pial.cortex.dfs'],...
    [subbasename,'.warp'],...
    [subbasename,'.cortex.dewisp.mask.nii.gz'],...
    [subbasename,'.cerebrum.mask.nii.gz'],...
    [subbasename,'.bfc.nii.gz'],...
    [subbasename,'.pvc.frac.nii.gz']};

for kkk=1:length(fn)
    if ~exist(fn{kkk},'file')
        disp1('The following file does not exist:','main',flags);
        disp1(sprintf('%s',fn{kkk}),'main',flags);
        disp1('Exiting the program','main',flags);
        return;
    end
end

p=mfilename('fullpath');
[pth,~,~]=fileparts(p);
pth=pth(1:end-4);
% pth=pth(1:kkk(1)+5);
% pth=p(1:end-20);


sprintf('SVREG Started...  \n');

if exist('atlasbasename','var')
    if atlasbasename(1)=='-'
        flags=atlasbasename;
        clear atlasbasename;
    end
end

if ~exist('flags','var')
    flags='';
end

if ~contains(flags,'-U')
    % create a local cluster object
    %delete(gcp('nocreate'));
    pc = parcluster('local');
    % explicitly set the JobStorageLocation to the temp directory that was
    % created in your sbatch script
    par_dir=strcat(subbasename,'_parcluster_tmp');
    if exist(par_dir,'dir')
        rmdir(par_dir,'s');
    end
    mkdir(par_dir);
    pc.JobStorageLocation = par_dir;
    ps = parallel.Settings;
    ps.Pool.AutoCreate = true;
    delete(gcp('nocreate'));
    parpool(3);
    
else
    ps = parallel.Settings;
    ps.Pool.AutoCreate = false;
end
% disp1('Computing cortical thickness using thicknessPVC method','svreg',flags);
% a=tic;
% thicknessPVC(subbasename);
% toc(a)
% disp1('thickess computed','svreg',flags);
hemi={'left','right'};

if ~contains(flags,'-s') || ~exist([subbasename_tmp,'.target.right.pial.cortex.reg.dfs'],'file')
    parfor jj=1:2
        svreg_label_surf_hemi(subbasename,atlasbasename,hemi{jj},surreg_varargin{:});
    end
    
        
    parfor jj=1:2
        refine_ROIs2(subbasename,hemi{jj},flags);
    end
    
%     disp1('Mapping cortical thickness to atlas','svreg',flags);
%     svreg_thickness2atlas(subbasename);
%     disp1('Thickness mapped to atlas','svreg',flags);
    
end
if ~contains(flags,'-S')
    
    
    %%NOTE that atlasbasename chanes from this point on in the script
    atlasbasename=[subbasename,'.target'];
    
    %% These two commanda can run in parallel
    ss{1}=atlasbasename;ss{2}=subbasename;
    if ~exist([subbasename_tmp,'_unitball_map.mat'],'file') || ~contains(flags,'-p')
        parfor sub=1:2
            volmap_ball(ss{sub},1,flags);
        end
    end
    
    svreg_volreg(subbasename, atlasbasename,volreg_varargin{:});
    
    svreg_refinements(subbasename, atlasbasename,'',flags);
    
    parfor jj=1:2
        refine_sulci_hemi(subbasename,hemi{jj},flags);
    end
end

%generate_stats_xls(subbasename, flags);


if ~contains(flags,'-k')
    clean_intermediate_files(subbasename);
end

if exist('par_dir','var')
    if exist(par_dir,'dir')
        rmdir(par_dir,'s');
    end
end

disp1('svreg sequence finished','svreg',flags);


