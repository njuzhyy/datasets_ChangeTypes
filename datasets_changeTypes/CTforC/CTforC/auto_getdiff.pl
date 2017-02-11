#########################################################################################
# C with no function overloading, so path and function name can be the key value        #
# function's information                                                                #
# hash table                                                                            #
#	key: path.functionname                                                              #
#	value: statements(with blanks preprocessed)	                                        #
#########################################################################################

#! /usr/bin/perl

use strict;
use Understand;
use Cwd;




my $path = getcwd();

`mkdir alldiff/`;
`mkdir allfunc/`;
`mkdir result/`;

my $arg=shift @ARGV;

&main();

sub main{

	#统一处理，
	my $hash_funcs_curr={};
	my $hash_funcs_prev={};
	print $arg,"\n";
	if($arg == 1){
		($hash_funcs_curr,$hash_funcs_prev)= patchcompare();
	
	}elsif($arg == 0){
		($hash_funcs_curr,$hash_funcs_prev)= versioncompare();
	}
	
	my ($changed,$delete) = savefunc($hash_funcs_curr, $hash_funcs_prev); 
	my @changedfuncs=@$changed;
	my @deletefuncs=@$delete;
	print "\nchangedfuncs :",$#changedfuncs+1;
	print "\ndeletefuncs:", $#deletefuncs+1;
	open deletefun, ">$path/result/deletefuncpath.txt" or warn"can't open the file";
	foreach my $delet(@deletefuncs){
		print deletefun $delet,"\n";
	}
	`mkdir func_beifen/`;
	`cp allfunc/* func_beifen/`;
	&parse_c();
	&getdiff();
}


sub patchcompare{
	my $folder_sources = "$path/source";
	my $dbFile = "$path/result/source.udb";
	unlink $dbFile;
 	
 	buildUndDb($dbFile, $folder_sources, 0);
	savedbinfo($dbFile);
	my $hash_funcs = createFuncsDb($dbFile);
	my $hash_funcs_prev = $hash_funcs;
	my $hash_funcs_curr = $hash_funcs;
	
 	buildUndDb($dbFile, $folder_sources, 0);
	my $patchdir="$path/patches/";
	my $patchhash={};
	opendir DH, $patchdir or die "Cannot open $patchdir: $!";
	foreach my $patchfuncname ( readdir DH ) {
		if ( $patchfuncname ne '.' && $patchfuncname ne '..' ) {
			my $patchid=substr($patchfuncname,length($patchfuncname)-3,3);
			
			$patchhash->{$patchid}=$patchdir.$patchfuncname;
		}
	}
	my $patchNum=keys %{$patchhash};
	foreach my $patchindex (1..$patchNum) {
		# apply patch
		my $index = sprintf("%03s",$patchindex);
		my $patch_filename = $patchhash->{$index};
		#打补丁
		applyPatch($folder_sources, $patch_filename);
	}
	`und -db $dbFile analyze -rescan -changed`;
	$hash_funcs_curr = createFuncsDb($dbFile);
	
	return( $hash_funcs_prev, $hash_funcs_curr);
}

sub versioncompare{
	 my $folder_sources1 = "$path/bugversion";
	 my $folder_sources2 = "$path/fixversion";
	 my $dbFile1 = "$path/result/pre.udb";
	 my $dbFile2 = "$path/result/cur.udb";

	 unlink $dbFile1;
	 unlink $dbFile2;
	 
	 buildUndDb($dbFile1, $folder_sources1, 0);
 	 savedbinfo($dbFile1);
 	 buildUndDb($dbFile2, $folder_sources2, 0);
 	
	 my $hash_funcs_prev = createFuncsDb($dbFile1);
	 my $hash_funcs_curr = createFuncsDb($dbFile2);
	 return( $hash_funcs_prev, $hash_funcs_curr);
}

