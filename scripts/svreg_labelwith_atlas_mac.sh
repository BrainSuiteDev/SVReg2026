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

  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

 Description:
 This function creates labels using a different atlas. This function works 
 only for BCI-DNI, USCBrain and USCLobes atlases. Since the underlying 
 anatomy is the same, you can process data using one brain and use it with 
 another one

 Usage:
 svreg_labelwith_atlas.sh subbasename atlasbasename postfix
 
 three arguments are required

 Arguments:
 subbasename: subject basename
 atlasbasename: atlas basename
 postfix: postfix


EOF

# Parse inputs
if [ $# -lt 3 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi


shift



# Set up path for MCR applications.
DYLD_LIBRARY_PATH=.:${BrainSuiteMCR}/runtime/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/bin/maci64 ;
DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${BrainSuiteMCR}/sys/os/maci64;
XAPPLRESDIR=${BrainSuiteMCR}/X11/app-defaults ;
export DYLD_LIBRARY_PATH;
export XAPPLRESDIR;


[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/svreg_labelwith_atlas.app/Contents/MacOS/svreg_labelwith_atlas "$@" 

exit
