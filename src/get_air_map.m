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



function get_air_map(mov_file_base,warp_file_mov,tar_file_base,outfile)

vm=load_nii(mov_file_base);
mov_sz=size(vm.img);

x_fname=get_rand_fname();
y_fname=get_rand_fname();
z_fname=get_rand_fname();
xw_fname=get_rand_fname();
yw_fname=get_rand_fname();
zw_fname=get_rand_fname();

vt=load_nii_z(tar_file_base);tar_sz=size(vt.img);
[X1,Y1,Z1]=meshgrid(1:mov_sz(2),1:mov_sz(1),1:mov_sz(3));

%%[X2,Y2,Z2]=meshgrid(1:tar_sz(2),1:tar_sz(1),1:tar_sz(3));

%vmx=vm;
%vmx.hdr.hist.magic='ni1';
vmx=make_nii(uint16(X1*100));
%vmx.img=ones(size(X1));
save_nii(vmx,[x_fname,'.img']);
copyfile([mov_file_base(1:end-4) '.hdr'], [x_fname,'.hdr'], 'f');


%vxx=load_nii('X.img');
vmx=make_nii(uint16(Y1*100));
save_nii(vmx,[y_fname,'.img']);
copyfile([mov_file_base(1:end-4) '.hdr'], [y_fname,'.hdr'], 'f');

vmx=make_nii(uint16(Z1*100));
save_nii(vmx,[z_fname,'.img']);
copyfile([mov_file_base(1:end-4) '.hdr'], [z_fname,'.hdr'], 'f');

%system(['C:\Users\ajosh_000\Downloads\AIR5.3.0\AIR5.3.0\reslice_unwarp.exe ',warp_file_mov,' warped_atlas.img',' -s 1 -a ',mov_file,' -o']);
pth11=fileparts(mov_file_base);
load(fullfile(pth11,'svreg_path.mat'),'svreg_path');
pth1=svreg_path;

if isdeployed
    if ispc
        exename=fullfile(pth1,'bin/warp_coord_vol.exe');
        fprintf('Using Executable %s\n',exename);
        dos(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[x_fname,'.img'],[xw_fname,'.img']));
        dos(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[y_fname,'.img'],[yw_fname,'.img']));
        dos(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[z_fname,'.img'],[zw_fname,'.img']));
    elseif ismac
        exename=fullfile(pth1,'bin/warp_coord_vol_mac');
        fprintf('Using Executable %s\n',exename);
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[x_fname,'.img'],[xw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[y_fname,'.img'],[yw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[z_fname,'.img'],[zw_fname,'.img']));
    else isunix
        exename=fullfile(pth1,'bin/warp_coord_vol_linux');
        fprintf('Using Executable %s\n',exename);
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[x_fname,'.img'],[xw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[y_fname,'.img'],[yw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[z_fname,'.img'],[zw_fname,'.img']));
    end
else
    if ispc
        exename=fullfile(pth1,'3rdParty/AIR_bin/warp_coord_vol.exe');
        fprintf('Using Executable %s\n',exename);
        dos(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[x_fname,'.img'],[xw_fname,'.img']));
        dos(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[y_fname,'.img'],[yw_fname,'.img']));
        dos(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[z_fname,'.img'],[zw_fname,'.img']));
    elseif ismac
        exename=fullfile(pth1,'3rdParty/AIR_bin/warp_coord_vol_mac');
        fprintf('Using Executable %s\n',exename);
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[x_fname,'.img'],[xw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[y_fname,'.img'],[yw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[z_fname,'.img'],[zw_fname,'.img']));
    else isunix
        exename=fullfile(pth1,'3rdParty/AIR_bin/warp_coord_vol_linux');
        fprintf('Using Executable %s\n',exename);
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[x_fname,'.img'],[xw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[y_fname,'.img'],[yw_fname,'.img']));
        unix(sprintf('"%s" "%s" "%s" "%s"',exename,warp_file_mov,[z_fname,'.img'],[zw_fname,'.img']));
    end
end
% reslice_warp_mex(warp_file_mov,[x_fname,'.img'],[xw_fname,'.img']);
% reslice_warp_mex(warp_file_mov,[y_fname,'.img'],[yw_fname,'.img']);
% reslice_warp_mex(warp_file_mov,[z_fname,'.img'],[zw_fname,'.img']);
%system(['C:\Users\ajosh_000\Downloads\AIR5.3.0\AIR5.3.0\reslice_warp.exe ',warp_file_mov,' Xwarped.img',' -s 1 -a ','X.img',' -o']);
%system(['C:\Users\ajosh_000\Downloads\AIR5.3.0\AIR5.3.0\reslice_warp.exe ',warp_file_mov,' Ywarped.img',' -s 1 -a ','Y.img',' -o']);
%system(['C:\Users\ajosh_000\Downloads\AIR5.3.0\AIR5.3.0\reslice_warp.exe ',warp_file_mov,' Zwarped.img',' -s 1 -a ','Z.img',' -o']);

Xw=load_nii([xw_fname,'.img']);Yw=load_nii([yw_fname,'.img']);Zw=load_nii([zw_fname,'.img']);
Xw=double(Xw.img)/100;Yw=double(Yw.img)/100;Zw=double(Zw.img)/100;

vt.img=interp3(double(vm.img),Xw,Yw,Zw);vt.img=1000/max(vt.img(:))*vt.img;
%save_nii(vt,'warpedatlas1.nii.gz');
vt.img(:,:,:,1)=Yw;vt.img(:,:,:,2)=Xw;vt.img(:,:,:,3)=Zw;
vt.hdr.dime.bitpix=32;
vt.hdr.dime.datatype=16;
vt.hdr.dime.dim(1)=4;vt.hdr.dime.dim(5)=3;
map=vt.img;
save([outfile,'_AIR.mat'],'map');



