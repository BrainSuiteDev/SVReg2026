function svreg_thickness2atlas(subbase)
% map thickness to atlas

subbase = remove_extn_basename(subbase);

[pth,subname,extt] = fileparts(subbase);
if isempty(pth)
    pth=pwd();
    subbase=fullfile(pth,subname,extt);
end


%% Output a log
logfname=[subbase,'.thickness.log'];
fp=fopen(logfname,'a+');
t = datestr(datetime('now'));
fprintf(fp,'%s:',t);
[svreg_version,svreg_build] = get_svreg_version(subbase);
fprintf(fp,'SVReg %s(%s):',svreg_version,svreg_build);

fprintf(fp,'svreg_thickness2atlas %s ',subbase);
fprintf(fp,'\n');

fclose(fp);
%%

inner_l = readdfs([subbase, '.left.inner.cortex.svreg.dfs']);
mid_l = readdfs([subbase, '.pvc-thickness_0-6mm.left.mid.cortex.dfs']);
tar_l = readdfs(fullfile(fileparts(subbase), 'atlas.left.mid.cortex.svreg.dfs'));

inner_r = readdfs([subbase, '.right.inner.cortex.svreg.dfs']);
mid_r = readdfs([subbase, '.pvc-thickness_0-6mm.right.mid.cortex.dfs']);
tar_r = readdfs(fullfile(fileparts(subbase), 'atlas.right.mid.cortex.svreg.dfs'));


tar_l.attributes=map_data_flatmap(inner_l,mid_l.attributes,tar_l);
tar_r.attributes=map_data_flatmap(inner_r,mid_r.attributes,tar_r);
tar_l = colorDFS(tar_l, tar_l.attributes, [0 6], jet(256));
tar_r = colorDFS(tar_r, tar_r.attributes, [0 6], jet(256));
tar_l=smooth_cortex_fast(tar_l,.5,2000);
tar_r=smooth_cortex_fast(tar_r,.5,2000);
writedfs(fullfile(fileparts(subbase), 'atlas.pvc-thickness_0-6mm.left.mid.cortex.dfs'),tar_l);
writedfs(fullfile(fileparts(subbase), 'atlas.pvc-thickness_0-6mm.right.mid.cortex.dfs'),tar_r);


