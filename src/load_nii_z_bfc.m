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

% fname is a file with extension .nii
% The function first checks if .nii file exists, if yes then it reads it. If
% no then it tries to loads .nii.gz file

function [v] =load_nii_z_bfc(fname)

if strcmp(fname(end-2:end),'.gz')
    fname=fname(1:end-3);
    %error('File extension sent in is not nii! exiting..')
end

if strcmp(fname(end-3:end),'nii')
    error('File extension sent in is not nii! exiting..')
end

if exist(fname,'file')
    v_orig = load_untouch_nii(fname);
    v = make_nii(double(v_orig.img), v_orig.hdr.dime.pixdim(2:4));
    v.fileprefix=v_orig.fileprefix;
    v_orig.img = [];
    v.m_orig = v_orig;
    
elseif exist([fname,'.gz'],'file')
    gunzip([fname,'.gz']);
    v_orig = load_untouch_nii(fname);
    v = make_nii(double(v_orig.img), v_orig.hdr.dime.pixdim(2:4));
    v.fileprefix=v_orig.fileprefix;
    v_orig.img = [];
    v.m_orig = v_orig;
    
    %v=read_nifti_gz([fname,'.gz']);
    delete(fname);
else
    error('file doesn''t exist. exiting');
end
