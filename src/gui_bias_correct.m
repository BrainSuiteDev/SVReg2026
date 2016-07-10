
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

