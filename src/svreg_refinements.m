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


function svreg_refinements(subbasename,atlas_name,varargin)
[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);

%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);

logfname=[subbasename_tmp,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'svreg_refinements %s %s ',subbasename,atlas_name);
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
    verbosity=flags(a(1)+1);
    verbosity= str2double(verbosity);
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
%disp1('Refining Volumetric ROIs','svreg_refinements');
refine_vol_labels(subbasename_tmp);
correct_vol_labels(subbasename,flags);

