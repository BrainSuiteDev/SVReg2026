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
    echo "Could not find Matlab 2023a with Matlab Compiler or Matlab 2023a (9.14)."
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
  datatype: 	[OPTIONAL] data type of output file. default is same as input_file
  bitpix: 	[OPTIONAL] bitpix of output file. default is same as input_file
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
$SVREG_EXEC "${exe_dir}"/svreg_apply_map "${MAPFILE}" "${DATAFILE}" "${OUTFILE}" "${TARFILE}" "${SMOOTHNESS}" "${DATATYPE}" "${BITPIX}" "${INTERP}" 

exit
