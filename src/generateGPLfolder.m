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


function generateGPLfolder(output_dir)

packaging_dir = pwd();
[root_dir, nm, ext] = fileparts(packaging_dir);
lic_file = fullfile(root_dir, 'docs', 'license_GPL_short.txt');
ignore_list = {'docs', '3rdParty'};

addLicenseOnTop(root_dir, output_dir, lic_file, ignore_list, true)
copyfile(fullfile(root_dir, 'docs', 'gpl-2.0.txt'), fullfile(output_dir, 'LICENSE.txt'))
%copyfile(fullfile(root_dir, 'docs', 'bdpchangelog.txt'), fullfile(output_dir, 'CHANGELOG.txt'))


% delete some selected files 
rmdir(fullfile(output_dir, 'docs'), 's')
delete(fullfile(output_dir, 'packaging_tools', 'addLicenseOnTop.m'))
%delete(fullfile(output_dir, 'packaging_tools', 'bdpGenerateHTMLreadme.m'))
delete(fullfile(output_dir, 'packaging_tools', 'generateGPLfolder.m'))

