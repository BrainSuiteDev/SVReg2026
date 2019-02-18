% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2019 The Regents of the University of California and the University of Southern California
% Created by Anand A. Joshi, Chitresh Bhushan, David W. Shattuck, Richard M. Leahy 
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; version 2.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
% USA.



function writedfc(fname,Curves,fprotocol)
% function writedfc(fname,Curves,fprotocol)
% 
% Writes curves in a dfc brainsuite file
%
% INPUT:
%   fname: the name of the curve file to be saved (*.dfc)
%   Curves: a structure with the curves
%   fprotocol: the file containing the protocol for the curves
%
%
% Authors: Anand A. Joshi, Dimitrios Pantazis
% Reads curves from DFC files
%disp(sprintf('saved xml file in the same dir as dfc file...'));


%open protocol file to get curve names
fid=fopen(fprotocol,'rb','ieee-le');

if (fid<0) 
    error('Unable to read:%s',fprotocol);
end

Mdata = char(fread(fid,'char'));
fclose(fid);


%write curve file
fid=fopen(fname,'wb','ieee-le');
if (fid<0) 
    error('Unable to open file %s in write mode',fname);    
end

hdr.magic = ['D' 'F' 'C' 'L' 'E' '\' '0' '0']'; %['L' 'O' 'N' 'I' 'D' 'F' 'C' ' ']';
hdr.version=[0,0,0,2]';
hdr.hdrsize=32;
hdr.mdoffset=36;
hdr.dataStart=length(Mdata)+hdr.mdoffset;
hdr.pdoffset=-1;
hdr.nContours=length(Curves);

fwrite(fid,hdr.magic,'char');
fwrite(fid,hdr.version,'char');
fwrite(fid,hdr.hdrsize,'int32');
fwrite(fid,hdr.dataStart,'int32');
fwrite(fid,hdr.mdoffset,'int32');
fwrite(fid,hdr.pdoffset,'int32');
fwrite(fid,hdr.nContours,'int32');
fwrite(fid,hdr.nContours,'int32');
%fseek(fid,hdr.mdoffset,'bof');

fwrite(fid,Mdata,'char');
%fseek(fid,hdr.dataStart,'bof');
for ctno=1:length(Curves)
    nopts = size(Curves{ctno},1);
    fwrite(fid,nopts,'int32');
    fwrite(fid,Curves{ctno}','float');
end

fclose(fid);


