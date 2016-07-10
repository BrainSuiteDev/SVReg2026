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


function thicknessPVC(varargin)
% Usage:
%   thicknessPVC(subbase)
%   thicknessPVC(subbase, vox_res_comp)
%   thicknessPVC(subbase, vox_res_comp, inner_erode_sz)
%   thicknessPVC(subbase, vox_res_comp, inner_erode_sz, flagStr)
%   thicknessPVC subbase ...
%
% Inputs:
%   subbase - Sub base name of subject (svreg-style)
%   vox_res_comp - Istropic size of voxel for computation in mm. Default value of 0.48 mm.
%   inner_erode_sz - size of ersion for inner mask in mm. Should be similar to voxel resolution of
%                    T1w data. Default value of 1 mm.
%   flagStr - A string which defines flag for type of gradient computation. Options are: 
%             '-c' : (default) Central difference estimate of derivative with weight of 1.7 along
%                    with 1.0 weight of forward difference.
%             '-c<N>' : Central difference estimate of derivative with weight of <N> along with 1.0
%                       weight of forward difference. Eg: '-c20',  '-c1000'. A weight of >1e10
%                       disables the forward difference entirely.
%             '-f' : Uses only old forward difference method (with shifted response function)
%
% Requires following files to be present on disk:
%    [subbase, '.inner.cortex.dfs']
%    [subbase, '.pial.cortex.dfs']
%    [subbase '.cortex.dewisp.mask.nii.gz']
%    [subbase '.cerebrum.mask.nii.gz']
%    [subbase '.pvc.frac.nii.gz']
%
% Writes out following files:
%     [subbase '.GM_frac.nii.gz']
%     [subbase '.heat_map_sol.nii.gz']
%     [subbase, '.pvc-thickness_0-6mm.isosurface.dfs']
%     [subbase, '.pvc-thickness_0-6mm.mid.cortex.dfs']
%     [subbase, '.heat_sol_comp.mat']
%

if nargin<1
   error('thicknessPVC must have atleast one input.')
end
[subbase, vox_res_comp, inner_erode_sz, gopts] = parseInputThicknessPVC(varargin);

tolFactor = 1e-12;
MaxPCGiter = 4500; % set more than 1200
pad_comp_vox = 10; % in unit of voxels
face_area_thresh = (vox_res_comp^2)/3; % in mm^2
inner_erode_sz = ceil(inner_erode_sz/vox_res_comp); % converted to voxels

inner = readdfsGz([subbase, '.inner.cortex.dfs']);
pial = readdfsGz([subbase, '.pial.cortex.dfs']);
msk_inner = load_untouch_nii_gz([subbase '.cortex.dewisp.mask.nii.gz']);
msk_cereb = load_untouch_nii_gz([subbase '.cerebrum.mask.nii.gz']);
pvc = load_untouch_nii_gz([subbase '.pvc.frac.nii.gz']);
volRes = pvc.hdr.dime.pixdim(2:4);
volSz = size(msk_cereb.img);

% compute GM fraction
GMfrac = zeros(size(pvc.img));
GMfrac(pvc.img>1 & pvc.img<=2) = pvc.img(pvc.img>1 & pvc.img<=2) - 1;
GMfrac(pvc.img>2 & pvc.img<=3) = 3 - pvc.img(pvc.img>2 & pvc.img<=3);
nii = pvc;
nii.img = GMfrac;
save_untouch_nii_gz(nii, [subbase '.GM_frac.nii.gz']);
GMfrac = GMfrac + eps;
clear nii pvc

% upsample surface faces & compute volume from surfaces
pial = upsampleSurfaceFace(pial, face_area_thresh, 6);
grid_min = floor(min([inner.vertices; pial.vertices], [], 1)./vox_res_comp - pad_comp_vox);
grid_max = ceil(max([inner.vertices; pial.vertices], [], 1)./vox_res_comp + pad_comp_vox);
grid_size = (grid_max - grid_min) + 1;
pial_vol = surf2vol(pial.vertices, grid_size, vox_res_comp, grid_min);
clear pial inner

% get masks in computational-vol coordinates
se1 = strel_sphere(1);

[volComp_x, volComp_y, volComp_z] = ndgrid((grid_min(1):grid_max(1))*vox_res_comp, ...
   (grid_min(2):grid_max(2))*vox_res_comp, (grid_min(3):grid_max(3))*vox_res_comp); % in mm

[volin_x, volin_y, volin_z] = ndgrid((0:(volSz(1)-1))*volRes(1), ...
   (0:(volSz(2)-1))*volRes(2), (0:(volSz(3)-1))*volRes(3)); % in mm, input grid

