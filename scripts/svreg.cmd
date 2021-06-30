@setlocal enableextensions enabledelayedexpansion
@echo off

if "%~1"=="" (
echo. 
echo svreg : surface and volume registration ^(svreg^)
echo   This program registers a subject's BrainSuite-processed volume and surfaces
echo   to an atlas, allowing for automatic labelling of volume and surface ROIs. 
echo   For more information, please see http://brainsuite.org
echo   Authored by Anand A. Joshi, Signal and Image Processing Institute
echo   Department of Electrical Engineering, Viterbi School of Engineering, USC
echo. 
echo   usage: svreg.sh [subject fileprefix] [atlas fileprefix] [flags]
echo. 
echo   required input:
echo   subject fileprefix      path and filename prefix of the subject's output
echo                           from BrainSuite's Cortical Surface Extraction
echo                           Sequence
echo. 
echo   optional input:
echo   atlas fileprefix        path and filename prefix of atlas files and labels
echo                           to which the subject will be registered
echo. 
echo   some optional flags:
echo   -v#     Controls the verbosity of output messages ^(# is 0, 1, or 2^)
echo   -s      Checks if all files necessary for volume registration are present;
echo           if so, skip the surface registration and perform only volume registration
echo   -S      surface registration only
echo   -k      keep the intermediate files after the svreg sequence is complete
echo   -t      display timestamps along with output messages
echo   -U      single threaded mode
echo For the full list, please check http://brainsuite.org/processing/svreg/usage/
echo. 

 	exit /b 0
  )

for %%? in ("%~dp0..") do set SVRegPath=%%~f?
set SVRegBinDir=%~dp0
echo using SVReg in !SVRegPath!

set SubjectFile=%~1
shift

set AtlasFile=!SVRegPath!\BrainSuiteAtlas1\mri.nii.gz

IF NOT "%~1"=="" (
    SET firstChar=%1
    SET firstChar=!firstChar:~0,1!
    ECHO !firstChar!
if NOT "!firstChar!"=="-" (
    set AtlasFile=%~1
    SHIFT
)
)

"!SVRegBinDir!svreg.exe" "!SubjectFile!" "!AtlasFile!" %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b 0
