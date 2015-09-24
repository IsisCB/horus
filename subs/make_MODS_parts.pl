sub mods_make_link_to_eac{
	my $linkRef=$_[0];
	my $target_eac_id=$linkRef->[0];
	my $xlinkRoleEAC=$linkRef->[1];
	my $xlinkRoleMODS=$linkRef->[2];
	my $localTypeEAC=$linkRef->[3];
	my $localTypeMODS=$linkRef->[4];
	my $eacIdentity=$linkRef->[5];
	my $resourceRelationshipTypeEAC=$linkRef->[6];
	my $modsDate=$linkRef->[7];
	my $modsDocType=$linkRef->[8];
	my $modsID=$linkRef->[9];
	
	$text_MODS="$text_MODS"."\t".'<extension xmlns:eac-cpf="http://eac.staatsbibliotek-berlin.de/schema/cpf.xsd">'."\n";
	$text_MODS="$text_MODS"."\t\t".'<eac-cpf:Relation xlink:role="'."$xlinkRoleMODS";
	$text_MODS="$text_MODS".'" xlink:type="simple" xlink:href="http://isiscb.org/xml/';
	$text_MODS="$text_MODS"."$directoryXMLa{ $target_eac_id }".'/'."$identifierXMLa{ $target_eac_id }".'.xml">'."\n";
	#$text_MODS="$text_MODS"."\t\t\t".'<eac-cpf:relationEntry localType="';
	#$text_MODS="$text_MODS"."$localTypeMODS".'">';
	#$text_MODS="$text_MODS"."$eacIdentity";
	#$text_MODS="$text_MODS".'</eac-cpf:relationEntry>'."\n";
	$text_MODS="$text_MODS"."\t\t".'</eac-cpf:Relation>'."\n";
	$text_MODS="$text_MODS"."\t".'</extension>'."\n";
	
	my $string="$linkRef->[0]---$linkRef->[1]---$linkRef->[2]---$linkRef->[3]---$linkRef->[4]---$linkRef->[5]---$linkRef->[6]---$linkRef->[7]---$linkRef->[8]---$linkRef->[9]";
	$modsLinks2Add2EAD{$target_eac_id}="$modsLinks2Add2EAD{$target_eac_id}\t$string";
	
	
		
}

sub mods_print_head{
	
	$text_MODS="$text_MODS".'<?xml version="1.0" encoding="UTF-8"?>'."\n";
	$text_MODS="$text_MODS".'<mods xmlns:xlink="http://www.w3.org/1999/xlink" '; 
	$text_MODS="$text_MODS".'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '; 
	$text_MODS="$text_MODS".'xmlns="http://www.loc.gov/mods/v3" '; 
	$text_MODS="$text_MODS".'version="3.5" ';
	$text_MODS="$text_MODS".'xsi:schemaLocation="http://www.loc.gov/mods/v3 '; 
	$text_MODS="$text_MODS".'http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">'."\n";
	
	
}

sub mods_make_title{
	$text_MODS="$text_MODS"."\t".'<titleInfo usage="primary">'."\n";
	
	if ($this->{doc_type} eq 'Review'){   
		if ($this->{doc_type} eq 'Review'){
			$rev_res=res_rlg($link2record,revRLG);
			$rev_title="$linked->{title}. $linked->{year}";
		}
		$text_MODS="$text_MODS"."\t\t".'<title>Book Review</title>'."\n";
	}else{
		my $title=$this->{title};
		$text_MODS="$text_MODS"."\t\t".'<title>'."$title".'</title>'."\n";
	}
	
	$text_MODS="$text_MODS"."\t".'</titleInfo>'."\n";
	
	#Add translated title if one is indicated in Edition details
	$eddetail=$this->{edition_details};
	if ($eddetail =~ /Translated\stitle:\s\[(.*?)\]/){
		$text_MODS="$text_MODS"."\t".'<titleInfo type="translated">'."\n";
		$text_MODS="$text_MODS"."\t\t".'<title>';
		my $trans_title=$1;
		$text_MODS="$text_MODS"."$trans_title";
		$text_MODS="$text_MODS".'</title>'."\n";
		$text_MODS="$text_MODS"."\t".'</titleInfo>'."\n";
		
	}
}

