function map_isothickness2atlas(subbasename)        

        s=readdfs([subbasename,'.iso-thickness_0-6mm.mid.cortex.dfs']);
        smid=readdfs([subbasename,'.inner.cortex.dfs']);
        %s.attributes(s.attributes>7)=7;
        smidl=readdfs([subbasename,'.left.inner.cortex.svreg.dfs']);
        smidr=readdfs([subbasename,'.right.inner.cortex.svreg.dfs']);
        
        [qq,ind1,ind2]=intersect(smid.vertices,smidl.vertices,'rows','stable');clear I;
        %smid.vertices(ind1(I),:) %same as left of S
        thicknessl=s.attributes(ind1);
        
        [qq,ind1,ind2]=intersect(smid.vertices,smidr.vertices,'rows','stable');clear I;
        %I(ind2)=1:length(ind2);
        %smid.vertices(ind1(I),:) %same as left of S
        thicknessr=s.attributes(ind1);
        pth1=fileparts(subbasename);
        smidltar=readdfs([pth1,'/atlas.left.mid.cortex.svreg.dfs']);
        smidrtar=readdfs([pth1,'/atlas.right.mid.cortex.svreg.dfs']);
        
        
        mapped_thickness_l=mygriddata(smidl.u',smidl.v',thicknessl,smidltar.u',smidltar.v');
        mapped_thickness_r=mygriddata(smidr.u',smidr.v',thicknessr,smidrtar.u',smidrtar.v');
        smidltar.attributes=mapped_thickness_l;        
        smidrtar.attributes=mapped_thickness_r;
        writedfs([pth1,'/atlas_isothickness.left.mid.cortex.svreg.dfs'],smidltar);
        writedfs([pth1,'/atlas_isothickness.right.mid.cortex.svreg.dfs'],smidrtar);
        
        

        