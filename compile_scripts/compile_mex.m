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

function compile_mex()

try
    bin_dir = pwd;
    src_dir = [bin_dir filesep '..' filesep 'src'];
    mex_dir = [src_dir filesep 'MEX_Files'];
    thirdparty_dir = [src_dir filesep '3rdParty'];
    mex_files = ['*.' mexext];
    
    
    
    %% Compile RCC
    cd([thirdparty_dir]);
    cpd_make;
    movefile(mex_files, mex_dir, 'f');
    
    %% Compile trilinear
    cd(thirdparty_dir);
    mex -v trilinear.cpp;
    movefile(mex_files, mex_dir, 'f');
    
    cd(bin_dir);
    
catch err
    cd(bin_dir);
    rethrow(err);
    
end
    fprintf('Note that the AIR files are not compiled here. Need to do that separately\n')'
end
