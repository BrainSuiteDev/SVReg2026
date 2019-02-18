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


function sur=combine_surf(s)
vnum=0;sur.faces=[];sur.vertices=[];sur.labels=[];
for kk=1:length(s)
    sur.vertices=[sur.vertices;s{kk}.vertices];
    if any(strcmp('labels',fieldnames(s{kk})))
        sur.labels=[sur.labels;s{kk}.labels];
    end
    sur.faces=[sur.faces;s{kk}.faces+vnum];
    vnum=size(sur.vertices,1);
end
sur1.faces=sur.faces;sur1.vertices=sur.vertices;
% sur=myclean_patch3(sur1);
