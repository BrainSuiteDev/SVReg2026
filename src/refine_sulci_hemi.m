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


function refine_sulci_hemi(subbasename,hemi,varargin)
% usage refine_sulci_hemi subbasename hemi [-flag1 -flag2 ...] 
% This function implements geodesic curvature flow for refinement of sulcal
% traces. The sulcal traces are assumed to be stored in
% [subbasename_tmp,'.',hemi,'.mapped.dfc'] and the surfaces are stored in
% [subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs']. The refined sulcal
% traces are stored in [subbasename_tmp,'.',hemi,'.','mapped.refined.dfc']
% This function is shared with you as is with no implied or explicit
% warranty. Use it at your own risk. Please email ajoshi@sipi.usc.edu if
% you have any questions.

[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);
tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
subbasename_tmp=fullfile(tmpdir,subname);

logfname=[subbasename_tmp,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'refine_sulci_hemi %s %s ',subbasename,hemi);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');

fclose(fp);
flags='';
for jj=1:size(varargin,2)
    flags=[flags,varargin{jj}];
end

if ~contains(flags,'v')
    verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);   verbosity= str2double(verbosity);
end


if exist('atlas_name','var')
    if atlas_name(1)=='-'
        flags=atlas_name;
        clear atlas_name;
    end
end

if ~exist('flags','var')
    flags='';
end
%clc;clear all;close all;
%opengl software;
if ~contains(flags,'gui')
    disp1(sprintf('RefSulc:%s',hemi),'refine_sulci_hemi',flags);
else
    disp1(sprintf('Refining Sulci for %s cortical hemisphere',hemi),'refine_sulci_hemi',flags);
end
dt=1;1e-4; Nit=5;
mu=3;%NumCommTri=100;
surf1=readdfs([subbasename_tmp,'.',hemi,'.mid.cortex.reg.dfs']);
curves1=readdfc_sipi([subbasename_tmp,'.',hemi,'.mapped.dfc']);
curvesout=curves1;


