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



function alpha = lplsrch(A,x,b,d,Tol,p)
alpha=0;
iterNo =1;
    Ad=A*d;
    Adsqr=Ad.*Ad;
Axxb=A*x-b;
while (iterNo < 100)
iterNo = iterNo + 1;
	x_plus_alphad=x+alpha*d;
    %Ax=A*x_plus_alphad;
	Axb=Axxb+alpha*Ad;
        Axbp_2=(Axb).^(p-2);
    Lprime_a=sum((Axbp_2.*Axb).*(Ad));
	Ldprime_a=(p-1)*sum(Axbp_2.*(Adsqr)); 
	updt= Lprime_a/Ldprime_a; 

if abs(updt)<Tol
    break;
end
       alpha = alpha - updt;

end
 
