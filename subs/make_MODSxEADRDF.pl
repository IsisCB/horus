#this scripts creates MODS3.5 XML records from Isis CB data exported from
#FileMaker database
#this script depends on horus.pl and other scripts used by the CB

#the understanding of MODS schema is based on this document
#http://www.loc.gov/standards/mods/userguide/generalapp.html

#date modified 19 Sept 2013 by Sylwester Ratowt sylwesterr@gmail.com
###########################################################################

sub make_MODSxEADRDF{
	#pulls names form FM citations and stores them to be converted in to xml alter
	
	use Time::Piece;
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	
	#this will make sure the rest of the necessary scripts will engage. 
	$eadrdfRun=1;
	
	#####
	#this is copied from make_rlg.pl script
	@rlgfields=();
	#makes the tab file for rlg; first set the array
	
	#create a variable for the linked record
	my $link2record=$this->{link2record};
	$linked=\%{$data{$link2record}};
	
	#produce each top level element in order
	
	
	
	#########################
	#name
	#
	#names need to be pulled from author, editor, ed details, and description fields.
	my $rec_id="$this->{record_number}";
	
	
	foreach $rtype (author, editor, edition_details,description){
		
		@names=split(/\n/, $namesIndex{$rec_id}->{$rtype});
		tie %new_names, "Tie::IxHash";    #this will retrives keys from hash in insertion order
		
		foreach $name (@names){
			$namec++;
			
			my @parts=split(/\t/, $name);
			my $original_name=$parts[0];
			my $order=$parts[1];
			my $last=$parts[2];
			my $first=$parts[3];
			my $suffix=$parts[4];
			my $prefix=$parts[5];
			
			my $new;
			if ($order eq 'asis'){
				$new="$prefix"."$last";
			}elsif ( $order eq 'western'){
				$new="$prefix"."$first $last, $suffix";
				$new=~s/,\s$//;
			}elsif ( $order eq 'asian' ){
				$new="$last $first";
			}elsif ($order eq 'etal'){
				#should never get here because it is caught earlier
			}else{
				error_b("Order $order in $name is record $record->{record_number} not known");
			}
			
			#create bare EAC-CPF records
			#check if the name already exists
			$nameCode="$order----$last----$first----$suffix----$prefix";
			
			#so, this checks agains a local file that is created on each run??
			#and not agains the authoritesFile.tab??
			#it check for values greater than 10 rather than exists, because if exists than it isgreated than 10. ok, that's an ugly code
			
			#unless ($authorityFile{$nameCode} > 10){
			#	$authorityID++;
			#	$authorityFile{$nameCode}=$authorityID;
			#	
			#}
			
			
			#this is good on the first run, but after that the codes exist but files
			#may not, so need to check if the file exists
			if ($authoList{$nameCode} eq ''){
				$authorityID++;
				$authoList{$nameCode}=$authorityID;
				$authoDisplayName{$authorityID}="$new";
				$authoParts{$authorityID}="$name";
				

				#this will keep track of only the new ones
				$newAutho{$nameCode}=$authorityID;
			}elsif(-e $eac_FileN){
				#do nothing
			}else{
				#if the file does not exist, but the name already is on the list
				$newAutho{$nameCode}=$authoList{$nameCode};
				$authoDisplayName{ $authoList{$nameCode} }="$new";
				$authoParts{ $authoList{$nameCode} }="$name";
			}
		}
	}#end of foreach
	
}#end of sub

