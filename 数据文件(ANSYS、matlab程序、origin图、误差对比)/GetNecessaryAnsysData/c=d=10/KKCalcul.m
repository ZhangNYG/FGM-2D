 % 打开文件
    fid = fopen( 'SaveAllDate.txt', 'r' ) ;
    fisave = fopen( 'KKDate.txt', 'w' ) ;
    DensitySHC=fopen( 'DensitySHCDate.txt', 'w' ) ;
     chushi=fopen( 'chushi.txt', 'w' ) ;
    fisaveE = fopen( 'KKDateE.txt', 'w' ) ;
    fisaveCS = fopen( 'DateCS.txt', 'w' ) ;
    fretongliang=fopen('dataretongliang.txt','w');
    
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
    
    fclose( fid ) ;
    for      n=1:1:node_number
        x=gNode( n, 1 );
        y=gNode( n, 2 );
        newx(n,1)=x;
        newy(n,1)=y;
        fprintf(fisaveCS,'%d    %f    %f\n',n,newx(n,1),newy(n,1));
         KKKKon(n,1)=10*exp(10*newx(n,1)+10*newy(n,1));
        
         fprintf( fretongliang,'%f\n',KKKKon(n,1));
    end
    fclose( fretongliang) ;
    fclose( fisaveCS) ;
    for              n=1:1:node_number
    
                        
                            x=gNode( n, 1 );
                            y=gNode( n, 2 );
                           Tchushi=1000000*x*y+10000*x+10000*y+500; 
                         
%                        for i=1:Nnode_1st
%                             if( gnode_1st( i )==n)
%                              Tchushi=100.0;
%                             end
%                        end
                         fprintf(chushi,'%f\n',Tchushi);

    end
    fclose( chushi) ;
    for      ie=1:element_number
                xi = gNode( gElement( ie, 1 ), 1 ) ;
                yi = gNode( gElement( ie, 1 ), 2 ) ;
                xj = gNode( gElement( ie, 2 ), 1 ) ;
                yj = gNode( gElement( ie, 2 ), 2 ) ;
                xm = gNode( gElement( ie, 3 ), 1 ) ;
                ym = gNode( gElement( ie, 3 ), 2 ) ;
                xaverage=(xi+xj+xm)/3;
                yaverage=(yi+yj+ym)/3;
                KK=10*exp(50*xaverage+50*yaverage);;%c=d=0.3时
  
                fprintf( fisave,'%f\n',KK);
                
    end
     fclose( fisave ) ;
        for      ie=1:element_number
                xi = gNode( gElement( ie, 1 ), 1 ) ;
                yi = gNode( gElement( ie, 1 ), 2 ) ;
                xj = gNode( gElement( ie, 2 ), 1 ) ;
                yj = gNode( gElement( ie, 2 ), 2 ) ;
                xm = gNode( gElement( ie, 3 ), 1 ) ;
                ym = gNode( gElement( ie, 3 ), 2 ) ;
                xaverage=(xi+xj+xm)/3;
                yaverage=(yi+yj+ym)/3;
               Density=1000*exp(0.3*1000*xaverage+0.3*1000*yaverage);%c=d=0.3时
  
                fprintf( DensitySHC,'%f\n',Density);
                
    end
     fclose( DensitySHC ) ;
      for      ie=1:element_number
                
                fprintf( fisaveE,'ESEL,S, , ,    %d \n',ie);
                fprintf( fisaveE,'EMODIF,all,MAT,%d\n',ie);
                
    end
     fclose( fisaveE) ;
    