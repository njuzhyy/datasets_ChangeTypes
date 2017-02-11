@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
fstore=open(storefile,"w");

@changePointerCall@ 
identifier f;
expression list es;
position p1,p2;
@@
*(@p1*f)(es)@p2


@script:python depends on changePointerCall@
p1 << changePointerCall.p1;
p2 << changePointerCall.p2;
f << changePointerCall.f;
es << changePointerCall.es;
@@

for pos in range(int(p1[0].line),int(p2[0].line)+1):
    if(str(pos) in linelist):
        fstore.write(f+"----------"+','.join(es)+"\n");
        break;


@finalize:python@
@@
fstore.close();
