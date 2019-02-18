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



function [imgpair att1 att2]=curvature_hierarchy_map_BS_xyz(surf1,surf2,NumSc,NPTS,wt,flags)
% This function calculates NumSc level of smoothed surface curvatures.
if ~exist('flags','var')
    flags='';
end
if isempty(strfind(flags,'v'))    
     verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);   verbosity= str2double(verbosity);
end

surf1sq=surf1;
surf2sq=surf2;
if isempty(strfind(flags,'gui'))
    disp1('Calculating Multiresolution curvature maps','svreg_label_surf_hemi',flags);
else
    disp1('MultiResCurv','svreg_label_surf_hemi',flags);
end
ll=linspace(-1,1,NPTS);
[X,Y]=meshgrid(ll,ll);
smth=1;
if ~exist('wt','var')
    wt=ones(size(X));
end

surf1=readdfs(sprintf('%s_smooth%d.dfs',surf1.name(1:end-16),smth));
surf2=readdfs(sprintf('%s_smooth%d.dfs',surf2.name(1:end-16),smth));

vcolor1=surf1.attributes;%curvature_cortex_fast(surf1,50,0,C1);
vcolor2=surf2.attributes;%curvature_cortex_fast(surf2,50,0,C2);
att1=vcolor1;att2=vcolor2;

vc_sq1=mygriddata(surf1sq.u',surf1sq.v',vcolor1,X,Y);
vc_sq2=mygriddata(surf2sq.u',surf2sq.v',vcolor2,X,Y);


img1.sc{1}=vc_sq1.*wt;
img2.sc{1}=vc_sq2.*wt;
if verbosity>1
if isempty(strfind(flags,'gui'))
    disp1(sprintf('curvature resolution 1/%d',NumSc),'svreg_label_surf_hemi',flags);
else
    disp1(sprintf('CurvResMaps %d/%d',1,NumSc),'svreg_label_surf_hemi',flags);
end
end
for jj=2:NumSc
    if verbosity>1
    if isempty(strfind(flags,'gui'))
        disp1(sprintf('curvature resolution %d/%d',jj,NumSc),'svreg_label_surf_hemi',flags);
    else
        disp1(sprintf('CurvResMaps %d/%d',jj,NumSc),'svreg_label_surf_hemi',flags);
    end
    end
    smth=smth+1;
    surf1=readdfs(sprintf('%s_smooth%d.dfs',surf1sq.name(1:end-16),smth));
    surf2=readdfs(sprintf('%s_smooth%d.dfs',surf2sq.name(1:end-16),smth));
    
    vcolor1=surf1.attributes;%curvature_cortex_fast(surf1,50,0,C1);
    vcolor2=surf2.attributes;%curvature_cortex_fast(surf2,50,0,C2);
    att1=att1+vcolor1;att2=att2+vcolor2;
    
    vc_sq1=mygriddata(surf1sq.u',surf1sq.v',vcolor1,X,Y);
    vc_sq2=mygriddata(surf2sq.u',surf2sq.v',vcolor2,X,Y);
    
    img1.sc{jj}=double(single(vc_sq1.*wt));
    img2.sc{jj}=double(single(vc_sq2.*wt));
end

imgpair.img1=img1;
imgpair.img2=img2;

if isempty(strfind(flags,'gui'))
    disp1('Multiresolution curvature maps are calculated','svreg_label_surf_hemi',flags);
end
