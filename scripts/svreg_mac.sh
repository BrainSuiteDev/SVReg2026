#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2012a is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /Applications/MATLAB/MATLAB_Compiler_Runtime/v717 ]; then
    BrainSuiteMCR="/Applications/MATLAB/MATLAB_Compiler_Runtime/v717"
  elif [ -e /Applications/MATLAB_R2012a.app/runtime ]; then
    BrainSuiteMCR="/Applications/MATLAB_R2012a.app";  
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

  svreg : surface and volume registration (svreg)
  This program registers a subject's BrainSuite-processed volume and surfaces
  to an atlas, allowing for automatic labelling of volume and surface ROIs. 
  For more information, please see http://brainsuite.org
  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: svregh.sh [subject fileprefix] [atlas fileprefix] [flags]

  required input:
  subject fileprefix      path and filename prefix of the subject's output
                          from BrainSuite's Cortical Surface Extraction
                          Sequence

  optional input:
  atlas fileprefix        path and filename prefix of atlas files and labels
                          to which the subject will be registered

  optional flags:
  -v#     Controls the verbosity of output messages (# is 0, 1, or 2)
  -r      Refine outputs at the expense of more processing time
  -s      Checks if all files necessary for volume registration are present;
          if so, skip the surface registration
  -k      keep the intermediate files after the svreg sequence is complete
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
    FLAGS="${FLAGS} ${token}";
  elif [ -z $ATLASPREFIX ]; then 
    ATLASPREFIX="$token";
  fi
  shift
done

if [ -z $ATLASPREFIX ]; then
  ATLASPREFIX="${exe_dir}/../BrainSuiteAtlas1/mri";
fi

# Set up path for MCR applications.
PATH=${exe_dir}:${PATH} ;
DYLD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/maci64;
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export PATH;
export DYLD_LIBRARY_PATH;
export XAPPLRESDIR;
#FLAGS="${FLAGS}r"
# Run the SVREG Sequence
${exe_dir}/svreg.app/Contents/MacOS/svreg "${FILEPREFIX}" "${ATLASPREFIX}" "${FLAGS}"

exit
