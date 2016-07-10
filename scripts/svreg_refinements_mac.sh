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

  svreg_refinements : Refine maps and volumetric labels (svreg)
  This program refines the maps and volumetric labels based on refined
  surface labels. It also checks and corrects the topology of volumetric
  and surface-based ROIs.
  For more information, please see http://brainsuite.org
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: svreg_refinements.sh [subject fileprefix] [atlas fileprefix] [flags]

  required input:
  subject fileprefix      path and filename prefix of the subject's output
                          from BrainSuite's Cortical Surface Extraction
                          Sequence
  atlas fileprefix        path and filename prefix of atlas files and labels
                          to which the subject will be registered

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

ATLASPREFIX=$1;
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


# Refine volume labels
${exe_dir}/svreg_refinements.app/Contents/MacOS/svreg_refinements "${FILEPREFIX}" "${ATLASPREFIX}" "${FLAGS}"
exit
