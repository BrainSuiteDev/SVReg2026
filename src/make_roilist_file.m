
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

function make_roilist_file(basename)


pth = fileparts(basename);
roi_list_fname = fullfile(pth,'roi_list_svreg.txt');

xmlfile = fullfile(pth,'brainsuite_labeldescription.xml');

x = xml2struct(xmlfile);
c = containers.Map('KeyType','int32','ValueType','char');

for i=1:length(x.labelset.label)
    
    c(str2double(x.labelset.label{i}.Attributes.id)) = x.labelset.label{i}.Attributes.fullname;

end


fname = [basename,'.svreg.label.nii.gz'];
if ~exist(fname,'file')
    fname = [basename,'.label.nii.gz'];
end

v = load_nii_BIG_Lab(fname);

labs = unique(v.img(:));

fid = fopen(roi_list_fname,'w');
[~,at_name] = fileparts(pth);
fprintf(fid,'# Atlas Name: %s\n',at_name);

for ind = 1:length(labs)
    fprintf(fid,'%d\t%s\n',labs(ind),c(labs(ind)));
end

fclose(fid);

