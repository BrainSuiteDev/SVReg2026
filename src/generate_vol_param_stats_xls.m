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

function generate_vol_param_stats_xls(subbasename,param_nii_filename,varargin)

subbasename = remove_extn_basename(subbasename);

% Generate statistics from a given volumetric parameter file
[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end

subname=strcat(subname,extt);


tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
% warning off
% mkdir(tmpdir);
% warning on
if ~exist(tmpdir,'dir')
    subbasename_tmp=subbasename;
else
    subbasename_tmp=fullfile(tmpdir,subname);
end
logfname=[subbasename_tmp,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'SVREG (generate_vol_param_stats_xls)  \n');
fprintf(fp,'generate_vol_param_stats_xls %s ',subbasename);

for narg=1:length(varargin)
    fprintf(fp,'%s ',varargin{narg});
end
fprintf(fp,'\n');
fclose(fp);

flags='';
for nflags=1:size(varargin,2)
    flags=[flags,varargin{nflags}];
end

if ~contains(flags,'v')
    verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);   
    verbosity= str2double(verbosity);
end

if(~(existfile([subbasename_tmp,'.svreg.corr.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.label.nii.gz'])|| existfile([subbasename_tmp,'.svreg.corr.manual.label.nii.gz'])))
    error('SVREG label file missing: SVREG volume labels file not found. Please check if <name>.svreg.corr.label.nii.gz or <name>.svreg.label.nii.gz or <name>.svreg.corr.manual.label.nii.gz exists.');
end;

%% Load the parameter nifti file
if(existfile(param_nii_filename))
 param=load_nii_z(param_nii_filename);
else
    error('Volume parameter file missing: Please check the volume paramter filepath.');
end;

%% svreg labels - change in the future such that it is not hardcoded
labs= unique(vl.img(:)); labs = union([1,2,3],setdiff(labs,0));

% labs=[1,2,3,120,121,130,131,142,143,144,145,146,147,150,151,...
%     162,163,164,165,166,167,168,169,170,171,172,173,...
%     182,183,184,185,186,187,222,223,224,225,226,227,...
%     228,229,242,243,310,311,322,323,324,325,326,327,...
%     328,329,330,331,342,343,344,345,346,347,422,423,...
%     424,425,442,443,444,445,446,447,500,501,612,613,...
%     614,615,616,617,620,621,630,631,640,641,650,651,...
%     660,661,662,663,670,671,680,681,690,691,701,710,720,721,740,760,780,800,850,900];


%% Load svreg corrected volume label nifti files
if existfile([subbasename_tmp,'.svreg.corr.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.label.nii.gz'])
    if contains(flags,'r')
        vl=load_nii_z([subbasename_tmp,'.svreg.corr.label.nii']);
    else
        vl=load_nii_z([subbasename_tmp,'.svreg.label.nii']);vl.img=mod(vl.img,1000);
    end
end

if existfile([subbasename_tmp,'.svreg.corr.manual.label.nii.gz'])
    vl=load_nii_z([subbasename_tmp,'.svreg.corr.manual.label.nii']);
end

%% Load tissue fractions
vf=load_nii_z([subbasename,'.pvc.frac.nii']);

% individual tissue fraction volumes
vgm.img=(vf.img>1).*double(1-abs(vf.img-2));
vcsf.img=(vf.img<2).*double(1-abs(vf.img-1));
vwm.img=(vf.img>2).*double(1-abs(vf.img-3));

% GM,WM,CSF,Tot mean and standard deviation volume initialization
gm_m=zeros(length(labs),1);
csf_m=zeros(length(labs),1);
wm_m=zeros(length(labs),1);
tot_m=zeros(length(labs),1);
gm_s=zeros(length(labs),1);
csf_s=zeros(length(labs),1);
wm_s=zeros(length(labs),1);
tot_s=zeros(length(labs),1);

