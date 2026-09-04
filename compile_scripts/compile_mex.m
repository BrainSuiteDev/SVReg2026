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

function compile_mex()

try
    bin_dir = pwd;
    src_dir = [bin_dir filesep '..'];
    mex_dir = [src_dir filesep 'MEX_Files'];
    thirdparty_dir = [src_dir filesep '3rdParty'];
    mex_files = ['*.' mexext];
    
    
    
    %% Compile RCC
    cd([thirdparty_dir]);
    cpd_make;
    movefile(mex_files, mex_dir, 'f');
    
    %% Compile trilinear
    cd(thirdparty_dir);
    if strcmp(computer('arch'), 'maci64')
        % recent updates broke compilation for Intel Mac environments --
        % see: https://www.mathworks.com/matlabcentral/answers/2180662-mex-compilation-failure-after-most-recent-macos-update
        mex LDFLAGS="$LDFLAGS -ld_classic" -v trilinear.cpp;
    else
        % Standard compilation for Apple Silicon, Windows, and Linux
        mex -v trilinear.cpp;
    end
    movefile(mex_files, mex_dir, 'f');
    
    cd(bin_dir);
    
catch err
    cd(bin_dir);
    rethrow(err);
    
end
    fprintf('Note that the AIR files are not compiled here. Need to do that separately\n')'
end
