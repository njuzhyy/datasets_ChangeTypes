
@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;

@switchcase@ 
expression e1,e2;
statement s1,s2;
position p1,p2,p3,p4;
@@

* switch@p1(e1)@p2{
*case@p3 e2:@p4
s1
...

}


@switchwithdefault@ 
expression e1,e2;
statement s1,s2;
position p5;
@@

 switch(e1){
case e2:
s1
...
*default@p5: s2

}



@script:python depends on switchcase@
p1 << switchcase.p1;
p2 << switchcase.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
	 flag=1;


@script:python depends on switchcase@
p3 << switchcase.p3;
p4 << switchcase.p4;
@@
for pos in range(int(p3[0].line),int(p4[0].line)+1):
    if(str(pos) in linelist):
	 flag=1;

@script:python depends on switchwithdefault@
p5 << switchwithdefault.p5;
@@
if(str(p5[0].line) in linelist):
  flag=1;

@finalize:python@
@@
if(flag==1):
  print >> outf,"6-switch case change";



