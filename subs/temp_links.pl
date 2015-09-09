
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
		$related_data[2]='http://resources.isisbibliography.org/MODS/CBJ'."$journal_link_ID".'.xml'
		$related_data[3]=unicode_convert($journals{$this->{journal_link}}, xml);
		make_related_item(@related_data);

	}elsif($this->{journal_link_review} ne ''){
		my $journal_link_ID="$this->{journal_link}";
		@related_data='';
		$related_data[0]='Appears in Journal';
		$related_data[1]='host';
		$related_data[2]='http://resources.isisbibliography.org/MODS/CBJ'."$journal_link_ID".'.xml'
		$related_data[3]=unicode_convert($journals{$this->{journal_link_review}}, xml);
		make_related_item(@related_data);
	}
	
	if ($this->{link2record} ne ''){
		my $linked_rec = $this->{link2record;
			
		if( $this->{doc_type} =~/Chapter/i ){
			@related_data='';
			$related_data[0]='Appears in Book';
			$related_data[1]='host';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$this->{link2record}".'.xml'
			$related_data[3]=unicde_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicde_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicde_convert($data{$linked_rec}->{editor}, xml);
			make_related_item(@related_data);
			
		}elsif( $this->{doc_type} =~/review/i ){
			@related_data='';
			$related_data[0]='Is a review of';
			$related_data[1]='reviewOf';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$this->{link2record}".'.xml'
			$related_data[3]=unicde_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicde_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicde_convert($data{$linked_rec}->{editor}, xml);
			$related_data[8]=unicde_convert($data{$linked_rec}->{year}, xml);
			make_related_item(@related_data);
			
		}elsif( $this->{doc_type} =~/article/i ){
			@related_data='';
			$related_data[0]='Part of Article Series';
			$related_data[1]='series';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$this->{link2record}".'.xml'
			$related_data[3]=unicde_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicde_convert($data{$linked_rec}->{author}, xml);
			$related_data[7]=unicde_convert($data{$linked_rec}->{pages}, xml);
			make_related_item(@related_data);
			
		}else{	
			@related_data='';
			$related_data[0]='Related item';
			$related_data[1]='host';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$this->{link2record}".'.xml'
			$related_data[3]=unicde_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicde_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicde_convert($data{$linked_rec}->{editor}, xml);
			make_related_item(@related_data);
			
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
		$related_data[2]='http://resources.isisbibliography.org/MODS/CBJ'."$this->{link2record}".'.xml'
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
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml'
			$related_data[3]=unicde_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicde_convert($data{$linked_rec}->{author}, xml);
			$related_data[7]=unicde_convert($data{$linked_rec}->{pages}, xml);
			make_related_item(@related_data);
			
        	}elsif($this->{doc_type} eq 'Book' && $data{$linked_rec}->{doc_type} eq 'Chapter'){
        		@related_data='';
        		$related_data[0]='Includes chapter';
        		$related_data[1]='constituent';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml'
			$related_data[3]=unicde_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicde_convert($data{$linked_rec}->{author}, xml);
			$related_data[7]=unicde_convert($data{$linked_rec}->{chpages}, xml);
			make_related_item(@related_data);
			
        	}else{
        		@related_data='';
        		$related_data[0]='Related item';
        		$related_data[1]='constituent';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$linked_rec".'.xml'
			$related_data[3]=unicde_convert($data{$linked_rec}->{title}, xml);
			$related_data[4]=unicde_convert($data{$linked_rec}->{author}, xml);
			$related_data[5]=unicde_convert($data{$linked_rec}->{editor}, xml);
			$related_data[8]=unicde_convert($data{$linked_rec}->{year}, xml);
			make_related_item(@related_data);
			
        	}
        
     
       
        #if the items is reviewed, list links to reviews 
        
        
        if ($this->{reviewes} ne ''){   ##is the spelling correct here? yes
        	
        	my @revs=split(/,/, $this->{reviewes});
        	foreach $rev (@revs){
        		next if $rev eq '';
         		
        		@related_data='';
        		$related_data[0]='Review';
			$related_data[1]='isReferencedBy';
			$related_data[2]='http://resources.isisbibliography.org/MODS/CBB'."$rev".'.xml'
			$related_data[3]=unicode_convert($journals{  $data{$rev}->{journal_link_review}} , xml);
			$related_data[4]=unicode_convert($data{$rev}->{author}, xml);
			$related_data[6]=unicode_convert($data{$rev}->{volume_rev}, xml);
			$related_data[7]=unicode_convert($data{$rev}->{jrevpages}, xml);
			$related_data[8]=unicode_convert($data{$rev}->{year}, xml);
			make_related_item(@related_data);
        	}
        	
        }
        
        
 
