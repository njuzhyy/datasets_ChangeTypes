@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;

@changegoto@ 
identifier i;
position p;
@@

*goto@p i;



@changegotolabel@ 
identifier i;
statement s;
position p;
@@

*i@p:s




@script:python depends on changegoto@
p << changegoto.p;
@@
if(str(p[0].line) in linelist):
  flag=1;


@script:python depends on changegotolabel@
p << changegotolabel.p;
@@
if(str(p[0].line) in linelist):
  flag=1;

@finalize:python@
@@
if(flag==1):
  print >> outf,"7-goto or gotolabel change";


