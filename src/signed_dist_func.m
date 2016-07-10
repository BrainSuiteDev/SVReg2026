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



function sdf=signed_dist_func(surf,sulcus,Nsteps)

if ~exist('Nsteps','var')
    Nsteps=1e10;
end

vconn=vertices_connectivity_fast(surf);

     dist=zeros(size(surf.vertices,1),1); dist=dist+1e5;
     dist(sulcus)=0;


flag=1;
nstp=1;
while(flag==1)
    flag=0;
    for jj=1:length(surf.vertices)
        [m,i] = min(dist(vconn{jj})); nv=vconn{jj}(i);
        ss=sqrt(sum([surf.vertices(nv,1)-surf.vertices(jj,1),surf.vertices(nv,2)-surf.vertices(jj,2),surf.vertices(nv,3)-surf.vertices(jj,3)].^2));
        if dist(jj)>m+ss %surf1.ver(i)
            dist(jj)=m+ss;
            flag=1;
        end
    end
    nstp=nstp+1;%
    %disp1(sprintf('%d / %d',nstp,Nsteps),'SDF computation');
    if nstp>Nsteps
        break;
    end
end

sdf=dist;
