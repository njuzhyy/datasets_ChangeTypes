@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;



@changereturnnull@ 
position p;
@@
*return@p;

@changereturn@ 
expression e;
position p1;
position p2;
@@
*return@p1 e;@p2




@script:python depends on changereturn@
p1 << changereturn.p1;
p2 << changereturn.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        flag=1;
        break;


@script:python depends on changereturnnull@
p << changereturnnull.p;
@@
if(p[0].line in linelist):
    flag=1;

@finalize:python@
@@
if(flag==1):
  print >> outf,"7-return change";

