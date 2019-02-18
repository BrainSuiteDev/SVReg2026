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

function gui_bias_correct
[fname,pathname]=uigetfile({'*.nii.gz;*.nii'},'Select .nii or .nii.gz file for bias field correction');
fname=fullfile(pathname,fname);
[v] = load_nii_z_bfc(fname);

v_label=load_nii_z_bfc([v.fileprefix(1:end-4),'.pvc.label.nii']);

vo=v;
%view_nii(v);
Msize=size(v.img);
% wm_avg=trimmean(v.img(v_label.img==2),50);
% gm_avg=trimmean(v.img(v_label.img==1),50);
% csf_avg=trimmean(v.img(v_label.img==0),50);
if(~sum(v_label.img==3))
    v_label.img=v_label.img+1;
end
% new BrainSUite labels
v.wm_avg=median(double(v.img(v_label.img==3)));
v.gm_avg=median(double(v.img(v_label.img==2)));
v.csf_avg=median(double(v.img(v_label.img==1)));
v.orig=v.img;
view_nii_bias_corr(v);