GM_frac_vol = interpn(volin_x, volin_y, volin_z, GMfrac, volComp_x, volComp_y, volComp_z, 'linear', eps);
clear GMfrac

temp = imgaussian(double(msk_inner.img>0), 0.7);
msk_inner_vol = interpn(volin_x, volin_y, volin_z, temp, volComp_x, volComp_y, volComp_z, 'linear', 0);
% msk_inner_vol = imerode(msk_inner_vol>0.5, se2);
msk_inner_vol = refineInnerMask(msk_inner_vol>0.5, GM_frac_vol, 1e-6, inner_erode_sz);

temp = imgaussian(double(msk_cereb.img>0), 0.7);
msk_cereb_vol = interpn(volin_x, volin_y, volin_z, temp, volComp_x, volComp_y, volComp_z, 'linear', 0);
msk_cereb_vol = imdilate(msk_cereb_vol>0.5, se1);

msk_compute = msk_cereb_vol & ~msk_inner_vol; 
msk_compute = imdilate(msk_compute, strel_sphere(3));
clear volin_x volin_y volin_z volComp_x volComp_y volComp_z
clear temp msk_inner msk_cereb 

% Fixed temp volume, 0 = unknown, 1-inner, 2-pial
heat_vol = zeros(grid_size);
heat_vol(~msk_cereb_vol) = 2;
heat_vol(msk_inner_vol) = 1;
heat_vol(pial_vol) = 2;
clear pial_vol

% create heat flow maps
heatWt = 1./GM_frac_vol;
heatWt(heatWt>1e6) = 1e6;

if gopts.central
   D = createAnisoDwithMaskCentral(grid_size(1), grid_size(2), grid_size(3), msk_compute, sqrt(heatWt), [1 1 1]./vox_res_comp);
   if gopts.centralWt < 1e10
      DF = createAnisoDwithMask(grid_size(1), grid_size(2), grid_size(3), msk_compute, sqrt(heatWt), [1 1 1]./vox_res_comp);
      D = [gopts.centralWt*D; DF];
      clear DF
   end
   
else % old forward difference code
   D = createAnisoDwithMask2(grid_size(1), grid_size(2), grid_size(3), msk_compute, sqrt(heatWt), [1 1 1]./vox_res_comp);
end


[mask_knw, unmask_knw] = createMaskOperators(msk_compute & heat_vol>0);
b = -1*D*unmask_knw*mask_knw*heat_vol(:); clear mask_knw unmask_knw heatWt

[~, unmask_unknw] = createMaskOperators(msk_compute & heat_vol==0);
A = D*unmask_unknw;
clear D mask_knw unmask_knw unmask_unknw

% Least sq. sol with pcg
Atb = A'*b; clear b; 
AtA = A'*A; clear A;

opts.type = 'nofill'; 
opts.michol = 'on';
L = ichol(AtA, opts); % preconditioner

