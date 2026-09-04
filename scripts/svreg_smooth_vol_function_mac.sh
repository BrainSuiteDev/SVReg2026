#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2025b is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /Applications/MATLAB/MATLAB_Runtime/R2025b ]; then
    BrainSuiteMCR="/Applications/MATLAB/MATLAB_Runtime/R2025b"
  elif [ -e /Applications/MATLAB_R2025b.app/runtime ]; then
    BrainSuiteMCR="/Applications/MATLAB_R2025b.app";  
  else
    echo
    echo "Could not find Matlab 2025b with Matlab Compiler or Matlab 2025b (v25.2)."
    echo "Please install the Matlab 2025b MCR from MathWorks at:"
    echo
    echo "https://www.mathworks.com/products/compiler/matlab-runtime.html"
    echo 
    echo "If you already have Matlab 2025b with the Matlab Compiler or Matlab 2025b"
    echo "installed, please edit ${exe_name} by uncommenting and editing the line:"
    echo "#BrainSuiteMCR=\"/path/to/your/MCR\";"
    echo "(replacing /path/to/your/MCR with the path to your Matlab or MCR installation)"
    echo "near the top of the file"
    echo
    exit 78
  fi
fi

read -d '' usage <<EOF

  svreg_smooth_vol_function : This script performs 3d volumetric smoothing using Gaussian kernel.
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: svreg_smooth_vol_function.sh in_file stdx stdy stdz out_file

  required input:
  in_file: input vol file
  stdx,stdy,stdz: std dev (in mm) in 3 directions
  out_vol: output vol file

EOF

# Parse inputs
if [ $# -lt 5 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi


INFILE=$1;
STDX=$2;
STDY=$3;
STDZ=$4;
OUTFILE=$5;
shift



# Set up path for MCR applications.
DYLD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/maci64;
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export DYLD_LIBRARY_PATH;
export XAPPLRESDIR;


[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/svreg_smooth_vol_function.app/Contents/MacOS/svreg_smooth_vol_function "${INFILE}" "${STDX}" "${STDY}" "${STDZ}" "${OUTFILE}" 

exit
