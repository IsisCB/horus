#this scripts creates MODS3.5 XML records from Isis CB data exported from
#FileMaker database
#this script depends on horus.pl and other scripts used by the CB

#the understanding of MODS schema is based on this document
#http://www.loc.gov/standards/mods/userguide/generalapp.html

###########################################################################

sub pull_names_for_EAC{
	#pulls names form FM citations and stores them to be converted in to xml later
	
	use Time::Piece;
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	
	
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
			
			my $authoID=$authoList{$nameCode};
			$authoIDx = sprintf("%09d", $authoID);
			$authoIDx='CBA'."$authoIDx";
			$authoIDx =~ /(A\d\d\d\d\d)/;
			$directoryXMLa{ $authoID  } = 'A/'."$1";
			$identifierXMLa{ $authoID }= $authoIDx;
			
			#BEGIN temp for making standalone list of names
			# my $printName='';
			# if ($order eq 'asis'){
			# $printName="$last";
			# print "1\n";
			# 
			# }elsif ($prefix ne '' && $suffix ne ''){
			# $printName = "$prefix $last, $first, $suffix";
			# print "2\n";
			# }elsif($prefix ne ''){	
			# $printName = "$prefix $last, $first";
			# print "3\n";
			# }elsif($suffix ne ''){
			# $printName = "$last, $first, $suffix";
			# print "4\n";
			# }elsif($first eq ''){
			# $printName = "$last";
			# print "5\n";
			# }else{
			# $printName = "$last, $first";
			# print "6\n";
			# }
			# if ($printName=~/,\s+$/){
			# print "$printName\n";
			# }
			# 
			# $printName=$printName);
			# 
			# my $namePart1="$last\t$first\t$suffix\t$prefix";
			# my $namePart2=$namePart1);
			# my $original_name_uni=$original_name);
			# $printName = "$printName\t$original_name\t$original_name_uni\t$order\t$namePart1\t$namePart2\t$rec_id\t$rtype\t$authoList{$nameCode}\t$nameCode\n";
			# use Encode;
			# use utf8;
			# binmode STDOUT, ":utf8";
			# #	$printName = $printName);
			# my $outfile = 'names.tab';
			# open OUT, ">>:utf8", $outfile or error_s("[Error 195] Cannot open $outfile $!");
			# print OUT "$printName";
			# close OUT;
			
			#END temp for making stadalone list of names
			
		}
	}#end of foreach
	
}#end of sub