#########################################################################################33
sub make_EACCPF{
	#read the list of the names pulled from FM citation records, and creates EAD xml from them 
	#but this needs to be done only for new names, do not overwirte old ones
	#will also create a new one if the name already appears in teh AuthorityFile but if a corespondign file does not exist


	foreach $name (keys %newAutho){ 

		$authoID=$authoList{$name};
		$authoListID='CBP'."$authoID";

		my $text_EAC='';
		
		#print the control element
		$text_EAC="$text_EAC".'<?xml version="1.0" encoding="UTF-8"?>'."\n";
		$text_EAC="$text_EAC".'<eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   xsi:schemaLocation="urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd">'."\n";
		$text_EAC="$text_EAC"."\t".'<control>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<recordId>'."$authoListID".'</recordId>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<maintenanceStatus>new</maintenanceStatus>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<maintenanceAgency>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<agencyName>History of Science Society Isis Bibliography</agencyName>'."\n";
		$text_EAC="$text_EAC"."\t\t".'</maintenanceAgency>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<languageDeclaration>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<language languageCode="eng">English</language>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<script scriptCode="Latn">Latin</script>'."\n";     #needs to come from here http://www.unicode.org/iso15924/iso15924-codes.html
		$text_EAC="$text_EAC"."\t\t".'</languageDeclaration>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<maintenanceHistory>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<maintenanceEvent>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<eventType>derived</eventType>'."\n";   #or should this be 'created' instead
		my $date = localtime->strftime('%Y-%m-%d');
		$text_EAC="$text_EAC"."\t\t\t\t".'<eventDateTime standardDateTime="'."$date".'">'."$date".'</eventDateTime>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<agentType>machine</agentType>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<agent>horus.pl</agent>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'</maintenanceEvent>'."\n";
		$text_EAC="$text_EAC"."\t\t".'</maintenanceHistory>'."\n";
		$text_EAC="$text_EAC"."\t".'</control>'."\n";
		
		#print the description element
		$text_EAC="$text_EAC"."\t".'<cpfDescription>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<identity>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<entityId>http://resources.isisbibliography.org/EAC/'."$authoListID".'.xml</entityId>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<entityType>person</entityType>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<nameEntry>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<part>';
		
		#prepare the name for dispaly
		
		my @parts=split(/----/, $name);
		my $order=$parts[0];
		my $last=unicode_convert($parts[1], xml);
		my $first=unicode_convert($parts[2], xml);
		my $suffix=unicode_convert($parts[3], xml);
		my $prefix=unicode_convert($parts[4], xml);
		
		
	
		$text_EAC="$text_EAC"."$authoDisplayName{$authoID}";                  
		$text_EAC="$text_EAC".'</part>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<part localType="family_name">'."$last".'</part>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<part localType="given_name">'."$first".'</part>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'</nameEntry>'."\n";
		$text_EAC="$text_EAC"."\t\t".'</identity>'."\n";
		
		#add comment to mark where the backlinks will be added
		$text_EAC="$text_EAC".'<!-- BACKLINKS -->'."\n";
		
		
		$text_EAC="$text_EAC"."\t".'</cpfDescription>'."\n";
		
		$text_EAC="$text_EAC".'</eac-cpf>';
		
		
		
		$eac_FileN="$eac_File"."$authoListID".'.xml';
		
		open OUT2, ">:utf8", $eac_FileN or error_s("[Error 195] Cannot open $eac_FileN $!");
		
		print OUT2 "$text_EAC\n";
		close OUT2;
		
		undef ($text_EAC);
		
		#add to the list of 
		#$authoritiesList="$authoritiesList"."$new\t$authoListID\t\tname extracted from FM records\n";
		
		
	}
	
	 
}

