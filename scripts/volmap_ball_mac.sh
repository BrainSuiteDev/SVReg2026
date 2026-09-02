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

  volmap_ball : map brain volume to the unit ball (svreg)
  This program maps the brain volume to the unit ball to aid in volume
  registration.
  For more information, please see http://brainsuite.org
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: volmap_ball.sh [subject fileprefix] [flags]

  required input:
  subject fileprefix      path and filename prefix of the subject's output
                          from BrainSuite's Cortical Surface Extraction
                          Sequence

  optional flags:
  -v#     Controls the verbosity of output messages (# is 0, 1, or 2)
  -t      display timestamps along with output messages

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


# Create map of brain volume to unit ball
[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/volmap_ball.app/Contents/MacOS/volmap_ball "${FILEPREFIX}" 1 "${FLAGS}"
exit
