function [ savedFileName ] = save_untouch_nii_gz(nii, savedFileName)


if strcmp(savedFileName(end-2:end), '.gz')
    savedFileName = savedFileName(1:end-3);
end

nii.img=cast(nii.img,nii.hdr.Datatype);
nii.hdr.TransformName='Sform';
niftiwrite(nii.img,savedFileName,nii.hdr,'Compressed',true);