#########################################################################################33
sub make_EACCPF_thes{
	#this read the FM Thesuarus list and makes EADCPR xml out of it
	
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	
	foreach $st (keys %subjects_type){
		
		if ($subjects_type{$st} =~ /Per\.\snames/i){
			$name_prefix='CBA';
			$entity_Type="person";
  		}elsif ($subjects_type{$st} eq '2003'){
  			$name_prefix='CBS';
  			$entity_Type="topicSubject";
  		}elsif ($subjects_type{$st} =~ /Time\speriod/i){
  			$name_prefix='CBT';
  			$entity_Type="timePeriod";
  		}elsif ($subjects_type{$st} =~ /Institutions/i){
  			$name_prefix='CBA';
  			$entity_Type="corporateBody";
 		 }elsif ($subjects_type{$st} =~ /Geog\.\sterm/i){
 		 	 $name_prefix='CBL';
 		 	 $entity_Type="geographicTerm";
  	  	 }else{
  	  	 	 #error_s("Unknown subject type $subjects_type{$d} in subject $d in record $rlgfields[0]");
  	  	 	 print "Unknown subject type $subjects_type{$st} in subject $st\n";   
  	  	 } 
  	  	 
  	  	 my $text_thes='';
  	  	 
  	  	 #print the control element
  	  	 $text_thes="$text_thes".'<?xml version="1.0" encoding="UTF-8"?>'."\n";
  	  	 $text_thes="$text_thes".'<eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   xsi:schemaLocation="urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd">'."\n";
  	  	 $text_thes="$text_thes"."\t".'<control>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<recordId>'."$name_prefix"."$st".'</recordId>'."\n";
  	  	 #$text_thes="$text_thes"."\t\t".'<recordId>'."$authoListID".'</recordId>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<maintenanceStatus>new</maintenanceStatus>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<maintenanceAgency>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<agencyName>History of Science Society Isis Bibliography</agencyName>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'</maintenanceAgency>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<languageDeclaration>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<language languageCode="eng">English</language>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<script scriptCode="Latn">Latin</script>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'</languageDeclaration>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<maintenanceHistory>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<maintenanceEvent>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t\t".'<eventType>derived</eventType>'."\n";   #or should this be 'created' instead
  	  	 my $nowdate = localtime->strftime('%Y-%m-%d');
  	  	 $text_thes="$text_thes"."\t\t\t\t".'<eventDateTime standardDateTime="'."$nowdate".'">'."$nowdate".'</eventDateTime>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t\t".'<agentType>machine</agentType>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t\t".'<agent>horus.pl</agent>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'</maintenanceEvent>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'</maintenanceHistory>'."\n";
  	  	 $text_thes="$text_thes"."\t".'</control>'."\n";
  	  	 
  	  	 if ($subjects_type{$st} eq 'Per. names'){
  	  	 	 
  	  	 	 #extract bit
  	  	 	 
  	  	 	 $name_copy=$subjects{$st};
  	  	 	 #get the dates
  	  	 	 if ($name_copy =~s/\((.*?)\)$//){
  	  	 	 	 $date=unicode_convert($1, xml);
  	  	 	 	 if ($date=~/(.*?)\-(.*)/ && $date!~ /[a-zA-Z]/){
  	  	 	 	 	 $bdate=$1;
  	  	 	 	 	 $ddate=$2;
  	  	 	 	 	 #pad with 0s to see if will get picked up by solr
  	  	 	 	 	 if ($bdate=~/^(\d\d\d)$/){
  	  	 	 	 	 	 $bdate='0'."$bdate";
  	  	 	 	 	 }
  	  	 	 	 	 if ($ddate=~/^(\d\d\d)$/){
  	  	 	 	 	 	 $ddate='0'."$ddate";
  	  	 	 	 	 }
  	  	 	 	 }elsif ($date=~/(\d\d\d)\-(\d\d\d)\s*?b\.*\s*c/i){
  	  	 	 	 	 $bdate='-0'."$1";
  	  	 	 	 	 $ddate='-0'."$2";
  	  	 	 	 }	 
  	  	 	 	 if ($date=~/b.*?(\d+)/){
  	  	 	 	 	 $bdate=$1;
  	  	 	 	 }
  	  	 	 	 if ($date=~/d.*?(\d+)/){
  	  	 	 	 	 $ddate=$1;
  	  	 	 	 }
  	  	 	 }
  	  	 	 
  	  	 	 #get the name
  	  	 	 if ($name_copy=~/(.*?),\s(.*?),\s.*/){
  	  	 	 	 $fam_name=$1;
  	  	 	 	 $giv_name=$2;
  	  	 	 	 
  	  	 	 }elsif ($name_copy=~/(.*?),\s(.*)/){
  	  	 	 	 $fam_name=$1;
  	  	 	 	 $giv_name=$2;
  	  	 	 	 
  	  	 	 }
  	  	 	 
  	  	 	 sqeez($name_copy);
  	  	 	 sqeez($fam_name); 
  	  	 	 sqeez($giv_name); 
  	  	 	 sqeez($bdate);
  	  	 	 sqeez($ddate);
  	  	 	 sqeez($date); 
  	  	 }else{  
  	  	 	 $name_copy=$subjects{$st};
  	  	 }#end if personal name
  	  	 
  	  	 ######################################
  	  	 #print the description element
  	  	 $text_thes="$text_thes"."\t".'<cpfDescription>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<identity>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<entityId>http://resources.isisbibliography.org/EAC/'."$name_prefix"."$st".'.xml</entityId>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<entityType>'."$entity_Type".'</entityType>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<nameEntry>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t\t".'<part>';
  	  	 $name_copy=unicode_convert($name_copy, xml);
  	  	 $text_thes="$text_thes".$name_copy;                  
  	  	 $text_thes="$text_thes".'</part>'."\n";
  	  	 
  	  	 if ($fam_name ne ''){
  	  	 	 $fam_name=unicode_convert($fam_name, xml);
  	  	 	 $text_thes="$text_thes"."\t\t\t\t".'<part localType="family_name">'."$fam_name".'</part>'."\n";
  	  	 }
  	  	 if ($giv_name ne ''){
  	  	 	 $giv_name=unicode_convert($giv_name, xml);
  	  	 	 $text_thes="$text_thes"."\t\t\t\t".'<part localType="given_name">'."$giv_name".'</part>'."\n";
  	  	 }
  	  	 
  	  	 $text_thes="$text_thes"."\t\t\t".'</nameEntry>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'</identity>'."\n";
  	  	 
  	  	 if ($date ne ''){
  	  	 	 $text_thes="$text_thes"."\t\t".'<description>'."\n";
  	  	 	 $text_thes="$text_thes"."\t\t\t".'<existDates>'."\n";
  	  	 	 $text_thes="$text_thes"."\t\t\t\t".'<dateSet>'."\n";
  	  	 	 if ($bdate ne '' && $ddate ne ''){
  	  	 	 	 $text_thes="$text_thes"."\t\t\t\t\t".'<dateRange>'."\n";
  	  	 	 	 $text_thes="$text_thes"."\t\t\t\t\t\t".'<fromDate standardDate="'."$bdate".'">'."$bdate".'</fromDate>'."\n";
  	  	 	 	 $text_thes="$text_thes"."\t\t\t\t\t\t".'<toDate standardDate="'."$ddate".'">'."$ddate".'</toDate>'."\n";
  	  	 	 	 $text_thes="$text_thes"."\t\t\t\t".'</dateRange>'."\n"; 
  	  	 	 }else{
  	  	 	 	 if ($bdate ne ''){
  	  	 	 	 	 $text_thes="$text_thes"."\t\t\t\t\t".'<date localType="Birth Date" standardDate="'."$bdate".'">'."$bdate".'</date>'."\n";
  	  	 	 	 }
  	  	 	 	 if ($ddate ne ''){
  	  	 	 	 	 $text_thes="$text_thes"."\t\t\t\t\t".'<date localType="Death Date" standardDate="'."$ddate".'">'."$ddate".'</date>'."\n";
  	  	 	 	 }
  	  	 	 }
  	  	 	 $text_thes="$text_thes"."\t\t\t\t\t".'<date localType="dates text">'."$date".'</date>'."\n";
  	  	 	 $text_thes="$text_thes"."\t\t\t\t".'</dateSet>'."\n";
  	  	 	 $text_thes="$text_thes"."\t\t\t".'</existDates>'."\n";
  	  	 	 $text_thes="$text_thes"."\t\t".'</description>'."\n";
  	  	 } #end of if date
  	  	 
  	  	 
  	  	 
  	  	 #add comment to mark where the backlinks will be added
  	  	 $text_thes="$text_thes".'<!-- BACKLINKS -->'."\n";
  	  	 
  	  	 $text_thes="$text_thes"."\t".'</cpfDescription>'."\n";
  	  	 
  	  	 $text_thes="$text_thes".'</eac-cpf>';
  	  	 
  	  	 
  	  	 $eac_FileN="$eac_File"."$name_prefix"."$st".'.xml';
  	  	 open OUT5, ">:utf8", $eac_FileN or error_s("[Error 195] Cannot open $eac_FileN $!");
  	  	 
  	  	 print OUT5 "$text_thes";
  	  	 
  	  	 close OUT5;
  	  	 
  	  	 undef ($text_thes);
  	  	 
  	  	 $entity_Type=$name_prefix=$item=$date=$bdate=$ddate=$fam_name=$giv_name=$name_copy=$date=$bdate=$ddate='';
  	  	 
  	  	 
  	  	 
  	} #end foreach       
  	
  	
} #end sub

