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

function sulc_map_vol(subbasename)
% Generates volumetric map of sulci in [subbasename,'.sulc.label.nii.gz']
%% Read the sulcal region labeled surface

fprintf('Generating volumetric regions\n');

l=readdfs([subbasename,'.','left','.mid.cortex.sulci.dfs']);
r=readdfs([subbasename,'.','right','.mid.cortex.sulci.dfs']);

%% Read pial and inner surfaces and compute intermediate surfaces
pl=readdfs([subbasename,'.','left','.pial.cortex.svreg.dfs']);pl=pl.vertices;
pr=readdfs([subbasename,'.','right','.pial.cortex.svreg.dfs']);pr=pr.vertices;

il=readdfs([subbasename,'.','left','.inner.cortex.svreg.dfs']);il=il.vertices;
ir=readdfs([subbasename,'.','right','.inner.cortex.svreg.dfs']);ir=ir.vertices;

ml = (il+pl)/2;
mr = (ir+pr)/2;
mpl=(ml+pl)/2;
mpr=(mr+pr)/2;
mil=(ml+il)/2;
mir=(mr+ir)/2;
labl=l.labels;
labr=r.labels;

%% Load volume labels

vol_lab = load_nii_BIG_Lab([subbasename,'.svreg.label.nii.gz']);
vol_img = vol_lab.img;

%pvc_lab = load_nii_BIG_Lab([subbasename,'.pvc.frac.nii.gz']);

xres = vol_lab.hdr.dime.pixdim(2);
yres = vol_lab.hdr.dime.pixdim(3);
zres = vol_lab.hdr.dime.pixdim(4);
SZ=size(vol_img);

%wm_msk=(pvc_lab.img>2.5);%vol_img>=2000;
%gm_msk=(pvc_lab.img>1.5)&(pvc_lab.img<=2.5);%pvc_lab.img==2;% & vol_img<2000;%vol_img>=1000 &

% Volumetric images
%vol_img(vol_img>=2000)=0;
%vol_img(pvc_lab.img==3)=0;

vol_img = mod(vol_img, 1000);
ind = find((vol_img >= 100) & (vol_img < 600));

%% Generate indices of the voxels to be labeled
[XX,YY,ZZ]=ind2sub(SZ,ind);XX=XX-1;YY=YY-1;ZZ=ZZ-1;

Xc = XX*xres;
Yc = YY*yres;
Zc = ZZ*zres;

from_vert=[pl;pr;il;ir;ml;mr;mil;mir;mpl;mpr];
from_labs=[labl;labr;labl;labr;labl;labr;labl;labr;labl;labr];

labs_vol=griddata(from_vert(:,1),from_vert(:,2),from_vert(:,3),from_labs,Xc,Yc,Zc,'nearest');

vol_lab.img=0*vol_lab.img;
vol_lab.img(ind)=labs_vol;%+1000*gm_msk(ind)+2000*wm_msk(ind);

%% Write sulcal regions as volume labels
save_untouch_nii_gz(vol_lab,[subbasename,'.sulci.label.nii.gz']);


