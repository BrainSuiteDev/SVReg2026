#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2025b is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /usr/local/MATLAB/MATLAB_Runtime/R2025b ]; then
    BrainSuiteMCR="/usr/local/MATLAB/MATLAB_Runtime/R2025b";
  elif [ -e /usr/local/MATLAB/R2025b/runtime ]; then
    BrainSuiteMCR="/usr/local/MATLAB/R2025b";
  else
    echo
    echo "Could not find Matlab 2025b with Matlab Compiler or Matlab 2025b (25.2)."
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

FLG=''
if [ $# -gt 2 ]; then
  echo "Surf Coloring will be done" 
  FLG=$3;
fi

shift


# Set up path for MCR applications.
PATH=${exe_dir}:${PATH} ;
LD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/glnxa64;
MCRJRE=${BrainSuiteMCR}/sys/java/jre/glnxa64/jre/lib/amd64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/native_threads ; 
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/server ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/client ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE} ;  
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export PATH;
export LD_LIBRARY_PATH;
export XAPPLRESDIR;


[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/svreg_make_atlas "${INFILE}" "${ATFILE}" "${FLG}" 

exit
