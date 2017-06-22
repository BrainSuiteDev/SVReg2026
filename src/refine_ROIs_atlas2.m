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
%
function refine_ROIs_atlas2(subs)
verbosity=2;
flags='k';
%subbasename=subs;
subs_out=[subs(1:end-3),'refined.dfs'];    

%These two are given
dt=1;1e-4; Nit=10;
mu=3;NumCommTri=50;
corr_topology_labels(subs,subs_out);

surf1=readdfs(subs_out);%([subs(1:end-3),'topcorr.dfs']);
labs=unique(surf1.labels);
labs=setdiff(labs,[0,324,325]);labs=labs(labs>=100);labs=labs(labs<600);
for kk1=labs(:)'
    for kk2=labs(:)'
        if kk1>=kk2
            continue;
        end
        vl1= find(surf1.labels == kk1); vl2= find(surf1.labels == kk2) ;
        [t,ind1]=intersect(surf1.faces(:,1),vl1);[t,ind12]=intersect(surf1.faces(:,1),vl2);
        [t,ind2]=intersect(surf1.faces(:,2),vl1);[t,ind22]=intersect(surf1.faces(:,2),vl2);
        [t,ind3]=intersect(surf1.faces(:,3),vl1);[t,ind32]=intersect(surf1.faces(:,3),vl2);
        ind_1=unique([ind1;ind2;ind3]);ind_2=unique([ind12;ind22;ind32]);
        vv=intersect(ind_1,ind_2);
        if length(vv)<NumCommTri
            continue;
        else
            surf1c=separate_surf_roi(surf1,[kk1,kk2]);%clear surf1;
        end
        if verbosity>1
        disp1(sprintf('ROIbdr %d-%d',kk1,kk2),'refine_ROIs2',flags);
        end
        %sulcus=dsearchn(surf1c.vertices,curves1{1});
        surf1co=surf1c;
        surf1c=smooth_cortex_fast(surf1c,.1,5);%surf1c=myclean_patch_cc(surf1c);
        surf1csm=smooth_cortex_fast(surf1c,.2,1000);
        
        [~,C]=vertices_connectivity_fast(surf1c);
        [curvature_sigmoid,~]=curvature_cortex_fast(surf1csm,50,0,C);
        f=(1+curvature_sigmoid).^(1+mu);
        %     f=surf1c.attributes.^mu;% f=log(f/min(f))+1e-6;%f=100*f; %f(f<1e-6)=1e-6;%f=ones(length(f),1);
        %f=ones(size(f));
        %Use fast matching method implementation from optimization of sulcal curves
        %method
        % phi=initialize_phi(surf1c,sulcus);
        %
        % patch('faces',surf1c.faces,'vertices',surf1c.vertices,'facevertexcdata',phi,'facecolor','interp','edgecolor','none');
        
        phi=initialize_phi_rois(surf1c,[kk1,kk2,0]);phi=phi/max(abs(phi));
        %phi=phi+100000*eps*rand(size(phi));
        
        % Get stiffness matrix
        [A,Dx,Dy]=get_stiffness_matrix_tri_wt(surf1c,f);
        
        % Get mass matrix
        B=get_mass_matrix_tri(surf1c);
        
        normgrad_phi=sqrt((Dx*phi).^2 + (Dy*phi).^2);
        
        T2V=tri2nodes(surf1c);
        
        g_phi=-((Dx*T2V*normgrad_phi) .* (Dx*phi) + (Dy*T2V*normgrad_phi) .* (Dy*phi))./(normgrad_phi+1e-6);
        
        g_phi=f.*(T2V*g_phi);
        
        % perform minimization
        
        M=(B+.5*dt*A);
        phi_orig=phi;
        
        surf1c=surf1csm;%smooth_cortex_fast(surf1c,.2,1000);
        phi0=get_zero_level_set(surf1c,phi);
        
        Nit=4*round(length(phi0)/400);
        if Nit==0
            continue;
        end
        colr=jet(Nit);
        t1=phi;t2=0*t1;
        for kk=1:Nit
            warning off
            [t1]=mypcg(M,(B-.5*dt*A)*phi,1e-200,300,diag(M),t1,flags);
            [t2]=mypcg(M,dt*B*g_phi,1e-200,300,diag(M),t2,flags);
            
            warning on
            
            phi=t1+t2;
            
            normgrad_phi=sqrt((Dx*phi).^2 + (Dy*phi).^2);
            g_phi=-((Dx*T2V*normgrad_phi) .* (Dx*phi) + (Dy*T2V*normgrad_phi) .* (Dy*phi))./(normgrad_phi+1e-6);
            
            g_phi=f.*(T2V*g_phi);
            
            % perform minimization
            if 0%kk==Nit%~mod(kk,5)
                
                phi0=get_zero_level_set(surf1c,phi);
                %                 hold on;
                figure;title(sprintf('kk1=%d,kk2=%d',kk1,kk2));
                patch('faces',surf1c.faces,'vertices',surf1c.vertices,'facevertexcdata',2*(phi<0),'facecolor','interp','edgecolor','none');
                hold on;mysphere(phi0,.3,colr(kk,:));caxis([-1,1])
                axis equal;drawnow;camlight;
                % F(kk)=getframe(h);
            end 
        end
        
        phi0=get_zero_level_set(surf1c,phi);
        
        surf1c.labels(phi>=0)=kk1;
        surf1c.labels(phi<0)=kk2;
        
        [c,ia,ib]=intersect(surf1.vertices,surf1co.vertices,'rows');
        surf1.labels(ia)=surf1c.labels;
        %writedfs([subs(1:end-3),'corrected.dfs'],surf1);
        writedfs(subs_out,surf1);
        %close all;
        
    end
end

corr_topology_labels(subs_out);

%recolor_by_label(subs_out,'C:\Users\ajoshi\Dropbox\Anand_HD\BCI-DNI_Brain\BCI-DNI_Brain');
%copy_attrib_colors(subbasename,'right');

