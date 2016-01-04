function label_cerebellum4(subbasename,subbasename_tmp)


atlas_pvc=load_nii_z([subbasename_tmp,'.target.label.nii.gz']);
sub_pvc=load_nii_z([subbasename,'.pvc.frac.nii.gz']);

UCF_PRECISION = 6; % number of decimal points to truncate at when writing ucf file
UCF_FORMAT = sprintf('%%.%df',UCF_PRECISION);
UCF_CONSTANT = 10^UCF_PRECISION;
subSZ=size(sub_pvc.img);tarSZ=size(atlas_pvc.img);
sub_res=sub_pvc.hdr.dime.pixdim(2:4);
tar_res=atlas_pvc.hdr.dime.pixdim(2:4);

[xxs,yys,zzs]=ndgrid(1:4:subSZ(1),1:4:subSZ(2),1:4:subSZ(3));xxs=(xxs-1)*sub_res(1);yys=(yys-1)*sub_res(2);zzs=(zzs-1)*sub_res(3);
[xxt,yyt,zzt]=ndgrid(1:4:tarSZ(1),1:4:tarSZ(2),1:4:tarSZ(3));xxt=(xxt-1)*tar_res(1);yyt=(yyt-1)*tar_res(2);zzt=(zzt-1)*tar_res(3);


vrt1=double(single([xxs(:),yys(:),zzs(:)]));
vrt2=double(single([xxt(:),yyt(:),zzt(:)]));
vrt1=floor(vrt1*UCF_CONSTANT) / UCF_CONSTANT; % to account for differing fprintf behavior
vrt2=floor(vrt2*UCF_CONSTANT) / UCF_CONSTANT; % on Mac OSX and Windows
name1o=[subbasename,'_cbm.ucf'];name2o=[subbasename,'_atlas_cbm.ucf'];
if exist(name1o,'file')
    delete(name1o);delete([name1o(1:end-4),'_wrpd.','ucf']);
end
if exist(name2o,'file')
    delete(name2o);delete([name2o(1:end-4),'_wrpd.','ucf']);
end
dlmwrite(name1o, vrt1, 'delimiter', '\t', 'precision', UCF_FORMAT);
dlmwrite(name2o, vrt2, 'delimiter', '\t', 'precision', UCF_FORMAT);
reslice_unwarp_ucf_mex([subbasename,'.warp'],name1o,[name1o(1:end-4),'_wrpd.','ucf']);
reslice_unwarp_ucf_mex([subbasename_tmp,'_atlas.warp'],name2o,[name2o(1:end-4),'_wrpd.','ucf']);

warped_sub_coordinates=load([name1o(1:end-4),'_wrpd.','ucf']);   
warped_sub_coordinates=double(single(warped_sub_coordinates));
warped_sub_coordinates(:,1)=warped_sub_coordinates(:,1)/sub_res(1)+1;warped_sub_coordinates(:,2)=warped_sub_coordinates(:,2)/sub_res(2)+1;warped_sub_coordinates(:,3)=warped_sub_coordinates(:,3)/sub_res(3)+1;
warped_atlas_coordinates=load([name2o(1:end-4),'_wrpd.','ucf']); warped_atlas_coordinates=double(single(warped_atlas_coordinates));warped_sub_coordinates(:,1)=warped_sub_coordinates(:,1)/tar_res(1)+1;warped_sub_coordinates(:,2)=warped_sub_coordinates(:,2)/tar_res(2)+1;warped_sub_coordinates(:,3)=warped_sub_coordinates(:,3)/tar_res(3)+1;
warped_sub_coordinatesX=xxs;warped_sub_coordinatesX(:)=warped_sub_coordinates(:,1);warped_sub_coordinatesY=yys;warped_sub_coordinatesY(:)=warped_sub_coordinates(:,2);warped_sub_coordinatesZ=zzs;warped_sub_coordinatesZ(:)=warped_sub_coordinates(:,3);
warped_atlas_coordinatesX=xxt;warped_atlas_coordinatesX(:)=warped_atlas_coordinates(:,1);warped_atlas_coordinatesY=yyt;warped_atlas_coordinatesY(:)=warped_atlas_coordinates(:,2);warped_atlas_coordinatesZ=zzt;warped_atlas_coordinatesZ(:)=warped_atlas_coordinates(:,3);

subwarped2atlasX=interp3(warped_atlas_coordinatesX,warped_sub_coordinatesY,warped_sub_coordinatesX,warped_sub_coordinatesZ);
subwarped2atlasY=interp3(warped_atlas_coordinatesY,warped_sub_coordinatesY,warped_sub_coordinatesX,warped_sub_coordinatesZ);
subwarped2atlasZ=interp3(warped_atlas_coordinatesZ,warped_sub_coordinatesY,warped_sub_coordinatesX,warped_sub_coordinatesZ);

warped_lab=interp3(atlas_pvc.img,subwarped2atlasY,subwarped2atlasX,subwarped2atlasZ);


