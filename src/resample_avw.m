% Copyright (C) 2017 The Regents of the University of California and the University of Southern California
% Created by Anand A. Joshi, Chitresh Bhushan, David W. Shattuck, Richard M. Leahy 


function vr=resample_avw(v,Msizer,method)
if ~exist('method','var')
    method='linear';
end

vr=v;
vr.img=resample_vol(double(v.img),Msizer,method);
Msize=size(v.img);
res=double(v.hdr.dime.pixdim(2:4));
XD=Msizer(1)/Msize(1);YD=Msizer(2)/Msize(2);ZD=Msizer(3)/Msize(3);
res=res./[XD,YD,ZD];
vr.hdr.dime.pixdim(2:4)=res;
vr.hdr.dime.dim(2:4)=Msizer;

