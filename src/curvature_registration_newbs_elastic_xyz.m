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



function curvature_registration_newbs_elastic_xyz(tar_surf,mov_surf,warped_surf,cf1,cf2,curves_no,subbasename,atlasbasename,flags,hemi)
if ~exist('flags','var')
   flags='';
end
if isempty(strfind(flags,'v'))
   verbosity=2;
else
   a=strfind(flags,'v');
   verbosity=flags(a(1)+1);
   verbosity= str2double(verbosity);
end

surf1name=tar_surf;%[base_fname_mov,'.target.left.mid.cortex.flatmap_noreg.dfs'];
surf2name=mov_surf;%[base_fname_mov,'.left.mid.cortex.flatmap_noreg.dfs'];

surf1=readdfs(surf1name);surf2=readdfs(surf2name);
C1=[];C2=[];
if exist('cf1','file') && exist('cf2','file')
   Curves1=readdfc_sipi(cf1);Curves2=readdfc_sipi(cf2);
   Curves1{15}=[];Curves1{28}=[];Curves2{15}=[];Curves2{28}=[];
   disp1(sprintf('Curves 15 and 28 are not reliable in the current protocol so removing from current protocol!!'),'svreg_label_surf_hemi',flags);
   
   for ii=curves_no%1:length(Curves1)
      
      if min(length(Curves1{ii}),length(Curves2{ii})) == 0
         Curves1{ii}=[];Curves2{ii}=[];
      else
         p1=param_curve(Curves1{ii});
         p2=param_curve(Curves2{ii});
         
         if length(Curves1{ii}) < length(Curves2{ii})
            indx=dsearchn(p2,p1);
            Curves2{ii}=Curves2{ii}(indx,:);
         else
            indx=dsearchn(p1,p2);
            Curves1{ii}=Curves1{ii}(indx,:);
         end
         
         Curves1{ii}=dsearchn(surf1.vertices,Curves1{ii});
         Curves2{ii}=dsearchn(surf2.vertices,Curves2{ii});
         C1=[C1;Curves1{ii}];
         C2=[C2;Curves2{ii}];
      end
   end
end

if isempty(strfind(flags,'gui'))
   disp1('Performing curvature registration','svreg_label_surf_hemi',flags);
else
   disp1('CurvatureReg','svreg_label_surf_hemi',flags);
end

[surf1,surf2o] = curvature_registration512g_wt_multi_bs_elastic_xyz_cg(surf1,surf2,C1,C2,subbasename,atlasbasename,flags,hemi);

surf2.attributes=surf2o.attributes;
writedfs(surf1name,surf1);
writedfs(surf2name,surf2);
writedfs(warped_surf,surf2o);