#########################################################################################33
sub make_EACCPF{
	#read the list of the names pulled from FM citation records, and creates EAC xml from them 
	#but this needs to be done only for new names, do not overwirte old ones
	#will also create a new one if the name already appears in teh AuthorityFile but if a corespondign file does not exist
	
	
	foreach $name (keys %newAutho){ 
		
		my $authoID=$newAutho{$name};
		
		my $text_EAC='';
		my $identityNote='Person';
		
		#print the control element
		$text_EAC="$text_EAC".'<?xml version="1.0" encoding="UTF-8"?>'."\n";
		#$text_EAC="$text_EAC".'<?xml-stylesheet type="text/xsl" href="http://isiscb.org/transforms/isiscb-eac-html.xsl"?>'."\n";
		$text_EAC="$text_EAC".'<eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   xsi:schemaLocation="urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd">'."\n";
		$text_EAC="$text_EAC"."\t".'<control>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<recordId>'."$identifierXMLa{$authoID}".'</recordId>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<otherRecordId localType="permalink">';
		$text_EAC="$text_EAC".'http://isiscb.org/xml/'."$directoryXMLa{$st}".'/'."$identifierXMLa{$st}".'.xml';
		$text_EAC="$text_EAC".'</otherRecordId>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<maintenanceStatus>new</maintenanceStatus>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<maintenanceAgency>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<agencyName>History of Science Society IsisCB</agencyName>'."\n";
		$text_EAC="$text_EAC"."\t\t".'</maintenanceAgency>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<languageDeclaration>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<language languageCode="eng">English</language>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<script scriptCode="Latn">Latin</script>'."\n";     #needs to come from here http://www.unicode.org/iso15924/iso15924-codes.html
		$text_EAC="$text_EAC"."\t\t".'</languageDeclaration>'."\n";
		$text_EAC="$text_EAC"."\t\t".'<localControl localType="typeOfEntity">'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<term>';
		$text_EAC="$text_EAC"."$identityNote";
		$text_EAC="$text_EAC".'</term>'."\n";
		$text_EAC="$text_EAC"."\t\t".'</localControl>'."\n";
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
		$text_EAC="$text_EAC"."\t\t\t".'<descriptiveNote><p>[automatically genereted, unverified name form]</p></descriptiveNote>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<entityId>'."$identifierXMLa{$authoID}".'</entityId>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<entityType>person</entityType>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'<nameEntry>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<part>';
		
		#prepare the name for dispaly
		
		my @parts=split(/----/, $name);
		my $order=$parts[0];
		my $last=$parts[1];
		my $first=$parts[2];
		my $suffix=$parts[3];
		my $prefix=$parts[4];
		
		$authoDisplayName{$authoID}=$authoDisplayName{$authoID};
		
		$text_EAC="$text_EAC"."$authoDisplayName{$authoID}";                  
		$text_EAC="$text_EAC".'</part>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<part localType="family_name">'."$last".'</part>'."\n";
		$text_EAC="$text_EAC"."\t\t\t\t".'<part localType="given_name">'."$first".'</part>'."\n";
		$text_EAC="$text_EAC"."\t\t\t".'</nameEntry>'."\n";
		$text_EAC="$text_EAC"."\t\t".'</identity>'."\n";
		
	
		#add linking records
		
  	  	my $links=eac_make_link_to_mods($authoID);
		$text_EAC="$text_EAC"."$links\n";
		
		$text_EAC="$text_EAC"."\t".'</cpfDescription>'."\n";
		
		$text_EAC="$text_EAC".'</eac-cpf>';
		### end of make text_EAC
		
		#wrtie file
		my $eac_FileN="$xmlDirectory"."$directoryXMLa{$authoID}".'/'."$identifierXMLa{$authoID}".'.xml';
  	  	my $eac_DirN="$xmlDirectory"."$directoryXMLa{$authoID}";
  	  	
  	  	unless (-d $eac_DirN ){
  	  		
  	  		mkdir ( $eac_DirN ) or die("Cannot make directory $eac_DirN $!");
  	  	}
  	  	
		
		open OUT2, ">:utf8", $eac_FileN or die("Cannot open $eac_FileN $!");
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
			$entity_Type="person";
			$identityNote='Person';
  		}elsif ($subjects_type{$st} eq '2003'){
  			$entity_Type="concept";
  			$identityNote='Topic';
  		}elsif ($subjects_type{$st} =~ /Time\speriod/i){
			$entity_Type="concept";
			$identityNote='Time Period';
  		}elsif ($subjects_type{$st} =~ /Institutions/i){
  			$entity_Type="corporateBody";
  			$identityNote='Institution';
 		 }elsif ($subjects_type{$st} =~ /Geog\.\sterm/i){
 		 	 $entity_Type="concept";
 		 	 $identityNote='Geographic Term';
  	  	 }elsif ($subjects_type{$st} =~ /Journal/i){
  	  	 	 $entity_Type="corporateBody";
  	  	 	 $identityNote='Periodical';
 		 }elsif ($subjects_type{$st} =~ /Publishers/i){
 		 	 $entity_Type="corporateBody";
 		 	 $identityNote='Publisher';
  		 }elsif ($subjects_type{$st} =~ /Classification/i){
 		 	 $entity_Type="concept";
 		 	 $identityNote='Classification';
  		 
 		 }else{
  	  	 	 #print "Unknown subject type $subjects_type{$st} in subject $st\n";   
  	  	 } 
  	  	 
  	  	 my $text_thes='';
  	  	 
  	  	 
  	  	 #print the control element
  	  	 $text_thes="$text_thes".'<?xml version="1.0" encoding="UTF-8"?>'."\n";
  	  	 #$text_thes="$text_thes".'<?xml-stylesheet type="text/xsl" href="http://isiscb.org/transforms/isiscb-eac-html.xsl"?>'."\n";
  	  	 $text_thes="$text_thes".'<eac-cpf xmlns="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   xsi:schemaLocation="urn:isbn:1-931666-33-4 http://eac.staatsbibliothek-berlin.de/schema/cpf.xsd">'."\n";
  	  	 
  	  	 
  	  	 $text_thes="$text_thes"."\t".'<control>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<recordId>'."$identifierXMLa{$st}".'</recordId>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<otherRecordId localType="permalink">';
  	  	 $text_thes="$text_thes".'http://isiscb.org/xml/'."$directoryXMLa{$st}".'/'."$identifierXMLa{$st}".'.xml';
  	 	 $text_thes="$text_thes".'</otherRecordId>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<maintenanceStatus>new</maintenanceStatus>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<maintenanceAgency>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<agencyName>History of Science Society Isis Bibliography</agencyName>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'</maintenanceAgency>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<languageDeclaration>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<language languageCode="eng">English</language>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<script scriptCode="Latn">Latin</script>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'</languageDeclaration>'."\n";
  	  	 
  	  	 $text_thes="$text_thes"."\t\t".'<localControl localType="typeOfEntity">'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<term>';
  	  	 $text_thes="$text_thes"."$identityNote";
  	  	 $text_thes="$text_thes".'</term>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'</localControl>'."\n";
  	  	 
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
  	  	 	 	 $date=$1;
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
  	  	 }#end of personal name
  	  	 
  	  	 ######################################
  	  	 #print the description element
  	  	 $text_thes="$text_thes"."\t".'<cpfDescription>'."\n";
  	  	 $text_thes="$text_thes"."\t\t".'<identity>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<entityId>'."$identifierXMLa{$st}".'</entityId>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<entityType>'."$entity_Type".'</entityType>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t".'<nameEntry>'."\n";
  	  	 $text_thes="$text_thes"."\t\t\t\t".'<part>';
  	  	 $name_copy=$name_copy;
  	  	 $text_thes="$text_thes".$name_copy;                  
  	  	 $text_thes="$text_thes".'</part>'."\n";
  	  	 
  	  	 if ($fam_name ne ''){
  	  	 	 $fam_name=$fam_name;
  	  	 	 $text_thes="$text_thes"."\t\t\t\t".'<part localType="family_name">'."$fam_name".'</part>'."\n";
  	  	 }
  	  	 if ($giv_name ne ''){
  	  	 	 $giv_name=$giv_name;
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
  	  	 
  	  
  	  	 
  	  	 #add linking records
  	  	 
  	  	 my $links=eac_make_link_to_mods($st);
  	  	 $text_thes="$text_thes"."$links\n";
  	  	 
  	  	 
  	  	 $text_thes="$text_thes"."\t".'</cpfDescription>'."\n";
  	  	 
  	  	 $text_thes="$text_thes".'</eac-cpf>';
  	  	 
  	  	 
  	  	 #write file
  	  	 my $eac_FileN="$xmlDirectory"."$directoryXMLa{$st}".'/'."$identifierXMLa{$st}".'.xml';
  	  	 my $eac_DirN="$xmlDirectory"."$directoryXMLa{$st}";
  	  	 unless (-d $eac_DirN ){
  	  	 	 
  	  	 	 mkdir ( $eac_DirN ) or error_s("[Error ] Cannot make directory $eac_DirN $!");
            	 }
            	 
  	  	 open OUT5, ">:utf8", $eac_FileN or die("[Error 195] Cannot open $eac_FileN $!");
  	  	 print OUT5 "$text_thes";
  	  	 close OUT5;
  	  	 
  	  	 undef ($text_thes);
  	  	 $entity_Type=$name_prefix=$item=$date=$bdate=$ddate=$fam_name=$giv_name=$name_copy=$date=$bdate=$ddate='';
  	  	 
  	  	 
  	  	 
  	} #end foreach       
  	
  	
} #end sub


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


