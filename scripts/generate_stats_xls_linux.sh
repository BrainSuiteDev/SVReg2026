#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2012a is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /usr/local/MATLAB/MATLAB_Compiler_Runtime/v717 ]; then
    BrainSuiteMCR="/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717";
  elif [ -e /usr/local/MATLAB/R2012a/runtime ]; then
    BrainSuiteMCR="/usr/local/MATLAB/R2012a";
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

  generate_stats_xls : calculate volumetric and surface stats (svreg)
  This program calculates the mean thickness, grey matter volume, white
  matter volume, CSF volume, total volume, and the cortical area of svreg's
  labeled regions of interest. It then saves the results in a csv file.
  For more information, please see http://brainsuite.org
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: generate_stats_xls.sh [subject fileprefix] [flags]

  required input:
  subject fileprefix      path and filename prefix of the subject's output
                          from BrainSuite's Cortical Surface Extraction
                          Sequence

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
LD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/glnxa64;
MCRJRE=${BrainSuiteMCR}/sys/java/jre/glnxa64/jre/lib/amd64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/native_threads ; 
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/server ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/client ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE} ;  
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export LD_LIBRARY_PATH;
export XAPPLRESDIR;

# Generate stats CSV file
${exe_dir}/generate_stats_xls "${FILEPREFIX}" "${FLAGS}"

exit
