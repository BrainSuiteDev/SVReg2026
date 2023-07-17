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


function svreg_volreg(subbasename, atlas_name,varargin)

subbasename = remove_extn_basename(subbasename);


[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end
subname=strcat(subname,extt);

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);


%% Output a log
logfname=[subbasename,'.svreg.log'];
fp=fopen(logfname,'a+');
t = datestr(datetime('now'));
fprintf(fp,'%s:',t);
[svreg_version,svreg_build] = get_svreg_version(subbasename);
fprintf(fp,'SVReg %s(%s):',svreg_version,svreg_build);
fprintf(fp,'svreg_volreg %s %s ',subbasename, atlas_name);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');

fclose(fp);
%%

flags='';
for jj=1:size(varargin,2)
    flags=[flags,varargin{jj}];
end
%  flags=strrep(flags,'-','');
%  a=strfind(flags,'v');
if isempty(strfind(flags,'-v'))
    verbosity=2;
else
    a=strfind(flags,'-v');
    verbosity=flags(a(1)+2);
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

if isempty(strfind(flags,'-gui'))
    disp1('Inverting the map to find intial volumetric map','svreg_volreg',flags);
else
    disp1('InvMap','svreg_volreg',flags);
end
load(sprintf('%s_unitball_map.mat',subbasename_tmp));
Brain1=Brain;

%load(sprintf('%s_unitball_map.mat',atlas_name));
load(sprintf('%s.target_unitball_map.mat',subbasename_tmp));
Brain2=Brain;
clear Brain;
Brain1_Msize=Brain1.Msize;

%% Find diffeomorphism between white matter

%[xx1,yy1,zz1]=ind2sub(Brain1.Msize,Brain1.mask_indx);xx1=(xx1-1)*Brain1.resolution(1);yy1=(yy1-1)*Brain1.resolution(2);zz1=(zz1-1)*Brain1.resolution(3);
[xx2{1},xx2{2},xx2{3}]=ind2sub(Brain2.Msize,Brain2.mask_indx);%xx2{1}=(xx2{1}-1)*Brain2.resolution(1);xx2{2}=(xx2{2}-1)*Brain2.resolution(2);xx2{3}=(xx2{3}-1)*Brain2.resolution(3);

%tic
for jj=1:3
    map12{jj}=mygriddata3(Brain2.volmap(:,1),Brain2.volmap(:,2),Brain2.volmap(:,3),xx2{jj},Brain1.volmap(:,1),Brain1.volmap(:,2),Brain1.volmap(:,3));
    % map12{jj}=double(truncate(map12{jj},12));
end
disp1('done inverting for the white matter','svreg_volreg',flags);

parfor jj=1:3
    pial_surfmap12{jj}=mygriddata3(Brain2.surf_map(:,1),Brain2.surf_map(:,2),Brain2.surf_map(:,3),Brain2.surf_pial.vertices(:,jj),Brain1.surf_map(:,1),Brain1.surf_map(:,2),Brain1.surf_map(:,3));
    inner_surfmap12{jj}=mygriddata3(Brain2.surf_map(:,1),Brain2.surf_map(:,2),Brain2.surf_map(:,3),Brain2.surf_cortex.vertices(:,jj),Brain1.surf_map(:,1),Brain1.surf_map(:,2),Brain1.surf_map(:,3));
    mid_surfmap12{jj}=mygriddata3(Brain2.surf_map(:,1),Brain2.surf_map(:,2),Brain2.surf_map(:,3),(Brain2.surf_pial.vertices(:,jj)+Brain2.surf_cortex.vertices(:,jj))/2,Brain1.surf_map(:,1),Brain1.surf_map(:,2),Brain1.surf_map(:,3));
    
    % pial_surfmap12{jj}=double(truncate(pial_surfmap12{jj},10));
end



v_disp.hdr.dime.dim(2:4)=Brain1.Msize;
v_disp.hdr.dime.pixdim(2:4)=Brain1.resolution;
xmap=zeros(Brain1_Msize);ymap=xmap;zmap=xmap;


vs_pvc=load_nii_z([subbasename,'.pvc.frac.nii.gz']);
vt_pvc=load_nii_z([subbasename_tmp,'.target.pvc.frac.nii.gz']);

