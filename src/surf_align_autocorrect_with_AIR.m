% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2017 The Regents of the University of California and the University of Southern California
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


function [surf1, surf2, C1, C2, Curves1, Curves2] = surf_align_autocorrect_with_AIR(surf1,surf2,Curves1,Curves2,surf1vertConn,~,surf2vertConn,~,boundary1,boundary2,Orient1,~,n_corr_it,sigma,Verbose,air_file_surf1,air_file_surf2,curves_no,flags)

UCF_PRECISION = 6; % number of decimal points to truncate at when writing ucf file
UCF_FORMAT = sprintf('%%.%df',UCF_PRECISION);
UCF_CONSTANT = 10^UCF_PRECISION;

if ~exist('flags','var')
   flags='';
end
%  flags=strrep(flags,'-','');
%  a=strfind(flags,'v');
if isempty(strfind(flags,'v'))
   verbosity=2;
else
   a=strfind(flags,'v');
   verbosity=flags(a(1)+1);   verbosity= str2double(verbosity);
end

%if(Verbose)
%    curvecolor=lines;
%end

mu=100;lambda=0.1;%1

MINV_IHF=100;%Min No of vertices in interhemispheric fissure

if length(Curves1)<1
   n_corr_it=1;
end

C1=[];C2=[];

if (Verbose)
   view_patch(surf1);%view_patch(surf2);
end
if ~isempty(curves_no) && ~isempty(Curves2)
   %   curves_no=str2double(curves_no);
   for ii=curves_no%1:length(Curves1)
      if min(length(Curves1{ii}),length(Curves2{ii})) == 0
         Curves1{ii}=[];Curves2{ii}=[];
      else
         p1=param_curve(Curves1{ii});
         p2=param_curve(Curves2{ii});
         
         if length(Curves1{ii}) < length(Curves2{ii})
            indx=dsearchn(p2,p1);
            Curves2{ii}=Curves2{ii}(indx,:);
         else
            indx=dsearchn(p1,p2);
            Curves1{ii}=Curves1{ii}(indx,:);
         end
         
         Curves1{ii}=dsearchn(surf1.vertices,Curves1{ii});
         Curves2{ii}=dsearchn(surf2.vertices,Curves2{ii});
         
         C1=[C1;Curves1{ii}];
         C2=[C2;Curves2{ii}];
      end
   end
end
surf1o=surf1;%surf2o=surf2;

surf1=readdfs(sprintf('%s_smooth%d.dfs',surf1.name(1:end-4),10));surf1.faces=surf1o.faces;
surf2=readdfs(sprintf('%s_smooth%d.dfs',surf2.name(1:end-4),10));
if isempty(strfind(flags,'gui'))
   disp1('Applying deformation field from AIR','svreg_label_surf_hemi',flags);
else
   disp1('AppAIRDef','svreg_label_surf_hemi',flags);
end
if (exist(air_file_surf1,'file') && exist(air_file_surf2,'file'))
   vrt1=double(single(surf1.vertices));vrt2=double(single(surf2.vertices));
   vrt1=floor(vrt1*UCF_CONSTANT) / UCF_CONSTANT; % to account for differing fprintf behavior
   vrt2=floor(vrt2*UCF_CONSTANT) / UCF_CONSTANT; % on Mac OSX and Windows
   name1o=surf1.name;name2o=surf2.name;
%    if exist([surf1.name(1:end-3),'ucf'],'file')
%       delete([surf1.name(1:end-3),'ucf']);
%    end
%    if exist([surf2.name(1:end-3),'ucf'],'file')
%       delete([surf2.name(1:end-3),'ucf']);
%    end
   disp1('Pausing for 5 sec. to clear file buffers','svreg_label_surf_hemi',flags);
   pause(5);
   dlmwrite([surf1.name(1:end-3),'ucf'], vrt1, 'delimiter', '\t', 'precision', UCF_FORMAT);
   dlmwrite([surf2.name(1:end-3),'ucf'], vrt2, 'delimiter', '\t', 'precision', UCF_FORMAT);

pth1=fileparts(fileparts(air_file_surf1));%getcurrentdir;%ctfroot;%mfilename('fullpath');
   
