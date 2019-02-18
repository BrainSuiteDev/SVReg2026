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

function svreg_labelwith_atlas(subbasename,atlasbasename,postfix)

if (nargin < 3)
    fprintf('USAGE: svreg_labelwith_atlas.sh subbasename, atlasbasename, postfix\n');
    fprintf('subbasename: subjectbasename as in svreg command line\n');
    fprintf('atlasbasename: The new atlas (BCI-DNI,USCBrain,USCLobes)\n');
    fprintf('postfix: the new postfix that will be added to the output file names\n');
end

postfix=[postfix,'.'];
[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);

%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);

logfname=[subbasename,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'svreg_labelwith_atlas %s %s %s',subbasename,atlasbasename,postfix);
fprintf(fp,'\n');

subpth=fileparts(subbasename);

% label surfaces
sl=readdfs([subbasename,'.left.mid.cortex.svreg.dfs']);
al=readdfs(fullfile(subpth,'atlas.left.mid.cortex.svreg.dfs'));
new_al=readdfs([atlasbasename,'.left.mid.cortex.dfs']);

sl.labels=map_data_flatmap(al, new_al.labels, sl, 'nearest');

slin=readdfs([subbasename,'.left.inner.cortex.svreg.dfs']);
slin.labels=sl.labels;

slpial=readdfs([subbasename,'.left.pial.cortex.svreg.dfs']);
slpial.labels=sl.labels;


sr=readdfs([subbasename,'.right.mid.cortex.svreg.dfs']);
ar=readdfs(fullfile(subpth,'atlas.right.mid.cortex.svreg.dfs'));
new_ar=readdfs([atlasbasename,'.right.mid.cortex.dfs']);

sr.labels=map_data_flatmap(ar, new_ar.labels, sr, 'nearest');



srin=readdfs([subbasename,'.right.inner.cortex.svreg.dfs']);
srin.labels=sr.labels;

srpial=readdfs([subbasename,'.right.pial.cortex.svreg.dfs']);
srpial.labels=sr.labels;

%if ~exist(subbasename_tmp,'dir')
mkdir(subbasename_tmp);
p1=fileparts(subbasename);
p1at=fileparts(atlasbasename);
p2=fileparts(subbasename_tmp);
copyfile(fullfile(p1at,'brainsuite_labeldescription.xml'),fullfile(p2,'brainsuite_labeldescription.xml'));

xml_fname = fullfile(p1,['brainsuite_labeldescription.',postfix,'xml']);
copyfile(fullfile(p2,'brainsuite_labeldescription.xml'),xml_fname);

copyfile(sprintf('%s.svreg.init.label.nii.gz',subbasename),sprintf('%s.label.surfreg.nii.gz',subbasename_tmp));
%end
%subbasename_tmp=subbasename;
slout=[subbasename_tmp,'.left.mid.cortex.reg.',postfix,'dfs'];
srout=[subbasename_tmp,'.right.mid.cortex.reg.',postfix,'dfs'];
sloutin=[subbasename_tmp,'.left.inner.cortex.svreg.',postfix,'dfs'];
sroutin=[subbasename_tmp,'.right.inner.cortex.svreg.',postfix,'dfs'];
sloutp=[subbasename_tmp,'.left.pial.cortex.svreg.',postfix,'dfs'];
sroutp=[subbasename_tmp,'.right.pial.cortex.svreg.',postfix,'dfs'];

writedfs(slout,sl);writedfs(sloutin,slin);writedfs(sloutp,slpial);
writedfs(srout,sr);writedfs(sroutin,srin);writedfs(sroutp,srpial);


hemi={'left','right'};
parfor j=1:2
    refine_ROIs2(subbasename,hemi{j},postfix);
%refine_ROIs2(subbasename,'right',['svreg.',postfix]);
end

slout=[subbasename,'.left.mid.cortex.svreg.',postfix,'dfs'];
srout=[subbasename,'.right.mid.cortex.svreg.',postfix,'dfs'];
sloutin=[subbasename,'.left.inner.cortex.svreg.',postfix,'dfs'];
sroutin=[subbasename,'.right.inner.cortex.svreg.',postfix,'dfs'];
sloutp=[subbasename,'.left.pial.cortex.svreg.',postfix,'dfs'];
sroutp=[subbasename,'.right.pial.cortex.svreg.',postfix,'dfs'];

recolor_by_label(slout,atlasbasename);
recolor_by_label(srout,atlasbasename);
recolor_by_label(sloutin,atlasbasename);
recolor_by_label(sroutin,atlasbasename);
recolor_by_label(sloutp,atlasbasename);
recolor_by_label(sroutp,atlasbasename);

vmap=load_nii_z([subbasename,'.svreg.map.nii.gz']);
vsl=load_nii_z([atlasbasename,'.label.nii.gz']);
vsl_sub=load_nii_z([subbasename,'.svreg.label.nii.gz']);

xmap2=vmap.img(:,:,:,1);
ymap2=vmap.img(:,:,:,2);
zmap2=vmap.img(:,:,:,3);
vsl_sub.img=interp3(vsl.img,(ymap2),(xmap2),(zmap2),'nearest',0);

save_untouch_nii_gz(vsl_sub,sprintf('%s.svreg.%slabel.nii.gz',subbasename_tmp,postfix));

svreg_refinements(subbasename,atlasbasename,postfix);

copyfile(fullfile(p1at,'brainsuite_labeldescription.xml'),fullfile(p2,'brainsuite_labeldescription.xml'));


% refine volume


