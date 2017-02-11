@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
outf=open(resultfile,"a");
forflag=0;
whileflag=0;
breakflag=0;


@changeFor@ 
expression e1,e2,e3;
statement s;
position p1;
position p2;
@@
*for@p1(e1;e2;e3)@p2
s

@changeFornull@ 
statement s;
position p1;
position p2;
@@
(
*for@p1(;;)@p2
s
|
*for@p1(...;...;)@p2
s
|
*for@p1(...;;...)@p2
s
|
*for@p1(;...;...)@p2
s
|
*for@p1(...;;)@p2
s
|
*for@p1(;...;)@p2
s
|
*for@p1(;;...)@p2
s
)

 
@changeWhile@
expression e;
statement s;
position p1,p2;
@@
*while@p1(e)@p2
s

@changebreak@ 
position p;
@@
*break@p;


@changecontinue@ 
position p;
@@
*continue@p;


@script:python depends on changeFor@
p1 << changeFor.p1;
p2 << changeFor.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        forflag=1;
        break;

@script:python depends on changeFornull@
p1 << changeFornull.p1;
p2 << changeFornull.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        forflag=1;
        

@script:python depends on changeWhile@
p1 << changeWhile.p1;
p2 << changeWhile.p2;
@@
for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        whileflag=1;
        break;


@script:python depends on changebreak@
p << changebreak.p;
@@
if(str(p[0].line) in linelist):
  breakflag=1;


@script:python depends on changecontinue@
p << changecontinue.p;
@@
if(str(p[0].line) in linelist):
  breakflag=1;


@finalize:python@
@@
if(forflag==1):
  print >> outf,"5-for change";
if(whileflag==1):
  print >> outf,"5-while change";
if(breakflag==1):
  print >> outf,"5-break or continue change";




