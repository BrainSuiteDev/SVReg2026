#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2019b is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /Applications/MATLAB/MATLAB_Runtime/v97 ]; then
    BrainSuiteMCR="/Applications/MATLAB/MATLAB_Runtime/v97"
  elif [ -e /Applications/MATLAB_R2019b.app/runtime ]; then
    BrainSuiteMCR="/Applications/MATLAB_R2019b.app";  
  else
    echo
    echo "Could not find Matlab 2019b with Matlab Compiler or MCR 2019b (v9.7)."
    echo "Please install the Matlab 2019b MCR from MathWorks at:"
    echo
    echo "http://www.mathworks.com/products/compiler/mcr/"
    echo 
    echo "If you already have Matlab 2019b with the Matlab Compiler or MCR 2019b"
    echo "installed, please edit ${exe_name} by uncommenting and editing the line:"
    echo "#BrainSuiteMCR=\"/path/to/your/MCR\";"
    echo "(replacing /path/to/your/MCR with the path to your Matlab or MCR installation)"
    echo "near the top of the file"
    echo
    exit 78
  fi
fi

read -d '' usage <<EOF

  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: svreg_resample.sh in_file out_file [dim] [dx] [dy] [dz] [method] [extrapval]

 Description:
 This function resamples 3D or 4D input NIFTI-1 file.

 Usage:
 svreg_resample.sh in_file out_file [dim] [dx] [dy] [dz] [method] [extrapval]
 while first two arguments are required, others are [OPTIONAL]

 Arguments:
 in_file: input nifti file in nii.gz file format
 out_file: output nifti file in nii.gz format
 [dim]: if this is '-size' output size is specified
        if this is '-res' output pixel resolution is specified
       default is -res 1 1 1 (istotropic sampling)
 [dx],[dy],[dz]: if the dim='-size', then this is interpreted as output size
                 if the dim=-res', then this is interpred as voxel resolution in x,y,z directions
 [method]: interpolation methods: 'linear', 'nearest','cubic','spline' the
 default is 'linear'.
 [extrapval]: Values for extrapolation outside the grid on the boundary.
 the default is median of all corners.

 If the functions is called with only input and output file names, it
 resamples to isotropic (1mm cubic) resolution


EOF

# Parse inputs
if [ $# -lt 2 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi


#shift



# Set up path for MCR applications.
DYLD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/maci64;
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export DYLD_LIBRARY_PATH;
export XAPPLRESDIR;


[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/svreg_resample.app/Contents/MacOS/svreg_resample "$@" 

exit
