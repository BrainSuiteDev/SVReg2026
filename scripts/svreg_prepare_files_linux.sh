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

  prepare_files : set up directory and files for registration sequence (svreg)
  This program copies the required XML, NII, and DFS files from the atlas
  directory to the subject directory for use during the registration process.
  It also generates mid-cortical surfaces, if they are not already present,
  and checks that all other required files are present. If one is missing, it
  displays the name of the missing file.
  For more information, please see http://brainsuite.org
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: prepare_files.sh [subject fileprefix] [atlas fileprefix]

  required input:
  subject fileprefix      path and filename prefix of the subject's output
                          from BrainSuite's Cortical Surface Extraction
                          Sequence
  atlas fileprefix        path and filename prefix of atlas files and labels
                          to which the subject will be registered

EOF

# Parse inputs
if [ $# -lt 2 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

FILEPREFIX=$1;
ATLASPREFIX=$2;

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
$SVREG_EXEC "${exe_dir}"/svreg_prepare_files "${FILEPREFIX}" "${ATLASPREFIX}"

exit
