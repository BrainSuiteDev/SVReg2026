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

  smooth_surf_func : This script performs Laplace Beltrami smoothing on cortical surfaces

  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: svreg_smooth_surf_function.sh in_file func_file out_file param

  required input:
  in_file: input surface file
  func_file: surface file with function to be smoothed in .attributes field
  out_surf: output surface file
  param (Optional): smoothing parameter (std dev in mm)

EOF

# Parse inputs
if [ $# -lt 3 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

INFILE=$1;
FUNCFILE=$2;
OUTFILE=$3;
if [ $# -gt 3 ]; then
	PARAM=$4;
else
	PARAM="10"
fi

shift


FLAGS=
while [ $# -gt 0 ]; do
  token="$1";
  IS_FLAG=`echo "$token" | grep -q '^-' && echo "T"`;
  
  if [ "$IS_FLAG" = "T" ]; then 
    FLAGS="$FLAGS${FLAGS:+ }$token"
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


[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/svreg_smooth_surf_function.app/Contents/MacOS/svreg_smooth_surf_function "${INFILE}" "${FUNCFILE}" "${OUTFILE}" "${PARAM}" 
exit
