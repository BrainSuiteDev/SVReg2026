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


function [surf1,surf2,imgpair] = curvature_registration512g_wt_multi_bs_elastic_xyz_cg(surf1,surf2,curves1,curves2,subbasename,atlasbasename,flags,hemi)
if ~exist('flags','var')
   flags='';
end

if isempty(strfind(flags,'v'))
   verbosity=2;
else
   a=strfind(flags,'v');
   verbosity=flags(a(1)+1);
   verbosity= str2double(verbosity);
end
NPTS=512;
xcurves=ceil(NPTS*surf1.u(curves1(:)));ycurves=ceil(NPTS*surf1.v(curves1(:)));
xcurves=[xcurves,ceil(NPTS*surf2.u(curves2(:)))];ycurves=[ycurves,ceil(NPTS*surf2.v(curves2(:)))];
surf1.u=2*surf1.u - 1;  surf1.v=2*surf1.v - 1;
surf2.u=2*surf2.u - 1;  surf2.v=2*surf2.v - 1;
ll=linspace(-1,1,NPTS);
[X,Y]=meshgrid(ll,ll);
[at_pth,~]=fileparts(atlasbasename);
if exist(fullfile(at_pth,'curvvar.mat'),'file')
   
   load(fullfile(at_pth,'curvvar.mat'));
   
   if ~exist('hemi','var')
      if length(surf1.u)==length(leftvar)
         hemivar=leftvar;
         hemi='left';
      else
         hemivar=rightvar;
         hemi='right';
      end
   else
      if strcmp(hemi,'left')
         hemivar=leftvar;
      elseif strcmp(hemi,'right')
         hemivar=rightvar;
      end
   end
   clear leftvar rightvar;
   WT = mygriddata(surf1.u',surf1.v',hemivar,X,Y);
   WTsgm = 2./(1+exp(WT.*2));
   WTsm = imgaussian(WTsgm,25,[80 80]);
   WTsm = double(single(WTsm));
else
   WTsm=ones(size(X));
end
[imgpair,att1,att2]=curvature_hierarchy_map_BS_xyz(surf1,surf2,10,NPTS,WTsm,flags);

pts1=[ones(NPTS,1),linspace(1,NPTS,NPTS)'];pts2=[NPTS*ones(NPTS,1),linspace(1,NPTS,NPTS)'];
pts3=[linspace(1,NPTS,NPTS)',ones(NPTS,1)];pts4=[linspace(1,NPTS,NPTS)',NPTS*ones(NPTS,1)];
pts=[pts1;pts2;pts3;pts4];pts=unique(pts,'rows');
xfixed=[pts(:,1);xcurves'];yfixed=[pts(:,2);ycurves'];
Options.Points1=[xfixed,yfixed];Options.Points2=[xfixed,yfixed];

load(fullfile(at_pth,sprintf('dist_map_%d',NPTS)),'dist_map');
Options.dist_img=dist_map;clear dist_map;

if isempty(strfind(flags,'gui'))
   disp1('Computing additive curvature','svreg_label_surf_hemi',flags);
else
   disp1('CompAddCurv','svreg_label_surf_hemi',flags);
end
for kk=9:-1:1
   imgpair.img1.sc{kk}=imgpair.img1.sc{kk}+imgpair.img1.sc{kk+1};
   imgpair.img2.sc{kk}=imgpair.img2.sc{kk}+imgpair.img2.sc{kk+1};
end

for kk=9:-1:1
   imgpair.img1.sc{kk}=truncate(imgpair.img1.sc{kk}, 15);
   imgpair.img2.sc{kk}=truncate(imgpair.img2.sc{kk}, 15);
end

Options.Similarity='p';
if isempty(strfind(flags,'gui'))
   disp1('Performing curvature registration','svreg_label_surf_hemi',flags);
else
   disp1('CurvReg','svreg_label_surf_hemi',flags);
end
st11=setdiff([1:10],[9,5,2,1]);
for ll=1:length(st11)
   imgpair.img1.sc{st11(ll)}=[];        imgpair.img2.sc{st11(ll)}=[];
end

tmp1=0;
for kk=[9,5,2,1]
   tmp1=tmp1+1;
   if verbosity>1
      if isempty(strfind(flags,'gui'))
         disp1(sprintf('Curvature registration at resolution %d/4',tmp1),'svreg_label_surf_hemi',flags);
      else
         disp1(sprintf('CurvRes %d/4',tmp1),'svreg_label_surf_hemi',flags);
      end
   end
   if kk<=2
      Options.SigmaFluid=16;
   else
      Options.SigmaFluid=8;
   end
   Options.SigmaDiff =1;
   Options.MaxRef=kk+1;
   
   mov=imgpair.img1.sc{kk};ref=imgpair.img2.sc{kk};
   max1=max([mov;ref]);max1=max(max1(:));
   min1=min([mov;ref]);min1=min(min1(:));
   mov=(mov-min1)/(max1-min1);
   ref=(ref-min1)/(max1-min1);
   mov=double(single(mov));ref=double(single(ref));
   save([subbasename,hemi,'.tmpmem.mat'],'img*','surf*','-v7.3'); clear img* surf*
   [~,Bx,By] = register_images_elastic_anand_landmarks_cg(sqrt(WTsm).*mov,sqrt(WTsm).*ref,Options,flags);
  % addpath(genpath('C:\Users\ajoshi\Downloads\demon_registration_version_8f'));
  % [~,Bx,By]=register_images(mov,ref,Options,flags);
   load([subbasename,hemi,'.tmpmem.mat'],'img*','surf*');     clear Ireg Fx Fy;
   %Bx=Bx.*WTsm;By=By.*WTsm;
   Bx=Bx*0;By=By*0;
   [X,Y]=meshgrid(1:NPTS);%
   YY1=min(max(1,Y+By),NPTS);XX1=min(max(1,X+Bx),NPTS);
   
   for jj=[5,2,1]
      imgpair.img1.sc{jj}=interp2((imgpair.img1.sc{jj}),(XX1),(YY1));
   end
   
   WX1=((NPTS-1)/2)*(surf2.u+1)+1;
   WY1=((NPTS-1)/2)*(surf2.v+1)+1;
   
   WX1=min(max(WX1,1),NPTS);WY1=min(max(WY1,1),NPTS);
   
   xxx1=interp2((XX1),WX1',WY1');
   yyy1=interp2((YY1),WX1',WY1');
   
   xxx1=(xxx1-1)*(2/(NPTS-1)) - 1;
   yyy1=(yyy1-1)*(2/(NPTS-1)) - 1;
   
   surf2.u=xxx1;surf2.v=yyy1;
   
end

surf1.u=0.5*(surf1.u+1);surf1.v=0.5*(surf1.v+1);
surf2.u=0.5*(surf2.u+1);surf2.v=0.5*(surf2.v+1);
surf1.attributes=(att1+5)/10;surf2.attributes=(att2+5)/10;
if isempty(strfind(flags,'gui'))
   disp1('Curvature registration done.','svreg_label_surf_hemi',flags);
end

