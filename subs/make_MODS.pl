#this scripts creates MODS3.5 XML records from Isis CB data exported from
#FileMaker database
#this script depends on horus.pl and other scripts used by the CB

#the understanding of MODS schema is based on this document
#http://www.loc.gov/standards/mods/userguide/generalapp.html

#this script creates output in the following files
#$mods_File="$ap".'Aux Files\IsisDP\MODS\CBB';
#$mods_J_File="$ap".'Aux Files\IsisDP\MODS\CBJ';
#$authoritiesFile="$ap".'Aux Files\IsisDP\authoritesFile.tab';
#$eac_File="$ap".'Aux Files\IsisDP\EAC\\';
#$rdf_File="$ap".'Aux Files\IsisDP\RDF\isis_authorities.ttl';
#$rdf_File_thes="$ap".'Aux Files\IsisDP\RDF\isis_authorities_thes.ttl';

#date modified 11 Aug 2014 by Sylwester Ratowt sylwesterr@gmail.com
###########################################################################

sub make_MODS{
	
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	
	
	
	$mods_FileN="$mods_File"."$this->{record_number}".'.xml';
	open OUT, ">:utf8", $mods_FileN or error_s("[Error 195] Cannot open $mods_FileN $!");
	
	
	#####
	#this is copied from make_rlg.pl script
	@rlgfields=();
	#makes the tab file for rlg; first set the array
	
	#create a variable for the linked record
	my $link2record=$this->{link2record};
	$linked=\%{$data{$link2record}};
	
	#for essey review kind of works which have an artifical fields
	if ($this->{mtitle} ne ''){
		$this->{title}=$this->{mtitle};
	}    
	if ($this->{msubjects} ne ''){
		$this->{subjects}=$this->{msubjects};
	}    
	if ($this->{mcategories} ne ''){
		$this->{categories}=$this->{mcategories};
	}    
	if ($this->{mdescription} ne ''){
		$this->{description}=$this->{mdescription};
	}    
	
	#######################
	$text_MODS='';
	
	#print XML header
	# TODO
	#this is copied from http://www.loc.gov/standards/mods/v3/mods99042030_linkedDataAdded.xml
	#need to be evaluated
	$text_MODS="$text_MODS".'<?xml version="1.0" encoding="UTF-8"?>'."\n";
	$text_MODS="$text_MODS".'<?xml-stylesheet type="text/xsl" href="http://wwww.isisbibliography.org/files/isiscb.xsl"?>'."\n";
	$text_MODS="$text_MODS".'<mods xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">'."\n";
	
	#also here defined the langauge and character endoding to be insered into tags
	
	
	############################
	#produce each top level element in order
	
	
	######################
	#make <titleInfo>
	$text_MODS="$text_MODS"."\t".'<titleInfo usage="primary">'."\n";
	
	
	
	if ($this->{doc_type} eq 'Review'){   
		#TODO
		#make titles for review
		#the title 
		
		if ($this->{doc_type} eq 'Review'){
			$rev_res=res_rlg($link2record,revRLG);
			$rev_title="$linked->{title}. $linked->{year}";
		}
		#comenting this out because $rev_res may contain odd tags
		#$text_MODS="$text_MODS"."\t\t".'<title>Review of '."$rev_res, $rev_title".'</title>'."\n";
		$text_MODS="$text_MODS"."\t\t".'<title>Book Review</title>'."\n";
	}else{
		#pull out the non sorintg bits from English title
		
		#if ($this->{title}=~s/^(The|An|A)\s//){
		#	$text_MODS="$text_MODS"."\t\t".'<nonSort>'."$1".'</nonSort>'."\n";
		#}    
		my $title=unicode_convert($this->{title}, xml);
		$text_MODS="$text_MODS"."\t\t".'<title>'."$title".'</title>'."\n";
	}
	
	$text_MODS="$text_MODS"."\t".'</titleInfo>'."\n";
	
	#Add translated title if one is indicated in Edition details
	#
	$eddetail=$this->{edition_details};
	if ($eddetail =~ /Translated\stitle:\s\[(.*?)\]/){
		$text_MODS="$text_MODS"."\t".'<titleInfo type="translated">'."\n";
		$text_MODS="$text_MODS"."\t\t".'<title>';
		my $trans_title=unicode_convert($1, xml);
		$text_MODS="$text_MODS"."$trans_title";
		$text_MODS="$text_MODS".'</title>'."\n";
		$text_MODS="$text_MODS"."\t".'</titleInfo>'."\n";
		
	}
	
	#########################
	#name
	#
	#names need to be pulled from author, editor, ed details, and description fields.
	my $rec_id=$this->{record_number};
	
	#print "$rec_id\n";
	
	
	foreach $rtype (author, editor, edition_details,description){
		
		@names=split(/\n/, $namesIndex{$rec_id}->{$rtype});
		tie %new_names, "Tie::IxHash";    #this will retrives keys from hash in insertion order
		
		foreach $name (@names){
			$namec++;
			
			my @parts=split(/\t/, $name);
			#do this so that the code will not be in unicode
			#$nameCode="$order----$last----$first----$suffix----$prefix";
			$nameCode="$parts[1]----$parts[2]----$parts[3]----$parts[4]----$parts[5]";
			
			my $original_name=$parts[0];
			my $order=$parts[1];
			my $last=unicode_convert($parts[2], xml);
			my $first=unicode_convert($parts[3], xml);
			my $suffix=unicode_convert($parts[4], xml);
			my $prefix=unicode_convert($parts[5], xml);
			
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
			
			
			#create bane EAC-CPF records
			#check if the name already exists
			#$nameCode="$order----$last----$first----$suffix----$prefix";
			#if ($authoList{$nameCode} eq ''){
			#	$authorityID++;
			#	$authoList{$nameCode}=$authorityID;
			#	$authoDisplayName{$authorityID}="$new";
			#	$authoParts{$authorityID}="$name";
			#	
			#	
			#	#this will keep track of only the new ones
			#	$newAutho{$nameCode}=$authorityID;
			#} 
			
			#names that are "asis" can be corporate or personal names
			#assumes it is a personal name otherwise    
			if ($order eq 'asis' || $order eq 'etal'){
				$text_MODS="$text_MODS"."\t".'<name>'."\n";
			}else{
				#$text_MODS="$text_MODS"."\t".'<name type="personal" authority="cb2003n" valueURI="authorities/cb2003n-'."$authorityID".'">'."\n";
				$text_MODS="$text_MODS"."\t".'<name type="personal">'."\n";
			}
			
			#first check if it is a real name or just et al.
			if ($order eq 'etal'){
				$text_MODS="$text_MODS"."\t\t".'<etal />'."\n";
			}else{
				
				if ($first ne ''){
					$text_MODS="$text_MODS"."\t\t".'<namePart type="given">'."$first".'</namePart>'."\n";
				}
				if ($last ne ''){
					$text_MODS="$text_MODS"."\t\t".'<namePart type="family">'."$last".'</namePart>'."\n";
				}
				if ($suffix ne ''){
					$text_MODS="$text_MODS"."\t\t".'<namePart type="termsOfAddress">'."$suffix".'</namePart>'."\n";
				}
				#prepare the name for dispaly
				$new;
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
				
				$text_MODS="$text_MODS"."\t\t".'<displayForm>'."$new".'</displayForm>'."\n";
				
				
				if ($rtype eq 'author'){
					$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>author</roleTerm></role>'."\n";
					$cpf_role='Creator';   #this is going to get used in printing the eac-cpf xlink
				}elsif($rtype eq 'editor'){
					$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>editor</roleTerm></role>'."\n";
					$cpf_role='Creator';   #this is going to get used in printing the eac-cpf xlink
				}else{
					#Don't show anything for names from edition details or Descriptions
					#but for demo verion do Oct 27, 2014
					$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>contributor</roleTerm></role>'."\n";
					$cpf_role='Contributor';   #this is going to get used in printing the eac-cpf xlink
				}   
			}
			$text_MODS="$text_MODS"."\t".'</name>'."\n";
			
			
			#make the extension link
			$text_MODS="$text_MODS"."\t".'<extension xmlns:eac-cpf="http://eac.staatsbibliotek-berlin.de/schema/cpf.xsd">'."\n";
			$text_MODS="$text_MODS"."\t\t".'<eac-cpf:Relation xlink:role="'."$cpf_role".'" xlink:type="simple" xlink:href="http://resources.isisbibliography.org/EAC/CBP'."$authoList{$nameCode}".'.xml">'."\n";
			$text_MODS="$text_MODS"."\t\t\t".'<eac-cpf:relationEntry localType="Person">';
			$text_MODS="$text_MODS"."$new";
			$text_MODS="$text_MODS".'</eac-cpf:relationEntry>'."\n";
			$text_MODS="$text_MODS"."\t\t".'</eac-cpf:Relation>'."\n";
			$text_MODS="$text_MODS"."\t".'</extension>'."\n";
			
			#add to the hash of MODS that are linked to the authority
			#the key to the hash is the ID of the EAC file
			#the values are tab delimted MODS IDs
			#makres all as 'createrOf' regardless of the type of contribution
			
			$hjaah='CBP'."$authoList{$nameCode}";
			
			$modsLinks2Add2EAD{$hjaah}="$modsLinks2Add2EAD{$hjaah}"."CBB"."$this->{record_number}".'.xml---creatorOf'."\t";
			
			$cpf_role='';
			
		}
		
	}
	
	
	
	
	
	#########################
	#typeOfResource
	
	$text_MODS="$text_MODS"."\t<typeOfResource>text</typeOfResource>\n";
	#########################3
	#genre 
	$text_MODS="$text_MODS"."\t".'<genre>';
	if ($this->{doc_type} eq 'JournalArticle'){
		$text_MODS="$text_MODS"."Journal Article";
	}else{
		$text_MODS="$text_MODS"."$this->{doc_type}";
	}
	$text_MODS="$text_MODS".'</genre>'."\n";
	#########################3
	#originInfo
	
	$text_MODS="$text_MODS"."\t<originInfo>\n";
	
	#place of publication
	my $ppub=$this->{place_publisher};
	if ($ppub ne ''){
		if(    $ppub=~/(.*?):\s(.*)/ ){
			my $place=$1;
			my $publisher=$2;
			$place=unicode_convert($place, xml);
			$publisher=unicode_convert($publisher, xml);
			$text_MODS="$text_MODS"."\t\t".'<place>'."\n\t\t\t".'<placeTerm type="text">'."$place".'</placeTerm>'."\n\t\t".'</place>'."\n";
			$text_MODS="$text_MODS"."\t\t".'<publisher>';
			$text_MODS="$text_MODS"."$publisher";
			$text_MODS="$text_MODS".'</publisher>'."\n";
		}
	}
	
	#date of publication
	
	my $dateyear;
	if ($this->{doc_type} eq 'Chapter'){
		$dateyear=$linked->{year};
	}else{    
		$dateyear=$this->{year};
	}
	
	if ($dateyear=~/^(\d\d\d\d)$/){
		$text_MODS="$text_MODS"."\t\t".'<dateCreated encoding="w3cdtf">';
		$text_MODS="$text_MODS"."$1";
		$text_MODS="$text_MODS".'</dateCreated>'."\n";
	}else{
		my $year=unicode_convert($dateyear, xml);
		$text_MODS="$text_MODS"."\t\t".'<dateCreated>';
		$text_MODS="$text_MODS"."$year";
		$text_MODS="$text_MODS".'</dateCreated>'."\n";
		
	}
	$text_MODS="$text_MODS"."\t</originInfo>\n";
	
	#############################
	#language  
	#needs to make this standard based
	if ($this->{language} ne '' && $this->{language} !~/unknown/i){
		my $lang=unicode_convert($this->{language}, xml);
		$text_MODS="$text_MODS"."\t".'<language><languageTerm>'."$lang".'</languageTerm></language>'."\n";
	}
	
	###################################
	#physicalDescription    
	my $pdet=$this->{phyical_details};
	if ($pdet ne ''){
		$pdet=~s/\$//g;
		$pdet=unicode_convert($pdet, xml);
		$text_MODS="$text_MODS"."\t".'<physicalDescription>'."\n\t\t".'<note>';
		$text_MODS="$text_MODS"."$pdet";
		$text_MODS="$text_MODS".'</note>'."\n\t".'</physicalDescription>'."\n"
	}
	
	
	####################################3
	#abstract
	#if ($this->{abstract}){
	#     	my $abstract=unicode_convert($this->{abstract}, xml);
	#	$text_MODS="$text_MODS"."\t".'<abstract>'."$this->{abstract}".'</abstract>'."\n";
	
	#}   
	
	########################3
	#tableOfContents    
	my $destoc=$this->{description};
	if ($destoc=~s/^Contents:\s//){
		$destoc=~s/\$//g;
		$destoc=unicode_convert($destoc, xml);
		$text_MODS="$text_MODS"."\t".'<tableOfContents>'."$destoc".'</tableOfContents>'."\n";
	}
	
	###########################
	#targetAudience 
	#
	###################################33
	#note
	my $eddet=$this->{edition_details};   
	if ($eddet ne ''){
		$eddet=~s/\$//g;
		$eddet=unicode_convert($eddet, xml);
		$text_MODS="$text_MODS"."\t".'<note displayLabel="Edition details">'."$eddet".'</note>'."\n";
	}
	my $des=$this->{description};
	unless ($des eq '' || $des=~/^Contents:\s/ || $des=~/xref/){
		$des=~s/\$//g;
		$des=unicode_convert($des, xml);
		$text_MODS="$text_MODS"."\t".'<note displayLabel="Description">'."$des".'</note>'."\n";
	}
	#######################
	#subject    
	
	
	undef(@topcub);
	undef(@percub);
	
	while($this->{subjects}=~/\[(.*?)\]/g){
		$d=$1;
		my $subject=unicode_convert($subjects{$d}, xml);
		$st_lc=lc($subjects_type{$d});
		
		#	$text_MODS="$text_MODS"."\t".'<subject authority="cb2003" authorityURI="" valueURI="cb2003/'."$d".'">'."\n";
		$text_MODS="$text_MODS"."\t".'<subject>'."\n";
		$cpf_role='Is about';    #all the subejcts are treated the same for now
		if ($subjects_type{$d} eq '2003'){
			$text_MODS="$text_MODS"."\t\t".'<topic>'."$subject".'</topic>'."\n";   
			$cpf_localType='Topic';
			$uri_link='CBS'."$d";
        }elsif ($subjects_type{$d} eq 'Time period'){
        	$text_MODS="$text_MODS"."\t\t".'<temporal>'."$subject".'</temporal>'."\n";
        	$cpf_localType='Time';
        	$uri_link='CBT'."$d";
        }elsif($subjects_type{$d} eq 'Geog. term'){
        	$text_MODS="$text_MODS"."\t\t".'<geographic>'."$subject".'</geographic>'."\n";
        	$cpf_localType='Place';
        	$uri_link='CBL'."$d";
        }elsif($subjects_type{$d} eq 'Institutions'){
        	$text_MODS="$text_MODS"."\t\t".'<name type="corporate">'."\n\t\t\t".'<namePart>'."$subject".'</namePart>'."\n\t\t".'</name>'."\n";
        	$cpf_localType='Corporation';
        	$uri_link='CBA'."$d";
        }elsif($subjects_type{$d} eq 'Per. names'){
        	$text_MODS="$text_MODS"."\t\t".'<name type="personal">'."\n\t\t\t".'<namePart>'."$subject".'</namePart>'."\n\t\t".'</name>'."\n";
        	$uri_link='CBA'."$d";
        	$cpf_localType='Person';
        	#check if the subject is on the allowed subjects list 
        }elsif($allowedsubterm{$st_lc} ne ''){ 
        	$text_MODS="$text_MODS"."\t\t".'<topic>'."$subject".'</topic>'."\n";   
        }else{
        	#error_s("Unknown subject type $subjects_type{$d} in subject $d in record $rlgfields[0]");
        }
        
        $text_MODS="$text_MODS"."\t".'</subject>'."\n";
        
        $text_MODS="$text_MODS"."\t".'<extension xmlns:eac-cpf="http://eac.staatsbibliotek-berlin.de/schema/cpf.xsd">'."\n";
        $text_MODS="$text_MODS"."\t\t".'<eac-cpf:Relation xlink:role="'."$cpf_role".'" xlink:type="simple" xlink:href="http://resources.isisbibliography.org/EAC/'."$uri_link.xml\">\n";
        $text_MODS="$text_MODS"."\t\t\t".'<eac-cpf:relationEntry localType="'."$cpf_localType".'">';
        $text_MODS="$text_MODS"."$subject";
        $text_MODS="$text_MODS".'</eac-cpf:relationEntry>'."\n";
        $text_MODS="$text_MODS"."\t\t".'</eac-cpf:Relation>'."\n";
        $text_MODS="$text_MODS"."\t".'</extension>'."\n";
        
        #add to the hash of MODS that are linked to the authority
        #the key to the hash is the ID of the EAD file
        #the values are tab delimted MODS IDs
        $modsLinks2Add2EAD{$uri_link}="$modsLinks2Add2EAD{$uri_link}"."CBB"."$this->{record_number}".'.xml---subjectOf'."\t";
        
        $cpf_role=$cpf_localType=$uri_link='';
        
    	} #end wthil(this->subject)
    	
    	#add CB categories as subjects
    	
    	my $cat1=$cat2='';
    	($cat1, $cat2)=split(/-/, $this->{categories});
    	foreach $cat ($cat1, $cat2){
    		if ($cat ne ''){
    			my $categ=unicode_convert($categories{$cat}, xml);
    			#$text_MODS="$text_MODS"."\t".'<subject authority="cb2003c" authorityURI="" valueURI="cb2003c/'."$cat".'">'."\n";
    			$text_MODS="$text_MODS"."\t".'<subject>'."\n";
    			if ($cat=~/3\d\d/){
    				$text_MODS="$text_MODS"."\t\t".'<temporal>'."$categories{$cat}".'</temporal>'."\n";
    			}else{
    				$text_MODS="$text_MODS"."\t\t".'<topic>'."$categories{$cat}".'</topic>'."\n";
    			}
    			$text_MODS="$text_MODS"."\t".'</subject>'."\n";
    		}
    	}
    	#####################
    	#classification 
    	#################################

#########################################################################################################################    	
    	#relatedItem
    	#
    	#if a journal article
    	#not sure how to prcoceed here. the LOC user guide to related element states that only link should be included and
    	#no other elements, but linking to a journal, does not provide infor about vol page etc. 
    	#going to do both wiht just link and with all the info explicityly
    	
    	#related items include journal tiles for journal articles and book review
    	#things that are linked via link2record filed (books for chapters, books for reviews, lead articles for articles
    	#also all back links, chapter listing, reviews, articles in a series listing
    	
    	#make xlink values
    	
    	my %xlinks='';
    	
    	if ( $this->{journal_link} ne '' ){
    		
		my $journal_link_ID="$this->{journal_link}";
		@related_data='';
		$related_data[0]='Appears in Journal';
		$related_data[1]='host';
		$related_data[2]='http://resources.isisbibliography.org/MODS/CBJ'."$journal_link_ID".'.xml';
		$related_data[3]=unicode_convert($journals{$this->{journal_link}}, xml);
		$related_data[6]=unicode_convert($this->{volume}, xml);
		$related_data[7]=unicode_convert($this->{pages}, xml);
		$related_data[8]=unicode_convert($this->{year}, xml);
		$journalTOC{$this->{journal_link}} = "$journalTOC{$this->{journal_link}}"."\t$this->{record_number}";
		make_related_item(@related_data);
		

	}elsif($this->{journal_link_review} ne ''){
		my $journal_link_ID="$this->{journal_link_review}";
		@related_data='';
		$related_data[0]='Appears in Journal';
		$related_data[1]='host';
		$related_data[2]='http://resources.isisbibliography.org/MODS/CBJ'."$journal_link_ID".'.xml';
		$related_data[3]=unicode_convert($journals{$this->{journal_link_review}}, xml);
		$related_data[6]=unicode_convert($this->{volume_rev}, xml);
		$related_data[7]=unicode_convert($this->{jrevpages}, xml);
		$related_data[8]=unicode_convert($this->{year}, xml);
		$journalTOC{$this->{journal_link_review}} = "$journalTOC{$this->{journal_link_review}}"."\t$this->{record_number}";
		make_related_item(@related_data);
	}
	
	if ($this->{link2record} ne ''){
		my $linked_rec = $this->{link2record};
			
		if( $this->{doc_type} =~/Chapter/i ){
			
			@related_data='';
			$related_data[0]='Appears in Book';
			$related_data[1]='host';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml';
			$related_data[3]=unicode_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicode_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicode_convert($data{$linked_rec}->{editor}, xml);
			$related_data[7]=unicode_convert($this->{chpages}, xml);
			$related_data[5]=unicode_convert($data{$linked_rec}->{year}, xml);
			make_related_item(@related_data);
			
		}elsif( $this->{doc_type} =~/review/i ){
			
			@related_data='';
			$related_data[0]='Review of';
			$related_data[1]='reviewOf';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml';
			$related_data[3]=unicode_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicode_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicode_convert($data{$linked_rec}->{editor}, xml);
			$related_data[8]=unicode_convert($data{$linked_rec}->{year}, xml);
			make_related_item(@related_data);
			
		}elsif( $this->{doc_type} =~/article/i ){
			
			@related_data='';
			$related_data[0]='Part of Article Series';
			$related_data[1]='series';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml';
			$related_data[3]=unicode_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicode_convert($data{$linked_rec}->{author}, xml);
			$related_data[6]=unicode_convert($data{$linked_rec}->{volume}, xml);
			$related_data[7]=unicode_convert($data{$linked_rec}->{pages}, xml);
			$related_data[8]=unicode_convert($data{$linked_rec}->{year}, xml);
			make_related_item(@related_data);
			
		}else{	
			
			@related_data='';
			$related_data[0]='Related item';
			$related_data[1]='host';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml';
			$related_data[3]=unicode_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicode_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicode_convert($data{$linked_rec}->{editor}, xml);
			$related_data[6]=unicode_convert($data{$linked_rec}->{volume}, xml);
			$related_data[7]=unicode_convert($data{$linked_rec}->{pages}, xml);
			$related_data[8]=unicode_convert($data{$linked_rec}->{year}, xml);
			make_related_item(@related_data);
		}
			
	}
	
	if ($this->{series} ne ''){
		
		my $series =unicode_convert($this->{series}, xml);
		my $series_nameonly=$series;
		my $series_number='';
		if ($series ne ''){
			
			#if you can grab the number, assume only the most simple forat "wwwwww, d"			
			if($series_nameonly=~s/,\s(\d+)$//){
				#now check to see if there are any other numbers of number 
				$series_number=$1;
				if($series_nameonly=~/\d/){
					#Clear this, so that it it will not mathc below
					$series_number='';
				}else{
					#make name and number parts
					$series = $series_nameonly; 
				}
				
			}
		}
		
		@related_data='';
		$related_data[0]='Part of Series';
		$related_data[1]='series';
		$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."XXXXXX".'.xml';
		$related_data[3]=$series;
		$related_data[9]=$series_number;
		make_related_item(@related_data);
		
	}
	
	#now do all the backlinks from chapters, reviews, etc

	
	my $linked_record=cb2tx($this->{linked_record});
	my @linkedrecords=split(/,/, $linked_record);
	
	#first do thig for sorting
	%tempcontlist='';
	foreach $linkrec (@linkedrecords){
		next if $linkrec eq '';
		
		sort_records(\%{$data{$linkrec}},conlist);
	}
	foreach $linked_rec (sort {$tempcontlist{$a} cmp $tempcontlist{$b}} keys  %tempcontlist){
		#need to make sure that only the records that are not skiped will be printed
		next if ($linked_rec eq '' || $data{$linked_rec}->{doc_type} eq '');
		
		if ($this->{doc_type} eq 'Journal Article' && $data{$linked_rec}->{doc_type} eq 'Journal Article'){

			@related_data='';
			$related_data[0]='Article in a series';
			$related_data[1]='constituent';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml';
			$related_data[3]=unicode_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicode_convert($data{$linked_rec}->{author}, xml);
			$related_data[7]=unicode_convert($data{$linked_rec}->{pages}, xml);
			make_related_item(@related_data);
			
        	}elsif($this->{doc_type} eq 'Book' && $data{$linked_rec}->{doc_type} eq 'Chapter'){
        		
        		@related_data='';
        		$related_data[0]='Includes chapter';
        		$related_data[1]='constituent';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml';
			$related_data[3]=unicode_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicode_convert($data{$linked_rec}->{author}, xml);
			$related_data[7]=unicode_convert($data{$linked_rec}->{chpages}, xml);
			make_related_item(@related_data);
			
        	}else{
        		@related_data='';
        		$related_data[0]='Related item';
        		$related_data[1]='constituent';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml';
			$related_data[3]=unicode_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicode_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicode_convert($data{$linked_rec}->{editor}, xml);
			$related_data[8]=unicode_convert($data{$linked_rec}->{year}, xml);
			make_related_item(@related_data);
			
        	}
        
     
        }       
        #if the items is reviewed, list links to reviews 
        
        
        if ($this->{reviewes} ne ''){   ##is the spelling correct here? yes
        	
        	my @revs=split(/,/, $this->{reviewes});
        	foreach $rev (@revs){
        		next if $rev eq '';
         		
        		@related_data='';
        		$related_data[0]='Review';
			$related_data[1]='isReferencedBy';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$rev".'.xml';
			$related_data[3]=unicode_convert($journals{  $data{$rev}->{journal_link_review}} , xml);
			$related_data[4]=unicode_convert($data{$rev}->{author}, xml);
			$related_data[6]=unicode_convert($data{$rev}->{volume_rev}, xml);
			$related_data[7]=unicode_convert($data{$rev}->{jrevpages}, xml);
			$related_data[8]=unicode_convert($data{$rev}->{year}, xml);
			make_related_item(@related_data);
        	}
        	
        }
        
        
 
    	
	
#########################################################################################################################	
	#############################    
	#identifier 
	#
	#the CB record ID
	$text_MODS="$text_MODS"."\t".'<identifier type="local" displayLabel="Isis CB object number">';
	$text_MODS="$text_MODS".'http://resources.isisbibliography.org/MODS/CBB'."$this->{record_number}".'.xml';
	$text_MODS="$text_MODS".'</identifier>'."\n";
	
	#if there is ISBN
	if ($this->{isbn} ne ''){
		my $isbn=unicode_convert($this->{isbn}, xml);
		$text_MODS="$text_MODS"."\t".'<identifier type="isbn" displayLabel="ISBN">';
		$text_MODS="$text_MODS"."$isbn";
		$text_MODS="$text_MODS".'</identifier>'."\n";
	}    
	
	#ISBN of the book for chapter records
	if ($linked->{isbn} ne ''){
		my $isbn=unicode_convert($linked->{isbn}, xml);
		$text_MODS="$text_MODS"."\t".'<identifier type="isbn" displayLabel="Book\'s ISBN">';
		$text_MODS="$text_MODS"."$isbn";
		$text_MODS="$text_MODS".'</identifier>'."\n";
	}    
	
	#ISSN
	if ($journals_issn{$this->{journal_link}} ne ''){
		my $issn=unicode_convert($journals_issn{$this->{journal_link}}, xml);
		$text_MODS="$text_MODS"."\t".'<identifier type="issn" displayLabel="Journal ISSN">';
		$text_MODS="$text_MODS"."$issn";
		$text_MODS="$text_MODS".'</identifier>'."\n";
	}    
	
	#ISSN for review records
	if ($journals_issn{$this->{journal_link_review}} ne ''){
		my $issn=unicode_convert($journals_issn{$this->{journal_link_review}}, xml);
		$text_MODS="$text_MODS"."\t".'<identifier type="issn" displayLabel="Journal ISSN">';
		$text_MODS="$text_MODS"."$issn";
		$text_MODS="$text_MODS".'</identifier>'."\n";
	}    
	
	#DOI 
	if ($this->{DOI} ne ''){
		$doi = $this->{DOI};
	}else{
		$doi = $this->{DOIrev};
	}
	if ($doi ne ''){
		$doi=unicode_convert($doi, xml);
		$text_MODS="$text_MODS"."\t".'<identifier type="doi" displayLabel="DOI">';
		$text_MODS="$text_MODS"."$doi";
		$text_MODS="$text_MODS".'</identifier>'."\n";
	}    
	
	
	#######################
	#location
	
	##########################
	#accessCondition
	
	#############################
	#part
	
	#########################
	#extension
	#
	
	####################
	#recordInfo
	@time=localtime(time);
	$year= $time[5]+1900;
	$month=$time[4]+1;
	$day=$time[3];
	my $CreationDate="$year-$month-$day";
	
	$text_MODS="$text_MODS"."\t".'<recordInfo>'."\n";
	
	$text_MODS="$text_MODS"."\t\t".'<recordOrigin>';
	$text_MODS="$text_MODS"."Record generated from Isis CB FileMaker databse $localversionFMO by horus.pl.";
	$text_MODS="$text_MODS"."The orignal CB record had the following information:\n";
	my $a1=unicode_convert($this->{source}, xml);
	$text_MODS="$text_MODS"."Source of Data: $a1\n";
	my $a2=unicode_convert($this->{date_modified}, xml);
	$text_MODS="$text_MODS"."Date Modified: $a2\n";
	my $a3=unicode_convert($this->{date_created}, xml);
	$text_MODS="$text_MODS"."Date Created: $a3\n";
	my $a4=unicode_convert($this->{modifier_name}, xml);
	$text_MODS="$text_MODS"."Last Changed by: $a4\n";
	my $a5=unicode_convert($this->{date_entered}, xml);
	$text_MODS="$text_MODS"."Date data entry completed: $a5\n";
	my $a6=unicode_convert($this->{date_proofed}, xml);
	$text_MODS="$text_MODS"."Date proofed: $a6\n";
	my $a7=unicode_convert($this->{date_sub_checked}, xml);
	$text_MODS="$text_MODS"."Date approved by bibliographer: $a7\n";
	my $a8=unicode_convert($this->{date_pub_print}, xml);
	$text_MODS="$text_MODS"."Date published in Isis: $a8\n";
	my $a9=unicode_convert($this->{date_pub_rlg}, xml);
	$text_MODS="$text_MODS"."Date published online: $a9\n";
	$text_MODS="$text_MODS"."\t\t".'</recordOrigin>'."\n";
	
	$text_MODS="$text_MODS"."\t\t".'<recordCreationDate encoding="w3cdtf">'."$CreationDate".'</recordCreationDate>'."\n";
	$text_MODS="$text_MODS"."\t".'</recordInfo>'."\n";
	########
	#closing
	
	$text_MODS="$text_MODS".'</mods>'."\n";
	
	
	print OUT "$text_MODS";
	undef ($text_MODS);
	undef ($link2record);
	close OUT;
	
	
}