############################################################################33
sub make_RDF{
	
	
	if ($rdf_first ne '1'){
		$rdf_first=1;
		#make file, print header
		
		open (OUT3, "> $rdf_File") || error_s("[Error 195] Cannot open $rdf_File $!");
		print OUT3 '@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .'."\n";
		print OUT3 '@prefix foaf: <http://xmlns.com/foaf/0.1/> .'."\n";
		print OUT3 '@prefix isis: <http://resources.isisbibliography.org/> .'."\n";
		print OUT3 '@prefix authority: <http://resources.isisbibliography.org/authority> .'."\n";
		print OUT3 '@prefix dbpedia: <http://dbpedia.org/ontology/> .'."\n";
	}
	
	
	foreach $name (keys %authorityFile){
		
		#print "$name\n";
		
		my @parts=split(/----/, $name);
		my $order=$parts[0];
		my $last=$parts[1];
		my $first=$parts[2];
		my $suffix=$parts[3];
		my $prefix=$parts[4];
		
		
		my $new;
		if ($order eq 'asis'){
			$new="$prefix"."$last";
		}elsif ( $order eq 'western'){
			$new="$prefix"."$first $last, $suffix";
			$new=~s/,\s$//;
		}elsif ( $order eq 'asian' ){
			$new="$last $first";
		}elsif ($order eq 'etal'){
			#should never get here because it is caught earlier
		}else{
			error_b("Order $order in $name is record $record->{record_number} not known");
		}
		
		sqeez($new);
		sqeez($first); 
		sqeez($last); 
		sqeez($bdate);
		sqeez($ddate);
		sqeez($date); 
		
		$item="$item"."\n"."authority:$authorityFile{$name} a isis:authority ;"."\n";
		$item="$item"."\t".'foaf:name "'."$new".'"@en ;'."\n";
		if ($first ne ''){
			$item="$item"."\t".'foaf:givenName "'."$first".'"@en ;'."\n";
		}
		if ($last ne ''){
			$item="$item"."\t".'foaf:familyName "'."$last".'"@en ;'."\n";
		}
		if ($bdate ne ''){
			$item="$item"."\t".'dbpedia:birthYear "'."$bdate".'" ;'."\n";
		}
		if ($ddate ne ''){
			$item="$item"."\t".'dbpedia:deathYear "'."$ddate".'" ;'."\n";
		}
		if ($date ne ''){
			$item="$item"."\t".'isis:date "'."$date".'" ;'."\n";
		}
		
		$item=~s/\s;\n$/ ./;
		print OUT3 "$item\n";
		
		#clear variables
		$item=$date=$bdate=$ddate=$fam_name=$giv_name=$name_copy=$date=$bdate=$ddate=$new=$first=$last='';
		
		
	}
	close OUT3;
	
	
	
} #end of sub

