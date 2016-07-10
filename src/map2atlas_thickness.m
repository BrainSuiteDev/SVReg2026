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



function map2atlas_thickness(subbasename,hemi)
%Map thickness from subject to atlas brain
%disp1('Mapping thickness from subject to atlas','svreg_label_surf_hemi');

tar=readdfs([subbasename,'.target.',hemi,'.mid.cortex.reg.dfs']);
%sub_th=readdfs([subbasename,'.right.mid.cortex.thickness.dfs']);
sub=readdfs([subbasename,'.',hemi,'.mid.cortex.reg.dfs']);
subin=readdfs([subbasename,'.',hemi,'.inner.cortex.reg.dfs']);
subout=readdfs([subbasename,'.',hemi,'.pial.cortex.reg.dfs']);
thickness=sqrt(sum((subout.vertices-subin.vertices).^2,2));
ss=sub;ss.attributes=thickness;
writedfs([subbasename,'.',hemi,'.mid.cortex.reg.dfs'],ss);


tar.attributes=map_data_flatmap(sub,thickness,tar);
writedfs([subbasename,'.target.',hemi,'.mid.cortex.reg.dfs'],tar);

cmpt=computer;
if ~strcmp(cmpt(1:5),'PCWIN')
    [s,r]=unix(['chmod -R 775 ',subbasename,'*.dfs']);
end



