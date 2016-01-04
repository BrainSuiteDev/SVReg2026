%||AUM|| Clean volumetric labels
%clc;close all;clear all;
%restoredefaultpath;
 %addpath(genpath('C:\Users\ajoshi\Documents\git_sandbox\svreg-matlab\src'));
% addpath(genpath('C:\Users\ajoshi\Documents\git_sandbox\svreg-matlab\dev'));
% addpath(genpath('C:\Users\ajoshi\Copy\Jessicas_HiRes'));


function surf_label_atlas(atlasbasename)

vlname=[atlasbasename,'.label.nii.gz'];
vbfc=[atlasbasename,'.bfc.nii.gz'];
sname=[atlasbasename,'.left.mid.cortex'];
sname2=[atlasbasename,'.right.mid.cortex'];

vbfc=load_nii_BIG_Lab(vbfc);
vl_new=load_nii_BIG_Lab(vlname);
ind=find((vbfc.img>=00));%&(vl_new.img<600));
[XX,YY,ZZ]=ind2sub(size(vl_new.img),ind);XX=XX-1;YY=YY-1;ZZ=ZZ-1;
dim=vl_new.hdr.dime.pixdim(2:4);
XX=XX.*dim(1);YY=YY.*dim(2);ZZ=ZZ.*dim(3);

s=readdfs([sname,'.dfs']);
s2=readdfs([sname2,'.dfs']);

F=TriScatteredInterp(XX,YY,ZZ,double(vl_new.img(ind)),'nearest');
s.labels=F(s.vertices);
%s.labels(s.labels<110 | s.labels>600 | s.labels==344 | s.labels==345 | s.labels==346 |s.labels==347 )=0;
ind=find((s.labels>0)&(mod(s.labels,2)==0));s.labels(ind)=s.labels(ind)+1;
writedfs([sname,'.dfs'],s);

s2.labels=F(s2.vertices);

%s2.labels(s2.labels<110 | s2.labels>600 | s2.labels==344 | s2.labels==345 | s2.labels==346 |s2.labels==347 )=0;
ind=find(mod(s2.labels,2)==1);s2.labels(ind)=s2.labels(ind)+1;
writedfs([sname2,'.dfs'],s2);

recolor_by_label([sname,'.dfs'],atlasbasename);
refine_ROIs_atlas2([sname,'.dfs']);
recolor_by_label([sname,'.refined.dfs'],atlasbasename);  

recolor_by_label([sname2,'.dfs'],atlasbasename);
refine_ROIs_atlas2([sname2,'.dfs']);
recolor_by_label([sname2,'.refined.dfs'],atlasbasename);  
copyfile([atlasbasename,'.left.mid.cortex.refined.dfs'],[atlasbasename,'.left.mid.cortex.dfs']);
copyfile([atlasbasename,'.right.mid.cortex.refined.dfs'],[atlasbasename,'.right.mid.cortex.dfs']);

copy_attrib_colors(atlasbasename,'left','dfs');
copy_attrib_colors(atlasbasename,'right','dfs');