A=find_affine_matrix(subbasename_tmp);
vsubdim=size(vs_pvc.img);sub_res=vs_pvc.hdr.dime.pixdim(2:4);
vatlasdim=size(vt_pvc.img);tar_res=vt_pvc.hdr.dime.pixdim(2:4);
[X,Y,Z]=ndgrid(1:vsubdim(1),1:vsubdim(2),1:vsubdim(3));
X=(X-1)*sub_res(1);Y=(Y-1)*sub_res(2);Z=(Z-1)*sub_res(3);

map=A*[X(:)';Y(:)';Z(:)';ones(1,length(X(:)))];
xmap=X; xmap(:)=map(1,:)./map(4,:);xmap=xmap/tar_res(1)+1;
ymap=Y; ymap(:)=map(2,:)./map(4,:);ymap=ymap/tar_res(2)+1;
zmap=Z; zmap(:)=map(3,:)./map(4,:);zmap=zmap/tar_res(3)+1;
clear X Y Z Bx By Bz map;
%xmap=min(max(xmap,1),vatlasdim(1));
%ymap=min(max(ymap,1),vatlasdim(2));
%zmap=min(max(zmap,1),vatlasdim(3));clear map;
disp('Affine map trunction removed');

map.img(:,:,:,1)=xmap;map.img(:,:,:,2)=ymap;map.img(:,:,:,3)=zmap;
map=make_nii(single(map.img),Brain1.resolution);%map.hdr.hist=vs_pvc.hdr.hist;map.untouch = 1;
pth1=fileparts(subbasename_tmp);
interm_file_base=fullfile(pth1,'brainsuite.icbm452.lpi.v08a.img');
map_affine=map;
if exist(interm_file_base,'file')
    sub2tar_air_map(subbasename,subbasename_tmp,interm_file_base,[subbasename_tmp,'.target']);
    disp1('Affine Map is Replaced by AIR based map','svreg_volreg',flags);
    map2=load_nii_z([subbasename_tmp,'.2Atlas_AIR.map.nii.gz']);
    map.img(isfinite(map2.img))=map2.img(isfinite(map2.img));
    map.img(~isfinite(map.img))=0;
    
    pix = 5; [x1,y1,z1] = ndgrid(-pix:pix);
    se1 = (sqrt(x1.^2 + y1.^2 + z1.^2) <=pix);
    msk1=imdilate(map.img==0,se1);
    
    map.img(msk1)=map_affine.img(msk1);
    disp1('Singularities in Air based map are solved by copy from affine map','svreg_volreg',flags);
end
%save_untouch_nii_gz(map,[subbasename_tmp,'.affine.map.nii.gz']);
%fixBSheader([subbasename,'.bfc.nii.gz'], [subbasename_tmp,'.affine.map.nii.gz'],[subbasename_tmp,'.affine.map.nii.gz']);
subjspace_info=niftiinfo([subbasename,'.bfc.nii.gz']);
dws_write_nii([subbasename_tmp,'.affine.map.nii.gz'],single(map.img),subjspace_info); % dws 7/8/23 

xmap(Brain1.mask_indx)=map12{1};
ymap(Brain1.mask_indx)=map12{2};
zmap(Brain1.mask_indx)=map12{3};

xdiff= round(Brain1.surf_pial.vertices(:,1)/Brain1.resolution(1)) - Brain1.surf_pial.vertices(:,1)/Brain1.resolution(1);
ydiff= round(Brain1.surf_pial.vertices(:,2)/Brain1.resolution(2)) - Brain1.surf_pial.vertices(:,2)/Brain1.resolution(2);
zdiff= round(Brain1.surf_pial.vertices(:,3)/Brain1.resolution(3)) - Brain1.surf_pial.vertices(:,3)/Brain1.resolution(3);

pial_ind=sub2ind(Brain1.Msize,round(Brain1.surf_pial.vertices(:,1)/Brain1.resolution(1)) +1,round(Brain1.surf_pial.vertices(:,2)/Brain1.resolution(2)) +1,round(Brain1.surf_pial.vertices(:,3)/Brain1.resolution(3)) +1);
inner_ind=sub2ind(Brain1.Msize,round(Brain1.surf_cortex.vertices(:,1)/Brain1.resolution(1)) +1,round(Brain1.surf_cortex.vertices(:,2)/Brain1.resolution(2)) +1,round(Brain1.surf_cortex.vertices(:,3)/Brain1.resolution(3)) +1);
mid_ind=sub2ind(Brain1.Msize,round(.5*(Brain1.surf_cortex.vertices(:,1)+Brain1.surf_pial.vertices(:,1))/Brain1.resolution(1)) +1,round(.5*(Brain1.surf_cortex.vertices(:,2)+Brain1.surf_pial.vertices(:,2))/Brain1.resolution(2)) +1,round(.5*(Brain1.surf_cortex.vertices(:,3)+Brain1.surf_pial.vertices(:,3))/Brain1.resolution(3)) +1);

%xmap(pial_ind)=pial_surfmap12{1}/tar_res(1)+ 1 + xdiff*sub_res(1)/tar_res(1);
%ymap(pial_ind)=pial_surfmap12{2}/tar_res(2)+ 1 + ydiff*sub_res(2)/tar_res(2);
%zmap(pial_ind)=pial_surfmap12{3}/tar_res(3)+ 1 + zdiff*sub_res(3)/tar_res(3);
xmap1=accumarray(pial_ind,pial_surfmap12{1}/tar_res(1)+ 1 + xdiff*sub_res(1)/tar_res(1),size(xmap(:)),@mean);
ymap1=accumarray(pial_ind,pial_surfmap12{2}/tar_res(2)+ 1 + ydiff*sub_res(2)/tar_res(2),size(ymap(:)),@mean);
zmap1=accumarray(pial_ind,pial_surfmap12{3}/tar_res(3)+ 1 + zdiff*sub_res(3)/tar_res(3),size(zmap(:)),@mean);
xmap(pial_ind)=xmap1(pial_ind);ymap(pial_ind)=ymap1(pial_ind);zmap(pial_ind)=zmap1(pial_ind);

xdiff= round(Brain1.surf_cortex.vertices(:,1)/Brain1.resolution(1)) - Brain1.surf_cortex.vertices(:,1)/Brain1.resolution(1);
ydiff= round(Brain1.surf_cortex.vertices(:,2)/Brain1.resolution(2)) - Brain1.surf_cortex.vertices(:,2)/Brain1.resolution(2);
zdiff= round(Brain1.surf_cortex.vertices(:,3)/Brain1.resolution(3)) - Brain1.surf_cortex.vertices(:,3)/Brain1.resolution(3);
xmap1=accumarray(inner_ind,inner_surfmap12{1}/tar_res(1)+ 1 + xdiff*sub_res(1)/tar_res(1),size(xmap(:)),@mean);
ymap1=accumarray(inner_ind,inner_surfmap12{2}/tar_res(2)+ 1 + ydiff*sub_res(2)/tar_res(2),size(ymap(:)),@mean);
zmap1=accumarray(inner_ind,inner_surfmap12{3}/tar_res(3)+ 1 + zdiff*sub_res(3)/tar_res(3),size(zmap(:)),@mean);
xmap(inner_ind)=xmap1(inner_ind);ymap(inner_ind)=ymap1(inner_ind);zmap(inner_ind)=zmap1(inner_ind);

xdiff= round((Brain1.surf_cortex.vertices(:,1)+Brain1.surf_pial.vertices(:,1))*.5/Brain1.resolution(1)) - (Brain1.surf_cortex.vertices(:,1)+Brain1.surf_pial.vertices(:,1))*.5/Brain1.resolution(1);
ydiff= round((Brain1.surf_cortex.vertices(:,2)+Brain1.surf_pial.vertices(:,2))*.5/Brain1.resolution(2)) - (Brain1.surf_cortex.vertices(:,2)+Brain1.surf_pial.vertices(:,2))*.5/Brain1.resolution(2);
zdiff= round((Brain1.surf_cortex.vertices(:,3)+Brain1.surf_pial.vertices(:,3))*.5/Brain1.resolution(3)) - (Brain1.surf_cortex.vertices(:,3)+Brain1.surf_pial.vertices(:,3))*.5/Brain1.resolution(3);
xmap1=accumarray(mid_ind,mid_surfmap12{1}/tar_res(1)+ 1 + xdiff*sub_res(1)/tar_res(1),size(xmap(:)),@mean);
ymap1=accumarray(mid_ind,mid_surfmap12{2}/tar_res(2)+ 1 + ydiff*sub_res(2)/tar_res(2),size(ymap(:)),@mean);
zmap1=accumarray(mid_ind,mid_surfmap12{3}/tar_res(3)+ 1 + zdiff*sub_res(3)/tar_res(3),size(zmap(:)),@mean);
xmap(mid_ind)=xmap1(mid_ind);ymap(mid_ind)=ymap1(mid_ind);zmap(mid_ind)=zmap1(mid_ind);


tissue1=load_nii_z([subbasename,'.pvc.frac.nii.gz']);
v_disp.img=zeros(Brain1.Msize(1),Brain1.Msize(2),Brain1.Msize(3),3);
v_disp.img(:,:,:,1)=xmap;v_disp.img(:,:,:,2)=ymap;v_disp.img(:,:,:,3)=zmap;
%v_disp.img=truncate(v_disp.img,12);
%v_disp=make_nii((v_disp.img),Brain1.resolution);%v_disp.hdr.hist=tissue1.hdr.hist;v_disp.untouch=1;
%save_untouch_nii_gz(v_disp,[subbasename_tmp,'.surfreg.map.nii.gz']);clear v_disp;
%fixBSheader([subbasename,'.bfc.nii.gz'], [subbasename_tmp,'.surfreg.map.nii.gz'],[subbasename_tmp,'.surfreg.map.nii.gz']);
dws_write_nii([subbasename_tmp,'.surfreg.map.nii.gz'],(v_disp.img),subjspace_info);clear v_disp;

vsl=load_nii_z([subbasename_tmp,'.target.label.nii']);
vsl.img=interp3(vsl.img,(ymap),(xmap),(zmap),'nearest');
vsl.hdr=tissue1.hdr;
vsl.hdr.dime.datatype=4;
vsl.hdr.Datatype = 'int16';
save_untouch_nii_gz(vsl,sprintf('%s.label.surfreg.nii.gz',subbasename_tmp));
clearvars -except subbasename subbasename_tmp flags
%extend_deformation_laplacian(subbasename,subbasename_tmp);
if strfind(flags,'-A')
    ind1=strfind(flags,'-A');
    for jj=ind1+2:length(flags)
        if ~isnan(str2double(flags(ind1+2:jj)))
            SurfConstrAlpha=str2double(flags(ind1+2:jj));
        end
    end
else
    SurfConstrAlpha=50;%15;
end
extend_deformation_laplacian_hippo(subbasename,subbasename_tmp,SurfConstrAlpha);

%extend_deformation_laplacian_hippo_hard_constraints(subbasename,subbasename_tmp,SurfConstrAlpha);

%make_map_better(subbasename_tmp,'surfreg');
%svreg_warp_surf(subbasename);

if strfind(flags,'-S')
    fix_surfreg_map_selective2(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
else
    fix_surfreg_map(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
    %     fix_surfreg_map_fixed_pt(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
    %     fix_surfreg_map_fixed_pt(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
    %     fix_surfreg_map_fixed_pt(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
    %     fix_surfreg_map_fixed_pt(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
    %     fix_surfreg_map_fixed_pt(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
    
end

make_map_better(subbasename_tmp,'surfreg');
map=load_nii_z([subbasename_tmp,'.surfreg.map.nii']);

v_atlas=load_nii_z([subbasename_tmp,'.target.pvc.frac.nii.gz']);

v_w=trilinear(double(v_atlas.img),double(map.img(:,:,:,2)),double(map.img(:,:,:,1)),double(map.img(:,:,:,3)));v_atlas.img=[];
%v_w=double(truncate(v_w,12));
tissue1=load_nii_z([subbasename,'.pvc.frac.nii.gz']);
vww.hdr=tissue1.hdr;
vww.img=v_w;vww.untouch=1;
save_untouch_nii_gz(vww,[subbasename_tmp,'.surfreg2.nii.gz']);


%svreg_elastic_vol_reg_parfor_laplacian(subbasename,subbasename_tmp)
if strfind(flags,'-H')
    nit=600;ind1=strfind(flags,'-H');
    for jj=ind1+1:length(flags)
        if ~isnan(str2double(flags(ind1+2:jj)))
            nit=str2double(flags(ind1+2:jj));
        end
    end
else
    nit=100;
end
svreg_elastic_vol_reg_nonlin_cg(subbasename,subbasename_tmp,nit);
%%%make_map_better(subbasename_tmp,'svreg'); This step is not done
%%%properly, since the final map is not copied from tmp dir.. skipping for
%%%now
disp1('Computing inverse of svreg map','svreg_volreg',flags);
inv_svreg_map(subbasename,subbasename_tmp,[subbasename_tmp,'.target']);
disp1('Done inverse of svreg map','svreg_volreg',flags);

%svreg_elastic_vol_reg_nonlin_cg
if isempty(strfind(flags,'gui'))
    disp1('Volumetric registration is done.','svreg_volreg',flags);
else
    disp1('IntRegDone','svreg_volreg',flags);
end

