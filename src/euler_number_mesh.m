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




function E=euler_number_mesh(s)
% 
    nv=size(s.vertices,1);
    
    e1=[s.faces(:,1),s.faces(:,2);s.faces(:,2),s.faces(:,3);s.faces(:,1),s.faces(:,3)];
    e1=sort(e1,2);e1=unique(e1,'rows');
    ne=size(e1,1);
    nf=size(s.faces,1);
    
    E=nf-ne+nv;
    


