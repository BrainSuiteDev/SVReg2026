%clear all;
function extend_deformation4(subbasename,subbasename_tmp)
%subbasename='/home/ajoshi/Downloads/BSA/2523412';
%label_cerebellum2(subbasename,[subbasename_tmp,'.target'],'');



brain_mask=load_nii_z([subbasename,'.cerebrum.mask.nii']);
%%%%brain_mask.img=imdilate(brain_mask.img, se3d);

pix = 10; [x1,y1,z1] = ndgrid(-pix:pix);
se1 = (sqrt(x1.^2 + y1.^2 + z1.^2) <=pix);
brain_mask.img=imdilate(brain_mask.img,se1);
brain_mask.img=255*(brain_mask.img==0);


tmp1=zeros(size(brain_mask.img));
cerebrum_mask=load_nii_z([subbasename,'.cortex.dewisp.mask.nii']);
cerebrum_mask.img=double(cerebrum_mask.img)+brain_mask.img;
Msize=size(cerebrum_mask.img);
atlas=load_nii_z([subbasename_tmp,'.target.pvc.frac.nii']);
res_tar=atlas.hdr.dime.pixdim(2:4);
res_sub=cerebrum_mask.hdr.dime.pixdim(2:4);
%disp1('Surface map from subject to atlas for pial surface','svreg_volreg',flags);
ssl=readdfs([subbasename_tmp,'.left.mid.cortex.reg.dfs']);
ttl=readdfs([subbasename_tmp,'.target.left.mid.cortex.reg.dfs']);
ssr=readdfs([subbasename_tmp,'.right.mid.cortex.reg.dfs']);
ttr=readdfs([subbasename_tmp,'.target.right.mid.cortex.reg.dfs']);
    midsub=[ssl.vertices;ssr.vertices];
%tic
midsub(:,1)=midsub(:,1)/res_sub(1)+1;
midsub(:,2)=midsub(:,2)/res_sub(2)+1;
midsub(:,3)=midsub(:,3)/res_sub(3)+1;

mid_ind=sub2ind(Msize,round(midsub(:,1)),round(midsub(:,2)),round(midsub(:,3)));
clear tmp1
parfor jj=1:3
    mid_surfmap12{jj}=mygriddata([ttl.u'],[ttl.v'],[ttl.vertices(:,jj)],[ssl.u'],[ssl.v']);
    tmp1{jj}=mygriddata([ttr.u'],[ttr.v'],[ttr.vertices(:,jj)],[ssr.u'],[ssr.v']);
    mid_surfmap12{jj}=[mid_surfmap12{jj};tmp1{jj}]/res_tar(jj) + 1; %convert to voxel coordinates
    midmap{jj}=accumarray(mid_ind,mid_surfmap12{jj},[Msize(1)*Msize(2)*Msize(3),1],@mean);
end
mid_ind=find(midmap{1});
cerebrum_mask.img(mid_ind)=255;



ssl=readdfs([subbasename_tmp,'.left.pial.cortex.reg.dfs']);
ttl=readdfs([subbasename_tmp,'.target.left.pial.cortex.reg.dfs']);
ssr=readdfs([subbasename_tmp,'.right.pial.cortex.reg.dfs']);
ttr=readdfs([subbasename_tmp,'.target.right.pial.cortex.reg.dfs']);
    pialsub=[ssl.vertices;ssr.vertices];
%tic
pialsub(:,1)=pialsub(:,1)/res_sub(1)+1;
pialsub(:,2)=pialsub(:,2)/res_sub(2)+1;
pialsub(:,3)=pialsub(:,3)/res_sub(3)+1;

pial_ind=sub2ind(Msize,round(pialsub(:,1)),round(pialsub(:,2)),round(pialsub(:,3)));
clear tmp1
parfor jj=1:3
    pial_surfmap12{jj}=mygriddata([ttl.u'],[ttl.v'],[ttl.vertices(:,jj)],[ssl.u'],[ssl.v']);
    tmp1{jj}=mygriddata([ttr.u'],[ttr.v'],[ttr.vertices(:,jj)],[ssr.u'],[ssr.v']);
    pial_surfmap12{jj}=[pial_surfmap12{jj};tmp1{jj}]/res_tar(jj) + 1; %convert to voxel coordinates
    pialmap{jj}=accumarray(pial_ind,pial_surfmap12{jj},[Msize(1)*Msize(2)*Msize(3),1],@mean);
end
pial_ind=find(pialmap{1});
cerebrum_mask.img(pial_ind)=255;



