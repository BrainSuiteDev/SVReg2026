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



function transfer_curves(subbasename,atlas_name,hemi)

if ~exist('atlas_name','var')
    disp1('No Atlas specified, using the default HD_Atlas from the SVREG package.','svreg_label_surf_hemi');
    p=mfilename('fullpath');
    [pth,~,~]=fileparts(p);
    pth=pth(1:end-4);
    %% Copy this file to the subject directory
    atlasbasename=fullfile(pth,'BrainSuiteAtlas1/mri.img');%'/ifs/faculty/shattuck/ajoshi/surf_reg/build_02_09_2011/Atlas/Labeled-Brain';
else
    atlasbasename=atlas_name;
end
if exist([atlasbasename,'.',hemi,'.dfc'],'file')
    copyfile([atlasbasename,'.',hemi,'.dfc'],[subbasename,'.target.',hemi,'.dfc'],'f');
    %    copyfile([atlasbasename,'.right.dfc'],[subbasename,'.target.right.dfc'],'f');
    if existfile([atlasbasename,'.',hemi,'.all.dfc'])
        copyfile([atlasbasename,'.',hemi,'.all.dfc'],[subbasename,'.target.',hemi,'.all.dfc'],'f');
    end
    %    copyfile([atlasbasename,'.right.all.dfc'],[subbasename,'.target.right.all.dfc'],'f');
    
    [at_pth,~]=fileparts(atlasbasename);
%    copyfile(fullfile(at_pth,'sulcal_protocol_HD.xml'),[subbasename,'.sulcal_protocol_HD.xml'],'f');
end

sub=readdfs([subbasename,'.',hemi,'.mid.cortex.reg.dfs']);
atlas=readdfs([subbasename,'.target.',hemi,'.mid.cortex.reg.dfs']);
[atcurves,hdr]=readdfc_sipi([subbasename,'.target.',hemi,'.dfc']);
subcurves=atcurves;
for nCurve=1:hdr.nContours
    ind=dsearchn(atlas.vertices,atcurves{nCurve});
    indsub=dsearchn([sub.u',sub.v'],[atlas.u(ind)',atlas.v(ind)']);
    sul1=sub.vertices(indsub,:);
    sul1=Remove_Curve_Defects(sul1');subcurves{nCurve}=sul1';
    %   fprintf('%d / %d\n',nCurve,hdr.nContours);
end

writedfc([subbasename,'.',hemi,'.mapped.dfc'],subcurves,[subbasename,'.sulcal_protocol_HD.xml']);

if existfile([subbasename,'.target.',hemi,'.all.dfc'])
    [atcurves,hdr]=readdfc_sipi([subbasename,'.target.',hemi,'.all.dfc']);
    subcurves=atcurves;
    for nCurve=1:hdr.nContours
        ind=dsearchn(atlas.vertices,atcurves{nCurve});
        indsub=dsearchn([sub.u',sub.v'],[atlas.u(ind)',atlas.v(ind)']);
        sul1=sub.vertices(indsub,:);
        sul1=Remove_Curve_Defects(sul1');subcurves{nCurve}=sul1';
        %   fprintf('%d / %d\n',nCurve,hdr.nContours);
    end
    
    writedfc([subbasename,'.',hemi,'.mapped.all.dfc'],subcurves,[subbasename,'.sulcal_protocol_HD.xml']);
end
