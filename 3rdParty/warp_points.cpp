// Copyright (c) 2017, The Regents of the University of California and the University of Southern California
// Created by Anand A. Joshi and David W. Shattuck
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <iostream>

extern "C" {
// defined in AIR.h
typedef int AIR_Error;
typedef int AIR_Boolean;
void AIR_report_error(const AIR_Error errornumber);
AIR_Error AIR_do_reslice_unwarp_ucf(const char *warpfile, const char *ucf_in,
                                    const char *ucf_out, const signed int parity,
                                    AIR_Boolean strict, AIR_Boolean ow);
}

int main(int argc, char *argv[])
{
  if(argc<4)
  {
    std::cout<<"Usage: "<<argv[0]<<" .warp_file ucf_in ucf_out\n"<<std::endl;
    return 1;
	}	
  const char *warpfile(argv[1]);
  const char *ucfIn(argv[2]);
  const char *ucfOut(argv[3]);
  AIR_Error errcode=AIR_do_reslice_unwarp_ucf(warpfile, ucfIn, ucfOut, 1, 1, 1);
  if (errcode!=0)
  {
    AIR_report_error(errcode);
    return 1;
  }
  return 0;
}

