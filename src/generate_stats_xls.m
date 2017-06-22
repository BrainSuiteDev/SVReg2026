% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2017 The Regents of the University of California and the University of Southern California
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



function generate_stats_xls(subbasename,varargin)

[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);
tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
if ~exist(tmpdir,'dir')
    subbasename_tmp=subbasename;
else
    subbasename_tmp=fullfile(tmpdir,subname);
end
logfname=[subbasename_tmp,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'generate_stats_xls %s ',subbasename);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');

fclose(fp);


flags='';
for jj=1:size(varargin,2)
    flags=[flags,varargin{jj}];
end
if ~contains(flags,'v')
    verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);   verbosity= str2double(verbosity);
end

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


labs= unique(vl.img(:)); labs = union([1,2,3],setdiff(labs,0));
% labs=[1,2,3,120,121,130,131,142,143,144,145,146,147,150,151,...
%     162,163,164,165,166,167,168,169,170,171,172,173,...
%     182,183,184,185,186,187,222,223,224,225,226,227,...
%     228,229,242,243,310,311,322,323,324,325,326,327,...
%     328,329,330,331,342,343,344,345,346,347,422,423,...
%     424,425,442,443,444,445,446,447,500,501,612,613,...
%     614,615,616,617,620,621,630,631,640,641,650,651,...
%     660,661,662,663,670,671,680,681,690,691,701,710,720,721,740,760,780,800,850,900];


l=readdfs([subbasename_tmp,'.left.mid.cortex.svreg.dfs']);
r=readdfs([subbasename_tmp,'.right.mid.cortex.svreg.dfs']);
li=readdfs([subbasename_tmp,'.left.inner.cortex.svreg.dfs']);
ri=readdfs([subbasename_tmp,'.right.inner.cortex.svreg.dfs']);
lp=readdfs([subbasename_tmp,'.left.pial.cortex.svreg.dfs']);
rp=readdfs([subbasename_tmp,'.right.pial.cortex.svreg.dfs']);
if existfile([subbasename_tmp,'.right.pial.cortex.manual.svreg.dfs'])&& existfile([subbasename_tmp,'.right.mid.cortex.manual.svreg.dfs'])&& existfile([subbasename,'.right.inner.cortex.manual.svreg.dfs'])
    l=readdfs([subbasename_tmp,'.left.mid.cortex.manual.svreg.dfs']);
    r=readdfs([subbasename_tmp,'.right.mid.cortex.manual.svreg.dfs']);
    li=readdfs([subbasename_tmp,'.left.inner.cortex.manual.svreg.dfs']);
    ri=readdfs([subbasename_tmp,'.right.inner.cortex.manual.svreg.dfs']);
    lp=readdfs([subbasename_tmp,'.left.pial.cortex.manual.svreg.dfs']);
    rp=readdfs([subbasename_tmp,'.right.pial.cortex.manual.svreg.dfs']);
end

% if thicknessPVC has been run then use thickness values from that.
if existfile([subbasename,'.pvc-thickness_0-6mm.right.mid.cortex.dfs'])
    r_th=readdfs([subbasename,'.pvc-thickness_0-6mm.right.mid.cortex.dfs']);
    r.attributes=r_th.attributes;
    l_th=readdfs([subbasename,'.pvc-thickness_0-6mm.left.mid.cortex.dfs']);
    l.attributes=l_th.attributes;
end


labs_sub=labs;
ind=[];
labs_sub=labs_sub(ind);
labs(ind)=[];

th_roi=zeros(length(labs),1);
roi_area=th_roi;roi_area_inner=roi_area;roi_area_pial=roi_area;

for jj=1:length(labs)
    th_roi(jj)=mean([l.attributes(l.labels==labs(jj));r.attributes(r.labels==labs(jj))]);
    if labs(jj)>600 | labs(jj)==3
        th_roi(jj)=0;
    end
end
triL=tri_area(l.faces,l.vertices);
triR=tri_area(r.faces,r.vertices);
triLi=tri_area(li.faces,li.vertices);
triRi=tri_area(ri.faces,ri.vertices);
triLp=tri_area(lp.faces,lp.vertices);
triRp=tri_area(rp.faces,rp.vertices);

noncortical=zeros(length(labs),1);

for jj=1:length(labs)
    if labs(jj)>600 || labs(jj)<100
        continue;
    end
    noncortical(jj)=1;
    tri_roi=find(((l.labels(l.faces(:,1))==labs(jj)) + (l.labels(l.faces(:,2))==labs(jj)) + (l.labels(l.faces(:,3))==labs(jj)))>=2);
    roi_area(jj)=sum(triL(tri_roi));
    roi_area_inner(jj)=sum(triLi(tri_roi));
    roi_area_pial(jj)=sum(triLp(tri_roi));
    
    tri_roi=find(((r.labels(r.faces(:,1))==labs(jj)) + (r.labels(r.faces(:,2))==labs(jj)) + (r.labels(r.faces(:,3))==labs(jj)))>=2);
    roi_area(jj)=roi_area(jj)+sum(triR(tri_roi));
    roi_area_inner(jj)=roi_area_inner(jj)+sum(triRi(tri_roi));
    roi_area_pial(jj)=roi_area_pial(jj)+sum(triRp(tri_roi));
