clc
clear

syms m  n a b c d  BB CC DD EE FF GG  deltn keltn leltn leltnzhen oeltn heltn  fi1 fi2 fi3 fi4 u0 h0  TTT
%把k全变n
 % 打开文件
    fid = fopen( 'SaveAllDate.txt', 'r' ) ;
    fin_save= fopen( 'SaveAnalyticDate.txt', 'w' ) ;
    
    % 读取节点坐标
    node_number = fscanf( fid, '%d', 1 ) ;
    gNode = zeros( node_number, 2 ) ;
    for i=1:node_number
        dummy = fscanf( fid, '%d', 1 ) ;
        gNode( i, : ) = fscanf( fid, '%f', [1, 2] ) ;
    end
    fclose(fid);

    
for i=1:node_number    
m=1;
x=gNode( i, 1 ) ;
y=gNode( i, 2 );
a=0.02;
b=0.01;
c=20;
d=20;
BB=300.0;
CC=300.0;
DD=10.0;
EE=-500000000.0;
FF=10000000;
GG=100000;
u0=300.0;
h0=10;
TTT=0.0;

for n=1:40

        deltn=sqrt(d^2+c^2+4*n^2*pi^2/a^2);
        leltn=1-cos(n*pi)*exp(-a*c/2);
        leltnzhen=1-cos(n*pi)*exp(a*c/2);

        keltn=4*n^2*pi^2+a^2*c^2
        %oeltn=16*EE*n*pi*a^2*(exp(-a*c/2)*cos(n*pi)/keltn+8*leltn/keltn^2-8*a*c/keltn^2*(-exp(-a*c/2)*cos(n*pi)-4*a*c/keltn*(-leltn)))-16*FF*n*pi*a*(-4*a*c*(-leltn)/keltn^2-cos(n*pi)*exp(-a*c/2)/keltn)-16*(GG-u0)*n*pi/keltn*leltn;
        %oeltn1=16*EE*n*pi*a^2*(exp(-a*c/2)*cos(n*pi)/keltn+8*leltn/(keltn^2)-(8*a*c/(keltn^2))*(-exp(-a*c/2)*cos(n*pi)-4*a*c/keltn*(-leltn)))
        XXXX=(exp(-a*c/2)*cos(n*pi)/keltn+8*leltn/(keltn^2)-(8*a*c/(keltn^2))*(-exp(-a*c/2)*cos(n*pi)-4*a*c/keltn*(-leltn)));
        oeltn1=16*EE*n*pi*a^2*XXXX;
        oeltn2=16*FF*n*pi*a*(-4*a*c*(-leltn)/(keltn^2)-cos(n*pi)*exp(-a*c/2)/keltn);
        oeltn3=16*(GG-u0)*n*pi/keltn*leltn;
        oeltn=oeltn1-oeltn2-oeltn3;
        
        heltnAAA=c*a*(cos(n-m)*pi*exp(a*c/2)-1)/(2*(n-m)^2*pi^2+c^2*a^2);%%%当c=0时 被除数为零
        heltnBBB=c*a*(cos(n-m)*pi*exp(a*c/2)-1)/(2*(n+m)^2*pi^2+c^2*a^2);
        heltn=h0*BB*(heltnAAA-heltnBBB)+h0*(CC-u0)*8*n*pi/keltn*leltnzhen;
  
        fi1=(-d+deltn)*DD;
        fi2=(-d-deltn)*DD;
        fi3=exp((-d+deltn)*b/2)*(h0+DD*exp(d*b)*(-d+deltn)/2);
        fi4=exp((-d-deltn)*b/2)*(h0-DD*exp(d*b)*(d+deltn)/2);
        AAAA=(oeltn*fi4-fi2*heltn)/(fi1*fi4-fi2*fi3);
        BBBB=(fi1*heltn-oeltn*fi3)/(fi1*fi4-fi2*fi3);
        WWWW=fi1*fi4-fi2*fi3;
        W1=oeltn*fi4-fi2*heltn;
        W2=fi1*heltn-oeltn*fi3;
        W3=oeltn*fi4;%oeltn 5    31032  fi4 -0.32446
        W4=fi2*heltn;%heltn 4  6434.2    fi2  -314.16
        W5=BBBB*exp((-d-deltn)/2*y);
        W6=AAAA*exp((-d+deltn)/2*y);
        W7=exp(-c/2*x)
        W8=sin(n*pi/a*x)
        W10=vpa( W8,8);
        W9=BBBB*exp((-d-deltn)/2*y)+AAAA*exp((-d+deltn)/2*y);
        TTT=TTT+(AAAA*exp((-d+deltn)/2*y)+BBBB*exp((-d-deltn)/2*y))*exp(-c*x/2)*sin(n*pi*x/a);

end

TTTT=TTT+u0
vpa(TTTT,8);
fprintf( fin_save,'%d\n',TTTT);

end
fclose(fin_save);
