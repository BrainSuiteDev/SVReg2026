function [ savedFileName ] = save_untouch_nii_gz(nii, savedFileName)


if strcmp(savedFileName(end-2:end), '.gz')
    savedFileName = savedFileName(1:end-3);
end



%ratio = nii.hdr.dime.pixdim(2:4) ./ nii.hdr.PixelDimensions;

nii.hdr.PixelDimensions = nii.hdr.dime.pixdim(2:4);

if isfield(nii.hdr.dime,'datatype')
    if nii.hdr.dime.datatype == 2
        nii.hdr.Datatype = 'uint8';
        nii.hdr.BitsPerPixel = 8;
    end
    if nii.hdr.dime.datatype == 4
        nii.hdr.Datatype = 'int16';
        nii.hdr.BitsPerPixel = 16;
    end


    if nii.hdr.dime.datatype == 8
        nii.hdr.Datatype = 'int32';
        nii.hdr.BitsPerPixel = 32;
    end



    if nii.hdr.dime.datatype == 16
        nii.hdr.Datatype = 'single';
        nii.hdr.BitsPerPixel = 32;
    end

    if nii.hdr.dime.datatype == 32
        nii.hdr.Datatype = 'complex';
        nii.hdr.BitsPerPixel = 64;
    end

    if nii.hdr.dime.datatype == 64
        nii.hdr.Datatype = 'double';
        nii.hdr.BitsPerPixel = 64;
    end
end

nii.img=cast(nii.img,nii.hdr.Datatype);
nii.hdr.ImageSize = size(nii.img);

nii.hdr.Transform.T(1,1)= nii.hdr.dime.pixdim(2);
nii.hdr.Transform.T(2,2)= nii.hdr.dime.pixdim(3);
nii.hdr.Transform.T(3,3)= nii.hdr.dime.pixdim(4);

nii.hdr.TransformName='Sform';
nii.hdr = rmfield(nii.hdr,'raw');
nii.hdr = rmfield(nii.hdr,'dime');
nii.hdr = rmfield(nii.hdr,'hist');
niftiwrite(nii.img,savedFileName,nii.hdr,'Compressed',true);