#############################################################################################
sub make_RDF_thesarus{
	#read the subjects databases and makes authority files for the person subjects. use the  FM thesaurus id as the id
	
	open (OUT4, "> $rdf_File_thes") || error_s("[Error 195] Cannot open $rdf_File $!");
	print OUT4 '@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .'."\n";
	print OUT4 '@prefix foaf: <http://xmlns.com/foaf/0.1/> .'."\n";
	print OUT4 '@prefix isis: <http://resources.isisbibliography.org/> .'."\n";
	print OUT4 '@prefix authority: <http://resources.isisbibliography.org/authority> .'."\n";
	print OUT4 '@prefix dbpedia: <http://dbpedia.org/ontology/> .'."\n";
	
	#now go through the whole subjects database and print personal names ones
	
	#for reference
	#$subjects{$parts[0]}="$parts[1]";        
	#$subjects_type{$parts[0]}="$parts[2]";   
        
        
	foreach $st (keys %subjects_type){
		
		if ($subjects_type{$st} eq 'Per. names'){
			
			#extract bit
			
			$name_copy=$subjects{$st};
			#get the dates
			if ($name_copy =~s/\((.*?)\)$//){
				$date=$1;
				if ($date=~/(.*?)\-(.*)/ && $date!~ /[a-zA-Z]/){
					$bdate=$1;
					$ddate=$2;
				}
				if ($date=~/b.*?(\d+)/){
					$bdate=$1;
				}
				if ($date=~/d.*?(\d+)/){
					$ddate=$1;
				}
			}
			
			#get the name
			if ($name_copy=~/(.*?),\s(.*?),\s.*/){
				$fam_name=$1;
				$giv_name=$2;
				
			}elsif ($name_copy=~/(.*?),\s(.*)/){
				$fam_name=$1;
				$giv_name=$2;
				
			}
			
			sqeez($name_copy);
			sqeez($fam_name); 
			sqeez($giv_name); 
			sqeez($bdate);
			sqeez($ddate);
			sqeez($date); 
			
			$item="$item"."\n"."authority:$st a isis:authority ;"."\n";
			$item="$item"."\t".'foaf:name "'."$name_copy".'"@en ;'."\n";
			if ($giv_name ne ''){
				$item="$item"."\t".'foaf:givenName "'."$giv_name".'"@en ;'."\n";
			}
			if ($fam_name ne ''){
				$item="$item"."\t".'foaf:familyName "'."$fam_name".'"@en ;'."\n";
			}
			if ($bdate ne ''){
				$item="$item"."\t".'dbpedia:birthYear "'."$bdate".'" ;'."\n";
			}
			if ($ddate ne ''){
				$item="$item"."\t".'dbpedia:deathYear "'."$ddate".'" ;'."\n";
			}
			if ($date ne ''){
				$item="$item"."\t".'isis:date "'."$date".'" ;'."\n";
			}
			
			$item=~s/\s;\n$/ ./;
			print OUT4 "$item\n";
			
			#clear variables
			$item=$date=$bdate=$ddate=$fam_name=$giv_name=$name_copy=$date=$bdate=$ddate='';
			
		}
		
		
	}       
	
	
	close OUT4;
} #end of sub
#############################################################################################
sub make_last_name_list_temp{
	#this is for SPW on 2014.09.18
	
	open (OUT4, "> thes_names.tab") || error_s("[Error 195] Cannot open thes_names.tab $!");
	
	#now go through the whole subjects database and print personal names ones
	
	#for reference
	#$subjects{$parts[0]}="$parts[1]";        
	#$subjects_type{$parts[0]}="$parts[2]";   
        
        
	foreach $st (keys %subjects_type){
		
		if ($subjects_type{$st} eq 'Per. names'){
			
			#extract bit
			
			$name_copy=$subjects{$st};
			#get the dates
			if ($name_copy =~s/\((.*?)\)$//){
				$date=$1;
				if ($date=~/(.*?)\-(.*)/ && $date!~ /[a-zA-Z]/){
					$bdate=$1;
					$ddate=$2;
				}
				if ($date=~/b.*?(\d+)/){
					$bdate=$1;
				}
				if ($date=~/d.*?(\d+)/){
					$ddate=$1;
				}
			}
			
			#get the name
			if ($name_copy=~/(.*?),\s(.*?),\s.*/){
				$fam_name=$1;
				$giv_name=$2;
				
			}elsif ($name_copy=~/(.*?),\s(.*)/){
				$fam_name=$1;
				$giv_name=$2;
				
			}
			
			sqeez($name_copy);
			sqeez($fam_name); 
			sqeez($giv_name); 
			sqeez($bdate);
			sqeez($ddate);
			sqeez($date); 
			print OUT4 "$st\t$name_copy\t$fam_name\t$giv_name\t$date\t$ddate\n";
			
			#clear variables
			$item=$date=$bdate=$ddate=$fam_name=$giv_name=$name_copy=$date=$bdate=$ddate='';
			
		}
		
		
	}       
	
	
	close OUT4;
} #end of sub

1;
