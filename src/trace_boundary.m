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



function bdr=trace_boundary(apst,vertConn,surf)
%disp('tracing boundary...');
ap=apst;cnt=1;flag=1;
bdr=ap;bdr=[bdr];
while(flag==1)
nbrs=vertConn{ap};
flag=0;
for ii=1:length(nbrs)
    if (length(intersect(nbrs(ii),bdr))==1) continue; end;
  % nbnbr= vertConn{nbrs(ii)};
  [triap,xx]=find(surf.faces==ap);
  [trinbr,xx]=find(surf.faces==nbrs(ii));
  
  if (length(intersect(triap,trinbr))==1)
       ap=nbrs(ii);bdr(end+1)=ap;
       flag=1;
       cnt=cnt+1;
        break;
   end
   
end
end
bdr=reshape(bdr,length(bdr),1);

if ((flag==0)&(length(bdr)<3))
    disp('Could not trace boundary!!! exiting');
    return
end

