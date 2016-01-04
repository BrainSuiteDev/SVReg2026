% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2015 The Regents of the University of California and the University of Southern California
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

function compile_all(varargin)
% Usage: compile_all --package <svreg_version> <atlas...>
% (e.g. compile_all --package 1.003 'BrainSuiteAtlas1')
% --no-compile flag skips compilation


currentdir = pwd;
try
    package = false;
    compile = true;
    if nargin >= 3
        for i = 1:nargin
            if strcmp(varargin{i}, '--package') && i+2 <= nargin
                package = true;
                svreg_version = varargin{i+1};
                %svreg_build = varargin{i+2};

                i = i + 2; %#ok
                atlases = {};
                while i <= length(varargin) && ~strcmp(varargin{i}, '--no-compile')
                    if isempty(atlases)
                        atlases{1} = varargin{i};
                    else
                        atlases{end+1} = varargin{i}; %#ok
                    end
                    i = i + 1; %#ok
                end
            elseif i <= length(varargin) && strcmp(varargin{i}, '--no-compile')
                compile = false;
            end
        end
    end
    
    if exist('svreg_version', 'var')
        set_version(svreg_version);
    end
    
    if compile
        restoredefaultpath;
        pp=pwd;
        cmd_str=[pp(1:end-16),'/3rdParty',pathsep,pp(1:end-16),'/MEX_Files',pathsep,pp(1:end-16),'/src'];
        addpath(cmd_str);

        
        %addpath(genpath('../src'));
        
        if ispc
           try
               mcc -m -v svreg.m
           catch
               disp('Dist Computing Toolbox Needs to be Disabled on Windows!!!!!! Needs to fix this!');
               rmpath(genpath('C:\Program Files\MATLAB\R2012a\toolbox\distcomp'));
               mcc -m -v svreg.m
           end
            mcc -m -v svreg_label_surf_hemi.m
            mcc -m -v generate_stats_xls.m
            mcc -m -v volmap_ball.m
            mcc -m -v svreg_volreg.m
            mcc -m -v clean_intermediate_files.m
            mcc -m -v refine_ROIs2.m
            mcc -m -v svreg_refinements.m
            mcc -m -v refine_sulci_hemi.m
            mcc -m -v register_cc_curve.m
            mcc -m -v thicknessPVC.m
            mcc -m -v svreg_smooth_surf_function.m
            mcc -m -v svreg_make_atlas.m

        elseif ismac || isunix
            cmd_str=['-I ',cmd_str];
            cmd_str = strrep(cmd_str, pathsep, ' -I ');
            
            mrt=matlabroot;
            cmd_str1=[mrt,'/bin/mcc -m -v svreg.m ' cmd_str];
            cmd_str3=[mrt,'/bin/mcc -m -v svreg_label_surf_hemi.m ' cmd_str];
            cmd_str4=[mrt,'/bin/mcc -m -v generate_stats_xls.m ' cmd_str];
            cmd_str5=[mrt,'/bin/mcc -m -v volmap_ball.m ' cmd_str];
            cmd_str6=[mrt,'/bin/mcc -m -v svreg_volreg.m ' cmd_str];
            cmd_str7=[mrt,'/bin/mcc -m -v clean_intermediate_files.m ' cmd_str];
            cmd_str8=[mrt,'/bin/mcc -m -v refine_ROIs2.m ' cmd_str];
            cmd_str9=[mrt,'/bin/mcc -m -v svreg_refinements.m ' cmd_str];
            cmd_str10=[mrt,'/bin/mcc -m -v refine_sulci_hemi.m ' cmd_str];
            cmd_str11=[mrt,'/bin/mcc -m -v register_cc_curve.m ' cmd_str];
            cmd_str12=[mrt,'/bin/mcc -m -v thicknessPVC.m ' cmd_str];
            cmd_str13=[mrt,'/bin/mcc -m -v svreg_smooth_surf_function.m ' cmd_str];
            cmd_str14=[mrt,'/bin/mcc -m -v svreg_make_atlas.m ' cmd_str];
            
            system(cmd_str1);
            system(cmd_str3);system(cmd_str4);
            system(cmd_str5);system(cmd_str6);
            system(cmd_str7);system(cmd_str8);
            system(cmd_str9);system(cmd_str10);
            system(cmd_str11);system(cmd_str12);
            system(cmd_str13);system(cmd_str14);
            
        end
        
        disp('Compilation done.');
    end
    
    if package
        disp('Packaging...');
        if ispc
            package_files_pc(svreg_version, atlases);
        elseif ismac
            package_files_mac(svreg_version, atlases);
        else
            package_files_linux(svreg_version, atlases);
        end
        cleanup();
        disp('Packing complete');
    end
