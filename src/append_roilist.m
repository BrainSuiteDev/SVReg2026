function append_roilist(roilst_file,svreg_version,svreg_build)

S = fileread(roilst_file);
S = sprintf('# SVReg Version: %s\n# SVReg Build: %s\n%s',svreg_version,svreg_build,S);
fid = fopen(roilst_file, 'w');
fwrite(fid, S, 'char');
fclose(fid);

