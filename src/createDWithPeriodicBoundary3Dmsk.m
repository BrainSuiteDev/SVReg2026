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


function [D1,D2,D3] = createDWithPeriodicBoundary3Dmsk(N1,N2,N3,mask_ind)
% [D,Dp] = createD(N1,N2)
%
% Generates the sparse two-dimensional finite difference (first-order neighborhoods) matrix D 
% for an image of dimensions N1xN2 (rows x columns).  The optional output
% argument Dp is the transpose of D.  Also works for vector images if one
% of N1 or N2 is 1.
% Based on createDwithMask by Justin Haldar (jhaldar@usc.edu) 11/02/2006
% Inspired by the dgrad function, written by W. C. Karl 4/98


%[~,bdr_indxMSK]=find_mask_bdr(mask_ind,[N1 N2 N3]);
%if exist('bdr1','var')
%    bdr_indxMSK=bdr1;
%end
if (not(isreal(N1)&&(N1>0)&&not(N1-floor(N1))&&isreal(N2)&&(N2>0)&&not(N2-floor(N2))))
    error('Inputs must be real positive integers');
end
if ((N1==1)&&(N2==1)&&(N3==1))
    error('Finite difference matrix can''t be generated for a single-pixel image');
end

D1 = [];
D2 = [];
D3 = [];

if (N1 > 1)&&(N2>1)&&(N3>1)    
    e = ones(N1,1);
    if (numel(e)>2)
        T = spdiags([e,-e],[0,1],N1,N1);
        T(N1,1)=-1;
        E = speye(N2);
        E2 = speye(N3);
        D1 = kron(E2,kron(E,T));D1=D1(mask_ind,mask_ind);%D1(bdr_indxMSK,:)=0;
    end
    e = ones(N2,1);
    if (numel(e)>2)
        T = spdiags([e,-e],[0,1],N2,N2);
        T(N2,1)=-1;
        E = speye(N1);
        E2 = speye(N3);
        D2 =  kron(E2,kron(T,E));D2=D2(mask_ind,mask_ind);%D2(bdr_indxMSK,:)=0;
    end
    e = ones(N3,1);
    if (numel(e)>2)
        T = spdiags([e,-e],[0,1],N3,N3);
        T(N3,1)=-1;
        E = speye(N1);
        E2 = speye(N2);
        D3 =  kron(T,kron(E2,E));D3=D3(mask_ind,mask_ind);%D3(bdr_indxMSK,:)=0;
    end
else % Image is a vector of length max(N1,N2)
   error('singleton dimensions not supported');
end
D1=-D1;D2=-D2;D3=-D3;
%D = -[D1;D2;D3];
