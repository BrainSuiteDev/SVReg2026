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


function ptmov_dist = l2dist_asy(ptmov,ptfxed,T)
% calculates distances from s1 to s2, s2 to s1 and calculates average along
% s1
%[indmov]=dsearchn(ptmov,ptfxed);
%dist_vec_indmov = ptfxed - ptmov(indmov,:);

[indfxed]=dsearchn(ptfxed,T,ptmov);
ptmov_dist = ptfxed(indfxed,:) - ptmov;

% dval = [dist_vec_indmov;dist_vec];
% ind = [indmov;[1:length(ptmov)]'];
% 
% dval1=zeros(length(ptmov),3);
% 
% dval1(:,1)=accumarray(ind,dval(:,1));
% dval1(:,2)=accumarray(ind,dval(:,2));
% dval1(:,3)=accumarray(ind,dval(:,3));
% 
% 
% divf=accumarray(ind,ones(length(ind),1));
% 
% dval1(:,1)=dval1(:,1)./divf;
% dval1(:,2)=dval1(:,2)./divf;
% dval1(:,3)=dval1(:,3)./divf;


%ptmov_dist=dval1;