sub mods_make_names{
	foreach $rtype (author, editor, edition_details,description){
		@names=split(/\n/, $namesIndex{$recordID}->{$rtype});
		#this will retrives keys from hash in insertion order
		tie %new_names, "Tie::IxHash"; 
		foreach $name (@names){
			$namec++;
			
			my @parts=split(/\t/, $name);
			#do this so that the code will not be in unicode
			#$nameCode="$order----$last----$first----$suffix----$prefix";
			$nameCode="$parts[1]----$parts[2]----$parts[3]----$parts[4]----$parts[5]";
			
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
			my $localTypeEAC='';
			my $localTypeMODS='';
			my $resourceRelationshipTypeEAC='';
			my $xlinkTypeEAC='';
			my $xlinkTypeMODS='';
			
			if ($order eq 'asis' || $order eq 'etal'){
				$text_MODS="$text_MODS"."\t".'<name>'."\n";
			}else{
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
				$new='';
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
					$roleTerm='author';
					#$xlinkRoleEAC='Author of';
					#$xlinkRoleMODS='Author';
					$localTypeEAC='contributor';
					$localTypeMODS='contributor';
					$resourceRelationshipTypeEAC='creatorOf';
				}elsif($rtype eq 'editor'){
					$roleTerm='editor';
					#$xlinkRoleEAC='Editor of';
					#$xlinkRoleMODS='Editor';
					$localTypeEAC='contributor';
					$localTypeMODS='contributor';
					$resourceRelationshipTypeEAC='creatorOf';
				}else{
					if ($isThesis eq 'yes' && $rtype eq 'edition_details'){
						$roleTerm='thesis advisor';
						#$xlinkRoleEAC='Thesis advisor';
						#$xlinkRoleMODS='Thesis advisor';
						$localTypeEAC='contributor';
						$localTypeMODS='contributor';
						$resourceRelationshipTypeEAC='other';
					}else{
						$roleTerm='contributor';
						#$xlinkRoleEAC='Contributor to';
						#$xlinkRoleMODS='Contributor';
						$localTypeEAC='contributor';
						$localTypeMODS='contributor';
						$resourceRelationshipTypeEAC='creatorOf';
					}
				}   
			}
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm type="text">';
			$text_MODS="$text_MODS"."$roleTerm";
			$text_MODS="$text_MODS".'</roleTerm></role>'."\n";
			$text_MODS="$text_MODS"."\t".'</name>'."\n";
			
			$linkData=[ $authoList{$nameCode}, $xlinkRoleEAC, $xlinkRoleMODS, $localTypeEAC, $localTypeMODS, $new, $resourceRelationshipTypeEAC, $this->{year}, $this->{doc_type}, $this->{record_number} ];
			mods_make_link_to_eac ($linkData);
			
		}
	}
}

sub mods_make_genre{
	$text_MODS="$text_MODS"."\t".'<genre>';
	if ($this->{doc_type} eq 'JournalArticle'){
		$this->{genre}='Journal Article';
		
	}elsif ($isThesis eq 'yes'){
		$this->{genre}='Thesis';
	}else{
		$this->{genre}="$this->{doc_type}";
	}
	$text_MODS="$text_MODS"."$this->{genre}";
	$text_MODS="$text_MODS".'</genre>'."\n";
}

sub mods_make_originInfo{
	$text_MODS="$text_MODS"."\t<originInfo>\n";
	
	#place of publication
	my $ppub=$this->{place_publisher};
	if ($ppub ne ''){
		if(    $ppub=~/(.*?):\s(.*)/ &&  $isThesis eq 'no'){
			my $place=$1;
			my $publisher=$2;
			$place=$place;
			$publisher=$publisher;
			$text_MODS="$text_MODS"."\t\t".'<place>'."\n\t\t\t".'<placeTerm type="text">'."$place".'</placeTerm>'."\n\t\t".'</place>'."\n";
			$text_MODS="$text_MODS"."\t\t".'<publisher>';
			$text_MODS="$text_MODS"."$publisher";
			$text_MODS="$text_MODS".'</publisher>'."\n";
		}else{
			$text_MODS="$text_MODS"."\t\t".'<publisher>';
			my $pub=$ppub; 
			$text_MODS="$text_MODS"."$pub";
			$text_MODS="$text_MODS".'</publisher>'."\n";
		}
		$citation=$ppub; 
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
		my $year=$dateyear;
		$text_MODS="$text_MODS"."\t\t".'<dateCreated>';
		$text_MODS="$text_MODS"."$year";
		$text_MODS="$text_MODS".'</dateCreated>'."\n";
		
	}
	$text_MODS="$text_MODS"."\t</originInfo>\n";
}

