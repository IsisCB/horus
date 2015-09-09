sub make_MODS_journals{
	
	#to run set $optionNew=1 in moose.pl make_MODS and run horus.pl make_MODS mode
	
	#this scripts creates MODS3.5 XML records from Isis CB _Journal records_ (serials) exported from
	#FileMaker database
	#this script depends on horus.pl and other scripts used by the CB
	
	#the understanding of MODS schema is based on this document
	#http://www.loc.gov/standards/mods/userguide/generalapp.html
	
	#date modified 18 NOv 2013 by Sylwester Ratowt sylwesterr@gmail.com
	###########################################################################
	
	#ID $id
	#journal name  -- break into 'title' and 'subtitle'
	#journal abbraviaon  $title_ab
	#issn $issn
	#publisher  $publisher
	#frequency $fre (use this conversion http://www.loc.gov/standards/valuelist/marcfrequency.html
	#other tiltes (nees to split on \n also clean up a bit Ceased, and coninted from) @alt_titles
	#languages  $language
	#home page $homepage
	#pagination (not currenlyt ecoded)
	
	######################
	
	#system ('cls');
	
	use utf8;
	use Encode;
	
	$infile=$journals_File;
	open (IN, "< $infile") || die "Cound't open $infile for reading\n";
	#the infile is expected to be tab delimted, with new line sympols replaced with \n
	
	
	while (<IN>){
		chomp;
		#reset 
		$subtitle=$title_org=@alt_titles='';
		
		#($id, $title_ab, $fre, $homepage, $issn, $language, $title, $alt_Titles, $publisher)=split(/\t/, $_);
		($id, $title, $title_ab, $issn)=split(/\t/, $_);
		
		sqeez($id);
		sqeez($title_ab);
		sqeez($fre);
		sqeez($homepage);
		sqeez($issn);
		sqeez($language);
		sqeez($title);
		sqeez($alt_Titles);
		sqeez($publihser);
		
		
		
		$title_org=$title;
		$subtitle='';
		$title=unicode_convert($title, xml);
		$alt_Titles=unicode_convert($alt_Titles, xml);
		$title_ab=unicode_convert($title_ab, xml);
		#need to break up title and subtitle and alt titles
		if ($title=~/(.*?):\s(.*)/){
			$title=$1;
			$subtitle=$2;
		}
		
		@alt_titles=split(/\\n/, $alt_Titles);
		
		
		#get rid of white spaces
		
		#see if the alt title is the same as main title
		#do the other alt title things
		
		#make frequencies
		
		
		#skip empty records
		unless ($title eq 'USE FOR NEW JOURNALS' || $title eq ''){
			
			$outfile=$mods_J_File."$id".'.xml';
			
			open OUT, ">:utf8", $outfile or error_s("[Error 195] Cannot open $outfile $!");
			
			
			#######################
			
			#print XML header
			# TODO
			#this is copied from http://www.loc.gov/standards/mods/v3/mods99042030_linkedDataAdded.xml
			#need to be evaluated
			print OUT '<?xml version="1.0" encoding="UTF-8"?>'."\n";
			print OUT '<mods xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">'."\n";
			
			#also here defined the langauge and character endoding to be insered into tags
			
			
			############################
			#produce each top level element in order
			
			
			#make <titleInfo>
			print OUT "\t".'<titleInfo usage="primary">'."\n";
			
			#pull out the non sorintg bits from English title
			
			if ($title=~s/^(The|An|A)\s//){
				print OUT "\t\t".'<nonSort>'."$1".'</nonSort>'."\n";
			}    
			
			print OUT "\t\t".'<title>'."$title".'</title>'."\n";
			
			
			if ($subtitle ne ''){
				print OUT "\t\t".'<subTitle>'."$subtitle".'</subTitle>'."\n";
				
			}
			
			print OUT "\t".'</titleInfo>'."\n";
			
			
			if ($title_ab ne ''){   #if there is an abbrivaited title
				print OUT "\t".'<titleInfo type="abbreviated">'."\n";
				print OUT "\t\t".'<title>'."$title_ab".'</title>'."\n";
				
				print OUT "\t".'</titleInfo>'."\n";
				
			}
			
			foreach $alt_title (@alt_titles) {
				
				unless ($alt_title eq $title_org || $alt_title eq $title_ab){
					print OUT "\t".'<titleInfo usage="alternative">'."\n";
					print OUT "\t\t".'<title>'."$alt_title".'</title>'."\n";
					print OUT "\t".'</titleInfo>'."\n";
				}
			}
			
			#
			#########################
			#typeOfResource
			
			print OUT "\t<typeOfResource>text</typeOfResource>\n";
			#########################
			
			#genre 
			print OUT "\t".'<genre authority="marcgt">';
			
			print OUT "Periodical";
			print OUT '</genre>'."\n";
			
			#########################3
			#originInfo
			
			
			print OUT "\t<originInfo>\n";
			if ($publisher ne ''){
				
				print OUT "\t\t".'<publisher>';
				print OUT "$publisher";
				print OUT '</publisher>'."\n";
			}
			print OUT "\t\t<issuance>".'serial</issuance>'."\n";
			
			if ($fre ne ''){
				#print OUT "\t\t".'<frequency authority="marcfrequency">'."$fre</frequency>\n";
				if ($fre =~/irr/i){
					print OUT "\t\t".'<frequency>'."irregular</frequency>\n";
				}elsif ($fre eq '1'){
					print OUT "\t\t".'<frequency>'."$fre time per year</frequency>\n";
				}else{
					print OUT "\t\t".'<frequency>'."$fre times per year</frequency>\n";
				}
				
			}
			
			print OUT "\t</originInfo>\n";
			
			
			
			
			#############################
			#language  
			#needs to make this standard based
			if ($language ne ''){
				print OUT "\t".'<language>'."$language".'</language>'."\n";
			}
			
			#############################    
			#identifier 
			#
			#the CB record ID
			print OUT "\t".'<identifier type="local" displayLabel="Isis CB object number">';
			print OUT 'http://resources.isisbibliography.org/MODS/CBJ'."$id".'.xml';
			print OUT '</identifier>'."\n";
			
			#ISSN
			if ($issn ne ''){
				print OUT "\t".'<identifier type="issn" displayLabel="ISSN">';
				print OUT "$issn";
				print OUT '</identifier>'."\n";
			}   
			
			#######################
			#add all the links
			
			my @links=split (/\t/, $journalTOC{$id});
			
			foreach $art_id (@links){
				next if $art_id eq '';
				$art=\%{$data{$art_id}};
				print OUT '<relatedItem displayLabel="Contains" type="constituent" xlink:href="http://resources.isisbibliography.org/MODS/CBB'."$art->{record_number}".'.xml">'."\n";
				my $author=unicode_convert($art->{author}, xml);
				print OUT "\t".'<name type="personal">'."\n";
				print OUT "\t\t".'<displayForm>'."$author".'</displayForm>'."\n";
				print OUT "\t\t".'<role><roleTerm>author</roleTerm></role>'."\n";
				print OUT "\t".'</name>'."\n";
				
				#article title
				print OUT "\t\t<titleInfo>\n";
				print OUT "\t\t\t<title>";
				if ($art->{doc_type}=~/review/i){
					print OUT '[Book review]';
				}else{
				my $title=unicode_convert($art->{title}, xml);
					print OUT "$title";
				}
				print OUT "</title>\n";
				print OUT "\t\t</titleInfo>\n";
				
				#vol, pages
				#format for volume field "4, no. 1",
				
				print OUT "\t\t<part>\n";
				my $vol;
				if ($art->{volume} ne ''){
					$vol=unicode_convert($art->{volume}, xml);
				}else{
					$vol=unicode_convert($art->{volume_rev}, xml);
				}
				sqeez ($vol);
				#now print
				#convert (no) to no. no
				$vol=~s/\s*\((.*)\)/, no. $1/;
				#now split vol. from no.
				if ($vol=~/(.*?),\sno\.\s(.*)/){
					#volume
					print OUT "\t\t\t".'<detail type="volume">'."\n";
					print OUT "\t\t\t\t".'<number>';    
					print OUT "$1";
					print OUT '</number>'."\n";    
					print OUT "\t\t\t".'</detail>'."\n";
					
					#number
					print OUT "\t\t\t".'<detail type="issue">'."\n";
					print OUT "\t\t\t\t".'<number>';    
					print OUT "$2";
					print OUT '</number>'."\n";
					print OUT "\t\t\t\t".'<caption>no.</caption>'."\n";   
					print OUT "\t\t\t".'</detail>'."\n";        
				}else{
					print OUT "\t\t\t".'<detail type="volume">'."\n";
					print OUT "\t\t\t\t".'<number>';    
					print OUT "$vol";
					print OUT '</number>'."\n";    
					print OUT "\t\t\t".'</detail>'."\n";
				}
				
				#pages
				
				
				print OUT "\t\t\t".'<extent unit="pages">'."\n";
				print OUT "\t\t\t\t".'<list>';
				my $pages;
				if ($art->{jrevpages} ne ''){
					$pages=unicode_convert($art->{jrevpages}, xml);
				}else{
					$pages=unicode_convert($art->{pages}, xml);
				}
				$pages=~s/--/-/;
				print OUT "$pages";
				print OUT '</list>'."\n";
				print OUT "\t\t\t".'</extent>'."\n";
				
				
				print OUT "\t\t</part>\n";	
				print OUT "\t<originInfo>\n";	
				
				my $year=unicode_convert($art->{year}, xml);
				
				if ($year=~/^(\d\d\d\d)$/){
					print OUT "\t\t".'<dateCreated encoding="w3cdtf">';
					print OUT "$1";
					print OUT '</dateCreated>'."\n";
				
				}else{
					print OUT "\t\t".'<dateCreated>';
					print OUT "$year";
					print OUT '</dateCreated>'."\n";
					
				}
				print OUT "\t</originInfo>\n";
				
				print OUT "\t".'</relatedItem>'."\n";
				
				
			}
			
			
			#######################
			#location
			if ($homepage ne ''){
				$homepage=unicode_convert($homepage, xml);
				print OUT "\t<location>\n";
				print OUT "\t\t<url>$homepage</url>\n";
				print OUT "\t</location>\n";
				
			}
			###
			print OUT "</mods>";
			
			close OUT;
		}
	}#end of while IN
	
	close IN;
	
}


1;
