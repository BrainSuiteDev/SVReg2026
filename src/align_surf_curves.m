% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2016 The Regents of the University of California and the University of Southern California
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


function [surf1,surf2]=align_surf_curves(surf1name,surf2name,cname1,cname2,airfile1,airfile2,curves_no,flags)

if isempty(strfind(flags,'v'))    
     verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);   
    verbosity=str2double(verbosity);
end

surf1=readdfs(surf1name);
surf2=readdfs(surf2name);


Curves1={};
Curves2={};

if exist(cname1,'file') && exist(cname2,'file')
    disp1('Sulcal curves file is found!! Will use these for alignment.','svreg_label_surf_hemi',flags);
    Curves1=readdfc_sipi(cname1);
    Curves2=readdfc_sipi(cname2);
end

if isempty(strfind(flags,'gui'))
    disp1('Computing faces and vertices connectivity','svreg_label_surf_hemi',flags);
else
    disp1('ComputeFaceVtxConn','svreg_label_surf_hemi',flags);
end

[surf1vertConn,C1]=vertices_connectivity_fast(surf1);
[surf2vertConn,C2]=vertices_connectivity_fast(surf2);

surf1facesVConn=faces_connectivity_fast(surf1);
surf2facesVConn=faces_connectivity_fast(surf2);

surf1facesConn=faces2faces_connectivity(surf1,surf1facesVConn);
surf2facesConn=faces2faces_connectivity(surf2,surf2facesVConn);

boundary1 = boundary_vertices(surf1,surf1vertConn,surf1facesVConn,surf1facesConn);
boundary2 = boundary_vertices(surf2,surf2vertConn,surf2facesVConn,surf2facesConn);


[surf1t,surf2t,~,~]=surf_align_autocorrect_with_AIR(surf1,surf2,Curves1,Curves2,surf1vertConn,C1,surf2vertConn,C2,boundary1,boundary2,'RAS','RAS',4,10,0,airfile1,airfile2,curves_no,flags);

surf1.map=surf1t.map;surf2.map=surf2t.map;


