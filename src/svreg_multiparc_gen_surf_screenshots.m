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

function svreg_multiparc_gen_surf_screenshots(subbasename, multi_dir, BrainSuitePath)

[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end

[pth, sub]=fileparts(subbasename);
subbasename_multi=fullfile(pth,'multiparc',sub);
    
if (nargin < 2)
    fprintf('USAGE: svreg_multi_parc.sh subbasename, atlasbasename\n');
    fprintf('subbasename: subjectbasename as in svreg command line\n');
    fprintf('atlasbasename: The new multi atlas (BCI-DNI,USCBrain,USCLobes)\n');
end

[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);

%mkdir(tmpdir);
subbasename_tmp = fullfile(tmpdir,subname);
atlasbasename = fullfile(BrainSuitePath,'svreg','BCI-DNI_brain_atlas','BCI-DNI_brain');

logfname=[subbasename,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'svreg_multi_parc_gen_surf_screenshots %s %s %s',subbasename,multi_dir,atlasbasename);
fprintf(fp,'\n');

subpth=fileparts(subbasename);

%at_pth = fileparts(atlasbasename);
%multi_dir = fullfile(at_pth, 'parcellations');

atd = dir(multi_dir);

for j = 3:length(atd)
    atlas_name = atd(j).name;

    slout=[subbasename_multi,'.left.mid.cortex.svreg.',atlas_name,'.dfs'];
    
    sl = readdfs(slout);
    h=figure;
    patch('vertices',sl.vertices,'faces',sl.faces,'facevertexcdata',sl.vcolor,'facecolor','flat','edgecolor','none');axis equal;axis off;material dull;
    axis equal;axis tight;title(atlas_name,'Interpreter','none');
    view(-90,0);camlight;
    ax = gca;
    ax.TitleFontSizeMultiplier = 1;ax.TitleFontSize=20;
    saveas(h,[subbasename_multi,'.left.',atlas_name,'.png']);
    
    sl = smooth_cortex_fast(sl,.5,3000);
    h=figure;
    patch('vertices',sl.vertices,'faces',sl.faces,'facevertexcdata',sl.vcolor,'facecolor','flat','edgecolor','none');axis equal;axis off;material dull;
    axis equal;axis tight;title(atlas_name,'Interpreter','none');
    ax = gca;
    ax.TitleFontSizeMultiplier = 1;ax.TitleFontSize=20;
    view(-90,0); camlight(0,-90);camlight;
    saveas(h,[subbasename_multi,'.left.smooth.',atlas_name,'.png']);
    
    close all;
        
end

if exist(tmpdir,'dir')        
    rmdir(tmpdir,'s');
end


