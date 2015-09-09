sub extract_for_analysis {
	
	use Encode;
	use utf8;
	
	my $id=$this->{record_number};
	my $journal=unicode_convert($journals{ $this->{journal_link} }, no_quote);
	my $category=$this->{categories};
	my $year=$this->{year};
	
	($cat1, $cat2) = split(/-/, $category);
	$cat1=$categories_short{$cat1};
	$cat2=$categories_short{$cat2};
	
	my @subjects=split(/\/\//, $this->{subjects});
	my @subs='';
	foreach $subject (@subjects){
		
		if($subject=~/\[(.*)\]/){
			push (@subs, $1);
		}
	}
	
	
	#journal-category
	if ($this->{journal_link}  ne ''){
		open OUT1, ">>:utf8", $journal_categories_File or error_b("[Error 728340954] Cannot open $eac_FileN $!");
		
		print OUT1 "$journal\t$id\t$category\t1\n";
		close OUT1;
		
		
		open OUT2, ">>:utf8", $journal_categories_split_File or error_b("[Error 7283gagh40954] Cannot open $eac_FileN $!"); 
		print OUT2 "$journal\t$id\t$cat1\n";
		if ($cat2 ne ''){
			print OUT2 "$journal\t$id\t$cat2\t1\n";
		}
		close OUT2;
		
		
	}	
	#subject-category
	
	
	
	#subject-subject
	
	
}

sub extract_for_analysis_authors{
	use Encode;
	use utf8;
	
	my $id=$this->{record_number};
	
	
	my $journal=unicode_convert($journals{ $this->{journal_link} }, no_quote);
	
	my $category=$this->{categories};
	my $year=$this->{year};
	
	($cat1, $cat2) = split(/-/, $category);
	$cat1=$categories_short{$cat1};
	$cat2=$categories_short{$cat2};
	
	my @subjects=split(/\/\//, $this->{subjects});
	my @subs='';
	foreach $subject (@subjects){
		
		if($subject=~/\[(.*)\]/){
			push (@subs, $1);
		}
	}
	
	
	
	pull_names($this, author);
	pull_names($this, editor);
	pull_names($this, description);
	pull_names($this, edition_details);
	contributors_list($id, final);
	
	@folks=split(/;/, $data{$id}->{contributors} );
	
	#my %folk1=make_name($id,edition_details,lf);   
	#my %folk2=make_name($id,description,lf);
	#my %folk3=make_name($id, author, lf);
	#my %folk4=make_name($id, editor, lf);
	
	#my %folks=(%folk1, %folk2, %folk3, %folk4);
	
	###do publisher
	my $publisher=unicode_convert($this->{place_publisher}, no_quote);
	
	
	if($publisher =~/:(.*);*/){
		$publisher=$1;
		
		sqeez($publisher);
		$publisher=~s/^the\s//i;
		$publisher=~s/Univ\./University/i;
		$publisher=~s/University\sPress/UP/i;
		sqeez($publisher);
		
		
		
	}
	
	#for books only, creates one row per published book, not per contributor
	if ($publisher ne ''){
		open OUT4, ">>:utf8", $analysis_publishers_File or error_b("[Error 724] Cannot open $analysis_author_publishers_File $!");
		if ($cat1 ne ''){
			print OUT4 "$cat1\t$publisher\t$year\t$id\t1\n";
		}
		if ($cat2 ne ''){
			
			print OUT4 "$cat2\t$publisher\t$year\t$id\t1\n";
		}
		close OUT4;
	}
	
	
	
	foreach $person (@folks){
		sqeez($person);
		unless ($person eq ''){
			
			$person=unicode_convert($person, no_quote);
			open OUT1, ">>:utf8",$analysis_author_File or error_b("[Error 7283q] Cannot open $eac_FileN $!");			
			
			if ($cat1 ne ''){
				print OUT1 "$person\t$cat1\t$journal\t$publisher\t$year\t$id\t1\n";
			}
			if ($cat2 ne ''){
				print OUT1 "$person\t$cat2\t$journal\t$publisher\t$year\t$id\t1\n";
				
			}
			close OUT1;
			
			
			#for journals only
			if ($journal ne ''){
				open OUT2, ">>:utf8", $analysis_author_journals_File or error_b("[Error 724] Cannot open $analysis_author_journals_File $!");
				if ($cat1 ne ''){
					print OUT2 "$person\t$cat1\t$journal\t$year\t$id\t1\n";
				}
				if ($cat2 ne ''){
					
					print OUT2 "$person\t$cat2\t$journal\t$year\t$id\t1\n";
				}
				close OUT2;
			}
			
			#for books only
			if ($publisher ne ''){
				open OUT3, ">>:utf8", $analysis_author_publishers_File or error_b("[Error 724] Cannot open $analysis_author_publishers_File $!");
				if ($cat1 ne ''){
					print OUT3 "$person\t$cat1\t$publisher\t$year\t$id\t1\n";
				}
				if ($cat2 ne ''){
					
					print OUT3 "$person\t$cat2\t$publisher\t$year\t$id\t1\n";
				}
				close OUT3;
			}
			
		}
	}
	
	
	@folks=%folk1=%folk2=%folk3=%folk4=$cat1=$cat2=$categoreis=$publisher=$year=$journal='';
	
	
	
	
	
}


sub extract_for_analysis_subjects{
	
	use Encode;
	use utf8;
	
	my $id=$this->{record_number};
	
	
	my $journal=unicode_convert($journals_abbreviations{ $this->{journal_link} }, no_quote);
	
	my $category=$this->{categories};
	my $year=$this->{year};
	my $title=unicode_convert($this->{title}, no_quote);
	
	($cat1, $cat2) = split(/-/, $category);
	if($categories_short{$cat1} ne ''){
		$cat1=	$categories_short{$cat1};
	}else{
		$cat1=$categories{$cat1};
	}
	if($categories_short{$cat2} ne ''){
		$cat1=	$categories_short{$cat2};
	}else{
		$categories{$cat2};
	}
	
	my @subjects=split(/\/\//, $this->{subjects});
	my @subs='';
	foreach $subject (@subjects){
		
		if($subject=~/\[(.*)\]/){
			push (@subs, $1);
		}
	}
	
	
	
	pull_names($this, author);
	pull_names($this, editor);
	pull_names($this, description);
	pull_names($this, edition_details);
	contributors_list($id, final);
	
	@folks=split(/;/, $data{$id}->{contributors} );
	
	
	foreach $s (@subs){
		unless ($subjects{$s} eq ''){
			$sub=unicode_convert( $subjects{$s}, no_quote );
			#person - subject
			
			open OUT1, ">>:utf8",$contributor_subject_File or error_b("[Error 7283q] Cannot open $eac_FileN $!");
			foreach $person (@folks){
				sqeez($person);
				unless ($person eq ''){
					
					$person=unicode_convert($person, no_quote);
					
					
					
					print OUT1 "$person\t$sub\t$year\t$id\n";
				}
			}
			
			close OUT1;
			
			#subecjt category
			open OUT2, ">>:utf8", $analysis_subject_category_File or error_b("[Error 724] Cannot open $analysis_subject_category_File $!");
			if ($cat1 ne ''){
				unless ($sub eq $cat1){
					print OUT2 "$sub\t$cat1\t$year\t$id\n";
				}
			}
			if ($cat2 ne ''){
				unless ($sub eq $cat2){
					print OUT2 "$sub\t$cat2\t$year\t$id\n";
				}
			}
			close OUT2;
			
			
			#Journal -subject	
			unless ($journal eq ''){
				open OUT3, ">>:utf8", $analysis_journal_subject_File or error_b("[Error 724] Cannot open $analysis_journal_subject_File $!");
				print OUT3 "$journal\t$sub\t$year\t$id\n";
				close OUT3;
			}
		}	
		
		
	}
	
}	


sub analysis_dissertation {
	use Encode;
	use utf8;
	
	my $desc=unicode_convert( $this->{description}, no_quote);
	
	if ($desc=~/dissertation\s+at\s+(.*?),\s+(\d\d\d\d)/i){
		my $school=$1;
		my $diss_year=$2;
		
		$school=~s/University/Univ./i;
		$school=~s/^the\s+//i;
		my $id=$this->{record_number};
		
		my $category=$this->{categories};
				
		($cat1, $cat2) = split(/-/, $category);
		
		if($categories_short{$cat1} ne ''){
			$cat1=	$categories_short{$cat1};
		}else{
			$cat1=$categories{$cat1};
		}
		
		if($categories_short{$cat2} ne ''){
			$cat2=	$categories_short{$cat2};
		}else{
			$cat2=$categories{$cat2};
		}
		
		if ($cat1 ne '' && $cat2 eq ''){
			$sub_cat=$cat1;
		}elsif($cat1 ne '' && $cat2 ne ''){
			$sub_cat=$cat2;
			$time_cat=$cat1;
		}		
		
		
		my $author=unicode_convert($this->{author}, no_quote) ;
		
		
		
		
		open OUT1, ">>:utf8", $analysis_dissertation_File or error_b("[Error 72254] Cannot open $analysis_dissertation_File $!");
		print OUT1 "$author\t$school\t$sub_cat\t$time_cat\t$diss_year\t$id\t1\n";
		close OUT1;
	}
	$school=$sub_cat=$time_cat=$year=$id=$cat1=$cat2='';
	
}
1;
