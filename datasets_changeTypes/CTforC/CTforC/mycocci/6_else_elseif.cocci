@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;

@changeElse@ 
statement s1,s2;
expression e;
position p;
@@

if(e) s1
*else@p 
s2



@changeElseIf@ 
expression e1,e2;
statement s,s1;
position p;
@@

if(e1) s
*else if@p(e2) 
s1



@script:python depends on changeElse@
p << changeElse.p;
@@
if(str(p[0].line) in linelist):
  flag=1;

@script:python depends on changeElseIf@
p << changeElseIf.p;
@@
if(str(p[0].line) in linelist):
  flag=1;



@finalize:python@
@@
if(flag==1):
  print >> outf,"6-else change";



