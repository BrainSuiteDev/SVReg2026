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



function [p,q,r,s]=connected_components(conn)

rowno=[];colno=[];datano=[];
for jj=1:length(conn)
    rowno = [rowno;repmat(jj,length(conn{jj}),1)];
    colno = [colno;conn{jj}'];
    datano= [datano;ones(length(conn{jj}),1)];
end
A=sparse(rowno,colno,datano); A=A+speye(size(A));
[p,q,r,s]=dmperm(A);