if isdeployed
   if ispc
      exename=fullfile(pth1,'bin/warp_points.exe');
      fprintf('Using Executable %s\n',exename);
      dos(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf1,[surf1.name(1:end-3),'ucf'],[surf1.name(1:end-4),'_wrpd.','ucf']));
      dos(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf2,[surf2.name(1:end-3),'ucf'],[surf2.name(1:end-4),'_wrpd.','ucf']));
   elseif ismac
       exename=fullfile(pth1,'bin/warp_points_mac');
       fprintf('Using Executable %s\n',exename);
       unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf1,[surf1.name(1:end-3),'ucf'],[surf1.name(1:end-4),'_wrpd.','ucf']));
       unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf2,[surf2.name(1:end-3),'ucf'],[surf2.name(1:end-4),'_wrpd.','ucf']));
   else isunix
      exename=fullfile(pth1,'bin/warp_points_linux');
      fprintf('Using Executable %s\n',exename);
      unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf1,[surf1.name(1:end-3),'ucf'],[surf1.name(1:end-4),'_wrpd.','ucf']));
      unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf2,[surf2.name(1:end-3),'ucf'],[surf2.name(1:end-4),'_wrpd.','ucf']));
   end
else
   if ispc
      exename=fullfile(pth1,'3rdParty/AIR_bin/warp_points.exe');
      fprintf('Using Executable %s\n',exename);
      dos(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf1,[surf1.name(1:end-3),'ucf'],[surf1.name(1:end-4),'_wrpd.','ucf']));
      dos(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf2,[surf2.name(1:end-3),'ucf'],[surf2.name(1:end-4),'_wrpd.','ucf']));
   elseif ismac
       exename=fullfile(pth1,'3rdParty/AIR_bin/warp_points_mac');
       fprintf('Using Executable %s\n',exename);
       unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf1,[surf1.name(1:end-3),'ucf'],[surf1.name(1:end-4),'_wrpd.','ucf']));
       unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf2,[surf2.name(1:end-3),'ucf'],[surf2.name(1:end-4),'_wrpd.','ucf']));
   else isunix
      exename=fullfile(pth1,'3rdParty/AIR_bin/warp_points_linux');
      fprintf('Using Executable %s\n',exename); 
      unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf1,[surf1.name(1:end-3),'ucf'],[surf1.name(1:end-4),'_wrpd.','ucf']));
       unix(sprintf('"%s" "%s" "%s" "%s"',exename,air_file_surf2,[surf2.name(1:end-3),'ucf'],[surf2.name(1:end-4),'_wrpd.','ucf']));
   end
end
   
   if ~exist([surf1.name(1:end-4),'_wrpd.','ucf'],'file')|| ~exist([surf2.name(1:end-4),'_wrpd.','ucf'],'file')
      flg=1;
   else
      flg=0;
      surf1.vertices=load([surf1.name(1:end-4),'_wrpd.','ucf']);   surf1.vertices=double(single(surf1.vertices));
      surf2.vertices=load([surf2.name(1:end-4),'_wrpd.','ucf']);   surf2.vertices=double(single(surf2.vertices));
%       delete([surf1.name(1:end-4),'_wrpd.','ucf']);
%       delete([surf1.name(1:end-3),'ucf']);
%       delete([surf2.name(1:end-4),'_wrpd.','ucf']);
%       delete([surf2.name(1:end-3),'ucf']);
   end
   if length(surf1.vertices)*length(surf2.vertices) == 0
      flg=1;
   end
   if flg==1
      disp1('SVREG Warning: .warp file was not in correct format. Continuing after trying to fix.','svreg_label_surf_hemi',flags);
      surf1=readdfs(sprintf('%s_smooth%d.dfs',name1o(1:end-4),10));surf1.faces=surf1o.faces;
      surf2=readdfs(sprintf('%s_smooth%d.dfs',name2o(1:end-4),10));
      at_m=mean(surf1.vertices,1);
      su_m=mean(surf2.vertices,1);
      surf1.vertices(:,1)=surf1.vertices(:,1)-at_m(1)+su_m(1);
      surf1.vertices(:,2)=surf1.vertices(:,2)-at_m(2)+su_m(2);
      surf1.vertices(:,3)=surf1.vertices(:,3)-at_m(3)+su_m(3);
   end
end

% if(Verbose)
%     [vcolor1,curvature]=curvature_cortex_fast(surf1,10,0,Cv1);
%     [vcolor2,curvature]=curvature_cortex_fast(surf2,10,0,Cv2);
% end

clear Cv1 Cv2
jj=1;
bdr1=[];

while(length(bdr1)<MINV_IHF) % There must be atleast MINV_IHF vertices in the interhemispherical fissure!!
   apst=boundary1(jj);
   bdr1=trace_boundary(apst,surf1vertConn,surf1);
   jj=jj+1;
