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
    echo "Could not find Matlab 2025b with Matlab Compiler or Matlab 2025b (v25.2)."
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


  svreg_apply_map : This script applies map to data

  Authored by Anand A. Joshi, Signal and Image Processing Institute
  Department of Electrical Engineering, Viterbi School of Engineering, USC

USAGE:
svreg_apply_map.sh map_file data_file out_file target_file [smoothness] [datatype] [bitpix] [interp_type]

  input:
  map_file: 	file containing deformation map to be applied
  data_file: 	data file to be warped. This can be scalar data like FA or .eig. file containing tensors
  out_file: 	output file containing warped data
  target_file: 	target image file for copying header. typically contains bfc image of the target
  smoothness: 	[OPTIONAL] stddev of gaussian smoothing of deformation in voxels for accurate  computation in of derivatives. default is 1.
  datatype: 	[OPTIONAL] data type of output file. default is float32
  bitpix: 	[OPTIONAL] bitpix of output file. default is float32
  interp_type: 	[OPTIONAL] default is 'nearest'

EOF

# Parse inputs
if [ $# -lt 1 ]; then
  echo
  echo "$usage";
  echo
  exit;
fi

MAPFILE=$1;
DATAFILE=$2;
OUTFILE=$3;
TARFILE=$4;
if [ $# -gt 4 ]; then
	SMOOTHNESS=$5;
else
	SMOOTHNESS="1"
fi

if [ $# -gt 5 ]; then
	DATATYPE=$6;
else
	DATATYPE="16"
fi

if [ $# -gt 6 ]; then
	BITPIX=$7;
else
	BITPIX="32"
fi

if [ $# -gt 7 ]; then
	INTERP=$8;
else
	INTERP="nearest"
fi
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


[[ "$SVREG_EXEC" != "exec" ]] &&  SVREG_EXEC=;
$SVREG_EXEC "${exe_dir}"/svreg_apply_map.app/Contents/MacOS/svreg_apply_map "${MAPFILE}" "${DATAFILE}" "${OUTFILE}" "${TARFILE}" "${SMOOTHNESS}" "${DATATYPE}" "${BITPIX}" "${INTERP}" 
exit
