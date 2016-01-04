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


function [ind_ato,ind_subo]=L2_surf_matching(surf_atlas,surf_sub,flags)
if isempty(strfind(flags,'v'))
   verbosity=2;
else
   a=strfind(flags,'v');
   verbosity=flags(a(1)+1);   verbosity= str2double(verbosity);
end

if isempty(strfind(flags,'gui'))
   disp1('L2 distance minimization started. This can take 10-15 min.','svreg_label_surf_hemi',flags);
else
   disp1('L2DistMinStart','svreg_label_surf_hemi',flags);
end

surf_atlaso=surf_atlas;
surf_subo=surf_sub;
surf_atlas=reducepatch(surf_atlas,.05);surf_atlas_rp=surf_atlas;

surf_sub=myclean_patch3(surf_sub);
surf_atlas=myclean_patch3(surf_atlas);

step_size=.6;
lap_reg=25;
L=loreta(surf_atlas);
T=DelaunayTri(surf_sub.vertices);

for kk=1:round(250/4)%150
   if isempty(strfind(flags,'gui')) && verbosity>1
      disp1(sprintf('Iteration %d/%d',kk,round(250/4)),'svreg_label_surf_hemi',flags);
   else
      if verbosity>1
         disp1(sprintf('Iter:%d/%d',kk,round(250/4)),'svreg_label_surf_hemi',flags);
      end
   end
   vec_atlas2sub = l2dist_asy(surf_atlas.vertices,surf_sub.vertices,T.Triangulation);
   S=speye(length(vec_atlas2sub));
   
   L1=[lap_reg*L;S];
   bx=[zeros(length(L),1);vec_atlas2sub(:,1)];
   by=[zeros(length(L),1);vec_atlas2sub(:,2)];
   bz=[zeros(length(L),1);vec_atlas2sub(:,3)];
   
   
   L1tL1=L1'*L1;
   M=diag(L1tL1)+eps;
   vx=mypcg_lp(L1'*L1,L1'*bx,1e-100,300,M,[],flags);
   vy=mypcg_lp(L1'*L1,L1'*by,1e-100,300,M,[],flags);
   vz=mypcg_lp(L1'*L1,L1'*bz,1e-100,300,M,[],flags);
   
   L1_dist=sqrt(mean(vec_atlas2sub(:).^2));
   err(kk)=L1_dist;
   if L1_dist>15
      disp1(sprintf('The asymmetric L1 distance is too large, exiting :%g',L1_dist),'svreg_label_surf_hemi');
      break;
   end
   surf_atlas.vertices=surf_atlas.vertices+step_size*[vx,vy,vz];
end

ind_sub=dsearchn(surf_sub.vertices,surf_atlas.vertices);
[~,ind_ato]=intersect(surf_atlaso.vertices,surf_atlas_rp.vertices,'rows');
[~,ind_subo]=intersect(surf_subo.vertices,surf_sub.vertices,'rows');
ind_subo=ind_subo(ind_sub);

ind_subo=ind_subo(1:4:end);
ind_ato=ind_ato(1:4:end);

if isempty(strfind(flags,'gui'))
   disp1('L2 distance minimization is done','svreg_label_surf_hemi',flags);
else
   disp1('L2DistMinDone','svreg_label_surf_hemi',flags);
end
