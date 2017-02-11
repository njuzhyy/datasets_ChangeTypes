@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;


@datadeclare@ 
type T;
identifier x1; 
position p1,p2;
@@
*T@p1 x1;@p2



@dataInitialValue@
type T;
identifier x;
expression E;
position p1,p2;
@@
*T x@p1 = E;@p2


@script:python depends on datadeclare@
p1 << datadeclare.p1;
p2 << datadeclare.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        flag=1;   
        break;
 




@script:python depends on dataInitialValue@
p1 << dataInitialValue.p1;
p2 << dataInitialValue.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        flag=1;
        break;


@finalize:python@
@@
if(flag==1):
  print >> outf,"1-data declare or initial change";


