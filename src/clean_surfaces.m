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



function clean_surfaces(subbasename,hemi)

%disp1('Cleaning Left Hemisphere surfaces');
s=readdfs([subbasename,'.',hemi,'.inner.cortex.dfs']);
[s,usedV]=myclean_patch_cc(s);
sp=readdfs([subbasename,'.',hemi,'.pial.cortex.dfs']);
sp.vertices=sp.vertices(usedV,:);
sp.faces=s.faces;
   if isfield(sp,'vcolor')
       sp.vcolor=sp.vcolor(usedV,:);
   end
   if isfield(sp,'attributes')
       sp.attributes=sp.attributes(usedV);
   end
   if isfield(sp,'labels')
       sp.labels=sp.labels(usedV);
   end
   
   if isfield(sp,'u')
       sp.u=sp.u(usedV);       sp.v=sp.v(usedV);
   end
   
   if isfield(sp,'normals')
       sp.normals=sp.normals(usedV,:);    %   p.v=po.v(loc);
   end
     

copyfile([subbasename,'.',hemi,'.inner.cortex.dfs'],[subbasename,'.',hemi,'.inner.cortex.orig.dfs'],'f');
copyfile([subbasename,'.',hemi,'.pial.cortex.dfs'],[subbasename,'.',hemi,'.pial.cortex.orig.dfs'],'f');
writedfs([subbasename,'.',hemi,'.inner.cortex.dfs'],s);
writedfs([subbasename,'.',hemi,'.pial.cortex.dfs'],sp);
%disp('done');
calc_mid_surf([subbasename,'.',hemi,'.inner.cortex.dfs'],[subbasename,'.',hemi,'.pial.cortex.dfs'],[subbasename,'.',hemi,'.mid.cortex.dfs']);

%disp('done');