catch err
    cd(currentdir);
    rethrow(err);
end
end
 

function set_version(svreg_version)

svreg_version=[svreg_version(1:end-4),'(build#',svreg_version(end-3:end),')'];

version_files = {
    ['..' filesep 'src' filesep 'svreg.m'], ...
    ['..' filesep 'src' filesep 'svreg_label_surf_hemi.m'], ...
    ['..' filesep 'src' filesep 'generate_stats_xls.m'], ...
    ['..' filesep 'src' filesep 'volmap_ball.m'], ...    
    ['..' filesep 'src' filesep 'svreg_volreg.m'], ...    
    ['..' filesep 'src' filesep 'clean_intermediate_files.m'], ...    
    ['..' filesep 'src' filesep 'refine_ROIs2.m'], ...
    ['..' filesep 'src' filesep 'svreg_refinements.m'], ...
    ['..' filesep 'src' filesep 'refine_sulci_hemi.m'], ...
    ['..' filesep '3rdParty' filesep 'register_cc_curve.m'], ...    
    ['..' filesep 'src' filesep 'thicknessPVC.m'], ...
    ['..' filesep 'src' filesep 'svreg_smooth_surf_function.m'], ...
    ['..' filesep 'src' filesep 'svreg_make_atlas.m']};

previous_version = fileread('svreg_version.txt');

if strcmp(previous_version, svreg_version)
    return;
end

for i = 1:length(version_files)
    fin = fopen(version_files{i});
    fout = fopen([version_files{i} '.tmp'],'a');
    
    while ~feof(fin)
        s = fgetl(fin);
        s = strrep(s, ['SVREG Version ' previous_version], ['SVREG Version ' svreg_version]);
        fprintf(fout,'%s\n',s);
    end
    
    fclose(fin);
    fclose(fout);
    movefile([version_files{i} '.tmp'], version_files{i});
end

fid = fopen('svreg_version.txt', 'w');
fprintf(fid, svreg_version);
fclose(fid);
end


function package_files_pc(svreg_version, atlases)
[workdir bindir] = setup_package(svreg_version, atlases);

copyfile('svreg.exe', [bindir filesep 'svreg.exe']);
copyfile('svreg_label_surf_hemi.exe', [bindir filesep 'svreg_label_surf_hemi.exe']);
copyfile('generate_stats_xls.exe', [bindir filesep 'generate_stats_xls.exe']);
copyfile('volmap_ball.exe', [bindir filesep 'volmap_ball.exe']);
copyfile('svreg_volreg.exe', [bindir filesep 'svreg_volreg.exe']);
copyfile('clean_intermediate_files.exe', [bindir filesep 'clean_intermediate_files.exe']);
copyfile('refine_ROIs2.exe', [bindir filesep 'refine_ROIs2.exe']);
copyfile('svreg_refinements.exe', [bindir filesep 'svreg_refinements.exe']);
copyfile('refine_sulci_hemi.exe', [bindir filesep 'refine_sulci_hemi.exe']);
copyfile('register_cc_curve.exe', [bindir filesep 'register_cc_curve.exe']);
copyfile('thicknessPVC.exe', [bindir filesep 'thicknessPVC.exe']);
copyfile('svreg_smooth_surf_function.exe', [bindir filesep 'svreg_smooth_surf_function.exe']);
copyfile('svreg_make_atlas.exe', [bindir filesep 'svreg_make_atlas.exe']);
copyfile('../3rdParty/AIR_bin/warp_coord_vol.exe', [bindir filesep 'warp_coord_vol.exe']);
copyfile('../3rdParty/AIR_bin/warp_points.exe', [bindir filesep 'warp_points.exe']);