for sul=1:length(curves1)
    if verbosity>1
        disp1(sprintf('refining %d/%d',sul,length(curves1)),'refine_sulci_hemi',flags);
    end
    sul1=curves1{sul};sul1=Remove_Curve_Defects(sul1');sul1=sul1';
    if isempty(sul1)
        continue;
    end
    
    ind=dsearchn(surf1.vertices,sul1);
    sdf=signed_dist_func(surf1,ind,7);
    %figure;patch('faces',surf1.faces,'vertices',surf1.vertices,'facevertexcdata',2*(sdf<30),'facecolor','interp','edgecolor','none');
    ptch= sdf<10;
    zp=zeros(length(surf1.vertices),1);zp(ptch)=1;
    sm=zp(surf1.faces(:,1))+zp(surf1.faces(:,2))+zp(surf1.faces(:,3));
    surf1c=surf1;
    surf1c.faces(sm<3,:)=[];
    if(length(surf1c.faces)<5)
        continue;
    end
        
    if sul ==23
        disp('hi');
    end
    surf1c=myclean_patch_cc(surf1c);
    if length(surf1c.vertices)<20
        continue;
    end
    bdr = boundary_vertices(surf1c);
    
    
    strtsul=sul1(1,:);
    endsul=sul1(end,:);
    
    dstrt=surf1c.vertices(bdr,:)-repmat(strtsul,length(bdr),1);dstrt=sqrt(sum(dstrt.^2,2));
    dend=surf1c.vertices(bdr,:)-repmat(endsul,length(bdr),1);dend=sqrt(sum(dend.^2,2));
    [~,mx]=max(dstrt-dend);[~,mn]=min(dstrt-dend);
    [vconn,VC]=vertices_connectivity_fast(surf1c);
    ind=dsearchn(surf1c.vertices,sul1);
    
    [~,Ps] = dijk(VC,bdr(mn),ind(1));
    [~,Pe] = dijk(VC,ind(end),bdr(mx));
    
    sulind=[Ps';ind;Pe'];lgth_strt=length(Ps');lgth_end=length(Pe');lgth_sul=length(ind');
    pth=[];
    for kk1=1:length(sulind)-1
        [~,PP]=dijk(VC,sulind(kk1),sulind(kk1+1));
        pth=[pth;PP(1:end-1)'];
    end
    pth=[pth;sulind(end)];
    sulind=pth;
    VC1=VC; VC1(:,sulind)=0; VC1(sulind,:)=0;[~,cc]=scomponents(VC1); cc(sulind)=0;
    concomp=sort(unique(cc));
    numv=zeros(length(concomp),1);
    for ll=2:length(concomp)
        numv(ll)=sum(cc==concomp(ll));
    end
    if length(numv)<2
        continue;
    end
    [~,id]=sort(numv);cc1=concomp(id(end)); cc2=concomp(id(end-1));
    cc1v=find(cc==cc1);
    surf1co=surf1c;
    surf1c=smooth_cortex_fast(surf1c,.1,5);%surf1c=myclean_patch_cc(surf1c);
    surf1csm=smooth_cortex_fast(surf1c,.2,1000);
    df=signed_dist_func(surf1c,sulind,15);
    phi=df;phi(cc1v)=-phi(cc1v);
    [curvature_sigmoid]=curvature_cortex_fast(surf1csm,50,0,VC);
    f=(1+curvature_sigmoid).^(1+mu);
    phi=phi/max(abs(phi));
    [A,Dx,Dy]=get_stiffness_matrix_tri_wt(surf1c,f);
    B=get_mass_matrix_tri(surf1c);    
    normgrad_phi=sqrt((Dx*phi).^2 + (Dy*phi).^2);    
    T2V=tri2nodes(surf1c);    
    g_phi=-((Dx*T2V*normgrad_phi) .* (Dx*phi) + (Dy*T2V*normgrad_phi) .* (Dy*phi))./(normgrad_phi+1e-6);    
    g_phi=f.*(T2V*g_phi);
    M=(B+.5*dt*A);
    surf1c=surf1csm;%smooth_cortex_fast(surf1c,.2,1000);
    colr=jet(Nit);
    t1=phi;t2=0*t1;
    for kk=1:Nit
        warning off
        t1=mypcg(M,(B-.5*dt*A)*phi,1e-200,1000,diag(M),t1,flags);
        t2=mypcg(M,dt*B*g_phi,1e-200,1000,diag(M),t2,flags);
        warning on
        phi=t1+t2;
        
        normgrad_phi=sqrt((Dx*phi).^2 + (Dy*phi).^2);
        g_phi=-((Dx*T2V*normgrad_phi) .* (Dx*phi) + (Dy*T2V*normgrad_phi) .* (Dy*phi))./(normgrad_phi+1e-6);
        
        g_phi=f.*(T2V*g_phi);
        
        if 0%~mod(kk,5)
            
            phi0=get_zero_level_set(surf1c,phi);
            h=figure;
            patch('faces',surf1csm.faces,'vertices',surf1csm.vertices,'facevertexcdata',f,'facecolor','interp','edgecolor','none');
            hold on;mysphere(phi0,.6,colr(kk,:));caxis([-.5,.5]);
            saveas(h,[subbasename,'.',hemi,sprintf('sul_%d_f_iter_%d.fig',sul,kk)]);
            
            axis equal;drawnow;camlight;
            
        end
    end
    [~,phi0tri]=get_zero_level_set(surf1c,phi);
    if isempty(phi0tri)
        curvesout{sul}=curves1{sul};
        continue;
    end
    stmp=surf1c;stmp.faces=phi0tri;stmp=myclean_patch_cc(stmp);
    [~,VCstmp]=vertices_connectivity_fast(stmp);
    [~,~,ib]=intersect(surf1c.vertices(bdr,:),stmp.vertices,'rows');vec=zeros(length(ib),3);
    if isempty(ib)
        curvesout{sul}=curves1{sul};
        continue;
    end
    if sum(isnan(ib))>0
        continue;
    end
    for kk11=2:length(ib)
        vec(kk11-1,:)=stmp.vertices(ib(1),:)-stmp.vertices(ib(kk11),:);
    end
    sul;
    hemi;
    tl=lgth_strt+lgth_end+lgth_sul;
    [~,indm]=max(sum(vec.^2,2));
    if length(vec)<4
        curvesout{sul}=[];
    else
        
        st=ib(1);ed=ib(indm+1);
        
        [~,pth]=dijk(VCstmp,st,ed);
        s1=round(length(pth)*lgth_strt/tl);e1=round(length(pth)*(tl-lgth_end)/tl);
        s11=min(s1,e1);e11=min(e1,length(pth));
        s1=s11;e1=e11;
        if s1>=1
            pth=pth(s1:e1);
        else
            continue;
        end
        
        [it]=dsearchn(surf1c.vertices,stmp.vertices(pth,:));
        curvesout{sul}=surf1co.vertices(it,:);
    end
end
writedfc([subbasename_tmp,'.',hemi,'.','mapped.refined.dfc'],curvesout,[subbasename_tmp,'.sulcal_protocol_HD.xml']);
copyfile([subbasename_tmp,'.',hemi,'.','mapped.refined.dfc'],[subbasename,'.',hemi,'.','mapped.refined.dfc'],'f');

if exist([subbasename,'.',hemi,'.','mapped.dfc'],'file')
    delete([subbasename,'.',hemi,'.','mapped.dfc']);
end

if isempty(strfind(flags,'gui'))
    disp1([hemi,' hemi sulcal refinement is done.'],'refine_sulci_hemi',flags);
else
    disp1('RefSulcDone','refine_sulci_hemi',flags);
end
