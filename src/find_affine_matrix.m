% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2017 The Regents of the University of California and the University of Southern California
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


function A=find_affine_matrix(surfbasename_tmp)
% returns affine matrix that maps subject's coordinates into atlas
% coordinates
sub_midr=readdfs([surfbasename_tmp,'.right.pial.cortex.reg.dfs']);
atlas_midr=readdfs([surfbasename_tmp,'.target.right.pial.cortex.reg.dfs']);

sub_midl=readdfs([surfbasename_tmp,'.left.pial.cortex.reg.dfs']);
atlas_midl=readdfs([surfbasename_tmp,'.target.left.pial.cortex.reg.dfs']);


mapped_subr(:,1)=mygriddata(sub_midr.u',sub_midr.v',sub_midr.vertices(:,1),atlas_midr.u',atlas_midr.v');
mapped_subr(:,2)=mygriddata(sub_midr.u',sub_midr.v',sub_midr.vertices(:,2),atlas_midr.u',atlas_midr.v');
mapped_subr(:,3)=mygriddata(sub_midr.u',sub_midr.v',sub_midr.vertices(:,3),atlas_midr.u',atlas_midr.v');

mapped_subl(:,1)=mygriddata(sub_midl.u',sub_midl.v',sub_midl.vertices(:,1),atlas_midl.u',atlas_midl.v');
mapped_subl(:,2)=mygriddata(sub_midl.u',sub_midl.v',sub_midl.vertices(:,2),atlas_midl.u',atlas_midl.v');
mapped_subl(:,3)=mygriddata(sub_midl.u',sub_midl.v',sub_midl.vertices(:,3),atlas_midl.u',atlas_midl.v');

S=[[mapped_subl',mapped_subr'];[ones(1,length(mapped_subl)),ones(1,length(mapped_subr))]];
AT=[[atlas_midl.vertices',atlas_midr.vertices'];[ones(1,length(atlas_midl.vertices)),ones(1,length(atlas_midr.vertices))]];

A=AT/S;