zip(workdir, workdir);
rmdir(workdir, 's');
end


function package_files_mac(svreg_version, atlases)
[workdir bindir] = setup_package(svreg_version, atlases);

copyfile('svreg.app', [bindir filesep 'svreg.app']);
copyfile('svreg_label_surf_hemi.app', [bindir filesep 'svreg_label_surf_hemi.app']);
copyfile('generate_stats_xls.app', [bindir filesep 'generate_stats_xls.app']);
copyfile('volmap_ball.app', [bindir filesep 'volmap_ball.app']);
copyfile('svreg_volreg.app', [bindir filesep 'svreg_volreg.app']);
copyfile('clean_intermediate_files.app', [bindir filesep 'clean_intermediate_files.app']);
copyfile('refine_ROIs2.app', [bindir filesep 'refine_ROIs2.app']);
copyfile('svreg_refinements.app', [bindir filesep 'svreg_refinements.app']);
copyfile('refine_sulci_hemi.app', [bindir filesep 'refine_sulci_hemi.app']);
copyfile('register_cc_curve.app', [bindir filesep 'register_cc_curve.app']);
copyfile('thicknessPVC.app', [bindir filesep 'thicknessPVC.app']);
copyfile('svreg_smooth_surf_function.app', [bindir filesep 'svreg_smooth_surf_function.app']);
copyfile('svreg_make_atlas.app', [bindir filesep 'svreg_make_atlas.app']);
copyfile('../3rdParty/AIR_bin/warp_coord_vol_mac', [bindir filesep 'warp_coord_vol_mac']);
copyfile('../3rdParty/AIR_bin/warp_points_mac', [bindir filesep 'warp_points_mac']);



copyfile('../scripts/svreg_mac.sh', [bindir filesep 'svreg.sh']);
copyfile('../scripts/svreg_label_surf_hemi_mac.sh', [bindir filesep 'svreg_label_surf_hemi.sh']);
copyfile('../scripts/generate_stats_xls_mac.sh', [bindir filesep 'generate_stats_xls.sh']);
copyfile('../scripts/volmap_ball_mac.sh', [bindir filesep 'volmap_ball.sh']);
copyfile('../scripts/svreg_volreg_mac.sh', [bindir filesep 'svreg_volreg.sh']);
copyfile('../scripts/clean_intermediate_files_mac.sh', [bindir filesep 'clean_intermediate_files.sh']);
copyfile('../scripts/refine_ROIs2_mac.sh', [bindir filesep 'refine_ROIs2.sh']);
copyfile('../scripts/svreg_refinements_mac.sh', [bindir filesep 'svreg_refinements.sh']);
copyfile('../scripts/refine_sulci_hemi_mac.sh', [bindir filesep 'refine_sulci_hemi.sh']);
copyfile('../scripts/register_cc_curve_mac.sh', [bindir filesep 'register_cc_curve.sh']);
copyfile('../scripts/thicknessPVC_mac.sh', [bindir filesep 'thicknessPVC.sh']);
copyfile('../scripts/svreg_smooth_surf_function_mac.sh', [bindir filesep 'svreg_smooth_surf_function.sh']);
copyfile('../scripts/svreg_make_atlas_mac.sh', [bindir filesep 'svreg_make_atlas.sh']);



fileattrib([bindir filesep '*.sh'], '+x');

system(sprintf('tar -czf %s.tar.gz %s', workdir, workdir));
rmdir(workdir, 's');
end


function package_files_linux(svreg_version, atlases)
[workdir bindir] = setup_package(svreg_version, atlases);

