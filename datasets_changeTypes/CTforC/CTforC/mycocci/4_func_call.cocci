@initialize:python@
lines << virtual.input;
resultfile << virtual.resultfile;
storefile << virtual.storefile;
@@
linelist=lines.split(",");
fstore=open(storefile,"w");

@changeCall@ 
identifier f;
expression list es;
position p1,p2;
@@
*f@p1(es)@p2


@script:python depends on changeCall@
p1 << changeCall.p1;
p2 << changeCall.p2;
f << changeCall.f;
es << changeCall.es;
@@
if(f!="_"):
    for pos in range(int(p1[0].line),int(p2[0].line)+1):
        if(str(pos) in linelist):
            fstore.write(f+"----------"+','.join(es)+"\n");
            break;


@finalize:python@
@@
fstore.close();

