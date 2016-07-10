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



function surf_flatten_newbs(tar_surf,mov_surf,tar_curves,mov_curves,out_tar_surf,out_mov_surf,air_file_surf1,air_file_surf2,curves_no,flags)

if ~exist('flags','var')
    flags='';
end
if isempty(strfind(flags,'gui'))
    disp1('Performing L2 registration and flattening','svreg_label_surf_hemi',flags);
else
    disp1('L2Reg','svreg_label_surf_hemi',flags);
end

[surf1,surf2]=align_surf_curves(tar_surf,mov_surf,tar_curves,mov_curves,air_file_surf1,air_file_surf2,curves_no,flags);
    
surf1.u=0.5*(1+surf1.map(:,1)');surf1.v=0.5*(1+surf1.map(:,2)');
surf2.u=0.5*(1+surf2.map(:,1)');surf2.v=0.5*(1+surf2.map(:,2)');

writedfs(out_tar_surf,surf1); writedfs(out_mov_surf,surf2);