copyfile('svreg', [bindir filesep 'svreg']);
copyfile('svreg_label_surf_hemi', [bindir filesep 'svreg_label_surf_hemi']);
copyfile('generate_stats_xls', [bindir filesep 'generate_stats_xls']);
copyfile('volmap_ball', [bindir filesep 'volmap_ball']);
copyfile('svreg_volreg', [bindir filesep 'svreg_volreg']);
copyfile('clean_intermediate_files', [bindir filesep 'clean_intermediate_files']);
copyfile('refine_ROIs2', [bindir filesep 'refine_ROIs2']);
copyfile('svreg_refinements', [bindir filesep 'svreg_refinements']);
copyfile('refine_sulci_hemi', [bindir filesep 'refine_sulci_hemi']);
copyfile('register_cc_curve', [bindir filesep 'register_cc_curve']);
copyfile('thicknessPVC', [bindir filesep 'thicknessPVC']);
copyfile('svreg_smooth_surf_function', [bindir filesep 'svreg_smooth_surf_function']);
copyfile('svreg_make_atlas', [bindir filesep 'svreg_make_atlas']);
copyfile('../3rdParty/AIR_bin/warp_coord_vol_linux', [bindir filesep 'warp_coord_vol_linux']);
copyfile('../3rdParty/AIR_bin/warp_points_linux', [bindir filesep 'warp_points_linux']);




copyfile('../scripts/svreg_linux.sh', [bindir filesep 'svreg.sh']);
copyfile('../scripts/svreg_label_surf_hemi_linux.sh', [bindir filesep 'svreg_label_surf_hemi.sh']);
copyfile('../scripts/generate_stats_xls_linux.sh', [bindir filesep 'generate_stats_xls.sh']);
copyfile('../scripts/volmap_ball_linux.sh', [bindir filesep 'volmap_ball.sh']);
copyfile('../scripts/svreg_volreg_linux.sh', [bindir filesep 'svreg_volreg.sh']);
copyfile('../scripts/clean_intermediate_files_linux.sh', [bindir filesep 'clean_intermediate_files.sh']);
copyfile('../scripts/refine_ROIs2_linux.sh', [bindir filesep 'refine_ROIs2.sh']);
copyfile('../scripts/svreg_refinements_linux.sh', [bindir filesep 'svreg_refinements.sh']);
copyfile('../scripts/refine_sulci_hemi_linux.sh', [bindir filesep 'refine_sulci_hemi.sh']);
copyfile('../scripts/register_cc_curve_linux.sh', [bindir filesep 'register_cc_curve.sh']);
copyfile('../scripts/thicknessPVC_linux.sh', [bindir filesep 'thicknessPVC.sh']);
copyfile('../scripts/svreg_smooth_surf_function_linux.sh', [bindir filesep 'svreg_smooth_surf_function.sh']);
copyfile('../scripts/svreg_make_atlas_linux.sh', [bindir filesep 'svreg_make_atlas.sh']);

fileattrib([bindir filesep '*.sh'], '+x');

tar([workdir '.tar.gz'], workdir);
rmdir(workdir, 's');
end


function [directory, bin_directory] = setup_package(svreg_version, atlases)

svreg_version=[svreg_version(1:end-4),'_build',svreg_version(end-3:end)];
svreg_string = strrep(num2str(svreg_version), '.', 'p');

directory =  sprintf('svreg_%s_%s', svreg_string, get_platform());
bin_directory = [directory filesep 'bin'];
rcc_directory = [directory filesep 'rcc'];

mkdir(directory);
mkdir(bin_directory);

copyfile(['..' filesep '3rdParty'], rcc_directory);
copyfile(['..' filesep 'LICENSE.txt'], [directory filesep 'LICENSE.txt']);
copyfile(['..' filesep 'NOTICE.txt'], [directory filesep 'NOTICE.txt']);
copyfile(['..' filesep 'README.txt'], [directory filesep 'README.txt']);

% Copy atlases
for ii = 1:length(atlases)
    atlas = atlases{ii};
    atlas_directory = [directory filesep atlas];
    copyfile(['..' filesep atlas], atlas_directory);
end

create_manifest(svreg_version, atlases, [directory filesep 'svregmanifest.xml']);

if ispc
    line_ending = 'CRLF';
else
    line_ending = 'LF';
end
set_line_endings([directory filesep 'svregmanifest.xml'], line_ending);
set_line_endings([directory filesep 'LICENSE.txt'], line_ending);
set_line_endings([directory filesep 'NOTICE.txt'], line_ending);
set_line_endings([directory filesep 'README.txt'], line_ending);

end


function create_manifest(svreg_version, atlases, filename)
svreg_version = num2str(svreg_version);
compile_date = datestr(now, 'yyyy-mm-dd');
mcr_version = get_mcr_version();
platform = get_platform();

