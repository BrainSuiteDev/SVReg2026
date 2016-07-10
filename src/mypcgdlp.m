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


function [x] = mypcgdlp(A,b,x,Tol,Maxit,p)
%x=ones(size(A,1),1);
g = p*(A'*((A*x-b).^(p-1)));
d = -g;
gtg = g'*g;
newgtg=0;
for i=1:Maxit
%     if gtg<Tol 
%         break;
%     end
    alpha=lplsrch(A,x,b,d,1e-12,p);
    x = x+alpha*d;
    g = p*(A'*((A*x-b).^(p-1)));
     
    newgtg=g'*g;
    beta=newgtg/gtg;
    gtg=newgtg;
    
    d=-g+beta*d;
end
%disp(sprintf('Mypcg did %d iterations Tol=%e',i,g'*g));


