@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
flag=0;


@funcDefine@ 
type T;
identifier f;
parameter list es;
position p1,p2;
@@
*T f@p1(es)
{@p2
...
}


@funcDeclare@ 
type T;
identifier f;
parameter list es;
position p1,p2;
@@
*T f@p1(es)@p2;




@script:python depends on funcDefine@
p1 << funcDefine.p1;
p2 << funcDefine.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)):
    if(str(pos) in linelist):
        flag=1;
        break;


@script:python depends on funcDeclare@
p1 << funcDeclare.p1;
p2 << funcDeclare.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
	flag=1;
        break;

@finalize:python@
@@
if(flag==1):
  print >> outf,"3-function define change";


