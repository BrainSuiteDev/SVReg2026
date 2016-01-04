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



function register_cc_curve(sname)
sname1=strrep(sname,'.right.mid.cortex_smooth10.dfs','');
sname1=strrep(sname1,'.left.mid.cortex_smooth10.dfs','');

logfname=[sname1,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'SVREG Version 15c(build#2219) (register_cc_curve)  \n');
fprintf(fp,'register_cc_curve %s \n',sname);
fclose(fp);

disp('The register_cc_curve program as a part of the RCC package is provided under the terms');
disp('of the GNU General Public License, version 2 as published by');
disp('the Free Software Foundation.');
disp('');
disp('RCC is based on Coherent Point Drift (CPD) Package provided from');
disp('https://sites.google.com/site/myronenko/research/cpd');
disp('RCC package is distributed in the hope that it will be useful,');
disp('but WITHOUT ANY WARRANTY; without even the implied warranty of');
disp('MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the');
disp('GNU General Public License for more details.')
disp('');
disp('You should have received a copy of the GNU General Public License');
disp('along with RCC package; if not, write to the Free Software');
disp('Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA');

load(sprintf('%s_in_register_cc.mat',sname));
opt_ptc.method='rigid';opt_ptc.corresp=0;opt_ptc.viz=0;

[Tr,~]=cpd_register(surf1.vertices(bdr1,[2,3]),surf2.vertices(bdr2,[2,3]),opt_ptc);
Tr.Y=double(single(Tr.Y));
opt_ptc.method='nonrigid';opt_ptc.corresp=1;opt_ptc.viz=0;
Tr.Y=double(single(Tr.Y));
[Tr,~]=cpd_register(surf1.vertices(bdr1,[2,3]),Tr.Y,opt_ptc);
Tr.Y=double(single(Tr.Y));

save(sprintf('%s_out_register_cc.mat',sname),'Tr');