sub savefunc {
	my ($hash_funcall_curr, $hash_funcall_prev) = @_;
	my @changedfunc;
	my @deletefunc;
	my %uniquefunc;
	my $allfunchash={};

	foreach my $funcpath (keys %{$hash_funcall_prev->{checksum}}){
		if(exists($hash_funcall_curr->{checksum}->{$funcpath})){
			if($hash_funcall_prev->{checksum}->{$funcpath} ne $hash_funcall_curr->{checksum}->{$funcpath}){
				push(@changedfunc, $funcpath);
				#print "----------------prefunc:\n";
				my $prev_text=$hash_funcall_prev->{alltext}->{$funcpath};
				#print "----------------currfunc:\n";
				my $curr_text=$hash_funcall_curr->{alltext}->{$funcpath};
				
				
				my $func=$hash_funcall_prev->{func}->{$funcpath};
	
				my $newfunname="";
				if(!exists $uniquefunc{$func}){
					$uniquefunc{$func}=1;
					$newfunname=$func."_1";
					$allfunchash->{$newfunname}=$funcpath;
				}else{
					$uniquefunc{$func}++;
					my $index=$uniquefunc{$func};
					$newfunname=$func."_".$index;
					$allfunchash->{$newfunname}=$funcpath;
				}
				my $prevfile="$path/allfunc/".$newfunname.".c";
				my $currfile="$path/allfunc/".$newfunname."_new.c";

				open pre,">$prevfile" or warn"can't open the file";
				print pre $prev_text;
				open curr,">$currfile" or warn"can't open the file";
				print curr $curr_text;

			}
		}else{
			push(@deletefunc, $funcpath);
		}
	}
	open funpath, ">$path/result/funcpath.txt" or warn"can't open the file";
	my @allfuncs=keys %{$allfunchash};
	foreach my $uniqfunc(@allfuncs){
		my $string = $uniqfunc.','.$allfunchash->{$uniqfunc};
		print funpath $string,"\n";
		
	}
	close funpath;
	return \@changedfunc,\@deletefunc;
}



sub parse_c{
	my $path = getcwd();
	my $folder_sources = "$path/allfunc/";
	my $parsecheckresult = "$path/result/parsecheckresult.txt";
	opendir DH, $folder_sources or die "Cannot open $folder_sources: $!";
	foreach my $funcname ( readdir DH ) {
		if ( $funcname ne '.' && $funcname ne '..' ) {
			my $funcpath = $folder_sources.$funcname;
			`echo "--------------$funcname-----------" >>$parsecheckresult`;
			my $parsecmd="spatch -parse-c $funcpath >> $parsecheckresult";
			`$parsecmd`;
			`echo " "`;
		}
	}
}

sub getdiff{
	my $path = getcwd();
	my $folder_sources = "$path/allfunc/";
	my %funcnamehash;
	opendir DH, $folder_sources or die "Cannot open $folder_sources: $!";
	foreach my $funcname ( readdir DH ) {
		if ( $funcname ne '.' && $funcname ne '..' ) {
			$funcnamehash{$funcname}=$folder_sources.$funcname;
		}
	}
	foreach my $func(keys %funcnamehash){
		my $newfunc=substr($func,0,length($func)-2)."_new.c";
		if(exists $funcnamehash{$newfunc}){
			my $prevfile= $funcnamehash{$func};
			my $currfile = $funcnamehash{$newfunc};
			my $difffilename="$path/alldiff/".substr($func,0,length($func)-2).".txt"; 
			print "\ndifffilename:",$difffilename;
			my $diff_cmd="diff -w -B -c $prevfile $currfile >$difffilename";
			`$diff_cmd`;
		}
	}
	
}

sub savedbinfo{
	my ($dbPath) = @_;
	my $db=openDatabase($dbPath);
	open dbinfo, ">$path/result/dbInfo.txt" or warn"can't open the file";

	my @files = $db->ents("file ~unknown ~unresolved");
	print dbinfo "fileNum :",$#files+1,"\n";
	

	
	my @dbfuncs = $db->ents("function ~unknown ~unresolved,method ~unknown ~unresolved");
	my $dbfuncNum=0;
	foreach my $dbfunc(@dbfuncs){
		next if ($dbfunc->library() =~ /standard/i);
		$dbfuncNum++;
	}
	print dbinfo "functionNum:(by db) : $dbfuncNum,\n";
	
	my $funNum=0;
	foreach my $file (@files){
		if ($file->library() !~ /standard/i){
			my @funcRefs = $file->filerefs("define", "function ~unknown ~unresolved,method ~unknown ~unresolved");
			$funNum=$funNum+@funcRefs;
		}
	}
	print dbinfo "functionNum:(by file) : $funNum,\n";

}

