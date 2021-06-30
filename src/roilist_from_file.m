
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


function labs = roilist_from_file(roi_list_fname)
fid = fopen(roi_list_fname);
a=fgetl(fid);

labs = [];
n=1;
while(ischar(a))
    if a(1) ~= '#'
        data1 = textscan(a, '%d%s','whitespace', '', 'Delimiter', sprintf('\t'));
        labs(n) = data1{1}; n= n+1; %#ok<AGROW>
    end
    a = fgetl(fid);
end
fclose(fid);
end