end


vf=load_nii_z([subbasename,'.pvc.frac.nii']);

vgm.img=(vf.img>1).*double(1-abs(vf.img-2));
vcsf.img=(vf.img<2).*double(1-abs(vf.img-1));
vwm.img=(vf.img>2).*double(1-abs(vf.img-3));

gmv=zeros(length(labs),1);
csfv=zeros(length(labs),1);
wmv=zeros(length(labs),1);
totv=zeros(length(labs),1);

if existfile([subbasename_tmp,'.svreg.corr.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.corr.manual.label.nii.gz'])
    for jj=1:length(labs)
        ind=(vl.img==labs(jj)); 
        gmv(jj)=sum(vgm.img(ind))*vl.hdr.dime.pixdim(2)*vl.hdr.dime.pixdim(3)*vl.hdr.dime.pixdim(4);
        csfv(jj)=sum(vcsf.img(ind))*vl.hdr.dime.pixdim(2)*vl.hdr.dime.pixdim(3)*vl.hdr.dime.pixdim(4);
        wmv(jj)=sum(vwm.img(ind))*vl.hdr.dime.pixdim(2)*vl.hdr.dime.pixdim(3)*vl.hdr.dime.pixdim(4);
        totv(jj)=wmv(jj)+gmv(jj);
    end
    gmv(1:3)=0;wmv(1:3)=0;csfv(1:3)=0;
    csfv(1)=sum(vcsf.img(:))*vl.hdr.dime.pixdim(2)*vl.hdr.dime.pixdim(3)*vl.hdr.dime.pixdim(4);totv(1)=csfv(1);
    gmv(2)=sum(vgm.img(:))*vl.hdr.dime.pixdim(2)*vl.hdr.dime.pixdim(3)*vl.hdr.dime.pixdim(4);totv(2)=gmv(2);
    wmv(3)=sum(vwm.img(:))*vl.hdr.dime.pixdim(2)*vl.hdr.dime.pixdim(3)*vl.hdr.dime.pixdim(4);totv(3)=wmv(3);
    
    labs_vol=zeros(length(labs_sub),1);
    for jj=1:length(labs_sub)
        ind=find(vl.img==labs_sub(jj)); 
        labs_vol(jj)=length(ind)*vl.hdr.dime.pixdim(2)*vl.hdr.dime.pixdim(3)*vl.hdr.dime.pixdim(4);
    end
end
if existfile([subbasename_tmp,'.right.pial.cortex.manual.svreg.dfs'])&& existfile([subbasename_tmp,'.right.mid.cortex.manual.svreg.dfs'])&& existfile([subbasename_tmp,'.right.inner.cortex.manual.svreg.dfs'])
    fp=fopen([subbasename_tmp,'.roiwise.manual.stats.txt'],'w');
else
    fp=fopen([subbasename_tmp,'.roiwise.stats.txt'],'w');
end
if existfile([subbasename_tmp,'.svreg.corr.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.label.nii.gz'])
    
    fprintf(fp,'ROI_ID\tMean_Thickness(mm)\tGM_Volume(mm^3)\tCSF_Volume(mm^3)\tWM_Volume(mm^3)\tTotal_Volume(GM+WM)(mm^3)\tCortical_Area_mid(mm^2)\tCortical_Area_inner(mm^2)\tCortical_Area_pial(mm^2)\n');
    for jj=1:length(labs)
        fprintf(fp,'%d\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\n',labs(jj),th_roi(jj),gmv(jj),csfv(jj),wmv(jj),totv(jj),roi_area(jj),roi_area_inner(jj),roi_area_pial(jj));
    end
else
    fprintf(fp,'ROI_ID\tMean_Thickness(mm)\tCortical_Area(mm^2)\n');
    for jj=1:length(labs)
        fprintf(fp,'%d\t%.6f\t%.6f\n',labs(jj),th_roi(jj),roi_area(jj));
    end
    
end

if existfile([subbasename_tmp,'.svreg.corr.label.nii.gz']) || existfile([subbasename_tmp,'.svreg.label.nii.gz'])
    
    for jj=1:length(labs_sub)
            fprintf(fp,'%d\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\n',labs_sub(jj),0,0,0,0,labs_vol(jj));
    end
end
fclose(fp);
if ~strcmp(subbasename_tmp,subbasename)
    copyfile([subbasename_tmp,'.roiwise.stats.txt'],[subbasename,'.roiwise.stats.txt'],'f')
    copyfile([subbasename_tmp,'.svreg.log'],[subbasename,'.svreg.log'],'f');
end
