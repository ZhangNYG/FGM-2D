fin_save=fopen('SaveAllDate.txt','w');
%获得全部节点坐标
fem_read=fopen('LIST ALL SELECTED NODES.txt','r');
counter=1;
node=[];
buff=fscanf(fem_read,'%s',1);
while ~feof(fem_read)
    if(strcmp(buff,'THZX')==1)              %NODE        X           Y           Z         THXY    THYZ    THZX 数据上第一行最后一个单词
        while(strcmp(buff,'NODE')~=1)   %数据上第一行第一个单词
                buff=fscanf(fem_read,'%s',1);
                if(feof(fem_read)==1)
                    break;
                end;
                if(strcmp(buff,'NODE')~=1)
                            node(counter,1)=str2num(buff);
                            for i =2:3
                                node(counter,i)=fscanf(fem_read,'%f',1);
                            end;
                             for i=1:4
                                dummy=fscanf(fem_read,'%s',1);
                             end;
                            counter=counter+1;
                end;
        end;
    end;
    if(feof(fem_read)==1)
            break;
            end;
buff=fscanf(fem_read,'%s',1);  
end;
[N_node,dummy]=size(node);
fprintf( fin_save,'%d\n',N_node);
zzzz=node;
fprintf( fin_save,'%d   %f  %f\n',node');
fprintf( fin_save,'\n');
fclose(fem_read);
%获得全部单元节点标号
felement_read=fopen('ListNode.txt','r');
counter=1;
element=[];
buff=fscanf(felement_read,'%s',1);
while ~feof(felement_read)
    if(strcmp(buff,'NODES')==1)              %NODE        X           Y           Z         THXY    THYZ    THZX 数据上第一行最后一个单词
        while(strcmp(buff,'ELEM')~=1)   %数据上第一行第一个单词
                buff=fscanf(felement_read,'%s',1);
                if(feof(felement_read)==1)
                    break;
                end;
                if(strcmp(buff,'ELEM')~=1)
                           element(counter,1)=str2num(buff);
                            for i =1:5
                                dummy=fscanf(fem_read,'%s',1);
                            end;
                            for i=2:4
                                element(counter,i)=fscanf(fem_read,'%f',1);
                            end;
                            dummy=fscanf(fem_read,'%s',1);
                            counter=counter+1;
                end;
        end;
    end;
    if(feof(felement_read)==1)
            break;
            end;
buff=fscanf(felement_read,'%s',1);  
end;
[N_element,dummy]=size(element);
fprintf( fin_save,'%d\n',N_element);
fprintf( fin_save,'%d   %d  %d  %d\n',element');
fprintf( fin_save,'\n');
fclose(felement_read);
%获得第一边界条件节点
fnode_1st_read=fopen('1stBC.txt','r');
counter=1;
node_1st=[];
buff=fscanf(fnode_1st_read,'%s',1);
while ~feof(fnode_1st_read)
    if(strcmp(buff,'THZX')==1)              %NODE        X           Y           Z         THXY    THYZ    THZX 数据上第一行最后一个单词
        while(strcmp(buff,'NODE')~=1)   %数据上第一行第一个单词
                buff=fscanf(fnode_1st_read,'%s',1);
                if(feof(fnode_1st_read)==1)
                    break;
                end;
                if(strcmp(buff,'NODE')~=1)
                           node_1st(counter,1)=str2num(buff);
                           
                             for i=1:6
                                dummy=fscanf(fnode_1st_read,'%s',1);
                             end;
                            counter=counter+1;
                end;
        end;
    end;
    if(feof(fnode_1st_read)==1)
            break;
            end;
buff=fscanf(fnode_1st_read,'%s',1);  
end;
[N_node_1st,dummy]=size(node_1st);
fprintf( fin_save,'%d\n',N_node_1st);
fprintf( fin_save,'%d\n',node_1st');
fprintf( fin_save,'\n');
fclose(fnode_1st_read);
%获得第二边界条件节点
fnode_2nd_read=fopen('2ndBC.txt','r');
counter=1;
node_2nd=[];
buff=fscanf(fnode_2nd_read,'%s',1);
while ~feof(fnode_2nd_read)
    if(strcmp(buff,'THZX')==1)              %NODE        X           Y           Z         THXY    THYZ    THZX 数据上第一行最后一个单词
        while(strcmp(buff,'NODE')~=1)   %数据上第一行第一个单词
                buff=fscanf(fnode_2nd_read,'%s',1);
                if(feof(fnode_2nd_read)==1)
                    break;
                end;
                if(strcmp(buff,'NODE')~=1)
                           node_2nd(counter,1)=str2num(buff);
                             for i=1:6
                                dummy=fscanf(fnode_2nd_read,'%s',1);
                             end;
                            counter=counter+1;
                end;
        end;
        
    end;
    if(feof(fnode_2nd_read)==1)
            break;
            end;
buff=fscanf(fnode_2nd_read,'%s',1);  
end;
[N_node_2nd,dummy]=size(node_2nd);
fprintf( fin_save,'%d\n',N_node_2nd);
fprintf( fin_save,'%d\n',node_2nd');
fprintf( fin_save,'\n');
fclose(fnode_2nd_read);
%获得第三边界条件节点
fnode_3th_read=fopen('3thBC.txt','r');
counter=1;
node_3th=[];
buff=fscanf(fnode_3th_read,'%s',1);
while ~feof(fnode_3th_read)
    if(strcmp(buff,'THZX')==1)              %NODE        X           Y           Z         THXY    THYZ    THZX 数据上第一行最后一个单词
        while(strcmp(buff,'NODE')~=1)   %数据上第一行第一个单词
                buff=fscanf(fnode_3th_read,'%s',1);
                if(feof(fnode_3th_read)==1)
                    break;
                end;
                if(strcmp(buff,'NODE')~=1)
                           node_3th(counter,1)=str2num(buff);
                             for i=1:6
                                dummy=fscanf(fnode_3th_read,'%s',1);
                             end;
                            counter=counter+1;
                end;
        end;
    end;
    if(feof(fnode_3th_read)==1)
            break;
            end;
buff=fscanf(fnode_3th_read,'%s',1);  
end;
[N_node_3th,dummy]=size(node_3th);
fprintf( fin_save,'%d\n',N_node_3th);
fprintf( fin_save,'%d\n',node_3th');
fprintf( fin_save,'\n');
fclose(fnode_3th_read);
fclose(fin_save);