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


function smooth_surf_hierarchy(surf_name,NumSc,flags)
% This function calculates NumSc level of smoothed surface curvatures.
if ~exist('flags','var')
    flags='';
end
%  flags=strrep(flags,'-','');
%  a=strfind(flags,'v');
if isempty(strfind(flags,'v'))    
     verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1); verbosity=str2num(verbosity);   
end

if isempty(strfind(flags,'gui'))
    disp1('Generating Smooth representations of the surface','svreg_label_surf_hemi',flags);
end

NIT=round(5000/NumSc);
surf1=readdfs(surf_name);

[~,C1]=vertices_connectivity_fast(surf1);

[surf1,A1]=smooth_cortex_fast(surf1,.8,50);
surf1.attributes=curvature_cortex_fast(surf1,50,0,C1);
smth=1;
writedfs(sprintf('%s_smooth%d.dfs',surf_name(1:end-4),smth),surf1);
    if isempty(strfind(flags,'gui'))& verbosity>1
disp1(sprintf('Smoothing step 1/%d',NumSc),'svreg_label_surf_hemi');
    end
for jj=2:NumSc
    if isempty(strfind(flags,'gui') )& verbosity>1
        disp1(sprintf('Smoothing step %d/%d',jj,NumSc),'svreg_label_surf_hemi');
    end
    surf1=smooth_cortex_fast(surf1,.1*4,round(NIT/4),A1);    
    surf1.attributes=curvature_cortex_fast(surf1,50,0,C1);
    smth=smth+1;
    writedfs(sprintf('%s_smooth%d.dfs',surf_name(1:end-4),smth),surf1);
end

% if isempty(strfind(flags,'gui'))
%     disp1('Done','svreg_label_surf_hemi',flags);
% end