sub mods_make_language{
	if ($this->{language} ne '' && $this->{language} !~/unknown/i){
		my $lang=$this->{language};
		$text_MODS="$text_MODS"."\t".'<language><languageTerm>'."$lang".'</languageTerm></language>'."\n";
	}
}

sub mods_make_physicalDescription{
	my $pdet=$this->{phyical_details};
	if ($pdet ne ''){
		$pdet=~s/\$//g;
		$pdet=$pdet;
		$text_MODS="$text_MODS"."\t".'<physicalDescription>'."\n\t\t".'<note>';
		$text_MODS="$text_MODS"."$pdet";
		$text_MODS="$text_MODS".'</note>'."\n\t".'</physicalDescription>'."\n"
	}
}

sub mods_make_abstract{
	if ($this->{abstract}){
		
		if ($this->{abstract}=~/{AbstractBegin}(.*?){AbstractEnd}/){
			my $abstract=$1;
			my $abstract=$abstract;
			$text_MODS="$text_MODS"."\t".'<abstract>'."$abstract".'</abstract>'."\n";
		}
		
	} 
}

sub mods_make_tableOfContents{
	my $destoc=$this->{description};
	
	if ($destoc=~s/^Contents:\s//){
		$destoc=~s/\$//g;
		$destoc=$destoc;
		$text_MODS="$text_MODS"."\t".'<tableOfContents>'."$destoc".'</tableOfContents>'."\n";
	}
}

sub mods_make_notes{
	my $eddet=$this->{edition_details};   
	unless ($isThesis eq 'yes'){
		if ($eddet ne ''){
			$eddet=~s/\$//g;
			$eddet=$eddet;
			$text_MODS="$text_MODS"."\t".'<note displayLabel="Edition details">'."$eddet".'</note>'."\n";
		}
	}
	my $des=$this->{description};
	my $essayReviewText='';
	
	while ($des=~/(<xref>(.*?)\[(.*?)\]<\/xref>)/g){
		my $xref=$3;
		@related_data='';
		my $makeEssayReviewText='';
		
		
		if ($des=~/^\s*Essay\sreview/){
			$related_data[0]='Review of';
			$related_data[1]='reviewOf';
			$makeEssayReviewText=1;
		}else{
			$related_data[0]='Related item';
			$related_data[1]='references';
		}
		$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$xref}".'/'."$identifierXML{$xref}".'.xml';
		$related_data[3]=$data{$xref}->{title};
		$related_data[4]=$data{$xref}->{author};
		$related_data[5]=$data{$xref}->{editor};
		$related_data[6]=$data{$xref}->{volume};
		$related_data[7]=$data{$xref}->{pages};
		$related_data[8]=$data{$xref}->{year};
		make_related_item(@related_data);
		
		if ($makeEssayReviewText eq '1'){
			if ($related_data[5] ne ''){
				$essayReviewText="$essayReviewText"."$related_data[4] $related_data[5], $related_data[3] ($related_data[8]). ";
			}else{
				$essayReviewText="$essayReviewText"."$related_data[4], $related_data[3] ($related_data[8]). ";
			}
			$makeEssayReviewText='';
		}
		
	}
	
	if ($essayReviewText ne ''){
		$des=~s/<xref>\sessayrev\s\[\d+\]<\/xref>;*//g;
		$des=~s/\.\s*$//;   	#get rid of a period if there is one at the end
		$des="$des $essayReviewText";
		sqeez($des);
		$essayReviewText='';
	}
	
	unless ($des eq '' || $des=~/^Contents:\s/ || $isThesis eq 'yes'){
		$des=~s/\$//g;
		$des=~s/<xref>//g;
		$des=~s/\[\d+\]<\/xref>//g;
		$des=$des;
		$text_MODS="$text_MODS"."\t".'<note displayLabel="Description">'."$des".'</note>'."\n";
	}
	
	if ($isThesis eq 'yes'){
		$des='Dissertation at '."$this->{place_publisher}.\n";
		$des="$des"."$this->{edition_details}.\n\n";
		$des="$des"."$this->{description}";
		$text_MODS="$text_MODS"."\t".'<note displayLabel="Description">'."$des".'</note>'."\n";
	}
}