end
jj=1;bdr2=[];
while(length(bdr2)<MINV_IHF)
   apst=boundary2(jj);
   bdr2=trace_boundary(apst,surf2vertConn,surf2);
   jj=jj+1;
end

if(Verbose)
   view_patch(surf1);view_patch(surf2);
end
dim=strfind(Orient1,'A');
if ~isempty(dim)
   [~,p1]=max(surf1.vertices(bdr1,dim));
   [~,p2]=min(surf1.vertices(bdr1,dim));
else
   
   dim=strfind(Orient1,'P');
   [~,p1]=min(surf1.vertices(bdr1,dim));
   [~,p2]=max(surf1.vertices(bdr1,dim));
end

clear surf1vertConn surf2vertConn

par=para_curve_circle_segmt(surf1.vertices(bdr1,:),[p1;p2],[0;pi]);

dim=strfind(Orient1,'S');

if ~isempty(dim)
   zb=surf1.vertices(bdr1,dim);
   if mean(zb(par<pi))<mean(zb(par>pi))
      par=2*pi-par;
   end;
else
   dim=strfind(Orient1,'I');
   zb=surf1.vertices(bdr1,dim);
   if mean(zb(par<pi))>mean(zb(par>pi))
      par=2*pi-par;
   end;
end

if(Verbose)
   Xb=surf1.vertices(bdr1,1);Yb=surf1.vertices(bdr1,2);Zb=surf1.vertices(bdr1,3);
   view_patch(surf1);fh=find(par<pi);sh=find(par>=pi);view(-90,0);
   hold on;line(Xb(fh),Yb(fh),Zb(fh),'color','r');line(Xb(sh),Yb(sh),Zb(sh),'color','b');
   title('Blue should be above and Red should be below!!');
end

xbdr=cos(par);ybdr=sin(par);

if(Verbose)
   figure; plot(xbdr,ybdr);title('This should be full circle!!');
end



xbdr=sign(xbdr).*(xbdr.^2); ybdr=sign(ybdr).*(ybdr.^2);

tmpxybdr=[xbdr,ybdr]*[1,-1;1,1];

xbdr1=tmpxybdr(:,1);ybdr1=tmpxybdr(:,2);

%xbdr1=xbdr;ybdr1=ybdr;



%dim=strfind(Orient2,'A');

% if ~isempty(dim)
%     [~,p1]=max(surf2.vertices(bdr2,dim));
%     [~,p2]=min(surf2.vertices(bdr2,dim));
% else
%     dim=strfind(Orient2,'P');
%     [~,p1]=min(surf2.vertices(bdr2,dim));
%     [~,p2]=max(surf2.vertices(bdr2,dim));
% end
if isempty(strfind(flags,'gui'))
   disp1('Registering corpus callosum curve','svreg_label_surf_hemi',flags);
else
   disp1('CCReg','svreg_label_surf_hemi',flags);
end
pth1=fileparts(fileparts(air_file_surf1));%getcurrentdir;%ctfroot;%mfilename('fullpath');
% [pth1,~,~]=fileparts(p1);

%%% For Andrew to check and change
save(sprintf('%s_in_register_cc.mat',surf2.name), 'bdr1', 'bdr2','surf1','surf2');

if isdeployed
   if ispc
      exename=fullfile(pth1,'bin\register_cc_curve.exe');
      %exename='register_cc_curve.exe';
      %sprintf('%s "%s"',exename,surf2.name)
      dos(sprintf('"%s" "%s"',exename,surf2.name));
   elseif ismac
       exename=fullfile(pth1,'bin/register_cc_curve.sh');
      %exename='register_cc_curve.sh';
      unix(sprintf('"%s" "%s"',exename,surf2.name));
   else isunix
      exename=fullfile(pth1,'bin/register_cc_curve.sh');
      %exename='register_cc_curve.sh';
      unix(sprintf('"%s" "%s"',exename,surf2.name));
   end
else
   register_cc_curve(surf2.name)
end

load(sprintf('%s_out_register_cc.mat',surf2.name));
%delete(sprintf('%s_out_register_cc.mat',surf2.name));
%delete(sprintf('%s_in_register_cc.mat',surf2.name));
xbdr2=griddata(surf1.vertices(bdr1,2),surf1.vertices(bdr1,3),xbdr1,Tr.Y(:,1),Tr.Y(:,2),'nearest'); %#ok<GRIDD>
ybdr2=griddata(surf1.vertices(bdr1,2),surf1.vertices(bdr1,3),ybdr1,Tr.Y(:,1),Tr.Y(:,2),'nearest'); %#ok<GRIDD>

