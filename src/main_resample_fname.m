
fname='my.nii.gz';
out_fname='my1.nii.gz';
NewSize=[256 256 256];
v=load_nii_BIG_Lab(fname);

vr=resample_avw(v,NewSize);
save_untouch_nii_gz(vr,out_fname);


