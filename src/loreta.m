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



function [W] = loreta(sparseFV)
%Implementation of Loreta on a tesselation
W=get_stiffness_matrix_tri_wt(sparseFV,ones(length(sparseFV.vertices),1));
return;
% %current density weighting
% dim = size(sparseFV.vertices,1);
% W = sparse(dim,dim);
% 
% for i=1:size(sparseFV.faces,1) %for all triangles
%   %  progress(i,1,size(sparseFV.faces,1),5000,'triangles');
%     
%     %Get points from face
%      trVertices = sparseFV.faces(i,:);
%      points = sparseFV.vertices(trVertices,:);
%     %Get new coord system
%     r1 = points(2,:)-points(1,:);
%     r = points(3,:)-points(1,:);
%     projr_r1 = (r1*r')/rownorm(r1);
%     r2 = sqrt(r*r' - abs(projr_r1)^2);
%     if(r1*r')<0
%         r2 = -r2;
%     end
%     pointsNew = [0 0; rownorm(r1) 0; projr_r1 r2];
%     %area of triangle
%     Area = rownorm(r1) * rownorm(r2) / 2;
%     
%     %find local ps functions
%     A = [pointsNew [1 1 1]'];
%     Ai = A^-1;
%     
%     %create matrix for local laplacian
%     DPs = Ai(1:2,:);
%     M = Area * DPs'*DPs;
%     
%     %update sparse matrix for global laplacian
%     W(trVertices(1),trVertices(1)) = W(trVertices(1),trVertices(1)) + M(1,1);
%     W(trVertices(1),trVertices(2)) = W(trVertices(1),trVertices(2)) + M(1,2);
%     W(trVertices(1),trVertices(3)) = W(trVertices(1),trVertices(3)) + M(1,3);
%     W(trVertices(2),trVertices(1)) = W(trVertices(2),trVertices(1)) + M(2,1);
%     W(trVertices(2),trVertices(2)) = W(trVertices(2),trVertices(2)) + M(2,2);
%     W(trVertices(2),trVertices(3)) = W(trVertices(2),trVertices(3)) + M(2,3);
%     W(trVertices(3),trVertices(1)) = W(trVertices(3),trVertices(1)) + M(3,1);
%     W(trVertices(3),trVertices(2)) = W(trVertices(3),trVertices(2)) + M(3,2);
%     W(trVertices(3),trVertices(3)) = W(trVertices(3),trVertices(3)) + M(3,3);
% 
% %     
% %     r1 = points(1,:);
% %     r2 = points(2,:);
% %     r3 = points(3,:);
% %     a = r2 - r1;
% %     b = r3 - r1;
% %     ex = a/norm(a);
% %     ey = b-dot(a,b)/dot(a,a)*a;
% %     ey = ey/norm(ey);
% %     xx = [0;dot(a,ex);dot(b,ex)];
% %     yy = [0;dot(a,ey);dot(b,ey)];
% %     npe = 3;
% %     K = [ones(npe,1) xx yy];
% %     E = inv(K);
% %     Area = dot(a,ex)*dot(b,ey)/2;
% %     gradE = E(2:end,1:end);
% % 
% %     S_loc = gradE'*gradE*Area;
% %     
%     
%     
%     
% end
%     
% 
% %disp('Condition Number:');
% %disp(condest(W));
%     
%     
%   
%     
%     
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
