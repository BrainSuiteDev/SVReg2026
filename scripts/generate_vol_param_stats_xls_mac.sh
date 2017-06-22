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

  generate_vol_param_stats_xls : calculate volumetric and surface stats (svreg)
  This program calculates the mean thickness, grey matter volume, white
  matter volume, CSF volume, total volume, and the cortical area of svreg's
  labeled regions of interest. It then saves the results in a csv file.
  For more information, please see http://brainsuite.org
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: generate_vol_param_stats_xls.sh [subject fileprefix] [flags]

  required input:
  subject fileprefix      path and filename prefix of the subject's output
                          from BrainSuite's Cortical Surface Extraction
                          Sequence
  param_nii_file          File that contains scalar map

  optional flags:
  -v#     Controls the verbosity of output messages (# is 0, 1, or 2)
  -r      Use if svreg sequence was run with refinement

EOF

# Parse inputs
if [ $# -lt 1 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

FILEPREFIX=$1;
shift
PARAM_NII_FILE=$1
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

# Generate stats CSV file
${exe_dir}/generate_vol_param_stats_xls.app/Contents/MacOS/generate_vol_param_stats_xls "${FILEPREFIX}" "${PARAM_NII_FILE}" "${FLAGS}"
exit