%% weighted mean and standard deviation of GM,WM,CSF voxels
if existfile([subbasename_tmp,'.svreg.corr.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.corr.manual.label.nii.gz'])
    for nlab=1:length(labs)
        ind=(vl.img==labs(nlab));
        if ~isempty(nonzeros(ind)) % no voxels in ROI
            if sum(vgm.img(ind)) ~= 0 % no GM voxels in ROI
                gm_m(nlab)= sum(vgm.img(ind).*param.img(ind))./sum(vgm.img(ind));
                M = length(nonzeros(vgm.img(ind)));
                gm_s(nlab)=sqrt(sum(vgm.img(ind).*(param.img(ind) - gm_m(nlab)).^2)/(((M-1)/M)*sum(vgm.img(ind))));
            else
                gm_m(nlab) = 0;gm_s(nlab) = 0;
            end;
            
            if sum(vcsf.img(ind)) ~= 0 % no CSF voxels in the ROI
                csf_m(nlab)=sum(vcsf.img(ind).*param.img(ind))./sum(vcsf.img(ind));
                M = length(nonzeros(vcsf.img(ind)));
                csf_s(nlab)=sqrt(sum(vcsf.img(ind).*(param.img(ind) - csf_m(nlab)).^2)/(((M-1)/M)*sum(vcsf.img(ind))));
            else
                gm_m(nlab) = 0;gm_s(nlab) = 0;
            end;
            
            if sum(vwm.img(ind)) ~=0 % no WM voxels in the ROI
                wm_m(nlab)=sum(vwm.img(ind).*param.img(ind))./sum(vwm.img(ind));
                M = length(nonzeros(vwm.img(ind)));
                wm_s(nlab)=sqrt(sum(vwm.img(ind).*(param.img(ind) - wm_m(nlab)).^2)/(((M-1)/M)*sum(vwm.img(ind))));
            else
                wm_m(nlab) = 0;wm_s(nlab) = 0;
            end;
            
            tot_m(nlab)= mean(param.img(ind));
            tot_s(nlab)= std(param.img(ind));
        else
             gm_m(nlab)=0;wm_m(nlab)=0;csf_m(nlab)=0; tot_m(nlab)=0;
             gm_s(nlab)=0;wm_s(nlab)=0;csf_s(nlab)=0;tot_s(nlab)=0;
        end;
    end
    
    % pure tissues -  need to change the fact that labels are hardcoded 
    gm_m(1:3)=0;wm_m(1:3)=0;csf_m(1:3)=0;
    gm_s(1:3)=0;wm_s(1:3)=0;csf_s(1:3)=0;
    
    csf_m(1)=sum(vcsf.img(:).*param.img(:))./sum(vcsf.img(:));% tot_m(1)=csf_m(1);
    M = length(nonzeros(vcsf.img(:)));
    csf_s(1)=sqrt(sum(vcsf.img(:).*(param.img(:) - csf_m(1)).^2)/(((M-1)/M)*sum(vcsf.img(:)))); %tot_s(1)=csf_s(1);
    
    gm_m(2)=sum(vgm.img(:).*param.img(:))./sum(vgm.img(:)); %tot_m(2)=gm_m(2);
    M = length(nonzeros(vgm.img(:)));
    gm_s(2)=sqrt(sum(vgm.img(:).*(param.img(:) - gm_m(2)).^2)/(((M-1)/M)*sum(vgm.img(:))));%tot_s(2)=gm_s(2);
    
    wm_m(3)=sum(vwm.img(:).*param.img(:))./sum(vwm.img(:));%tot_m(3)=wm_m(3);
    M = length(nonzeros(vwm.img(:)));
    wm_s(3)=sqrt(sum(vwm.img(:).*(param.img(:) - wm_m(3)).^2)/(((M-1)/M)*sum(vwm.img(:))));%tot_s(3)=wm_s(3);
    
    tot_m(1:3)= mean(param.img(:));
    tot_s(1:3)= std(param.img(:));
end

if existfile([subbasename_tmp,'.right.pial.cortex.manual.svreg.dfs'])&& existfile([subbasename_tmp,'.right.mid.cortex.manual.svreg.dfs'])&& existfile([subbasename_tmp,'.right.inner.cortex.manual.svreg.dfs'])
    fp=fopen([subbasename_tmp,'.param.roiwise.manual.stats.txt'],'w');
else
    fp=fopen([subbasename_tmp,'.param.roiwise.stats.txt'],'w');
end

if existfile([subbasename_tmp,'.svreg.corr.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.label.nii.gz'])  
    fprintf(fp,'ROI_ID\tGM voxels (mean)\tGM voxels (std dev)\tWM voxels (mean)\tWM voxels (std dev)\tCSF voxels (mean)\tCSF voxels (std dev)\tAll voxels (mean)\tAll voxels (std dev)\t\n');
    for nlab=1:length(labs)
        fprintf(fp,'%d\t\t\t%.6f\t\t\t%.6f\t\t\t%.6f\t\t\t%.6f\t\t\t%.6f\t\t\t%.6f\t\t\t%.6f\t\t\t%.6f\n',labs(nlab),gm_m(nlab),gm_s(nlab),wm_m(nlab),wm_s(nlab),csf_m(nlab),csf_s(nlab),tot_m(nlab),tot_s(nlab));
    end
end

fclose(fp);
if ~strcmp(subbasename_tmp,subbasename)
    copyfile([subbasename_tmp,'.param.roiwise.stats.txt'],[subbasename,'.param.roiwise.stats.txt'],'f')
    copyfile([subbasename_tmp,'.svreg.log'],[subbasename,'.svreg.log'],'f');
end
