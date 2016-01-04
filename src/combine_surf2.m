function sur=combine_surf2(s)
vnum=0;sur.faces=[];sur.vertices=[];sur.labels=[];
for kk=1:length(s)
    if isempty(s{kk})
        continue;
    end
    sur.vertices=[sur.vertices;s{kk}.vertices];
  %  sur.labels=[sur.labels;s{kk}.labels];
    sur.faces=[sur.faces;s{kk}.faces+vnum];
    vnum=size(sur.vertices,1);
end
sur1.faces=sur.faces;sur1.vertices=sur.vertices;
 sur=myclean_patch3(sur1);