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


function calc_mid_surf(inner,pial,mid)
%
s1=readdfs(inner);
s2=readdfs(pial);
s3.faces=s1.faces;s3.vertices=0.5*(s1.vertices+s2.vertices);
if exist(mid,'file')
    delete(mid);
end
   if isfield(s1,'vcolor')
       s3.vcolor=s1.vcolor;
   end
   if isfield(s1,'attributes')
       s3.attributes=s1.attributes;
   end
   if isfield(s1,'labels')
       s3.labels=s1.labels;
   end
   
   if isfield(s1,'u')
       s3.u=s1.u;       s3.v=s1.v;
   end
   
   if isfield(s1,'normals')
       s3.normals=s1.normals;    %   p.v=po.v(loc);
   end
     

%this is target surface written into mov surfaces dir
writedfs(mid,s3);
