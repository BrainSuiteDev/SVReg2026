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



function svreg(subbasename,atlasbasename,varargin)

[pth,subname,extt]=fileparts(subbasename);
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
fprintf(fp,'SVREG Version 15c(build#2225) (svreg)  \n');
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
if isempty(strfind(flags,'-v'))
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
    disp1('USAGE:','main',flags);
    disp1('Matlab: svreg $subbasename $atlas_basename [skip_surfreg]','main',flags);
    disp1('Command Line:run_svreg.sh $MCR_RUNTIME $subbasename [-flags]','main',flags);
    disp1('s flag skips the surface registration and directly performs volume registration if the required files exist.','main',flags);
    disp1('k flag keeps the intermediate files.','main',flags);
    disp1(' ','main',flags);
    disp1('Please refer to http://brainsuite.loni.ucla.edu for documentation.','main',flags);
    return;
end

if isempty(strfind(flags,'-gui'))
    disp1('Started SVREG Version 15c(build#2225) (svreg) sequence','main',flags);
    disp1('The whole surface volume registration and labeling sequence takes about 90-100 min.','main',flags);
else
    disp1('StartSVREG:SVREG Version 15c(build#2225) (svreg)','main',flags);
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
mtlbpool=exist('matlabpool');

if mtlbpool==2 && ~isempty(strfind(flags,'-P'))
    try
        matlabpool close force;
        matlabpool(3);
    catch
        delete(gcp('nocreate'));
        parpool(3);
        
    end
end
p=mfilename('fullpath');
[pth,~,~]=fileparts(p);
pth=pth(1:end-4);
% pth=pth(1:kkk(1)+5);
% pth=p(1:end-20);


sprintf('SVREG Version 15c(build#2225) (svreg), Started...  \n');

if exist('atlasbasename','var')
    if atlasbasename(1)=='-'
        flags=atlasbasename;
        clear atlasbasename;
    end
end

if ~exist('flags','var')
    flags='';
end

%svreg_prepare_files(subbasename, atlasbasename,flags);
hemi={'left','right'};

%% These two commands can run in parallel
if isempty(strfind(flags,'-s')) || ~exist([subbasename_tmp,'.target.right.pial.cortex.reg.dfs'],'file')
    parfor jj=1:2
        svreg_label_surf_hemi(subbasename,atlasbasename,hemi{jj},surreg_varargin{:});
    end
    %svreg_label_surf_hemi(subbasename,atlasbasename,'left',flags);
    
    %if ~isempty(strfind(flags,'r'))
    parfor jj=1:2
        refine_ROIs2(subbasename,hemi{jj},flags);
    end
    %end
end
if isempty(strfind(flags,'-S'))
    
    
    %map2atlas_thickness(subbasename);
    
    %%NOTE that atlasbasename chanes from this point on in the script
    atlasbasename=[subbasename,'.target'];
    
    %% These two commanda can run in parallel
    ss{1}=atlasbasename;ss{2}=subbasename;
    if ~exist([subbasename_tmp,'_unitball_map.mat'],'file') || isempty(strfind(flags,'-p'))
        parfor sub=1:2
            volmap_ball(ss{sub},1,flags);
        end
    end
    %volmap_ball(ss{2},1,flags);
    
    svreg_volreg(subbasename, atlasbasename,volreg_varargin{:});
    
    %This can be made optional with a flag
    
    if 1%~isempty(strfind(flags,'r'))
        %%These two can be run in parallel
        
        svreg_refinements(subbasename, atlasbasename,flags);
        
        %%These two can be run in parallel
        parfor jj=1:2
            refine_sulci_hemi(subbasename,hemi{jj},flags);
        end
    else
        copyfile([subbasename_tmp,'.left.mid.cortex.reg.dfs'],   [subbasename,'.left.mid.cortex.svreg.dfs'],'f');
        copyfile([subbasename_tmp,'.right.mid.cortex.reg.dfs'],  [subbasename,'.right.mid.cortex.svreg.dfs'],'f');
        copyfile([subbasename_tmp,'.left.inner.cortex.reg.dfs'], [subbasename,'.left.inner.cortex.svreg.dfs'],'f');
        copyfile([subbasename_tmp,'.right.inner.cortex.reg.dfs'],[subbasename,'.right.inner.cortex.svreg.dfs'],'f');
        copyfile([subbasename_tmp,'.left.pial.cortex.reg.dfs'],  [subbasename,'.left.pial.cortex.svreg.dfs'],'f');
        copyfile([subbasename_tmp,'.right.pial.cortex.reg.dfs'], [subbasename,'.right.pial.cortex.svreg.dfs'],'f');
    end
end

generate_stats_xls(subbasename, flags);


if isempty(strfind(flags,'-k'))
    clean_intermediate_files(subbasename);
end
if mtlbpool==2 && ~isempty(strfind(flags,'-P'))
    try
        matlabpool close
    catch
        delete(gcp('nocreate'));
    end
end
disp1('svreg sequence finished','svreg',flags);