sub createFuncsDb{
	my ($dbPath) = @_;
	my $funcsall={};
	
	print "dbpath: $dbPath\n";
	my $db=openDatabase($dbPath);
	print "db:$db\n";
	my @files = $db->ents("file ~unknown ~unresolved");
	print "file:",$#files+1,"\n";
	foreach my $file (sort {lc($a->relname()) cmp lc($b->relname());} @files){
		if ($file->library() =~ /standard/i){
			print "library file:".$file->relname()."\n";
		}
	}

	foreach my $file (sort {lc($a->relname()) cmp lc($b->relname());} @files){
		next if ($file->library() =~ /standard/i);
		my $lexer = $file->lexer();
		my @funcRefs = $file->filerefs("define", "function,method  ~unknown ~unresolved");
		foreach my $funcRef (@funcRefs){
			my $endRef = $funcRef->ent->ref("end");
			next if (! defined $endRef);
			my @lexemes = $lexer->lexemes($funcRef->line, $endRef->line);
			my $key = $file->relname().",".$funcRef->ent->longname();
			my $usefultext = ""; 
			my $alltext="";  
			
			my $flag=0;
			foreach my $lexeme (@lexemes) {
				next if($lexeme->token() =~ /comment/i);
				if($lexeme->text eq $funcRef->ent->name()){
					$flag=1;
				}
				next if($flag==0);
				$usefultext .= $lexeme->text if($lexeme->text || $lexeme->text== '0');
				$alltext .=$lexeme->text if($lexeme->text || $lexeme->text== '0');
			}
			$usefultext =~ s/\s+//g; #remove all spaces
			
			if(!exists $funcsall->{checksum}->{$key}){
				$funcsall->{checksum}->{$key} = Understand::Util::checksum($usefultext);
				$funcsall->{text}->{$key} = $usefultext;
				my $type=$funcRef->ent->type();
				$funcsall->{alltext}->{$key} =$type." ".$alltext;
				
				$funcsall->{func}->{$key} =  $funcRef->ent->longname();
			}
			else{
				open same,">$path/result/samename.txt" or warn"can't open the file";
				print same $key,"\n";
				print same $funcsall->{func}->{$key},"\n";
				print same $file->relname().",".$key,"\n";
				print same "----------------------------------------------- \n";
			
			}
	
		}
	}

	closeDatabase($db,$dbPath);
	return $funcsall;
}

sub buildUndDb {
	my ($dbFile, $folder_sources, $flag) = @_;
	my $prev_path = getcwd();
	unlink $dbFile;
	chdir $folder_sources;
	
	if($flag == 1){
		`make clean`;
	}

	
	chdir $folder_sources;
	my $build_cmd = "und create -db $dbFile -languages c++ add $folder_sources analyze -all";		
	my $temp = `$build_cmd`;

	chdir $prev_path;
}

sub patchFileName {
	my ($folder_patches, $patch_prefix, $patch) = @_;
	my $prev_path = getcwd();
	my $index = sprintf("%03s",$patch);
	my $patch_file = "$patch_prefix"."$index";
	my $patch_name = "$folder_patches/$patch_file";
	return $patch_name;
}

sub applyPatch {
	my ($folder_sources, $patch_filename) = @_;
	my $prev_path = getcwd();
	chdir $folder_sources;
	my $patch_cmd = "patch -p0 < $patch_filename";
	`$patch_cmd`; # apply a patch file
	chdir $prev_path;
}



# subroutines
sub openDatabase($){
    my ($dbPath) = @_;
    
    my $db = Understand::Gui::db();

    # path not allowed if opened by understand
    if ($db&&$dbPath) {
		die "database already opened by GUI, don't use -db option\n";
    }

    # open database if not already open
    if (!$db) {
		my $status;
		die usage("Error, database not specified\n\n") unless ($dbPath);
		($db,$status)=Understand::open($dbPath);
		die "Error opening database: ",$status,"\n" if $status;
    }
    return($db);
}

sub closeDatabase($){
    my ($db, $dbPath)=@_;
    # close database only if we opened it
    $db->close() if ($dbPath);
}
