function  FGM_2D( file_in )
% 本程序稳态温度场2016年5月5日晚上九点完稿
%      2D-FGM( filename )
%  输入参数： 
%      file_in  ---------- 有限元模型文件

% 定义全局变量
%      gNode ------------- 节点坐标
%      gElement ---------- 单元定义
%      gK ---------------- 整体刚度矩阵
%      gDelta ------------ 整体节点坐标
%      gNodeStress ------- 节点应力
%      gElementStress ---- 单元应力
%      gnode_1st-----------第一边界节点号
%      gnode_2nd-----------第二边界节点号
%      gnode_3th-----------第三边界节点号

    global gNode gElement  gK gP TDelta  gnode_1st gnode_2nd gnode_3th

    if nargin < 1
        file_in = 'SaveAllDate.txt' ;
    end
    
        % 建立有限元模型并求解，保存结果
        FemModel( file_in ) ;          % 定义有限元模型
        [element_number,dummy] = size( gElement );      %取出单元总个数
        for   ie=1:1:element_number 
        gElementTurn(ie);               %转换单元节点号数组数据，让其复合第一二三类边界条件jm边在边界的规则
        end
        TTT=SolveModel ;                   % 求解有限元模型
% 计算结束
%     disp( sprintf( '计算正常结束，结果保存在文件 %s 中', file_out ) ) ;
%     disp( sprintf( '可以使用后处理程序 exam4_2_post.m 显示计算结果' ) ) ;
return

function FemModel(filename)
%  定义有限元模型
%  输入参数：
%      filename --- 有限元模型文件
%  返回值：
%      无
%  说明：
%      该函数定义平面问题的有限元模型数据：
%        gNode ------- 节点定义
%        gElement ---- 单元定义
%        gMaterial --- 材料定义，包括弹性模量，梁的截面积和梁的抗弯惯性矩
%        gBC1 -------- 约束条件

    global gNode gElement  gBC1 gnode_1st gnode_2nd gnode_3th
    
    % 打开文件
    fid = fopen( filename, 'r' ) ;
    
    % 读取节点坐标
    node_number = fscanf( fid, '%d', 1 ) ;
    gNode = zeros( node_number, 2 ) ;
    for i=1:node_number
        dummy = fscanf( fid, '%d', 1 ) ;
        gNode( i, : ) = fscanf( fid, '%f', [1, 2] ) ;
    end
    
    % 读取单元定义
    element_number = fscanf( fid, '%d', 1 ) ;
    gElement = zeros( element_number, 3 ) ;
    for i=1:element_number
        dummy = fscanf( fid, '%d', 1 ) ;
        gElement( i, : ) = fscanf( fid, '%d', [1, 3] ) ;
    end
    %读取第一类边界节点
    Nnode_1st = fscanf( fid, '%d', 1 ) ;
    gnode_1st = zeros( Nnode_1st, 1 ) ;
    for i=1:Nnode_1st
        
        gnode_1st( i ) = fscanf( fid, '%d', 1) ;
    end
    %读取第二类边界节点
    Nnode_2nd = fscanf( fid, '%d', 1 ) ;
    gnode_2nd = zeros( Nnode_2nd, 1 ) ;
    for i=1:Nnode_2nd
        
        gnode_2nd( i ) = fscanf( fid, '%d', 1) ;
    end
    %读取第三类边界节点
    Nnode_3th = fscanf( fid, '%d', 1 ) ;
    gnode_3th = zeros( Nnode_3th, 1 ) ;
    for i=1:Nnode_3th
        
        gnode_3th( i ) = fscanf( fid, '%d', 1) ;
    end
  
   
    % 关闭文件
    fclose( fid ) ;
return


