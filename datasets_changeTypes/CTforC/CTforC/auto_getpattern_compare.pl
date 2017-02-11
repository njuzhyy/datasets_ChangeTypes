

use strict;
use Cwd;

my $path = getcwd();


my $changelinehash=&getchangeline();
system("sh jingwhile.sh");
my $jinglinehash=&getjingline();
my $whilelinehash=&getwhileline();
&findpattern($changelinehash,$jinglinehash,$whilelinehash);


sub getchangeline {
	my $changelinehash = {};
	my $diffpath = "$path/alldiff/";
	opendir DH, $diffpath or die "can't open $diffpath:$!";
	
	foreach my $file ( readdir DH ) {
		next if ( $file eq '.' || $file eq '..' );
		
		my $difffile = $diffpath . $file;
		my $file = substr($file,0,length($file)-4);
		
		open( difffile, $difffile );

		my @lines = <difffile>;
		close difffile;

		#----------------------------------------
		my $preflag = 0;    
		my $inpairflag = 0;   
		my $i          = 0;

		my $pairIndex = 0;

		my $curbegin     = 0;
		my $curend       = 0;
		my @changedlines = ();
		foreach my $line (@lines) {
			chomp($line);

			#get file name

			$i++;
			next if ( $i <= 3 );

			if ( $inpairflag == 0 && $line =~ m/^\*\*\*/ ) {

				$inpairflag = 1;
				$preflag    = 1;
				$pairIndex++;

				#print "here-----$line\n";
				my @items      = split( /,/,   $line );
				my @beginitems = split( /\s+/, $items[0] );
				my @enditems   = split( /\s+/, $items[1] );
				my $begin      = $beginitems[$#beginitems];
				my $end        = $enditems[0];

				$curbegin = $begin;
				$curend   = $end;

				#print "!!!!ok!!ok---$curbegin,-----$curend\n";

				next;
			}
			
			if ( $i == $#lines + 1 ) {
				if (  $line =~ m/^\-\-\-/ ) {
					if ( $preflag == 1 ) {
						$changelinehash->{$file}->{$pairIndex}->{before} = 0;
					}
					else {
						my @copy = @changedlines;
						$changelinehash->{$file}->{$pairIndex}->{before} = \@copy;
					}
					$changelinehash->{$file}->{$pairIndex}->{after} = 0;
					next;
				}
				elsif ( $line =~ m/^\+/ || $line =~ m/^\-/ || $line =~ m/^\!/ )
				{
					push( @changedlines, $curbegin );
				}
				my @copy = @changedlines;
				$changelinehash->{$file}->{$pairIndex}->{after} = \@copy;
				next;

			}

			if ( $inpairflag == 1 ) {
				if ( $line =~ m/^\*\*\*/ ) {

					$inpairflag = 0;
					$curbegin   = 0;
					$curend     = 0;

					if ( $preflag == 2 ) {
						$changelinehash->{$file}->{$pairIndex}->{after} = 0;
					}
					else {

						my @copy = @changedlines;
						$changelinehash->{$file}->{$pairIndex}->{after} =\@copy;
					}

					@changedlines = ();    
					$curbegin = 0;
					$curend   = 0;
					$preflag      = 0;
					next;
				}
				if ( $line =~ m/^\-\-\-/ ) {

					if ( $preflag == 1 ) {
						$changelinehash->{$file}->{$pairIndex}->{before} = 0;
					}
					else {
						my @copy = @changedlines;
						$changelinehash->{$file}->{$pairIndex}->{before} = \@copy;
					}

					@changedlines = ();    
					my @items      = split( /,/,   $line );
					my @beginitems = split( /\s+/, $items[0] );
					my @enditems   = split( /\s+/, $items[1] );
					my $begin      = $beginitems[$#beginitems];
					my $end        = $enditems[0];

					$curbegin = $begin;
					$curend   = $end;
					$preflag  = 2;        
					next;
				}

				#print $line,"\n";
				if ( $line =~ m/^\+/ || $line =~ m/^\-/ || $line =~ m/^\!/ ) {
					push( @changedlines, $curbegin );

					#print "-----changed: ",$curbegin;
					$curbegin++;
					$preflag = 0;
					next;

				}
				else {
					$curbegin++;
					$preflag = 0;
					next;
				}

			}

		}


	}
	return $changelinehash;
}


sub getjingline{
	my $jinglinehash={};
	#`grep -rn '^\s*#' allfunc/ > result/jingresult.txt`;
	my $jingfile="$path/result/jingresult.txt";
	open( FILE, $jingfile ) || die "can not open the file: $jingfile!";
	my @jinglist = <FILE>;
	close FILE;

	foreach my $line (@jinglist) {
		#allfunc/gui_mch_init_1_new.c:8:#if  YYADD
		my @items=split(/\//,$line);
		my @infos=split(/:/,$items[1]);
		my $key=substr( $infos[0], 0, length($infos[0]) - 2 );
		$jinglinehash->{$key}->{$infos[1]}=1; #gui_mch_init_1_new.c-----8
	}
	return $jinglinehash;
}


sub getwhileline{
	my $whilelinehash={};
	#`grep -rn 'while\s*(' allfunc/ > result/whileresult.txt`;
	my $whilefile="$path/result/whileresult.txt";
	open( FILE, $whilefile ) || die "can not open the file: $whilefile!";
	my @whilelist = <FILE>;
	close FILE;

	foreach my $line (@whilelist) {
		#allfunc/reset_job_indices_1_new.c:10: while (js.j_firstj != old)
		my @items=split(/\//,$line);
		my @infos=split(/:/,$items[1]);
		my $key=substr( $infos[0], 0, length($infos[0]) - 2 );
		$whilelinehash->{$key}->{$infos[1]}=1; #reset_job_indices_1_new.c-----10
	}
	return $whilelinehash;
}

sub findpattern{
	my $changelinehash=$_[0];
	my $jinglinehash=$_[1];
	my $whilelinehash=$_[2];
	my %funcnamehash;
	my $folder_sources = "$path/allfunc/";
	opendir DH, $folder_sources or die "Cannot open $folder_sources: $!";
	foreach my $funcname ( readdir DH ) {
		if ( $funcname ne '.' && $funcname ne '..' ) {
			$funcnamehash{$funcname}=$folder_sources.$funcname;
		}
	}
	my $comparedresultfile="$path/result/patterncomparedresult.txt";
	open(comparedOUTFILE, ">>$comparedresultfile");
  
	foreach my $func ( keys %funcnamehash ) {
		
		#next if($func ne "vim_regsub_both_1.c");
		my $newfunc = substr( $func, 0, length($func) - 2 ) . "_new.c";
		
		if ( exists $funcnamehash{$newfunc} ) {
			my $prevfile = $funcnamehash{$func};
			my $currfile = $funcnamehash{$newfunc};
			
			$func= substr($func,0,length($func)-2);
			$newfunc= substr($newfunc,0,length($newfunc)-2);
			
			print comparedOUTFILE ("*********************$func*********************\n");
			
			
			my @pairs = keys %{ $changelinehash->{$func} };
			foreach my $pair(@pairs){
				#next if($pair ne "3");
				my $beforelines = $changelinehash->{$func}->{$pair}->{before};
				my $afterlines = $changelinehash->{$func}->{$pair}->{after};
				
				my $jingchangeflage=0;
				my $whilechangeflage=0;
				my $beforestring="";
				if($beforelines==0){
					$beforestring="0";
				}else{
					$beforestring=join(",",@$beforelines);
					foreach my $beforechangeline (@$beforelines){
						if(exists $jinglinehash->{$func}->{$beforechangeline}){
							$jingchangeflage = 1;
						}
					}
					foreach my $beforechangeline (@$beforelines){
						if(exists $whilelinehash->{$func}->{$beforechangeline}){
							$whilechangeflage = 1;
						}
					}
				}
				my $afterstring="";
				if($afterlines==0){
					$afterstring="0";
				}else{
					$afterstring=join(",",@$afterlines);
					foreach my $afterchangeline(@$afterlines){
						if(exists $jinglinehash->{$newfunc}->{$afterchangeline}){
							$jingchangeflage = 1;
						}
					}
					foreach my $afterchangeline(@$afterlines){
						if(exists $whilelinehash->{$newfunc}->{$afterchangeline}){
							$whilechangeflage = 1;
						}
					}
				}
				print comparedOUTFILE ("pair: $pair---before---$beforestring\n");
				print comparedOUTFILE ("pair: $pair---after---$afterstring\n");
				
				
				if($jingchangeflage == 1){
					print comparedOUTFILE ("8-jing change\n");
					$jingchangeflage = 0;
				}
				if($whilechangeflage == 1){
					print comparedOUTFILE ("5-while change\n");
					$whilechangeflage = 0;
				}
				
				
				my $folder_cocci = "$path/mycocci/";
				opendir cocciDH, $folder_cocci or die "Cannot open $folder_cocci: $!";
				foreach my $cocci ( readdir cocciDH ) {
					if ( $cocci ne '.' && $cocci ne '..' && $cocci =~ /.cocci$/) {
						#------------------test----
						#next if($cocci ne "assign_ad_rm_ch.cocci");
						
						print $cocci,"\n";
						
						my $coccipath=$folder_cocci.$cocci;
						
						my $prevmatchfile="$path/result/prevmatchstore.txt";
						my $curmatchfile="$path/result/curmatchstore.txt";
						my $prevclearcmd="cat /dev/null >$prevmatchfile";
						`$prevclearcmd`;
						my $curclearcmd="cat /dev/null >$curmatchfile";
						`$curclearcmd`;
				
						my $patch_cmd ="spatch --sp-file $coccipath  $prevfile -D input=$beforestring -D resultfile=$comparedresultfile -D storefile=$prevmatchfile";
						`$patch_cmd`;    # apply a patch file
						
						my $patch_cmd ="spatch --sp-file $coccipath  $currfile -D input=$afterstring -D resultfile=$comparedresultfile -D storefile=$curmatchfile";
						`$patch_cmd`;    # apply a patch file
						
						
						my $changeflag=0;
						open( PRE, $prevmatchfile ) || die "can not open the file: $!";
						my @prevlinelist = <PRE>;
						close PRE;
						open( CUR, $curmatchfile ) || die "can not open the file: $!";
						my @curlinelist = <CUR>;
						close CUR;
						
						#---prev
						my $prehash={};
						foreach my $line(@prevlinelist){
							my @items=split(/----------/,$line);
							$prehash->{$items[0]}->{$items[1]}=1;
						}
						#---cur
						my $curhash={};
						foreach my $line(@curlinelist){
							my @items=split(/----------/,$line);
							$curhash->{$items[0]}->{$items[1]}=1;
							#------
							if(! exists $prehash->{$items[0]}->{$items[1]}){
								$changeflag=1;
								last;
							}
						}
						#----
						foreach my $item1(keys %{$prehash}){
							foreach my $item2 (keys %{$prehash->{$item1}}){
								if(!exists $curhash->{$item1}->{$item2}){
									$changeflag=1;
									last;
								}
							}
							
						}
						
						if($changeflag==1){
							print comparedOUTFILE ("$cocci\n");
						}
						
					
					}
				}
				
				
				
				
				
			}
				
		
		}
		
		
	}
	
	
}
