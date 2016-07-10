% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2016 The Regents of the University of California and the University of Southern California
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


function svreg_smooth_surf_function(insurf, insurffunc, outsurf, param)
% This function performs smoothing of data on surfaces
% 
if (nargin < 3)
    fprintf('USAGE: svreg_smooth_surf_function.sh in_surf, in_func, out_surf\n');
    fprintf('in_surf: input surface file\n');
    fprintf('in_func: surface file in which surface function is defined in attributes field\n');
    fprintf('out_surf: input surface file\n');
    fprintf('param (Optional): smoothing parameter (std dev in mm)\n');
end

s=readdfsGz(insurf);

if ~exist('param','var')
    param=10;
end
if ischar(param)
    param=str2double(param);
end

fs=readdfs(insurffunc);

a1=sqrt(param);a2=a1;
aniso=ones(size(fs.attributes));normalize=0;
f=smooth_surf_function(s,fs.attributes,a1,a2,aniso,normalize);
s.attributes=f;

writedfs(outsurf,s);

