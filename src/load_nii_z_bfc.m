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