#############################################################################################
sub eac_make_link_to_mods{
	my $eacID=$_[0];
	my $text_EAC;
	my @refsMODS = split (/\t/, $modsLinks2Add2EAD{$eacID} );
	#print "$modsLinks2Add2EAD{$eacID} $modsLinks2Add2EAD{$eacID}\n";
	
	$text_EAC="$text_EAC".'<relations>'."\n";
	my %sorting='';
	foreach $refMODS (@refsMODS){
		 my @sort = split (/---/, $refMODS);
		 
		 #make a sort key
		my $sortkey="$sort[6]-$sort[7]-$sort[8]";
		$sorting{$refMODS}=$sortkey;
		
	}
	
	foreach my $ref  (sort { $sorting{$b} cmp $sorting{$a}} keys %sorting ) {
		next if $ref eq '';
		
		($linkID, $xlinkRoleEAC, $xlinkRoleMODS, $localTypeEAC, $localTypeMODS ,$eacIdentity, $resourceRelationTypeEAC, $modsDate, $modsDocType, $modsID )= split (/---/, $ref);;
		
		my $this = \%{$data{$modsID}};
		my $title;
		my $responsibility=$this->{responsibility};
		
		if ($this->{doc_type}=~/review/i){
			$title='[Book Review]';
		}else{
			$title=$this->{title};
			
		}
		
		$text_EAC="$text_EAC".'<resourceRelation resourceRelationType="'."$resourceRelationTypeEAC";
		$text_EAC="$text_EAC".'" xlink:type="simple" xlink:role="';
		$text_EAC="$text_EAC"."$xlinkRoleEAC";
		$text_EAC="$text_EAC".'" xlink:href="'.'http://isiscb.org/xml/';
		$text_EAC="$text_EAC"."$directoryXML{$modsID}".'/'."$identifierXML{$modsID}".'.xml">'."\n";
		
		#$text_EAC="$text_EAC	".'<relationEntry localType="'."$localTypeEAC".'">';
		#$text_EAC="$text_EAC"."[$modsDocType] $title. $responsibility";
		#if ($modsDate ne ''){
		#	$text_EAC="$text_EAC"." ($modsDate)";
		#}
		#$text_EAC="$text_EAC".'</relationEntry>'."\n";
		$text_EAC="$text_EAC".'<objectXMLWrap>'."\n";
		$text_EAC="$text_EAC".'<mods xmlns="http://www.loc.gov/mods/v3">'."\n";
		$text_EAC="$text_EAC".'<genre>';
		$text_EAC="$text_EAC"."$this->{doc_type}";
		$text_EAC="$text_EAC".'</genre>'."\n";
		$text_EAC="$text_EAC".'<titleInfo>'."\n";
		$text_EAC="$text_EAC".'<title>'."$title".'</title>'."\n";
		$text_EAC="$text_EAC".'</titleInfo>'."\n";
		
		$text_EAC="$text_EAC".'<name>'."\n";
		$text_EAC="$text_EAC".'<namePart>';
		$text_EAC="$text_EAC"."$this->{responsibility}";
		$text_EAC="$text_EAC".'</namePart>';
		$text_EAC="$text_EAC".'<role>'."\n";
		$text_EAC="$text_EAC".'<roleTerm>';
		$text_EAC="$text_EAC"."$xlinkRoleMODS";
		$text_EAC="$text_EAC".'</roleTerm>';
		$text_EAC="$text_EAC".'</role>'."\n";
		$text_EAC="$text_EAC".'</name>'."\n";
		
		if ($year ne ''){
			$text_EAC="$text_EAC".'<originInfo>'."\n";
			$text_EAC="$text_EAC".'<dateCreated>'."$this->{year}".'</dateCreated>'."\n";
			$text_EAC="$text_EAC".'</originInfo>'."\n";
		}
		$text_EAC="$text_EAC".'</mods>'."\n";
		$text_EAC="$text_EAC".'</objectXMLWrap>'."\n";
		$text_EAC="$text_EAC".'</resourceRelation>'."\n";
	}	 
	
$text_EAC="$text_EAC".'</relations>'."\n";
return($text_EAC);

}


1;