function TTT=SolveModel
%  求解有限元模型
%  输入参数：
%     无
%  返回值：
%     无
%  说明：
%      该函数求解有限元模型，过程如下
%        1. 计算单元刚度矩阵，集成整体刚度矩阵
%        2. 计算单元的等效节点力，集成整体节点力向量
%        3. 处理约束条件，修改整体刚度矩阵和节点力向量
%        4. 求解方程组，得到整体节点位移向量
%        5. 计算单元应力和节点应力

    global gNode gElement  gBC1 gK gP TDelta   gnode_1st gnode_2nd gnode_3th
    fidoutdate = fopen( 'Outdate.txt', 'w' ) ;

    % step1. 定义整体刚度矩阵和节点力向量
    [node_number,dummy] = size( gNode ) ;
    gK = sparse( node_number , node_number ) ;
    gP = sparse( node_number , 1 ) ;

    % step2. 计算单元刚度矩阵，并集成到整体刚度矩阵中
    [element_number,dummy] = size( gElement ) ;
    for ie=1:1:element_number
        disp( sprintf(  '计算刚度矩阵，当前单元: %d', ie  ) ) ;
        k = StiffnessMatrix( ie ) ;
        AssembleStiffnessMatrix( ie, k ) ;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %计算右侧列向量 P
%     function p = PonclusionP(ie)
    for ie=1:1:element_number
        disp( sprintf(  '计算右侧列向量 P，当前单元: %d', ie  ) ) ;
        p = PonclusionP(ie) ;
        AssembleP( ie, p) ;
    end
     % %     % step4. 处理约束条件，修改刚度矩阵和节点力向量。采用乘大数法 
        [bc_number,dummy] = size( gnode_1st ) ;
         for ibc=1:1:bc_number
             n = gnode_1st (ibc, 1 ) ;
         
             gP(n) = 300* gK(n,n) * 1e12 ;%引入边界温度此处为常量300K                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%第一类边界温度量
             gK(n,n) = gK(n,n) * 1e12;
         end
    % step 5. 求解方程组，得到节点温度数组
    TDelta = gK \ gP ;
    TTT=full(TDelta);
    TTT=TTT';
    
    fprintf( fidoutdate,'%f\n',TTT );
    fclose(fidoutdate);
 
return









