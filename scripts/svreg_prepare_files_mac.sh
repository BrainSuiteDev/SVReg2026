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
    echo "Could not find Matlab 2015b with Matlab Compiler or MCR 2015b (v9.0)."
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

  prepare_files : set up directory and files for registration sequence (svreg)
  This program copies the required XML, NII, and DFS files from the atlas
  directory to the subject directory for use during the registration process.
  It also generates mid-cortical surfaces, if they are not already present,
  and checks that all required files are present. If one is missing, it
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
DYLD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/maci64;
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export DYLD_LIBRARY_PATH;
export XAPPLRESDIR;

# Prepare files for svreg sequence
${exe_dir}/svreg_prepare_files.app/Contents/MacOS/svreg_prepare_files "${FILEPREFIX}" "${ATLASPREFIX}"
exit
