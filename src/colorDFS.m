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


function [fv, cdata, v_data] = colorDFS(fv, data, clim, cmap)
% Generates RGB-colored data for surface using inputs. 
%   fv - dfs struct
%   data - same # elements as number of vertices or faces
%   clim - [low high]
%   cmap - nx3 matrix, eg: jet(256)
%
% When data as same length as vertices, it adds/overwrites fv.vcolor - useful to save as dfs
% format. Otherwise removes fv.vcolor. cdata is the RGB output in both case.

data = data(:);

if length(data)==length(fv.vertices)
   v_data = true;
elseif length(data)==length(fv.faces)
   v_data = false;
else
   error('length of data must match either number of vertices or number of faces!')
end

if nargin<4
   cmap = gray(256);
end

if ~exist('clim', 'var')
   temp = sort(data(:), 'ascend');
   low = temp(max(floor(length(temp)*0.02), 1));
   high = temp(floor(length(temp)*0.985));
   clim = [low high];
   
   if clim(1)==clim(2)
      clim = clim + [-1 1];
   end
   clim
   clear temp
end

% resample data in range of [1 length(cmap)]
nlev = length(cmap);
data = (data-clim(1))/(clim(2)-clim(1));
data(data<0) = 0;
data(data>1) = 1;
data = (data*(nlev-1)) + 1;

cdata(:,1) = interp1(cmap(:,1), data, 'linear');
cdata(:,2) = interp1(cmap(:,2), data, 'linear');
cdata(:,3) = interp1(cmap(:,3), data, 'linear');

if v_data
   fv.vcolor = cdata;
else
   fv.vcolor = [];
   fv = rmfield(fv, 'vcolor');
end

end
