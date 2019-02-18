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
function package_source(out_dir)

src_dirs={'src','compile_scripts','MEX_Files','scripts'};
for jj=1:length(src_dirs)
    copyfile(fullfile('..',src_dirs{jj}),fullfile(out_dir,src_dirs{jj}));
end
mkdir(fullfile(out_dir,'3rdParty'));
copyfile('../3rdParty/*.m',fullfile(out_dir,'3rdParty'));
copyfile('../3rdParty/*.c',fullfile(out_dir,'3rdParty'));
copyfile('../3rdParty/trilinear.cpp',fullfile(out_dir,'3rdParty'));
mkdir(fullfile(out_dir,'3rdParty','AIR_bin'));
copyfile('../README.md',out_dir);
copyfile('../LICENSE.txt',out_dir);
copyfile('../COMPILATION.txt',out_dir);
copyfile('../NOTICE_src.txt',fullfile(out_dir,'NOTICE.txt'));
zip([out_dir,'.zip'],out_dir);