tol = tolFactor/norm(Atb);
[x,fl,rr,it,rv] = pcg(AtA, Atb, tol, MaxPCGiter, L, L', 1.5*ones(size(AtA,2),1));
[fl, rr, it]
clear AtA Atb L

[mask_knw, unmask_knw] = createMaskOperators(msk_compute & heat_vol>0);
[~, unmask_unknw] = createMaskOperators(msk_compute & heat_vol==0);
heat_map = unmask_knw*mask_knw*heat_vol(:) + unmask_unknw*x;
heat_map = reshape(heat_map, grid_size);
heat_map(~msk_cereb_vol) = 2;
heat_map(msk_inner_vol) = 1;
clear mask_knw unmask_knw unmask_unknw x heat_vol


% save heat_map
[volComp_x, volComp_y, volComp_z] = ndgrid((grid_min(1):grid_max(1))*vox_res_comp, ...
   (grid_min(2):grid_max(2))*vox_res_comp, (grid_min(3):grid_max(3))*vox_res_comp);

[volin_x, volin_y, volin_z] = ndgrid((0:(volSz(1)-1))*volRes(1), ...
   (0:(volSz(2)-1))*volRes(2), (0:(volSz(3)-1))*volRes(3)); % in mm, input grid

nii = load_untouch_nii_gz([subbase '.cortex.dewisp.mask.nii.gz']);
nii.img = interpn(volComp_x, volComp_y, volComp_z, heat_map, volin_x, volin_y, volin_z, 'linear', 2);
save_untouch_nii_gz(nii, [subbase '.heat_map_sol.nii.gz'], 64);

% Compute thickness (using iso-surface)
[gy,gx,gz] = gradient(heat_map, vox_res_comp, vox_res_comp, vox_res_comp);
grd_mag = sqrt(gy.^2 + gx.^2 + gz.^2);
thickness_vol = GM_frac_vol./grd_mag;
thickness_vol(~isfinite(thickness_vol)) = 0;

fv = isosurface(volComp_x, volComp_y, volComp_z, heat_map, 1.5);
pvc_iso_thickness = interpn(volComp_x, volComp_y, volComp_z, thickness_vol, ...
   fv.vertices(:,1), fv.vertices(:,2), fv.vertices(:,3), 'linear');
fv.attributes = pvc_iso_thickness;
fv = colorDFS(fv, fv.attributes, [0 6], jet(256));
writedfs([subbase, '.pvc-thickness_0-6mm.isosurface.dfs'], fv);

inner = readdfsGz([subbase, '.inner.cortex.dfs']);
pial = readdfsGz([subbase, '.pial.cortex.dfs']);
if isequal(size(inner.vertices), size(pial.vertices))
   if verLessThan('matlab', '7.14.1') % R2012a or lower
      F = TriScatteredInterp(fv.vertices(:,1), fv.vertices(:,2), fv.vertices(:,3), pvc_iso_thickness, 'nearest');
   else
      F = scatteredInterpolant(fv.vertices(:,1), fv.vertices(:,2), fv.vertices(:,3), pvc_iso_thickness, 'nearest', 'nearest');
   end
   mid = inner;
   mid.vertices = (inner.vertices + pial.vertices)/2;
   mid.attributes = F(mid.vertices(:,1), mid.vertices(:,2), mid.vertices(:,3));
   mid = colorDFS(mid, mid.attributes, [0 6], jet(256));
   writedfs([subbase, '.pvc-thickness_0-6mm.mid.cortex.dfs'], mid);
end

if exist([subbase, '.left.inner.cortex.svreg.dfs'],'file')
    split_thickness_map(subbase);
end

save([subbase, '.heat_sol_comp.mat'], 'volComp_x', 'volComp_y', 'volComp_z', 'heat_map', ...
   'thickness_vol', 'vox_res_comp', 'gopts', '-v7.3');
clearvars -except subbase

end

function vol = surf2vol(vert, sz, res, grid_min)
% Returns logical volume from surface
vol = false(sz);
temp = round(vert./res) + 1;
ind = sub2ind(sz, temp(:,1)-grid_min(1), temp(:,2)-grid_min(2), temp(:,3)-grid_min(3));
vol(ind) = true;
end

function msk_out = refineInnerMask(msk_inner, GM_frac, GM_thresh, erode_sz)
% Erodes inner mask to include voxels which is larger than GM_frac>GM_thresh

se = strel_sphere(1);
temp = msk_inner>0;
for k = 1:erode_sz
   tempE = imerode(temp, se);
   temp = ((temp & ~tempE) & (GM_frac<GM_thresh)) | tempE;
end
msk_out = temp;

end

function [subbase, vox_res_comp, inner_erode_sz, gopts] = parseInputThicknessPVC(var)
% Parse input, so that it can handle compiled as well as function style inputs

subbase = var{1};

if length(var)>1
   if ischar(var{2})
      vox_res_comp = str2double(var{2});
   else
      vox_res_comp = var{2};
   end   
end

if length(var)>2
   if ischar(var{3})
      inner_erode_sz = str2double(var{3});
   else
      inner_erode_sz = var{3};
   end   
end


% flag for OLD forward difference: -f (Uses Anand's modified code with, shifted response function)
% flag for central difference: -c (defaults to 1.7 weight for central difference & 1.0 weight to forward difference)
% flag for central difference: -c20 (uses a weight of 20 for central difference  & 1.0 weight to forward difference)
if length(var)>3
   if ischar(var{4})
      temp = strtrim(var{4});
      
      switch temp(1:2)
         case '-f'
            fprintf('\nUsing old forward-difference method.\n')
            gopts.central = false;
            
         case '-c'
            gopts.central = true;
            if length(temp)>2
               gopts.centralWt = str2double(temp(3:end));
               if ~isfinite(gopts.centralWt)
                  error('Could not understand the flagStr: %s', temp)
               end               
            else
               gopts.centralWt = 1.7; % almost 1/0.6
            end            

         otherwise
            error('Fourth input to thicknessPVC must be a flag of form -c or -f.')
      end
   else
      error('Fourth input to thicknessPVC must be a string flag.')
   end
end


if ~exist('vox_res_comp', 'var')
   vox_res_comp = 0.48; % in mm
end

if ~exist('inner_erode_sz', 'var')
   inner_erode_sz = 1; % in mm
end

if ~exist('gopts', 'var')
   gopts.central = true;
   gopts.centralWt = 1.7;
end

end


