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


function rte = pred2path(P,s,t)
%PRED2PATH Convert predecessor indices to shortest paths from node 's' to 't'.
%   rte = pred2path(P,s,t)
%     P = |s| x n matrix of predecessor indices (from DIJK)
%     s = FROM node indices
%       = [] (default), paths from all nodes
%     t = TO node indices
%       = [] (default), paths to all nodes
%   rte = |s| x |t| cell array of paths (or routes) from 's' to 't', where
%         rte{i,j} = path from s(i) to t(j)
%                  = [], if no path exists from s(i) to t(j)
%
% (Used with output of DIJK)

% Copyright (c) 1994-2002 by Michael G. Kay
% Matlog Version 6 19-Sep-2002

% Input Error Checking ******************************************************
error(nargchk(1,3,nargin));

[rP,n] = size(P);

if nargin < 2 | isempty(s), s = (1:n)'; else s = s(:); end
if nargin < 3 | isempty(t), t = (1:n)'; else t = t(:); end

if any(P < 0 | P > n)
   error(['Elements of P must be integers between 1 and ',num2str(n)]);
elseif any(s < 1 | s > n)
   error(['''s'' must be an integer between 1 and ',num2str(n)]);
elseif any(t < 1 | t > n)
   error(['''t'' must be an integer between 1 and ',num2str(n)]);
end
% End (Input Error Checking) ************************************************

rte = cell(length(s),length(t));

[ans,idxs] = find(P==0);

for i = 1:length(s)
%    if rP == 1
%       si = 1;
%    else
%       si = s(i);
%       if si < 1 | si > rP
%          error('Invalid P matrix.')
%       end
%    end
   si = find(idxs == s(i));
   for j = 1:length(t)
      tj = t(j);
      if tj == s(i)
         r = tj;
      elseif P(si,tj) == 0
         r = [];
      else
         r = tj;
         while tj ~= 0
            if tj < 1 | tj > n
               error('Invalid element of P matrix found.')
            end
            r = [P(si,tj) r];
            tj = P(si,tj);
         end
         r(1) = [];
      end
      rte{i,j} = r;
   end
end

if length(s) == 1 & length(t) == 1
   rte = rte{:};
end

%rte = t;
while 0%t ~= s
   if t < 1 | t > n | round(t) ~= t
      error('Invalid ''pred'' element found prior to reaching ''s''');
   end
   rte = [P(t) rte];
   t = P(t);
end

