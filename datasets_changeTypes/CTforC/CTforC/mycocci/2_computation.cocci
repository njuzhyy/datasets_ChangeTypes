@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;


@assignment using "assign.iso"@ 
expression e1,e2;
position p1;
position p2;
@@

* e1@p1 = e2;@p2

@selfassign using "selfassign.iso"@ 
expression e1;
position p1;
@@
* ++e1@p1;

@script:python depends on assignment@
p1 << assignment.p1;
p2 << assignment.p2;
@@

for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        flag=1; 
        break;

@script:python depends on selfassign@
p1 << selfassign.p1;
@@
if(str(p1[0].line) in linelist):
    flag=1; 



@finalize:python@
@@
if(flag==1):
  print >> outf,"2-computation change";







