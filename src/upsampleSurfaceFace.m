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


function s_out = upsampleSurfaceFace(s_in, area_thresh, niter)
% Upsamples faces with area larger than specified threshold by adding mean of the vertices of the
% faces as new vertex. 
% s_in - Surface structure. Must contain vertices and faces fields. 
% area_thresh - Minimum area threshold in mm^2
% s_out - Output surface structure. Only contains vertices, faces and labels (if present in input
%         structure)

if ~exist('niter', 'var')
   niter = 1;
end
s_out = s_in;

for k = 1:niter
   s_in = s_out;
   
   % compute_face_area
   if area_thresh>0
      Fvert2 = s_in.vertices(s_in.faces(:,2),:) - s_in.vertices(s_in.faces(:,1),:);
      Fvert3 = s_in.vertices(s_in.faces(:,3),:) - s_in.vertices(s_in.faces(:,1),:);
      Fvert2_norm = sqrt(sum(Fvert2.^2, 2));
      Fvert3_norm = sqrt(sum(Fvert3.^2, 2));
      csin_angle = sum(Fvert2.*Fvert3, 2) ./ (Fvert2_norm.*Fvert3_norm);
      Farea = 0.5 * (Fvert2_norm .* Fvert3_norm .* sqrt(1-csin_angle.^2));
      clear Fvert2 Fvert3 Fvert2_norm Fvert3_norm csin_angle
      
      face_msk = Farea>area_thresh;
   else
      face_msk = true(size(s_in.faces, 1), 1);
   end
   
   new_vert = (  s_in.vertices(s_in.faces(face_msk,1),:) ...
      + s_in.vertices(s_in.faces(face_msk,2),:) ...
      + s_in.vertices(s_in.faces(face_msk,3),:))/3;
   
   nVert = length(s_in.vertices);
   newInd = nVert + [1:length(new_vert)]';
   
   s_out.vertices = [s_in.vertices; new_vert];
   s_out.faces = s_in.faces(~face_msk,:);
   newFace = [...
      [s_in.faces(face_msk,2) newInd s_in.faces(face_msk,1)]; ...
      [s_in.faces(face_msk,3) newInd s_in.faces(face_msk,2)]; ...
      [s_in.faces(face_msk,1) newInd s_in.faces(face_msk,3)]];
   s_out.faces = [s_out.faces; newFace];
   
   if isfield(s_in,'labels')
      s_out.labels = [s_in.labels; median(s_in.labels(s_in.faces(face_msk,:)),2)];
   end
end

end
