@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;

@changeIf@ 
expression e;
statement s1,s2;
position p1,p2;
@@
*if@p1(e)@p2
s1
else
s2

@script:python depends on changeIf@
p1 << changeIf.p1;
p2 << changeIf.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        flag=1;
        break;

@finalize:python@
@@
if(flag==1):
  print >> outf,"6-if change";