xmap1=zeros(size(surf1.vertices(:,1)));ymap1=xmap1;xmap2=zeros(size(surf2.vertices(:,2)));ymap2=xmap2;
if isempty(C1)
   if isempty(strfind(flags,'gui'))
      disp1('Performing L2 registration','svreg_label_surf_hemi',flags);
   else
      disp1('L2Reg','svreg_label_surf_hemi',flags);
   end
   [C1,C2]=L2_surf_matching(surf1,surf2,flags);
end

if isempty(strfind(flags,'gui'))
   disp1('Mapping to unit square','svreg_label_surf_hemi',flags);
else
   disp1('SqrMap','svreg_label_surf_hemi',flags);
end
sigma=sigma*ones(length(C1),1);

for jjj=1:n_corr_it
   [xmap1,ymap1,xmap2,ymap2]=mymap_le_align_varsig_ini(surf1,surf2,bdr1,bdr2,xbdr1,ybdr1,xbdr2,ybdr2,C1,C2,sigma,2,mu,lambda,xmap1,ymap1,xmap2,ymap2,flags);
   surf1.map=[xmap1,ymap1];
   surf2.map=[xmap2,ymap2];
   if sum(isnan(xmap1(:)))
      disp1('THERE ARE ERRORS IN SURFACES! POSSIBLY ISOLATED/DISCONNECTED PATCHES!!TRYING TO CONTINUE.. CHECK OUTPUT!!','svreg_label_surf_hemi',flags);
      surf2oo=surf2;
      surf2=myclean_patch2(surf2);
      %[~,ind]=setdiff(surf2oo.vertices,surf2.vertices,'rows');
      %[~,~,ind2o]=intersect(surf2oo.vertices,surf2.vertices,'rows');
      [~,bdr22,ind2o]=intersect(surf2.vertices,surf2oo.vertices(bdr2,:),'rows');bdr22(ind2o)=bdr22;
      [~,C22,ind2o]=intersect(surf2.vertices,surf2oo.vertices(C2,:),'rows');C22(ind2o)=C22;
      xmap1=zeros(size(surf1.vertices(:,1)));ymap1=xmap1;xmap2=zeros(size(surf2.vertices(:,2)));ymap2=xmap2;
      [xmap1,ymap1,xmap2,ymap2]=mymap_le_align_varsig_ini(surf1,surf2,bdr1,bdr22,xbdr1,ybdr1,xbdr2,ybdr2,C1,C22,sigma,2,mu,lambda,xmap1,ymap1,xmap2,ymap2,flags);
      surf1.map=[xmap1,ymap1];
      surf2oo.map(:)=1;        [~,ind1o,ind2o]=intersect(surf2oo.vertices,surf2.vertices,'rows');
      surf2oo.map(ind1o,1)=xmap2(ind2o);surf2oo.map(ind1o,2)=ymap2(ind2o);
      surf2=surf2oo;clear surf2oo;
      xmap2=surf2.map(:,1);ymap2=surf2.map(:,2);
   end
   ori1=orientation_tri(surf1.faces,xmap1,ymap1);
   if(length(find(ori1==1)) < length(find(ori1==-1)))
      wrong_ori=1;
   else
      wrong_ori=-1;
   end
   ind= ori1==wrong_ori;
   opts1=surf1.faces(ind,:);opts1=opts1(:);
   opts1=unique(opts1);
   [~,ind1]=intersect(C1,opts1);
   ori2=orientation_tri(surf2.faces,xmap2,ymap2);
   if(length(find(ori2==1)) < length(find(ori2==-1)))
      wrong_ori=1;
   else
      wrong_ori=-1;
   end
   ind= ori2==wrong_ori;
   opts2=surf2.faces(ind,:);opts2=opts2(:);
   opts2=unique(opts2);
   [~,ind2]=intersect(C2,opts2);
   oind=union(ind1,ind2);
   surf.faces=surf1.faces; surf.vertices=[xmap1,ymap1];
   co=-ones(size(surf.vertices,1),1);co(opts1)=1;
   if(Verbose)
      figure; patch(surf,'FaceColor','interp','FaceVertexCData',co);
   end
   sigma(oind)=sigma(oind)./2;
end


function currentDir = getcurrentdir
currentDir = '';
if isdeployed
    [status, currentDir] = system('path');
    if status == 0
        currentDir = char(regexpi(currentDir, 'Path=(.*?);', 'tokens', 'once'));
    end
else % MATLAB mode.
   currentDir = pwd;
end
