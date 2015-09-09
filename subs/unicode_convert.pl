#this is the sub verion of the script. The standalon can be found uder Aux Files as unicode_convert2.pl




sub read_unicode_conversion{
	
	#this is tab delimited conversion list. column one has the CB character mark, column 2 has the unicode character
	$map1="$ap".'Aux Files\subs\unicodeMap.tsv';
	
	open IN, "<:utf8", $map1 or die "Couldn't open file $map1: $!";
	while (<IN>){
		chomp;
		$codes_temp1=$_;
		chopm;
		@codes_temp=split(/\t/, $codes_temp1);
		unless ($codes_temp[1]=~/\[empty\]/){
			$uni{$codes_temp[0]}=$codes_temp[1];     #unicode character
		}
	}
	
	close IN;
	
}


###########################################################
sub unicode_convert{
	
	$text=$_[0];
	my $option=$_[1];
	#$text=decode('ISO-8859-1', $text);
	
	#do the conversion
	#this is copeid and modified from character_convert.pl
	
	
	#commented out on 13 Aug 2013. are there any circumstances where this shouls not be commented out?
	#first gradb all the <url>
	#$nextcburlsubtextcnt=1;
	#while($text=~/(<url>.*?<\/url>)/g){
	#    $text=~s/($1)/CBURLSUBTEXT$nextcburlsubtextcnt URLEND/g;
	#    $cburlsub{$nextcburlsubtextcnt}=$1;
	#    $nextcburlsubtextcnt++
	#}
	
	#get rid of $ signes that are not <$>
	$text=~s/([^<])\$/$1/g;
	
	while($text=~/(<.*?>)/g){
		($grab=$1)=~s/""/"/;             #if already csv
		
		#if ($grab eq '<lt>' || $grab eq '<gt>' || $grab=~/<com:.*?>/){        #<lt> and <gt> should not be replaced
		#     #do notin
		#}elsif ($uni{$grab}){
		if ($option eq 'xml' && $grab=~/<com:.*?>/){
			$text=~s/$grab//;
		}elsif ($uni{$grab}){
			
			$match2=$match=$grab;
			$match2=~s/\^/\\^/;      #otherwise will not match
			$match2=~s/\?/\\?/;      #otherwise will not match
			$match2=~s/\(/\\(/;      #otherwise will not match
				$match2=~s/\$/\\\$/;     #otherwise will not match
				$match2=~s/\*/\\*/;      #otherwise will not match
				$match2=~s/\+/\\+/;      #otherwise will not match
				$match2=~s/\./\\./;      #otherwise will not match
				#$match2=~s/"/""/;
				
				
				$l1ch=$uni{$grab};
				$text=~s/$match2/$l1ch/;
				
				
				
		
		}elsif($grab=~/<\/*i>/i || $grab=~/<\/*em>/i || $grab eq '<newline>'){
			#do nothing
		}else{
			
			#print "$grab is not a recognized character command";
			log_p("$grab is not a recognized character command in text: $text");
			#$error="$error\n$grab is not a recognized character command";
			if ($option eq 'xml'){
				$grab=~s/[\(|\)]//;
				if($grab=~/^<(\w)>$/){
					my $sub=$1;
					$text=~s/$grab/$sub/;
				}elsif($grab=~/^<(\w)[^\w]>$/){
					my $sub=$1;
					$text=~s/$grab/$sub/;
				}else{
					$text=~s/$grab/[]/;
				}
				
			}
		}
	}
	
	#return the url things
	#while($text=~/(CBURLSUBTEXT(.*?)\sURLEND)/g){
	#    $mt2=$2;
	#    $text=~s/($1)/$cburlsub{$mt2}/g;
	#    
	#}
	#undef(%cburlsub);
	undef ($match);
	undef ($match2);
	undef ($grab);
	
	if ($option eq 'xml'){
		$text=~s/<newline>/\n\n/g;
		$text=~s/&/&amp;/g;
	}
	
	if ($option eq 'no_quote'){
		$text=~s/"//g;
	}
	
	return ($text);
}

1;
