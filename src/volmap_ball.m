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



function ret=volmap_ball(basename,resample_factor,varargin)

[pth,subname,extt]=fileparts(basename);
subname=strcat(subname,extt);
tmpdir=fullfile(pth,[strrep(subname,'.target',''),'.svreg.tmp']);
tmpdir=strrep(tmpdir,'.target','');
%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);
if strfind(basename,'target')
basename=subbasename_tmp;
end

if ~exist('resample_factor','var')
    resample_factor=1;
else
    if ischar(resample_factor)
        resample_factor=str2double(resample_factor);
    end
end
logfname=[subbasename_tmp,'.svreg.log'];
logfname=strrep(logfname,'target.','');

fp=fopen(logfname,'a+');
fprintf(fp,'SVREG Version 15c(build#2225) (volmap_ball)  \n');
fprintf(fp,'volmap_ball %s %d ',basename,resample_factor);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');
fclose(fp);
ret='True';

flags='';
for jj=1:size(varargin,2)
    flags=[flags,varargin{jj}];
end
%  flags=strrep(flags,'-','');
%  a=strfind(flags,'v');
if isempty(strfind(flags,'v'))
    verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);   verbosity= str2double(verbosity);
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

if isempty(strfind(flags,'gui'))
    disp1('p-harmonic mapping of a hemisphere volume','volmap_ball',flags);
else
    disp1('pharmMapBall','volmap_ball',flags);
end



cortex_mask=[basename,'.cortex.dewisp.mask.nii'];
    v1=load_nii_z(fullfile(cortex_mask));

if resample_factor ~=1
    v1=resample_avw(v1,size(v1.img)*2);v1.img=uint8(255*(v1.img>128));
end
%delete(fullfile(cortex_mask));
surfl=readdfs([subbasename_tmp,'.left.inner.cortex.reg.dfs']);
surfr=readdfs([subbasename_tmp,'.right.inner.cortex.reg.dfs']);

surflp=readdfs([subbasename_tmp,'.left.pial.cortex.reg.dfs']);
surfrp=readdfs([subbasename_tmp,'.right.pial.cortex.reg.dfs']);

surflm=readdfs([subbasename_tmp,'.left.mid.cortex.reg.dfs']);
surfrm=readdfs([subbasename_tmp,'.right.mid.cortex.reg.dfs']);


surfl.u = 2*surfl.u - 1; surfl.v = 2*surfl.v - 1;
surfr.u = 2*surfr.u - 1; surfr.v = 2*surfr.v - 1;

%rl=sqrt(surfl.u.^2+surfl.v.^2);
%rr=sqrt(surfr.u.^2+surfr.v.^2);

surfl.u=min(max(surfl.u,-1),1);surfl.v=min(max(surfl.v,-1),1);
surfr.u=min(max(surfr.u,-1),1);surfr.v=min(max(surfr.v,-1),1);

UV=[surfl.u',surfl.v'];
UV =0.5*(UV*[1,1;1,-1]);
l1=sum(abs(UV),2);
l2=sqrt(sum(UV.^2,2));
UV=(UV./[l2,l2]).*[l1,l1];
surfl.u=UV(:,1);surfl.v=UV(:,2);
R=sqrt(sum(UV.^2,2));

UVWl=real([UV,cos(asin(R))]);
% p.vertices=UVW;
% view_patch(p);


UV=[surfr.u',surfr.v'];
UV =0.5*(UV*[1,1;1,-1]);
l1=sum(abs(UV),2);
l2=sqrt(sum(UV.^2,2));
UV=(UV./[l2,l2]).*[l1,l1];
surfr.u=UV(:,1);surfr.v=UV(:,2);
R=sqrt(sum(UV.^2,2));

UVWr=real([UV,-cos(asin(R))]);
% p.vertices=UVW;
% view_patch(p);
s{1}=surfl;s{2}=surfr;
sp{1}=surflp;sp{2}=surfrp;
sm{1}=surflp;sm{2}=surfrp;

surflr=combine_surf(s);surflrp=combine_surf(sp);surflr_mid=combine_surf(sm);
surflr_map=[UVWl;UVWr];
%resamp_factor=2;
%v1.hdr.dime.pixdim(2:4)/0.7;
% v1=resample_avw(v1,resample_factor*size(v1.img));
Brain.mask_indx=find(v1.img>=200);Brain.Msize=size(v1.img);
Brain.resolution=v1.hdr.dime.pixdim(2:4);%/resamp_factor;
Brain.surf=surflr;Brain.surfmap=surflr_map;%.vertices;

Brain.surf=surflr;Brain.surfmap=surflr_map;%.vertices;


%Brain.surfmap=[surf1_map.vertices;surf1_map.vertices];
Brain.surf_cortex = surflr;
Brain.surf_mid = surflr_mid;
Brain.surf_pial = surflrp;

Brain.surf_map = surflr_map;
clear v* sur*

Brain=volmap2ball_bs(Brain,flags);
%volmap=Brain.volmap;

save([subbasename_tmp,'_unitball_map.mat'],'Brain');
