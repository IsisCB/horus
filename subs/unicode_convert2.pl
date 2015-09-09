sub read_unicode_file {
	
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	###################################################
	
	
	#this is tab delimited conversion list. column one has the CB character mark, column 2 has the unicode character
	$map1='C:\CB Directory\Aux Files\unicodeMap.tsv';
	
	
	
	###################################################################
	#read in the conversion maps
	
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

sub unicode_convert2 {	
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	
	my $text= $_[0];
	my $option=$_[1];
	$text=decode('ISO-8859-1', $text);
	
	
	
	#print $text;
	
	#do the conversion
	#this is copeid and modified from character_convert.pl
	
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
		if ($uni{$grab}){
			
			$match2=$match=$grab;
			$match2=~s/\^/\\^/;      #otherwise will not match
			$match2=~s/\?/\\?/;      #otherwise will not match
			$match2=~s/\(/\\(/;      #otherwise will not match
				$match2=~s/\$/\\\$/;     #otherwise will not match
				$match2=~s/\*/\\*/;      #otherwise will not match
				$match2=~s/\+/\\+/;      #otherwise will not match
				$match2=~s/\./\\./;      #otherwise will not match
				$match2=~s/"/""/;
				
				
				$l1ch=$uni{$grab};
				$text=~s/$match2/$l1ch/;
				
				
				
		}else{
			
			#print "$grab is not a recognized character command";
			#$error="$error\n$grab is not a recognized character command";
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
	
	return "$text";

}
1;
