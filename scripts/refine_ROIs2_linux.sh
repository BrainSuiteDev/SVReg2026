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
    FLAGS="$FLAGS${FLAGS:+ }$token"
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

[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/refine_ROIs2 "${FILEPREFIX}" "${HEMI}" "${FLAGS}"

exit
