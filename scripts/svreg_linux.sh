#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2015b is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /usr/local/MATLAB/MATLAB_Runtime/v90 ]; then
    BrainSuiteMCR="/usr/local/MATLAB/MATLAB_Runtime/v90";
  elif [ -e /usr/local/MATLAB/R2015b/runtime ]; then
    BrainSuiteMCR="/usr/local/MATLAB/R2015b";
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

  some optional flags:
  -v#     Controls the verbosity of output messages (# is 0, 1, or 2)
  -s      Checks if all files necessary for volume registration are present;
          if so, skip the surface registration and perform only volume registration
  -S      surface registration only
  -k      keep the intermediate files after the svreg sequence is complete
  -t      display timestamps along with output messages
  -U      singlethreaded mode
For the full list, please check http://brainsuite.org/processing/svreg/usage/
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


# Run the SVREG Sequence
#FLAGS="${FLAGS}r"
${exe_dir}/svreg "${FILEPREFIX}" "${ATLASPREFIX}" "${FLAGS}"

exit
