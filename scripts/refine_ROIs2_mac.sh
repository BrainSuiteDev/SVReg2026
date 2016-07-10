#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2015b is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /Applications/MATLAB/MATLAB_Runtime/v90 ]; then
    BrainSuiteMCR="/Applications/MATLAB/MATLAB_Runtime/v90"
  elif [ -e /Applications/MATLAB_R2015b.app/runtime ]; then
    BrainSuiteMCR="/Applications/MATLAB_R2015b.app";  
  else
    echo
    echo "Could not find Matlab 2015b with Matlab Compiler or MCR 2015b (v7.17)."
    echo "Please install the Matlab 2015b MCR from MathWorks at:"
    echo
    echo "http://www.mathworks.com/products/compiler/mcr/"
    echo 
    echo "If you already have Matlab 2015b with the Matlab Compiler or MCR 2015b"
    echo "installed, please edit ${exe_name} by uncommenting and editing the line:"
    echo "#BrainSuiteMCR=\"/path/to/your/MCR\";"
    echo "(replacing /path/to/your/MCR with the path to your Matlab or MCR installation)"
    echo "near the top of the file"
    echo
    exit 78
  fi
fi

read -d '' usage <<EOF

  refine_ROIs2 : refine ROI boundaries of given hemisphere (svreg)
  This program refines the ROI boundaries using the geodesic curvature flow. 
  The ROI boundaries are modified such that they conform to the underlying 
  anatomical curvatures. The surfaces are then recolored according to the labels.
  For more information, please see http://brainsuite.org
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: refine_ROIs2.sh [subject fileprefix] [hemi] [flags]

  required input:
  subject fileprefix      path and filename prefix of the subject's output
                          from BrainSuite's Cortical Surface Extraction
                          Sequence
  hemi                    the hemisphere to refine; either left or right

  optional flags:
  -v#     Controls the verbosity of output messages (# is 0, 1, or 2)
  -t      display timestamps along with output messages

EOF

# Parse inputs
if [ $# -lt 2 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

FILEPREFIX=$1;
shift

HEMI=$1;
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

# Run ROI refinement
${exe_dir}/refine_ROIs2.app/Contents/MacOS/refine_ROIs2 "${FILEPREFIX}" "${HEMI}" "${FLAGS}"
exit