sub make_related_item{
	
	
	my $xlink_display_label=$_[0];
	my $xlink_type=$_[1];
	my $xlink_val=$_[2];
	my $xlink_title=$_[3];
	my $xlink_author=$_[4];
	my $xlink_editor=$_[5];
	my $xlink_volume=$_[6];
	my $xlink_pages=$_[7];
	my $xlink_year=$_[8];
	my $xlink_series_number=$_[9];
	

	$xlink_pages=~s/--/-/;
	
	$text_MODS="$text_MODS"."\t".'<relatedItem displayLabel="'."$xlink_display_label".'" type="'."$xlink_type".'" xlink:href="'."$xlink_val".'">'."\n";
	
	#if want to seperate the authors or editors
	# tie %linkauthor, "Tie::IxHash";
	# %linkauthor=make_name($linkrec,author,lf);      
	# foreach $linkname (keys %linkauthor){
	
	if ($xlink_title ne ''){
		$text_MODS="$text_MODS"."\t".'<titleInfo><title>'."\n";
		$text_MODS="$text_MODS"."$xlink_title\n";
		$text_MODS="$text_MODS"."\t".'</title></titleInfo>'."\n";
	}
	
	
	if ($xlink_author ne ''){
		
		$text_MODS="$text_MODS"."\t".'<name type="personal">'."\n";
		$text_MODS="$text_MODS"."\t\t".'<displayForm>'."$xlink_author".'</displayForm>'."\n";
		if ($xlink_author =~/;/){
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>authors</roleTerm></role>'."\n";
		}else{
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>author</roleTerm></role>'."\n";
		}
		$text_MODS="$text_MODS"."\t".'</name>'."\n";	
		
	}
	
	if ($xlink_editor ne ''){
		$text_MODS="$text_MODS"."\t".'<name type="personal">'."\n";
		$text_MODS="$text_MODS"."\t\t".'<displayForm>'."$xlink_editor".'</displayForm>'."\n";
		if ($xlink_editor =~/;/){
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>editors</roleTerm></role>'."\n";
		}else{
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>editor</roleTerm></role>'."\n";
		}
		$text_MODS="$text_MODS"."\t".'</name>'."\n";	
		
	}
	
	if ($xlink_vol ne '' || $xlink_pages ne ''){
		$text_MODS="$text_MODS"."\t\t<part>\n";
	}
	
	if ($xlink_volume ne ''){
		$text_MODS="$text_MODS"."\t\t\t".'<detail type="volume">'."\n";
		$text_MODS="$text_MODS"."\t\t\t\t".'<number>';    
		$text_MODS="$text_MODS"."$xlink_volume";
		$text_MODS="$text_MODS".'</number>'."\n";    
		$text_MODS="$text_MODS"."\t\t\t".'</detail>'."\n";
	}
	
	if ($xlink_pages ne ''){

		$text_MODS="$text_MODS"."\t\t\t".'<extent unit="pages">'."\n";
        	$text_MODS="$text_MODS"."\t\t\t\t".'<list>';
        	$text_MODS="$text_MODS"."$xlink_pages";
        	$text_MODS="$text_MODS".'</list>'."\n";
        	$text_MODS="$text_MODS"."\t\t\t".'</extent>'."\n";
        }
        
        if ($xlink_vol ne '' || $xlink_pages ne ''){
        	$text_MODS="$text_MODS"."\t\t</part>\n";
        }        			
        
        
        if ($xlink_year ne ''){
        	
		$text_MODS="$text_MODS"."\t<originInfo>\n";	
		
		$text_MODS="$text_MODS"."\t\t".'<dateCreated>';
		$text_MODS="$text_MODS"."$xlink_year";
		$text_MODS="$text_MODS".'</dateCreated>'."\n";
		
		
		$text_MODS="$text_MODS"."\t</originInfo>\n";
	}
	$text_MODS="$text_MODS"."\t".'</relatedItem>'."\n";
}

1;