function gElementTurn(ie)   %转换单元节点号数组数据，让其复合第一二三类边界条件jm边在边界的规则
        global  gElement gNode gnode_1st gnode_2nd gnode_3th%定义全局变量
        [NgElement,dummy] = size( gElement ) ;
        [Nnode_1st,dummy] = size( gnode_1st ) ;  %取出第一类边界节点号的个数
        [Nnode_2nd,dummy] = size( gnode_2nd ) ;  %取出第二类边界节点号的个数
        [Nnode_3th,dummy] = size( gnode_3th) ;  %取出第三类边界节点号的个数
        %判断是否为第一类边界单元  如果是第一类边界单元，那么单元上必须有两个节点在第一类边界节点中那么m为2；   
        m=0;
        for i=1:3
            for j=1:Nnode_1st
               if(gElement( ie, i )==gnode_1st(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                   %判断那个两个节点为j，m
                    m=0;
                    for i=1:3
                          for j=1:Nnode_1st
                           if(gElement( ie, i )==gnode_1st(j))
                               m=m+1;
                               if(m==1)
                                   j_1st=gElement( ie, i );
                               end
                               if(m==2)
                                   m_1st=gElement( ie, i );
                               end
                           end
                        end
                    end
                    %判断其中为i的点
                    for i=1:3
                        if(~(gElement( ie, i )==j_1st|m_1st==gElement( ie, i )))
                            i_1st=gElement( ie, i );
                        end
                    end
                     gElement( ie, 1 )=i_1st;
                     gElement( ie, 2 )=j_1st;
                     gElement( ie, 3 )=m_1st;
        end
        %判断是否为第二类边界单元  如果是第二类边界单元，那么单元上必须有两个节点在第二类边界节点中那么m为2；   
        m=0;
        for i=1:3
            for j=1:Nnode_2nd
               if(gElement( ie, i )==gnode_2nd(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                   %判断那个两个节点为j，m
                    m=0;
                    for i=1:3
                          for j=1:Nnode_2nd
                           if(gElement( ie, i )==gnode_2nd(j))
                               m=m+1;
                               if(m==1)
                                   j_2nd=gElement( ie, i );
                               end
                               if(m==2)
                                   m_2nd=gElement( ie, i );
                               end
                           end
                        end
                    end
                    %判断其中为i的点
                    for i=1:3
                        if(~(gElement( ie, i )==j_2nd|m_2nd==gElement( ie, i )))
                            i_2nd=gElement( ie, i );
                        end
                    end
                     gElement( ie, 1 )=i_2nd;
                     gElement( ie, 2 )=j_2nd;
                     gElement( ie, 3 )=m_2nd;
        end
                %判断是否为第三类边界单元  如果是第三类边界单元，那么单元上必须有两个节点在第三类边界节点中那么m为2；   
        m=0;
        for i=1:3
            for j=1:Nnode_3th
               if(gElement( ie, i )==gnode_3th(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                   %判断那个两个节点为j，m
                    m=0;
                    for i=1:3
                          for j=1:Nnode_3th
                           if(gElement( ie, i )==gnode_3th(j))
                               m=m+1;
                               if(m==1)
                                   j_3th=gElement( ie, i );
                               end
                               if(m==2)
                                   m_3th=gElement( ie, i );
                               end
                           end
                        end
                    end
                    %判断其中为i的点
                    for i=1:3
                        if(~(gElement( ie, i )==j_3th|m_3th==gElement( ie, i )))
                            i_3th=gElement( ie, i );
                        end
                    end
                     gElement( ie, 1 )=i_3th;
                     gElement( ie, 2 )=j_3th;
                     gElement( ie, 3 )=m_3th;
        end
    


return











function k = StiffnessMatrix( ie )
%  计算单元刚度矩阵
%  输入参数:
%     ie ----  单元号
%  返回值:
%     k  ----  单元刚度矩阵
  
    
    global gNode gnode_3th gElement %gMaterial 
   
    [Nnode_3th,dummy] = size( gnode_3th ) ; %取出第三类边界节点号的个数
%判断是否为第三类边界单元  如果是第三类边界单元，那么单元上必须有两个节点在第三类边界节点中那么m为2；
    m=0;
    for i=1:3
        for j=1:Nnode_3th
           if(gElement( ie, i )==gnode_3th(j))
               m=m+1;
               
           end
        end
    end
%如果判断为第三类边界条件进入下面程序段
    if(m==2)
                
                
                 k = zeros( 6, 6 ) ;
            %    E  = gMaterial( gElement(ie, 4), 1 ) ;
            %   mu = gMaterial( gElement(ie, 4), 2 ) ;
            %    h  = gMaterial( gElement(ie, 4), 3 ) ;
                xi = gNode( gElement( ie, 1 ), 1 ) ;
                yi = gNode( gElement( ie, 1 ), 2 ) ;
                xj = gNode( gElement( ie, 2 ), 1 ) ;
                yj = gNode( gElement( ie, 2 ), 2 ) ;
                xm = gNode( gElement( ie, 3 ), 1 ) ;
                ym = gNode( gElement( ie, 3 ), 2 ) ;
                xaverage=(xi+xj+xm)/3;
                yaverage=(yi+yj+ym)/3;
                
            %计算导热系数在这导热系数c=d=0.1，
               % kconduct=exp(xaverage*0.1+yaverage*0.1);
               %ansys验证
              % kconduct=1;%热导率
               kconduct=10*exp(xaverage*10+yaverage*10);%c=d=0.1时
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%导热率
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    k=D*exp(cx+dy)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    D=1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%()
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% kconduct=exp(xaverage*0.1+yaverage*0.1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%kconduct=exp(xaverage*0.1+yaverage*0.1);

                ai = xj*ym - xm*yj ;
                aj = xm*yi - xi*ym ;
                am = xi*yj - xj*yi ;
                bi = yj - ym ;
                bj = ym - yi ;
                bm = yi - yj ;
                ci = -(xj-xm) ;
                cj = -(xm-xi) ;
                cm = -(xi-xj) ;
                area = ElementArea( ie ) ;
                fi=kconduct/area/4; %fi为系数Φ
                k=zeros(3,3);
                %si为jm边长
                si=sqrt(bi^2+ci^2);
                %hcon为换热系数
                hcon=10*exp(10*((xj+xm)/2)) %h%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%上边界换热系数函数变化h0=1，h=h0exp(cx)
                k(1,1)=fi*(bi^2+ci^2);
                k(2,2)=fi*(bj^2+cj^2)+hcon*si/3;
                k(3,3)=fi*(bm^2+cm^2)+hcon*si/3;
                k(1,2)=fi*(bi*bj+ci*cj);
                k(2,1)=fi*(bi*bj+ci*cj);
                k(1,3)=fi*(bi*bm+ci*cm);
                k(3,1)=fi*(bi*bm+ci*cm);
                k(2,3)=fi*(bj*bm+cj*cm)+hcon*si/6;
                k(3,2)=fi*(bj*bm+cj*cm)+hcon*si/6;

                   
    end
    %如果非第三类边界单元进入下程序段
    if(m<2)
    k = zeros( 6, 6 ) ;
%    E  = gMaterial( gElement(ie, 4), 1 ) ;
%   mu = gMaterial( gElement(ie, 4), 2 ) ;
%    h  = gMaterial( gElement(ie, 4), 3 ) ;
    xi = gNode( gElement( ie, 1 ), 1 ) ;
    yi = gNode( gElement( ie, 1 ), 2 ) ;
    xj = gNode( gElement( ie, 2 ), 1 ) ;
    yj = gNode( gElement( ie, 2 ), 2 ) ;
    xm = gNode( gElement( ie, 3 ), 1 ) ;
    ym = gNode( gElement( ie, 3 ), 2 ) ;
    xaverage=(xi+xj+xm)/3;
    yaverage=(yi+yj+ym)/3;
%计算导热系数在这导热系数c=d=0.1，
   % kconduct=exp(xaverage*0.1+yaverage*0.1);
     %kconduct=1;%热导率%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%导热率
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     k=exp(cx +dy)
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     kconduct=10*exp(xaverage*10+yaverage*10);%c=d=0.1时
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ai = xj*ym - xm*yj ;
    aj = xm*yi - xi*ym ;
    am = xi*yj - xj*yi ;
    bi = yj - ym ;
    bj = ym - yi ;
    bm = yi - yj ;
    ci = -(xj-xm) ;
    cj = -(xm-xi) ;
    cm = -(xi-xj) ;
    area = ElementArea( ie );
    fi=kconduct/area/4;
    k=zeros(3,3);
    k(1,1)=fi*(bi^2+ci^2);
    k(2,2)=fi*(bj^2+cj^2);
    k(3,3)=fi*(bm^2+cm^2);
    k(1,2)=fi*(bi*bj+ci*cj);
    k(2,1)=fi*(bi*bj+ci*cj);
    k(1,3)=fi*(bi*bm+ci*cm);
    k(3,1)=fi*(bi*bm+ci*cm);
    k(2,3)=fi*(bj*bm+cj*cm);
    k(3,2)=fi*(bj*bm+cj*cm);
    end
 %   B = [bi  0 bj  0 bm  0
 %         0 ci  0 cj  0 cm
 %        ci bi cj bj cm bm] ;
 %   B = B/2/area ;
 %   D = [ 1-mu    mu      0
 %          mu    1-mu     0
 %           0      0   (1-2*mu)/2] ;
 %   D = D*E/(1-2*mu)/(1+mu) ;
 %  k = transpose(B)*D*B*h*abs(area) ;    
return



function area = ElementArea( ie )
%  计算单元面积
%  输入参数:
%     ie ----  单元号
%  返回值:
%     area  ----  单元面积
    global gNode gElement gMaterial 

    xi = gNode( gElement( ie, 1 ), 1 ) ;
    yi = gNode( gElement( ie, 1 ), 2 ) ;
    xj = gNode( gElement( ie, 2 ), 1 ) ;
    yj = gNode( gElement( ie, 2 ), 2 ) ;
    xm = gNode( gElement( ie, 3 ), 1 ) ;
    ym = gNode( gElement( ie, 3 ), 2 ) ;
    ai = xj*ym - xm*yj ;
    aj = xm*yi - xi*ym ;
    am = xi*yj - xj*yi ;
    area = abs((ai+aj+am)/2)  ;
return

function AssembleStiffnessMatrix( ie, k )
%  把单元刚度矩阵集成到整体刚度矩阵
%  输入参数:
%      ie  --- 单元号
%      k   --- 单元刚度矩阵
%  返回值:
%      无
    global gElement gK
    for i=1:1:3
        for j=1:1:3               
                    M = gElement(ie,i) ;
                    N = gElement(ie,j) ;
                    gK(M,N) = gK(M,N) + k(i,j) ;                
        end
    end
return

%计算P列向量函数
function p = PonclusionP(ie )   
%      ie  ----- 单元号
         global   gElement gNode   gnode_1st  gnode_2nd   gnode_3th
         p=zeros(3,1);
         for i=1:3
            p(i,1)=0;%p矩阵初始化
         end
         [Nnode_1st,dummy] = size( gnode_1st ) ;  %取出第一类边界节点号的个数
         [Nnode_2nd,dummy] = size( gnode_2nd ) ;  %取出第二类边界节点号的个数
         [Nnode_3th,dummy] = size( gnode_3th) ;  %取出第三类边界节点号的个数         
         %判断是否为第一类边界单元  如果是第一类边界单元，那么单元上必须有两个节点在第一类边界节点中那么m为2；   
        m=0;
        for i=1:3
            for j=1:Nnode_1st
               if(gElement( ie, i )==gnode_1st(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
            for i=1:3
            p(i,1)=0;%此处无内热源所以为零，如想添加第一类边界下的内热源，参考书孔26页
            end
        end
          
         %判断是否为第 二类边界单元  如果是第二类边界单元，那么单元上必须有两个节点在第二类边界节点中那么m为2；       
        m=0;
        for i=1:3
            for j=1:Nnode_2nd
               if(gElement( ie, i )==gnode_2nd(j))
                   m=m+1;
               end
            end
        end
        if (m==2)             
                xi = gNode( gElement( ie, 1 ), 1 ) ;
                yi = gNode( gElement( ie, 1 ), 2 ) ;
                xj = gNode( gElement( ie, 2 ), 1 ) ;
                yj = gNode( gElement( ie, 2 ), 2 ) ;
                xm = gNode( gElement( ie, 3 ), 1 ) ;
                ym = gNode( gElement( ie, 3 ), 2 ) ;
                bi = yj - ym ;
                ci = -(xj-xm) ;
                %si为jm边长
                si=sqrt(bi^2+ci^2);
                %qflux=100*((xj+xm)/2)^2     %热通量的函数本问题为x方向上边界
                p(1,1)=0;%此处无内热源所以为零，如想添加第一类边界下的内热源，参考书孔26页
                p(2,1)=0.5*(-500000000*(xj)^2+10000000*xj+100000)*si;%10.0*(xj)^2此处无内热源所以为零，如想添加第一类边界下的内热源，参考书孔26页
                p(3,1)=0.5*(-500000000*(xm)^2+10000000*xm+100000)*si;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%热通量q=Ex^2+Fx+G
        end
 
        %判断是否为第 三类边界单元  如果是第三类边界单元，那么单元上必须有两个节点在第三类边界节点中那么m为2；       
        m=0;
        for i=1:3
            for j=1:Nnode_3th
               if(gElement( ie, i )==gnode_3th(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                    xi = gNode( gElement( ie, 1 ), 1 ) ;
                    yi = gNode( gElement( ie, 1 ), 2 ) ;
                    xj = gNode( gElement( ie, 2 ), 1 ) ;
                    yj = gNode( gElement( ie, 2 ), 2 ) ;
                    xm = gNode( gElement( ie, 3 ), 1 ) ;
                    ym = gNode( gElement( ie, 3 ), 2 ) ;
                    xaverage=(xi+xj+xm)/3;
                    
                    bi = yj - ym ;
                    ci = -(xj-xm) ;
                    %si为jm边长
                    si=sqrt(bi^2+ci^2);
                    %hcon为换热系数
                    
                    
                    hcon=10*exp(10*((xj+xm)/2));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %hcon为换热系数
                   
                    
                    
                    p(1,1)=0;%此处无内热源所以为零，如想添加第一类边界下的内热源，参考书孔26页
                    p(2,1)=0.5*hcon*si*(1000*sin(xj*pi/0.02)+300);%此处无内热源所以为零，如想添加第一类边界下的内热源，参考书孔26页
                    p(3,1)=0.5*hcon*si*(1000*sin(xm*pi/0.02)+300);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TF=300*sin(xm*pi/20)+300
        end
 
return


function AssembleP (ie, p) 
%  把单元P集成到整体P
%  输入参数:
%      ie  --- 单元号
%      p  --- 单元p矩阵
%  返回值:
%      无
    global gElement   gP
    for i=1:1:3
                    M = gElement(ie,i) ;                    
                    gP(M,1) = gP(M,1) + p(i,1) ;
    end
    
return


