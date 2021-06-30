function sc=close_surf(s)
%tic
so=s;
tr=triangulation(s.faces,s.vertices);
bd=tr.freeBoundary;%bd=flipud([bd;bd(1,:)]);
%toc
% vertConn=vertices_connectivity_fast(s);
%
% surf1facesConn=faces2faces_connectivity(s,vertConn);
%
% boundary1 = boundary_vertices(s,vertConn,surf1facesVConn,surf1facesConn);
%
% bd=trace_boundary(bd(1,1),vertConn,s)

%hold on;line(s.vertices(bd(:,1),1),s.vertices(bd(:,1),2),s.vertices(bd(:,1),3))

varx(1)=var(s.vertices(bd(:,1),1));varx(2)=var(s.vertices(bd(:,1),2));varx(3)=var(s.vertices(bd(:,1),3));
[~,a]=min(varx);
vvv=[s.vertices(bd(:,1),1),s.vertices(bd(:,1),2),s.vertices(bd(:,1),3)];vvv1=vvv;
%vvv1=[so.vertices(bd(:,1),1),so.vertices(bd(:,1),2),so.vertices(bd(:,1),3)];

vvv(:,a)=[];
vvv(end,:)=[];
DT=delaunayTriangulation(vvv,[[1:length(vvv)]',[2:length(vvv),1]']);

cc.faces=DT.ConnectivityList(isInterior(DT),:);
%cc.faces=[cc.faces(:,2),cc.faces(:,1),cc.faces(:,3)];
[~,ia,ib]=intersect(vvv,DT.Points,'rows','stable');

cc.vertices=[mean(s.vertices(bd(:,1),a))*ones(length(DT.Points),1),DT.Points];
cc.vertices(ia,1)=[vvv1(1:end-1,1)];

%view_patch(cc);
ss{1}=s;ss{2}=cc;
sc=combine_surf1(ss);

[~,~,ia]=intersect(s.vertices,sc.vertices,'rows','stable');
std_thrc=zeros(length(sc.vertices),1);
std_thrc(ia)=so.attributes;
sc.attributes=std_thrc;


function sur=combine_surf1(s)
vnum=0;sur.faces=[];sur.vertices=[];sur.labels=[];
for kk=1:length(s)
    sur.vertices=[sur.vertices;s{kk}.vertices];
    %    sur.labels=[sur.labels;s{kk}.labels];
    sur.faces=[sur.faces;s{kk}.faces+vnum];
    vnum=size(sur.vertices,1);
end
sur1.faces=sur.faces;sur1.vertices=sur.vertices;
sur=myclean_patch3(sur1);