sub mods_make_subject{
	
	while($this->{subjects}=~/\[(.*?)\]/g){
		my $subject_id=$1;
		my $subject=$subjects{$subject_id};
		next if $subject eq '';
		$st_lc=lc($subjects_type{$subject_id});
		my $mods_subject_type;
		my $mods_subject_type_close;
		my $xlinkRole;
		
		$text_MODS="$text_MODS"."\t".'<subject>'."\n";
		    
		if ($subjects_type{$subject_id} eq '2003'){
			$mods_subject_type='<topic>';
			$mods_subject_type_close='</topic>';
			$localTypeMODS='Topic';
			$localTypeEAC='subject';
			#$xlinkRoleMODS='Is about';
			#$xlinkRoleEAC='Subject of';
			$resourceRelationshipTypeEAC='subjectOf';
		}elsif ($subjects_type{$subject_id} eq 'Time period'){
			$mods_subject_type='<temporal>';
			$mods_subject_type_close='</temporal>';
			$localTypeMODS='Time';
			$localTypeEAC='subject';
			#$xlinkRoleMODS='Is about';                                                                
			#$xlinkRoleEAC='Subject of';
			$resourceRelationshipTypeEAC='subjectOf';
        	}elsif($subjects_type{$subject_id} eq 'Geog. term'){
        		$mods_subject_type='<geographic>';
			$mods_subject_type_close='</geographic>';
        		$localTypeMODS='Place';
        		$localTypeEAC='subject';
        		#$xlinkRoleMODS='Is about';
        		#$xlinkRoleEAC='Subject of';
        		$resourceRelationshipTypeEAC='subjectOf';
        	}elsif($subjects_type{$subject_id} eq 'Institutions'){
        		$mods_subject_type='<name type="corporate"><namePart>';
			$mods_subject_type_close='</namePart></name>';
        		$localTypeMODS='Corporation';
        		$localTypeEAC='subject';
        		#$xlinkRoleMODS='Is about';
        		#$xlinkRoleEAC='Subject of';
        		$resourceRelationshipTypeEAC='subjectOf';
        	}elsif($subjects_type{$subject_id} eq 'Per. names'){
        		$mods_subject_type='<name type="personal"><namePart>';
			$mods_subject_type_close='</namePart></name>';
        		$localTypeMODS='Person';
        		$localTypeEAC='subject';
        		#$xlinkRoleMODS='Is about';
        		#$xlinkRoleEAC='Subject of';
        		$resourceRelationshipTypeEAC='subjectOf';
        	}elsif($allowedsubterm{$st_lc} ne ''){ 
        		$mods_subject_type='<topic>';
			$mods_subject_type_close='</topic>';
			$localTypeMODS='Topic';
			$localTypeEAC='subject';
			#$xlinkRoleMODS='Is about';
			#$xlinkRoleEAC='Subject of';
			$resourceRelationshipTypeEAC='subjectOf';
        	}else{
        		#error_s("Unknown subject type $subjects_type{$d} in subject $d in record $rlgfields[0]");
        	}
        
        	$text_MODS="$text_MODS"."\t\t"."$mods_subject_type";
        	$text_MODS="$text_MODS"."$subject";
        	$text_MODS="$text_MODS"."$mods_subject_type_close"."\n";
        	$text_MODS="$text_MODS"."\t".'</subject>'."\n";
	
        
	$linkData=[ $subject_id, $xlinkRoleEAC, $xlinkRoleMODS, $localTypeEAC, $localTypeMODS, $subject, $resourceRelationshipTypeEAC, $this->{year}, $this->{doc_type}, $this->{record_number} ];
	mods_make_link_to_eac ($linkData);
		
        }

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
	my $xlink_publisher=$_[10];
	
	

	$xlink_pages=~s/--/-/;
	
	$text_MODS="$text_MODS"."\t".'<relatedItem displayLabel="'."$xlink_display_label".'" type="'."$xlink_type";
	if ($xlink_val ne ''){
		$text_MODS="$text_MODS".'" xlink:href="'."$xlink_val";
	}
	$text_MODS="$text_MODS".'">'."\n";
	
	#if want to seperate the authors or editors
	# tie %linkauthor, "Tie::IxHash";
	# %linkauthor=make_name($linkrec,author,lf);      
	# foreach $linkname (keys %linkauthor){
	
	if ($xlink_title ne ''){
		$text_MODS="$text_MODS"."\t".'<titleInfo><title>';
		sqeez($xlink_title);
		$text_MODS="$text_MODS"."$xlink_title";
		$text_MODS="$text_MODS".'</title></titleInfo>'."\n";
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
	
	if ($xlink_vol ne '' || $xlink_pages ne '' || $xlink_series_number ne ''){
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
        
        if ($xlink_series_number ne ''){
        	$text_MODS="$text_MODS"."\t\t\t".'<detail type="volume">'."\n";
		$text_MODS="$text_MODS"."\t\t\t\t".'<number>';    
		$text_MODS="$text_MODS"."$xlink_series_number";
		$text_MODS="$text_MODS".'</number>'."\n";    
		$text_MODS="$text_MODS"."\t\t\t".'</detail>'."\n";
        }
        
        if ($xlink_vol ne '' || $xlink_pages ne '' || $xlink_series_number ne ''){
        	$text_MODS="$text_MODS"."\t\t</part>\n";
        }        			
        
        
        if ($xlink_year ne '' || $xlink_publisher ne ''){
        	
		$text_MODS="$text_MODS"."\t<originInfo>\n";	
		
		if ($xlink_year ne ''){
			$text_MODS="$text_MODS"."\t\t".'<dateCreated>';
			$text_MODS="$text_MODS"."$xlink_year";
			$text_MODS="$text_MODS".'</dateCreated>'."\n";
		}
		if ($xlink_publisher ne ''){
			$text_MODS="$text_MODS"."\t\t".'<publisher>';
			$text_MODS="$text_MODS"."$xlink_publisher";
			$text_MODS="$text_MODS".'</publisher>'."\n";
		}
		
		
		$text_MODS="$text_MODS"."\t</originInfo>\n";
	}
	$text_MODS="$text_MODS"."\t".'</relatedItem>'."\n";
}

sub mods_make_mods_related_items{
	my %xlinks='';
    	
    	if ( $this->{journal_link} ne '' ){
    		
		my $journal_link_ID="$journalIDmap{ $this->{journal_link} }";
		@related_data='';
		$related_data[0]='Appears in Journal';
		$related_data[1]='host';
		$related_data[2]='http://isiscb.org/xml/'."$directoryXMLa{ $journal_link_ID}".'/'."$identifierXMLa{ $journal_link_ID }".'.xml';
		$related_data[3]=$journals{$this->{journal_link}};
		$related_data[6]=$this->{volume};
		$related_data[7]=$this->{pages};
		$related_data[8]=$this->{year};
		#$journalTOC{$this->{journal_link}} = "$journalTOC{$this->{journal_link}}"."\t$this->{record_number}";
		#$modsLinks2Add2EAD{$journal_link_ID}="$modsLinks2Add2EAD{$journal_link_ID}"."$recordID".'---other---Includes'."\t";  
		my $jtitle_short='';
		if ($related_data[3]=~/(.*?):/){
			$jtitle_short=$1;
		}else{
			$jtitle_short=$related_data[3]
		}
		$citation="$jtitle_short $related_data[6]: $related_data[7]"; 
		$citation=~s/(.*)--/$1-/;
		make_related_item(@related_data);
		

	}elsif($this->{journal_link_review} ne ''){
		my $journal_link_ID="$journalIDmap{ $this->{journal_link_review} }";
		@related_data='';
		$related_data[0]='Appears in Journal';
		$related_data[1]='host';
		$related_data[2]='http://isiscb.org/xml/'."$directoryXMLa{ $journal_link_ID }".'/'."$identifierXMLa{ $journal_link_ID }".'.xml';
		$related_data[3]=$journals{$this->{journal_link_review}};
		$related_data[6]=$this->{volume_rev};
		$related_data[7]=$this->{jrevpages};
		$related_data[8]=$this->{year};
		#$journalTOC{$this->{journal_link_review}} = "$journalTOC{$this->{journal_link_review}}"."\t$this->{record_number}";
		my $jtitle_short='';
		if ($related_data[3]=~/(.*?):/){
			$jtitle_short=$1;
		}else{
			$jtitle_short=$related_data[3]
		}
		$citation="$jtitle_short $related_data[6]: $related_data[7]";
		$citation=~s/(.*)--/$1-/;
		#$modsLinks2Add2EAD{$journal_link_ID}="$modsLinks2Add2EAD{$journal_link_ID}"."$recordID".'---other---Includes'."\t";  
		make_related_item(@related_data);
	}
	
	if ($this->{link2record} ne '' ){
		my $linked_rec = $this->{link2record};
			
		if( $this->{doc_type} =~/Chapter/i ){
			
			@related_data='';
			$related_data[0]='Appears in Book';
			$related_data[1]='host';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[5]=$data{$linked_rec}->{editor};
			$related_data[7]=$this->{chpages};
			$related_data[8]=$data{$linked_rec}->{year};
			$related_data[10]=$data{$linked_rec}->{place_publisher};
			make_related_item(@related_data);
			
			$citation = "Pp. $related_data[7] in $related_data[3] edited by ";
			my %names = make_name($linked_rec, editor, li);
			foreach $name (keys %names){
				$name_unicode = $names{$name};
				$citation= "$citation"."$name_unicode; "; 
			}
			$citation=~s/--/-/;
			$citaiton=~s/;\s$//;
			
		}elsif( $this->{doc_type} =~/review/i ){
			
			@related_data='';
			$related_data[0]='Review of';
			$related_data[1]='reviewOf';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[5]=$data{$linked_rec}->{editor};
			$related_data[8]=$data{$linked_rec}->{year};
			make_related_item(@related_data);
			
		}elsif( $this->{doc_type} =~/article/i ){
			
			@related_data='';
			$related_data[0]='Part of Article Series';
			$related_data[1]='series';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[6]=$data{$linked_rec}->{volume};
			$related_data[7]=$data{$linked_rec}->{pages};
			$related_data[8]=$data{$linked_rec}->{year};
			make_related_item(@related_data);
			
		}else{	
			
			@related_data='';
			$related_data[0]='Related item';
			$related_data[1]='host';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[5]=$data{$linked_rec}->{editor};
			$related_data[6]=$data{$linked_rec}->{volume};
			$related_data[7]=$data{$linked_rec}->{pages};
			$related_data[8]=$data{$linked_rec}->{year};
			make_related_item(@related_data);
		}
			
	}
	
	if ($this->{series} ne '' && $isThesis eq 'no'){
		
		my $series =$this->{series};
		my $series_nameonly=$series;
		my $series_number='';
		if ($series ne ''){
			
			#if you can grab the number, assume only the most simple forat "wwwwww, d"			
			if($series_nameonly=~s/,\s+(\d+)$//){
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
		#$related_data[2]='http://isiscb.org/xml/CBB'."XXXXXX".'.xml';
		$related_data[2]='';
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
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[7]=$data{$linked_rec}->{pages};
			make_related_item(@related_data);
			
        	}elsif($this->{doc_type} eq 'Book' && $data{$linked_rec}->{doc_type} eq 'Chapter'){
        		
        		@related_data='';
        		$related_data[0]='Includes chapter';
        		$related_data[1]='constituent';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[7]=$data{$linked_rec}->{chpages};
			make_related_item(@related_data);
			
        	}elsif( $esseyrefs{$linked_rec} ne ''){
		
        		my @linked=split(/,/, $esseyrefs{$linked_rec} );
        		my @sorted = sort {$a <=> $b} @linked;
        		my $er_linked_rec=$sorted[1];  #there is an empty records that goes in [0]
        		
        		@related_data='';
        		$related_data[0]='Is reviewed by';
        		$related_data[1]='isReferencedBy';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[5]=$data{$linked_rec}->{editor};
			$related_data[8]=$data{$linked_rec}->{year};
			make_related_item(@related_data);
		
		}else{
        		@related_data='';
        		$related_data[0]='Related item';
        		$related_data[1]='constituent';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$data{$linked_rec}->{title};
			$related_data[4]=$data{$linked_rec}->{author};
			$related_data[5]=$data{$linked_rec}->{editor};
			$related_data[8]=$data{$linked_rec}->{year};
			make_related_item(@related_data);
			
        	}
        
     
        }       
        #if the items is reviewed, list links to reviews 
        
        
        if ($this->{reviewes} ne ''){   ##is the spelling correct here? yes
        	
        	my @revs=split(/,/, $this->{reviewes});
        	foreach $rev (@revs){
        		next if $rev eq '';
         		
        		@related_data='';
        		$related_data[0]='Is reviewed by';
			$related_data[1]='isReferencedBy';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$linked_rec}".'/'."$identifierXML{$linked_rec}".'.xml';
			$related_data[3]=$journals{  $journalIDmap { $data{$rev}->{journal_link_review}}} ;
			$related_data[4]=$data{$rev}->{author};
			$related_data[6]=$data{$rev}->{volume_rev};
			$related_data[7]=$data{$rev}->{jrevpages};
			$related_data[8]=$data{$rev}->{year};
			make_related_item(@related_data);
        	}
        	
        }
        
        
        #make a reference to the printed CB volume where the citation came from
        #the id is expected in sqare bracets in the Data Publihsed Print field
        if ( $this->{date_pub_print} =~ /\[(\d+)\]/ ){
        		my $printCBid=$1;
        		@related_data='';
        		$related_data[0]='Citation originally published in';
			$related_data[1]='isReferencedBy';
			$related_data[2]='http://isiscb.org/xml/'."$directoryXML{$printCBid}".'/'."$identifierXML{$printCBid}".'.xml';
			$related_data[3]=$data{$printCBid}->{title};
			$related_data[4]=$data{$printCBid}->{author};
			$related_data[5]=$data{$printCBid}->{editor};
			$related_data[8]=$data{$printCBid}->{year};
			make_related_item(@related_data);
        }
}

sub mods_make_identifier{
	$text_MODS="$text_MODS"."\t".'<identifier type="local" displayLabel="Permanent link">';
	$text_MODS="$text_MODS".'http://isiscb.org/xml/'."$directoryXML{$recordID}".'/'."$identifierXML{$recordID}".'.xml';
	$text_MODS="$text_MODS".'</identifier>'."\n";
	
	$text_MODS="$text_MODS"."\t".'<identifier type="isis" displayLabel="isisCB identifier">';
	$text_MODS="$text_MODS"."$identifierXML{$recordID}";
	$text_MODS="$text_MODS".'</identifier>'."\n";
	
	#if there is ISBN
	
	my $isbn = '';
	if ($this->{isbn} ne ''){
		$isbn=$this->{isbn};
	}elsif($linked->{isbn} ne '' && $this->{doc_type} eq 'Chapter'){
		$isbn= $linked->{isbn};
	}
	my @isbns=split(/[,|;]/, $isbn);
	
	foreach $is (@isbns){
		$is=~s/\-//g;
		if ( $is=~ /([\d|x]{13}|[\d|x]{10})/i ){
			$text_MODS="$text_MODS"."\t".'<identifier type="isbn" displayLabel="ISBN">';
			$text_MODS="$text_MODS"."$1";
			$text_MODS="$text_MODS".'</identifier>'."\n";
		}
	}    
	
	
	#ISSN
	my $issn ='';
	if ($journals_issn{$this->{journal_link}} ne ''){
		$issn=$journals_issn{$this->{journal_link}};
	}elsif	($journals_issn{$this->{journal_link_review}} ne ''){
		$issn=$journals_issn{$this->{journal_link_review}};
	}
	
	my @issns=split(/[,|;]/, $issn);
	foreach $is (@issns){
		next if ($is eq '');
		sqeez($is);
		#$is=~s /\-//;   #worldcat seems to work fine with the dash
		$text_MODS="$text_MODS"."\t".'<identifier type="issn" displayLabel="ISSN">';
		$text_MODS="$text_MODS"."$is";
		$text_MODS="$text_MODS".'</identifier>'."\n";
	}    
	
		
	#DOI 
	my $doi='';
	if ($this->{DOI} ne ''){
		$doi = $this->{DOI};
	}else{
		$doi = $this->{DOIrev};
	}
	
	unless ($doi eq ''){
		sqeez($doi);
		if ( $doi=~/doi\.org\/(.*)/ ){
			$doi=$1;
		}
		$text_MODS="$text_MODS"."\t".'<identifier type="doi" displayLabel="DOI">';
		$text_MODS="$text_MODS"."$doi";
		$text_MODS="$text_MODS".'</identifier>'."\n";
	}    
}

sub mods_make_classification{
	my $cat1=$cat2=$catCombined=$cataloger='';
    	($cat1, $cat2)=split(/-/, $this->{categories});
    	
    	
    	if ($catalogerInfo{ $this->{record_number} } =~ /neu/ ){
    		$cataloger='neu';	
    	}else{
    		$cataloger='spw';
    	}
    	
    	$text_MODS="$text_MODS"."\t".'<classification authority="isisCB-codes" edition="'."$cataloger".'">';
    	$text_MODS="$text_MODS"."$this->{categories}";
    	$text_MODS="$text_MODS".'</classification>'."\n";
    	foreach $cat ($cat1, $cat2){

    		my $categ=$categories{$cat};
    		$text_MODS="$text_MODS"."\t".'<classification authority="isisCB-category" edition="'."$cataloger".'">';
    		$text_MODS="$text_MODS"."$categ";
    		$catCombined="$catCombined"."$categ - ";
    		$text_MODS="$text_MODS".'</classification>'."\n";
    	}
    	$text_MODS="$text_MODS"."\t".'<classification authority="isisCB-category-combined" edition="'."$cataloger".'">';
    	$catCombined=~ s/\s-\s$//;
    	$text_MODS="$text_MODS"."$catCombined";
    	$text_MODS="$text_MODS".'</classification>'."\n";	
    	
    	$roleTerm='';
	#$xlinkRoleEAC='Classification';
	#$xlinkRoleMODS='Is about';
	$localTypeEAC='subject';
	$localTypeMODS='Classification';
	$resourceRelationshipTypeEAC='subjectOf';
    	
	#print "$this->{record_number} - $this->{categories} - $eacClassificationCode{ $this->{categories} }\n";
	
    	$linkData=[ $eacClassificationCode{ $this->{categories} }, $xlinkRoleEAC, $xlinkRoleMODS, $localTypeEAC, $localTypeMODS, $catCombined, $resourceRelationshipTypeEAC, $this->{year}, $this->{doc_type}, $this->{record_number} ];
	mods_make_link_to_eac ($linkData);
}

sub mods_make_recordInfo{
	#prepopulated text for the search app etc
	
	$text_MODS="$text_MODS"."\t".'<note type="displayText_1">';
	
        $text_MODS="$text_MODS"."$this->{responsibility}";
	$citationTemp=$citationTemp."$displayText_1\t";
        $text_MODS="$text_MODS".'</note>'."\n";
	
	$text_MODS="$text_MODS"."\t".'<note type="displayText_2">';
	my $title=$this->{title};
	$text_MODS="$text_MODS"."$title";
	$text_MODS="$text_MODS".'</note>'."\n";
	
	$text_MODS="$text_MODS"."\t".'<note type="displayText_3">';
	$text_MODS="$text_MODS"."$citation";  #gets made above
	$citationTemp=$citationTemp."$citation\n";
	$text_MODS="$text_MODS".'</note>'."\n";
	
	
	
	####################
	#recordInfo
	@time=localtime(time);
	$year= $time[5]+1900;
	$month=$time[4]+1;
	$day=$time[3];
	my $CreationDate="$year-$month-$day";
	
	$text_MODS="$text_MODS"."\t".'<recordInfo>'."\n";
	
	$text_MODS="$text_MODS"."\t\t".'<recordOrigin>'."\n";
	$text_MODS="$text_MODS"."Record generated from IsisCB FileMaker database version $localversionFMO by horus.pl.\n";
	$text_MODS="$text_MODS"."The orignal IsisCB record had the following information:\n";
	my $a1=$this->{source};
	$text_MODS="$text_MODS"."Source of Data: $a1\n";
	my $a2=$this->{date_modified};
	$text_MODS="$text_MODS"."Date Modified: $a2\n";
	my $a3=$this->{date_created};
	$text_MODS="$text_MODS"."Date Created: $a3\n";
	my $a4=$this->{modifier_name};
	$text_MODS="$text_MODS"."Last Changed by: $a4\n";
	my $a5=$this->{date_entered};
	$text_MODS="$text_MODS"."Date data entry completed: $a5\n";
	my $a6=$this->{date_proofed};
	$text_MODS="$text_MODS"."Date proofed: $a6\n";
	my $a7=$this->{date_sub_checked};
	$text_MODS="$text_MODS"."Date approved by bibliographer: $a7\n";
	my $a8=$this->{date_pub_print};
	$text_MODS="$text_MODS"."Date published in Isis: $a8\n";
	my $a9=$this->{date_pub_rlg};
	$text_MODS="$text_MODS"."Date published online: $a9\n";
	$text_MODS="$text_MODS"."\t\t".'</recordOrigin>'."\n";
	
	$text_MODS="$text_MODS"."\t\t".'<recordCreationDate encoding="w3cdtf">'."$CreationDate".'</recordCreationDate>'."\n";
	$text_MODS="$text_MODS"."\t".'</recordInfo>'."\n";
	########
	#closing
}

1;
