#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2012a is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /Applications/MATLAB/MATLAB_Compiler_Runtime/v717 ]; then
    BrainSuiteMCR="/Applications/MATLAB/MATLAB_Compiler_Runtime/v717"
  elif [ -e /Applications/MATLAB_R2012a.app/runtime ]; then
    BrainSuiteMCR="/Applications/MATLAB_R2012a.app";  
  else
    echo
    echo "Could not find Matlab 2012a with Matlab Compiler or MCR 2012a (v7.17)."
    echo "Please install the Matlab 2012a MCR from MathWorks at:"
    echo
    echo "http://www.mathworks.com/products/compiler/mcr/"
    echo 
    echo "If you already have Matlab 2012a with the Matlab Compiler or MCR 2012a"
    echo "installed, please edit ${exe_name} by uncommenting and editing the line:"
    echo "#BrainSuiteMCR=\"/path/to/your/MCR\";"
    echo "(replacing /path/to/your/MCR with the path to your Matlab or MCR installation)"
    echo "near the top of the file"
    echo
    exit 78
  fi
fi

read -d '' usage <<EOF

  svreg_make_atlas : This script creates a new atlas from a given subject

  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: svreg_make_atlas.sh subbasename atlasbasename

  required input:
  subbasename: subject base name
  atlasbasename: name of the atlas

EOF

# Parse inputs
if [ $# -lt 1 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

INFILE=$1;
ATFILE=$2;

shift


FLAGS=
while [ $# -gt 0 ]; do
  token="$1";
  IS_FLAG=`echo "$token" | grep -q '^-' && echo "T"`;
  
  if [ "$IS_FLAG" = "T" ]; then 
    FLAGS="${FLAGS} ${token}";
  fi
  shift
done

# Set up path for MCR applications.
DYLD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/maci64;
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export DYLD_LIBRARY_PATH;
export XAPPLRESDIR;


# Perform volume registration
${exe_dir}/smooth_surf_function.app/Contents/MacOS/svreg_make_atlas "${INFILE}" "${ATFILE}" 
exit
