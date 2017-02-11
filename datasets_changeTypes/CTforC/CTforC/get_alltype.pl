


use strict;

use Cwd;

my $path = getcwd();


my $filetype={};
my $filepath={};

my $filepathfile = "$path/result/funcpath.txt";
open( pathfile,$filepathfile);	
my @pathlines   = <pathfile>;
close pathfile;

foreach my $curline(@pathlines){
	chomp($curline);
	#reset_job_indices_1,bash32/jobs.c,reset_job_indices
	my @items=split(/,/,$curline);
	my $path=$items[1].",".$items[2];
	print $path,"\n";
	if(!exists $filepath->{$items[0]}){
		$filepath->{$items[0]}=$path;
		#reset_job_indices_1---------bash32/jobs.c,reset_job_indices
	}
}

#--------------get_next_mword_1.c-----------
#NB total files = 1; perfect = 1; pbs = 0; timeout = 0; =========> 100%
my $parsefilepath = "$path/result/parsecheckresult.txt";
open( parsefile,$parsefilepath);	
my @lines   = <parsefile>;
close parsefile;
my $prefalg=0;
my $curfuncname="";
my $parsehash={};
foreach my $curline(@lines){
	chomp($curline);
	if($curline =~ /^--------------/){
		$prefalg=1;
		my @items=split(/-+/,$curline);
		$curfuncname = $items[1];
		next;
	}
	if($prefalg == 1){
		if($curline =~ /=========> 100%$/){
			$parsehash->{$curfuncname}=1;
			$curfuncname = "";
			$prefalg = 0;
		}
	}
	
}


#-------------------------------------------
my $resultfilepath = "$path/result/patterncomparedresult.txt";
open( resultfile,$resultfilepath);	
my @lines   = <resultfile>;
close resultfile;

my $curfilepath="";
my $typefilecount=0;
my $inparsedfileflag=0;
foreach my $curline(@lines){
	chomp($curline);
	if($curline =~ /^\*\*\*/){
		my @items=split(/\*+/,$curline);
		my $funcname=$items[1]; #new_job_1
		my $funcfilename=$funcname.".c"; #new_job_1.c
		my $newfuncfilename=$funcname."_new.c"; #new_job_1_new.c
		if(exists $parsehash->{$funcfilename} && exists $parsehash->{$newfuncfilename}){
			$inparsedfileflag = 1;
			$curfilepath = $filepath->{$funcname};
			$filetype->{$curfilepath}->{0}=1; 
			next;
		} else{
			$inparsedfileflag = 0;
			next;
		}

		
	}
	if( $inparsedfileflag == 1){
		if ($curline =~ /pair/){
			next;
		}else{
			my $type = substr($curline, 0, 1);
			if(!exists $filetype->{$curfilepath}->{$type}){
				$filetype->{$curfilepath}->{$type}=1;
			}
		}
	}
	
}	

my $counttype1=0;
my $counttype2=0;
my $counttype3=0;
my $counttype4=0;
my $counttype5=0;
my $counttype6=0;
my $counttype7=0;
my $counttype8=0;

my $typefile = "$path/result/ok_alltype.txt";	
open( typefile, ">>$typefile" );
foreach my $file (keys %{$filetype}){
	my @types =keys % {$filetype->{$file}};
	@types=sort(@types);
	shift @types; 
	my $typestring=join(",", @types);
	$typestring=$file.",".$typestring;
	syswrite(typefile, "$typestring\n" );
	
	foreach my $t(@types){
		if($t == '1') {$counttype1++;}
		elsif($t == '2'){ $counttype2++;}
		elsif($t == '3'){ $counttype3++;}
		elsif($t == '4') {$counttype4++;}
		elsif($t == '5') {$counttype5++;}
		elsif($t == '6') {$counttype6++;}
		elsif($t == '7') {$counttype7++;}
		elsif($t == '8') {$counttype8++;}
	}
}

print typefile "counttype1: $counttype1\n";
print typefile "counttype2: $counttype2\n";
print typefile "counttype3: $counttype3\n";
print typefile "counttype4: $counttype4\n";
print typefile "counttype5: $counttype5\n";
print typefile "counttype6: $counttype6\n";
print typefile "counttype7: $counttype7\n";
print typefile "counttype8: $counttype8\n";

close typefile;