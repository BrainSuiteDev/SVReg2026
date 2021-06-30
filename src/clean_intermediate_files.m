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


function clean_intermediate_files(subbasename,varargin)

subbasename = remove_extn_basename(subbasename);

[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end

%% Output a log
logfname=[subbasename,'.svreg.log'];
fp=fopen(logfname,'a+');
t = datestr(datetime('now'));
fprintf(fp,'%s:',t);
[svreg_version,svreg_build] = get_svreg_version(subbasename);
fprintf(fp,'SVReg %s(%s):',svreg_version,svreg_build);
fprintf(fp,'clean_intermediate_files %s ',subbasename);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');

fclose(fp);
%%
fclose('all');
[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);
tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
pause(1);
try
    rmdir(tmpdir,'s');
    pause(3);
    if exist(tmpdir,'dir')        
        rmdir(tmpdir,'s');
    end
catch
    disp1('error deleting temp dir','clean_intermediate_files',[]);
end
