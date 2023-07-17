#!/bin/bash

exe_name=$0
exe_dir=`dirname "$0"`

# If MCR R2023a is installed in a non-default location, define correct path 
# on next line and uncomment it (remove the leading "#")
#BrainSuiteMCR="/path/to/your/MCR";

if [ -z "$BrainSuiteMCR" ]; then
  if [ -e /usr/local/MATLAB/MATLAB_Runtime/R2023a ]; then
    BrainSuiteMCR="/usr/local/MATLAB/MATLAB_Runtime/R2023a";
  elif [ -e /usr/local/MATLAB/R2023a/runtime ]; then
    BrainSuiteMCR="/usr/local/MATLAB/R2023a";
  else
    echo
    echo "Could not find Matlab 2023a with Matlab Compiler or Matlab 2023a (9.0)."
    echo "Please install the Matlab 2023a MCR from MathWorks at:"
    echo
    echo "https://www.mathworks.com/products/compiler/matlab-runtime.html"
    echo 
    echo "If you already have Matlab 2023a with the Matlab Compiler or Matlab 2023a"
    echo "installed, please edit ${exe_name} by uncommenting and editing the line:"
    echo "#BrainSuiteMCR=\"/path/to/your/MCR\";"
    echo "(replacing /path/to/your/MCR with the path to your Matlab or MCR installation)"
    echo "near the top of the file"
    echo
    exit 78
  fi
fi


read -d '' usage <<EOF

  gui_bias_correct.sh : gui bias-field correction (svreg)
  This program allows you to manually correct the bias-field in images that
  require it. It uses the tissue classification results of BrainSuite and
  thus requires the Cortical Extraction Sequence to be run through tissue
  classification.

  For more information, please see 
  http://neuroimage.usc.edu/neuro/Resources/bfc_correction_tool

  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

  usage: gui_bias_correct.sh

EOF

# Parse inputs
if [ $# -gt 0 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

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
$SVREG_EXEC "${exe_dir}"/gui_bias_correct
exit
