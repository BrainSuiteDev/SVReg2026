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



function sub2tar_air_map(subbasename,subbasename_tmp,interm_file_base,atlasbasename)

warp_file_mov=[subbasename,'.warp'];
sub_file_base=[subbasename,'.bfc.nii.gz'];
outfile1=get_rand_fname();

get_air_map(interm_file_base,warp_file_mov,sub_file_base,outfile1)

warp_tar_file_mov=[subbasename_tmp,'_atlas.warp'];
tar_file_base=[atlasbasename,'.bfc.nii.gz'];
outfile2=get_rand_fname();

get_air_map(interm_file_base,warp_tar_file_mov,tar_file_base,outfile2)
tar_file_base=[atlasbasename];
sub_file_base=[subbasename];
sub_file_base_tmp=subbasename_tmp;
get_sub2tar_air_map(interm_file_base,sub_file_base,sub_file_base_tmp,tar_file_base,outfile1,outfile2);