clear ssl ssr ttl ttr

% Use accumarry as in
% http://stackoverflow.com/questions/16086874/matlab-find-and-apply-function-to-values-of-repeated-indices



clear pial_surfmap*


map=load_nii_z([subbasename_tmp,'.surfreg.map.nii.gz']);
xmap=double(map.img(:,:,:,1));
ymap=double(map.img(:,:,:,2));
zmap=double(map.img(:,:,:,3)); clear map;
xmap(pial_ind)=pialmap{1}(pial_ind);ymap(pial_ind)=pialmap{2}(pial_ind);zmap(pial_ind)=pialmap{3}(pial_ind);
xmap(mid_ind)=midmap{1}(mid_ind);ymap(mid_ind)=midmap{2}(mid_ind);zmap(mid_ind)=midmap{3}(mid_ind);

[J3]=myjacobian3dmap(xmap,ymap,zmap);
%cerebrum_mask.img(J3<0)=0;
deformation{1}=xmap;
deformation{2}=ymap;
deformation{3}=zmap;

known_pts_ind=find(cerebrum_mask.img(:));
%known_pts_ind=known_pts_ind(1:100:end);

b{1}=zeros(length(cerebrum_mask.img(:)),1);b{2}=b{1};b{3}=b{1};
unknown_pts_ind=1:length(cerebrum_mask.img(:));
unknown_pts_ind(known_pts_ind)=[];
b{1}(known_pts_ind)=deformation{1}(known_pts_ind);
b{2}(known_pts_ind)=deformation{2}(known_pts_ind);
b{3}(known_pts_ind)=deformation{3}(known_pts_ind);

d1 = createDDWithDBoundary3D(Msize(1), Msize(2), Msize(3));
%d1 = createDWithPeriodicBoundary3D(Msize(1), Msize(2), Msize(3));
%[~,~,d1] = laplacian(Msize);

%d=[d1;d2];clear d1 d2;
alpha=10;%5000;
%d = [alpha*d;speye(size(d,2))];
d = [alpha*d1];clear d1 d2;

b{1}=d*b{1};b{2}=d*b{2};b{3}=d*b{3};
d(:,known_pts_ind)=[];
disp1('Extending the map','extend_deformation','mt');%dtd=d'*d;
tic
parfor jj=1:3
deformation{jj}(unknown_pts_ind) = lsqr(d, -b{jj}, 1e-16, 3000);
%deformation{jj}(unknown_pts_ind)=pcg(dtd,-d'*b{jj},1e-16, 1000);
end
toc
disp1('Done','extend_deformation','mt');
clear dtd; d;
xmap=deformation{1};
ymap=deformation{2};
zmap=deformation{3};
%deformation{1}=deformation{1}+defmeanx;
%deformation{2}=deformation{2}+defmeany;
%deformation{3}=deformation{3}+defmeanz;


map=load_nii_z([subbasename_tmp,'.surfreg.map.nii']);
map.img(:,:,:,1)=xmap;map.img(:,:,:,2)=ymap;map.img(:,:,:,3)=zmap;
save_untouch_nii_gz(map,[subbasename_tmp,'.surfreg.map.nii.gz']);
%gzip([subbasename_tmp,'.surfreg.map.nii']);
%delete([subbasename_tmp,'.surfreg.map.nii']);

v_atlas=load_nii_z([subbasename_tmp,'.target.pvc.frac.nii']);

%delete([atlas_name,'.nii']);
%v_w=double(zeros(size(br_msk)));
v_w=trilinear(double(v_atlas.img),double(map.img(:,:,:,2)),double(map.img(:,:,:,1)),double(map.img(:,:,:,3)));v_atlas.img=[];
v_w=double(truncate(v_w,12));
%v_w=interp3(double(v_atlas.img),ymap,xmap,zmap);
%vww=view_vol(v_w,Brain1_Msize,Brain1_resolution);
tissue1=load_nii_z([subbasename,'.pvc.frac.nii']);
vww.hdr=tissue1.hdr;
vww.img=v_w;
%vww.hdr.dime.datatype=v_atlas.hdr.dime.datatype;vww.hdr.dime.bitpix=v_atlas.hdr.dime.bitpix;
%vww.img=uint16(double(vww.img).*double(br_msk1));clear v_w;
%vww.hdr=tissue1.hdr;
save_untouch_nii_gz(vww,[subbasename_tmp,'.surfreg.nii.gz']);%gzip([subbasename_tmp,'.surfreg.nii']);delete([subbasename_tmp,'.surfreg.nii']);