atlases_xml = '';
for ii = 1:length(atlases)
    atlas = atlases{ii};
    if strcmp(atlas, 'BrainSuiteAtlas1')
        atlas_tag = sprintf('<atlas>%s</atlas>', atlas);
    else
        atlas_basename = get_atlas_basename(atlas);
        atlas_tag = sprintf('<atlas basename="%s">%s</atlas>', atlas_basename, atlas);
    end
    atlases_xml = [atlases_xml '\t' atlas_tag '\n'];
end

manifest = sprintf(...
    ['<?xml version="1.0" encoding="UTF-8"?>\n' ...
    '<svregmanifest>\n' ...
    '\t<version>%s</version>\n'...
    '\t<build>%s</build>\n'...
    '\t<date>%s</date>\n'...
    '\t<mcrversion>%s</mcrversion>\n'...
    '\t<minimumbrainsuiteversion>14a</minimumbrainsuiteversion>\n'...
    '\t<platform>%s</platform>\n'...
    '%s'...
    '</svregmanifest>'], svreg_version(1:end-4-6),svreg_version(end-3:end) , compile_date, mcr_version, platform, atlases_xml);

fid = fopen(filename, 'w');
fprintf(fid, manifest);
fclose(fid);
end


function mcr_version = get_mcr_version()
[major minor update] = mcrversion;
mcr_version = [num2str(major) '.' num2str(minor)];
if update ~= 0
    mcr_version = [mcr_version '.' num2str(update)];
end
end


function platform = get_platform()
platform = computer('arch');

if strcmp(platform, 'glnxa64')
    platform = 'linux';
end
end


function basename = get_atlas_basename(atlas)
atlas_dir = ['..' filesep atlas];
check_file = dir([atlas_dir filesep '*.bfc.nii.gz']);
[~, name, ~] = fileparts(check_file.name);
k = strfind(name, '.bfc.nii');
basename = name(1:k(1)-1);
end


function set_line_endings(filename, lineEnding)
% Sets the line endings of given filename to given lineEnding style
% lineEnding = 'CRLF' or 'win': Windows line endings (\r\n)
% lineEnding = 'LF' or 'unix' : Unix line endings (\n)
% Default is 'LF' (program only checks for 'CRLF' or 'win' and does LF otherwise)
% NOTE: THIS FUNCTION OVERWRITES THE ORIGINAL FILE.
fid = fopen(filename, 'r');
if (fid == -1)
    fprintf('Could not open file %s. Make sure that it is a valid file.\n', filename);
    return;
end

lineEnding = lower(lineEnding);
if strcmp(lineEnding, 'crlf') || strcmp(lineEnding, 'win')
    lineEnding = sprintf('\r\n');
else
    lineEnding = sprintf('\n');
end

fileContents = '';
line = fgetl(fid);
while (ischar(line))
    fileContents = [fileContents line lineEnding]; %#ok
    line = fgetl(fid);
end

fclose(fid);
fid = fopen(filename, 'w');
fprintf(fid, fileContents);
fclose(fid);
end


function cleanup()
if ispc
    fileEnding = '.exe';
elseif ismac
    fileEnding = '.app';
else
    fileEnding = '';
end

executables = {['clean_intermediate_files' fileEnding], ...
    ['generate_stats_xls' fileEnding], ...
    ['refine_ROIs2' fileEnding], ...
    ['refine_sulci_hemi' fileEnding], ...
    ['register_cc_curve' fileEnding], ...
    ['svreg' fileEnding], ...
    ['svreg_label_surf_hemi' fileEnding], ...
    ['svreg_refinements' fileEnding], ...
    ['svreg_volreg' fileEnding], ...
    ['volmap_ball' fileEnding], ...
    ['thicknessPVC' fileEnding], ...
    ['svreg_smooth_surf_function' fileEnding], ...
    ['svreg_make_atlas' fileEnding]};

if ismac
    for i = 1:length(executables)
        rmdir(executables{i}, 's')
    end
else
    delete(executables{:});
end

delete('run_*.sh', 'mccExcludedFiles.log', 'readme.txt');
end
