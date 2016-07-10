% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2016 The Regents of the University of California and the University of Southern California
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



function [Curves,hdr]=readdfc_sipi(fname)
% Author Anand A. Joshi
% Reads curves from DFC files
%disp(sprintf('saved xml file in the same dir as dfc file...'));

fid=fopen(fname,'rb','ieee-le');
if (fid<0) 
    error('Unable to read:%s',fname);
end
% if (fid<0) 
%     error('unable to open file'); 
% end;

%hdr.magic = ['D' 'U' 'F' 'F' 'S' 'U' 'R' 'F']';

hdr.magic=char(fread(fid,8,'char')); %#ok<FREAD>
hdr.version=fread(fid,4,'char');
hdr.hdrsize=fread(fid,1,'int32');
hdr.dataStart=fread(fid,1,'int32');
hdr.mdoffset=fread(fid,1,'int32');
hdr.pdoffset=fread(fid,1,'int32');
hdr.nContours=fread(fid,1,'int32');

fseek(fid,hdr.mdoffset,'bof');
hdr.Mdata=char(fread(fid,hdr.dataStart-hdr.mdoffset,'char')); %#ok<FREAD,NASGU>
%if exist([fname(1:end-4),'.xml'],'file')
%    delete([fname(1:end-4),'.xml']);
%end
%fod=fopen([fname(1:end-4),'.xml'],'w','ieee-le');
%fprintf(fod,Mdata);
%fclose(fod);

fseek(fid,hdr.dataStart,'bof');
Curves = cell(hdr.nContours,1); % one empty cell per curve
for ctno=1:hdr.nContours
    nopts=fread(fid,1,'int32');
    XYZ=fread(fid,3*nopts,'float');
    XYZ=(reshape(XYZ,3,nopts))';
    Curves{ctno}=XYZ;
end


fclose(fid);

if length(Curves)==28
    disp1(sprintf('The file %s is traced using 28 curve protocol',fname));
    Curves2 = cell(26,1); % one empty cell per curve
    for cnum=1:25
        Curves2{cnum}=Curves{cnum};
    end
    for cnum=15:26
        Curves2{cnum}=Curves{cnum+1};
    end
if exist([fname(1:end-4),'.xml'],'file')
    delete([fname(1:end-4),'.xml']);
end
fod=fopen([fname(1:end-4),'.xml'],'w','ieee-le');
fprintf(fod,Mdata);
fclose(fod);
    
    writedfc([fname(1:end-4),'26.dfc'],Curves2,[fname(1:end-4),'.xml']);
    Curves=Curves2;
%elseif length(Curves)==26
%    disp1(sprintf('The file %s is traced using 26 curve protocol',fname));
end

%Curves=orderCurves([fname(1:end-4),'.xml'],Curves);
