#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2023a is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /Applications/MATLAB/MATLAB_Runtime/R2023a ]; then
    BrainSuiteMCR="/Applications/MATLAB/MATLAB_Runtime/R2023a"
  elif [ -e /Applications/MATLAB_R2023a.app/runtime ]; then
    BrainSuiteMCR="/Applications/MATLAB_R2023a.app";  
  else
    echo
    echo "Could not find Matlab 2023a with Matlab Compiler or Matlab 2023a (v9.0)."
    echo "Please install the Matlab 2023a MCR from MathWorks at:"
    echo
    echo "https://www.mathworks.com/products/compiler/matlab-runtime.html"
    echo 
    echo "If you already have Matlab 2023a with the Matlab Compiler or Matlab 2023a"
    echo "installed, please edit ${exe_name} by uncommenting and editing the line:"
    echo "#BrainSuiteMCR=\"/path/to/your/MCR\";"
    echo "(replacing /path/to/your/MCR with the path to your Matlab or MCR installation)"
    echo "near the top of the file"
    echo
    exit 78
  fi
fi

read -d '' usage <<EOF

  svreg_get_mni_tal : Convert subject's voxel coordinates to mni and Talairach coordinates
  subbasename: subjects base name
  atlasbasename: atlas base name 
  sx,sy,sz: xyz coordinates
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: svreg_get_mni_tal.sh [subject fileprefix] [atlas fileprefix] [sx] [sy] [sz]

EOF

# Parse inputs
if [ $# -lt 5 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

FILEPREFIX=$1;
ATLASPREFIX=$2;
SX=$3
SY=$4
SZ=$5

# Set up path for MCR applications.
DYLD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/maci64;
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export DYLD_LIBRARY_PATH;
export XAPPLRESDIR;

[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/svreg_get_mni_tal.app/Contents/MacOS/svreg_get_mni_tal "${FILEPREFIX}" "${ATLASPREFIX}" "${SX}" "${SY}" "${SZ}"
exit
