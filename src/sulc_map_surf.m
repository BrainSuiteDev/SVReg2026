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


function sulc_map_surf(subbasename, hemi,xmlf,xmlc,dist_thr)

if ~exist('dist_thr','var')
    dist_thr=10;
end

file_sul=[subbasename,'.',hemi,'.mapped.refined.dfc'];

%%
fprintf('Generating sulcal regions on %s hemisphere\n',hemi);
if ~exist(file_sul,'file')
    disp('Sulci are not refined.');
    refine_sulci_hemi(subbasename, hemi);
end

%% Read surface, smooth is compute mean and Gaussian curvatures
s=readdfs([subbasename,'.',hemi,'.mid.cortex.svreg.dfs']);
so=s;
s=smooth_cortex_fast(s,.1,200);

Cmean=patchcurvature(s,1);

%% compute curvature map
s.attributes=1.0*(Cmean>0);
ss=s;
s=smooth_cortex_fast(s,.1,2200);
s.attributes=ss.attributes;
s.vcolor(:,1)=1-0.5*s.attributes;
s.vcolor(:,2)=s.vcolor(:,1);
s.vcolor(:,3)=s.vcolor(:,1);

%% find distance from the curves
allsulind=[];
sul=readdfc_sipi(file_sul);
if length(sul)==26
    newsul=cell(36,1);
    sul_26_to_36=[1,2,3,4,5,6,8,9,10,11,12,14,18,19,20,21,22,23,24,25,26,29,30,31,33,35];
    for jj=1:26
        newsul{sul_26_to_36(jj)}=sul{jj};
    end
    sul=newsul;
end
writedfc([subbasename,'.',hemi,'.mapped.refined.dfc'],sul,xmlc);
dist=zeros([size(s.vertices,1),1])+1e6;
labs=zeros([size(s.vertices,1),1]);
for jj=1:length(sul)
    if isempty(sul{jj})
        continue;
    end
    [~,~,ind2]=intersect(sul{jj},so.vertices,'rows','stable');
    s.vcolor(ind2,:)=1;
    sdf=signed_dist_func(s,ind2,2);
    sdf(sdf>20)=1e6;
    [dist,I]=min([dist,sdf],[],2);
    labs(I==2)=jj;
    allsulind=union(allsulind,ind2);
end

s.attributes(dist<2)=1;
s.vcolor(:,1)=1-0.5*s.attributes;
s.vcolor(:,2)=s.vcolor(:,1);
s.vcolor(:,3)=s.vcolor(:,1);


%% delete faces that are not on sulci
sulind=find(s.attributes<=0);
sr=s;
Z=0*sr.faces;
a1=ismember(s.faces(:,1),sulind);
Z(a1,1)=1;
a1=ismember(s.faces(:,2),sulind);
Z(a1,2)=1;
a1=ismember(s.faces(:,3),sulind);
Z(a1,3)=1;

Z=sum(Z,2)>1;
sr.faces(Z,:)=[];
sr=myclean_patch3(sr);

[~,ia,~]=intersect(s.vertices,sr.vertices,'rows','stable');
labs1=0*labs;
labs1(ia)=labs(ia);

% Delete the regions that are far away from the transferred sulci.
labs1(dist>dist_thr)=0;

trilab=median(labs1(s.faces),2);
newlabs=0*labs1;

%% do connected component analysis of the labels
for jj=1:length(sul)
    st=s;
    st.faces(trilab~=jj,:)=[];
    if isempty(st.faces)
        continue;
    end
    st=myclean_patch_cc(st);
    [~,ia,~]=intersect(s.vertices,st.vertices,'rows','stable');
    newlabs(ia)=jj;
end
flg= strcmp(hemi,'left');
ind1=(newlabs~=0);
newlabs(ind1)=flg+2*(newlabs(ind1)-1)+4000;
newlabs=newlabs.*(Cmean>0);

so.labels=newlabs;
writedfs([subbasename,'.',hemi,'.mid.cortex.sulci.dfs'],so);
% 
 %% color the sulcal regions
recolor_by_label([subbasename,'.',hemi,'.mid.cortex.sulci.dfs'],[],xmlf);

%%
s.labels=newlabs;
writedfs([subbasename,'.',hemi,'.smooth.mid.cortex.sulci.dfs'],s);

%% color the sulcal regions
recolor_by_label([subbasename,'.',hemi,'.smooth.mid.cortex.sulci.dfs'],[],xmlf);

