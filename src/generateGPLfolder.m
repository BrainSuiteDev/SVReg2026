function generateGPLfolder(output_dir)

packaging_dir = pwd();
[root_dir, nm, ext] = fileparts(packaging_dir);
lic_file = fullfile(root_dir, 'docs', 'license_GPL_short.txt');
ignore_list = {'docs', '3rdParty'};

addLicenseOnTop(root_dir, output_dir, lic_file, ignore_list, true)
copyfile(fullfile(root_dir, 'docs', 'gpl-2.0.txt'), fullfile(output_dir, 'LICENSE.txt'))
%copyfile(fullfile(root_dir, 'docs', 'bdpchangelog.txt'), fullfile(output_dir, 'CHANGELOG.txt'))


% delete some selected files 
rmdir(fullfile(output_dir, 'docs'), 's')
delete(fullfile(output_dir, 'packaging_tools', 'addLicenseOnTop.m'))
%delete(fullfile(output_dir, 'packaging_tools', 'bdpGenerateHTMLreadme.m'))
delete(fullfile(output_dir, 'packaging_tools', 'generateGPLfolder.m'))

