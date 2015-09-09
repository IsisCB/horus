sub moose {
	$option=$_[0];
	#Title:The Moose
	#Author: sylwester ratowt
	#Date: 10 January 2005
	#Description: This script manipulates a file exported from FileMaker
	#       and performes some machine cleaning on that file. It alos
	#       preperes the data for export to RLG, as well as creat LaTeX
	#       file in a variety of formats.
	#####################################################################
	
	
	
	
	############################################################################
	#REQUIRE
	############################################################################
	
	require Text::CSV;                  #spliting csv
	use File::Copy;
	require Net::FTP;
	require Tie::IxHash;
	use Roman;
	#use diagnostics;
	
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	
	
	require 'subs\sqeez.pl';
	require 'subs\read_aux_files.pl';
	require 'subs\read_data.pl';
	require 'subs\print_data.pl';
	require 'subs\errors.pl';
	require 'subs\sorts.pl';
	require 'subs\names.pl';
	require 'subs\pages.pl';
	require 'subs\index.pl';
	require 'subs\full_citation.pl';
	require 'subs\check_form.pl';
	require 'subs\make_tex.pl';
	require 'subs\subjects_check.pl';
	require 'subs\tex_parts.pl';
	require 'local\introduction.pl';
	require 'subs\makejlist.pl';
	require 'subs\set_options.pl';
	require 'subs\category_comand.pl';
	require 'subs\fm_read_options.pl';
	require 'subs\print_section.pl';
	require 'subs\babel.pl';
	require 'subs\hyphenation.pl';
	require 'subs\make_ris.pl';
	require 'subs\make_rlg.pl';
	require 'subs\make_html.pl';
	require 'subs\make_MODS.pl';
	require 'subs\make_MODS_parts.pl';
	require 'subs\make_MODSxEADRDF.pl';
	
	############################################################################
	#READ DATA
	############################################################################
	
	#determine what is going on
	read_fm_options();
	set_options($option);
	
	read_aux_files();
	

	tie %namesIndex,  "Tie::IxHash";
	
	open IN, "<:utf8", $the_in_File or error_b("[Error 171] Cannot open $the_in_File $!");
	
	my $howmany=-1;
	$bksp=chr(8);
	print "Reading       ";
	while (<IN>){
		
		chomp;
		if($howmany==-1){
			read_header($_);              #for the first record splits fileds
		}else{
			my $record = read_data($_);                   #this will pull out all important information, sort etc
			
			push (@tosort1, $record);
			#moved this down, becase rev sort need data form book which may not have been read yet
			#sort_records( \%{$data{$record}} , $options[$choice]);     #creat a hash with record numbers which can be sorted approprietaly
			
		}
		$howmany++;
		if($howmany=~/000$/){
			print "$bksp$bksp$bksp$bksp$bksp$bksp";
			@prtdig=split(//, $howmany);
			while ($#prtdig < 5){             #padd till there are 6 digits
				unshift (@prtdig, ' ');
			}
			foreach $a (@prtdig){
				print "$a";
			}
		}    
	}
	
	#temp for making standalone contribtor list
	#close OUT;
	
	foreach $a (@tosort1){
		sort_records( \%{$data{$a}} , $options[$choice]);     #creat a hash with record numbers which can be sorted approprietaly
	}
	
	
	
	print "$bksp$bksp$bksp$bksp$bksp$bksp";
        @prtdig=split(//, $howmany);
        while ($#prtdig < 5){             #padd till there are 6 digits
        	unshift (@prtdig, ' ');
        }
        foreach $a (@prtdig){
        	print "$a";
        }    
        print " records.\n";
        close IN;
        
        
        #now decide which records are missing
        foreach $m (keys %linkedrecords){
        	if($linkedrecords{$m} ne 'exists'){
        		$missingrecords=1;
        	}
        }
        if ($missingrecords==1){
        	$togetfile=$toget_File;
        	open (OUT, "> $togetfile") || error_b("[Error 172] Counld not open $togetfile $!"); 
        	foreach $m (keys %linkedrecords){
        		unless ($m eq '') {
        			print OUT "$m\t \n";
        			if ($linkedrecords{$m} ne 'exists'){
        				$linkedrecords{$m}=~s/,$//;
        				warning_q("[Warning 101] Record $linkedrecords{$m} links to missing record $m.");
        			}
        		}          
        	}
        	close OUT;   
        }    
        
        log_q("$howmany records read");
        log_q("moose.pl running $options[$choice] mode");
        
        ############################################################################
        #PROCESS DATA -- TO FILEMAKER
        ############################################################################
        if($options[$choice] eq 'regular' || $options[$choice] eq 'one'){
        	
        	
        	$recordcount=0;
        	#print "Writing       ";
        	foreach my $record (sort keys %sort_array){
        		#   $recordcount++;
        		#    print "$bksp$bksp$bksp$bksp$bksp$bksp";
        		#    @prtdig=split(//, $recordcount);
        		#    while ($#prtdig < 5){             #padd till there are 6 digits
        		#        unshift (@prtdig, ' ');
        		#    }
        		#    foreach $a (@prtdig){
        		#        print "$a";
        		#    }
        		
        		
        		#tie hashs referece to $this
        		$this=\%{$data{$record}};
        		#make a value for journal title
        		if ($this->{journal_link} ne ''){
        			$this->{journal}=$journals{$this->{journal_link}};
}elsif($this->{journal_link_review}  ne ''){
	$this->{journal}=$journals{$this->{journal_link_review}};
}
#now do all the things that need to be done
check_form($this);
pages($this);
#subjects_check($this);  #
$this->{'place_publisher'}=~s/\s:\s/: /g;
$this->{'place_publisher'}=~s/\s;\s/; /g;
#if($this->{checkedout}=~/check/ && $this->{doc_type} ne 'Review'){
#    subjects_suggest($this);
#    }

full_citation($this);
if($this->{doc_type} eq 'Review'){
	#do nothing, the book is what needs to be run
}elsif($this->{doc_type} eq 'Book'){
	make_tex($this, $tex_File);
	make_tex_rev($this, $tex_File);
}else{
	make_tex($this, $tex_File);
}    


#print to import back only if checked out ( this should take care of the moose genereted essay review record)
#print "$this->{record_number} - $this->{checkedout} \n";
if($this->{checkedout}=~/check/){
	make_mer($this);
}

		}#end foreach
		make_tex_end($tex_File);
		log_q("$recordcount records printed");
		#print " records.\n";
		
		
	}
	
	############################################################################
	#PROCESS DATA -- TO LATEX
	############################################################################
	if($options[$choice] eq 'proof' || $options[$choice] eq 'final' || $options[$choice] eq 'htmldb' || $options[$choice] eq 'printout' || $options[$choice] eq 'printoutALPHA'){
		
		$item_count=1;
		#sort things to determine the item numbers
		foreach $record (sort {$sort_array{$a} cmp $sort_array{$b}}  keys %sort_array){
			$this=\%{$data{$record}};
			$itemnumber{ $this->{record_number} } = $item_count;
			$item_count++;
		}
		
		
		#clearup the reviewss
		foreach $r (keys %revieweditems){
			#first take the sort orders for the items that are acctualy reviewd
			next if $r eq '';
			next if $sort_rev_array{$r} eq '';
			$revieweditems{$r}=$sort_rev_array{$r};
		}
		$rev_item_count=1;
		#sort things to determine the item numbers
		foreach $record (sort {$revieweditems{$a} cmp $revieweditems{$b}}  keys %revieweditems){
			$this=\%{$data{$record}};
			$revitemnumber{ $this->{record_number} } = 'R'."$rev_item_count";
			$rev_item_count++;
		}
		
		$recordcount=0;
		print "Writing       ";
		#now read the data for real
		foreach $record (sort {$sort_array{$a} cmp $sort_array{$b}}  keys %sort_array){
			$recordcount++;
			print "$bksp$bksp$bksp$bksp$bksp$bksp";
			@prtdig=split(//, $recordcount);
			while ($#prtdig < 5){             #padd till there are 6 digits
				unshift (@prtdig, ' ');
			}
			foreach $a (@prtdig){
				print "$a";
			}
			
			
			#tie hashs referece to $this
			$this=\%{$data{$record}};
			
			#now do all the things that need to be done
			###############################
			#pull_names($this, author);
			#pull_names($this, editor);
			#pull_names($this, description);
			#pull_names($this, edition_details);
			
			#contributors_list($this->{record_number}, author, last_first);
			#contributors_listcontributors_list($this->{record_number}, editor, last_first);
			#contributors_list($this->{record_number}, description, last_first);
			contributors_list($this->{record_number}, final);
			###################################################3
			subjects_check($this);
			make_tex($this, $tex_File);        
			add2index($this,$recordcount,$record); 
			
		}#end foreach
		
		###now print review
		make_rev_chap($tex_File);
		$recordcount=0;
		foreach $record (sort {$revieweditems{$a} cmp $revieweditems{$b}}  keys %revieweditems){
			$recordcount++;
			
			#tie hashs referece to $this
			$this=\%{$data{$record}};
			#contributors_list($this->{record_number}, final);
			make_tex_rev($this, $tex_File);         #second arguemnt is the name of the file
			$indexnumber='R'."$recordcount";
			#add2index($this,$indexnumber,$record); 
			
		}#end foreach
		
		make_tex_end($tex_File);   #argument will be the filename
		log_q("$recordcount records printed");
		print " records.\n";
	}
	
	############################################################################
	#PROCESS DATA -- TO RLG
	############################################################################
	if($options[$choice] eq 'rlg'){
		
		#set the array of export field names
		@rlg_export_fields=qw(RecordID doctype author editor title details year series details2 publish journal volume pages author2 title2 editor title publisher empty1 ISBN contrib language descript empty2 subjects contents );
		
		print "Writing       ";
		$bksp=chr(8);
		foreach $record (keys %sort_array){
			$recordcount++;
			if($recordcount=~/0$/){     #print on the 10s
				print "$bksp$bksp$bksp$bksp$bksp$bksp";
				@prtdig=split(//, $recordcount);
				while ($#prtdig < 5){             #padd till there are 6 digits
					unshift (@prtdig, ' ');
				}
				foreach $a (@prtdig){
					print "$a";
				}
			}   
			
			#tie hashs referece to $this
			$this=\%{$data{$record}};
			
			pull_names($this,author);
			pull_names($this,editor);
			pull_names($this,description);
			pull_names($this,edition_details);
			#added 12 feb 2009
			#subjects_check($this);
			
			make_rlg($this);
			
		}#end foreach
		print "$bksp$bksp$bksp$bksp$bksp$bksp";
		@prtdig=split(//, $recordcount);
		while ($#prtdig < 5){             #padd till there are 6 digits
			unshift (@prtdig, ' ');
		}
		foreach $a (@prtdig){
			print "$a";
		}
		print " records.\n";
		#close the tex file
		$outfile2=$rlg_out_File;
		open (OUT2, ">> $outfile2") || error_s("[Error 195] Cannot open $outfile2 $!");
		print OUT2 "\n";
		close OUT2;
		
		log_q("$recordcount records written");
	}
	
	
	############################################################################
	#process data for MODS
	############################################################################
	if($options[$choice] eq 'make_MODS'){
		
		
		print "Running make_MODES \n";
		require 'subs\unicode_convert2.pl';
		
		read_unicode_file(); 
		
		#set the array of export field names
		#@rlg_export_fields=qw(RecordID doctype author editor title details year series details2 publish journal volume pages author2 title2 editor title publisher empty1 ISBN contrib language descript empty2 subjects contents );
		
		#this is the counter for creating authority records
		#this only matters on the first run, after than then last number in the authority file will replace it
		$authorityID=100000;
		
		print "reading $authoritiesFile...";
		open (AUTHO, "< $authoritiesFile") || print "Cannot open $authoritiesFile for reading $!\n";
		while (<AUTHO>){
			chomp;
			@authoPs=split(/\t/, $_ );
			$authoList{$authoPs[0]}=$authoPs[1];
			if ($authoPs[1]=~/(\d+)/){
				
				#set the coutner for the next authority record to be the largest one in the file
				if ($1 > $authorityID){
					$authorityID = $1;
				}
			}
		}
		
		close AUTHO;
		print "DONE\n";
		
		
		
		
		print "runing make_MODS...\n";
		my $counter;
		foreach $record (keys %sort_array){
			$counter++;
			if($counter=~/0000$/){
				print "\t$counter\n";
			}
			#tie hashs referece to $this
			$this=\%{$data{$record}};
			
			pull_names($this,author);
			pull_names($this,editor);
			pull_names($this,description);
			pull_names($this,edition_details);
			
			pull_names_for_EAC($this);
			make_MODS($this);
		}
		
		
		print "DONE\n";
		
		print "running make_EACCPF...\n";		
		make_EACCPF();
		print "\tDONE\n";
	
		print "Making EAC files...\n";
		make_EACCPF_thes();
		
		
		#now print out the autholities file for all the authories
		
		$authList_FileN="$ap".'Aux Files\IsisDP\authoritesFile.tab';
		
		print "remaking $authList_FileN...";
		open (AUTHLIST, "> $authList_FileN") || error_s("[Error 195] Cannot open $authList_FileN $!");
		foreach $name (keys %authoList){
			print AUTHLIST "$name\t$authoList{$name}\n";
		}
		close AUTHLIST;   
		print "DONE\n";
		
		open OUT, ">:utf8", 'citations.tab' or error_s("[Error 195] Cannot open citations.tab $!");
		print OUT $citationTemp;
		close OUT;
		
		log_q("$recordcount records written");
	}
	
	############################################################################
	#PROCESS DATA -- TO RIS
	############################################################################
	if($options[$choice] eq 'ris'){
		
		@rlg_export_fields=qw(RecordID doctype author editor title details year series details2 publish journal volume pages author2 title2 editor title publisher empty1 ISBN contrib language descript empty2 subjects contents );
		
		print "Writing       ";
		$bksp=chr(8);
		foreach $record (keys %sort_array){
			$recordcount++;
			if($recordcount=~/0$/){     #print on the 10s
				print "$bksp$bksp$bksp$bksp$bksp$bksp";
				@prtdig=split(//, $recordcount);
				while ($#prtdig < 5){             #padd till there are 6 digits
					unshift (@prtdig, ' ');
				}
				foreach $a (@prtdig){
					print "$a";
				}
			}   
			
			#tie hashs referece to $this
			$this=\%{$data{$record}};
			
			pull_names($this,author);
			pull_names($this,editor);
			pull_names($this,description);
			pull_names($this,edition_details);
			#added 12 feb 2009
			subjects_check($this);
			
			make_ris($this);
		}#end foreach
		print "$bksp$bksp$bksp$bksp$bksp$bksp";
		@prtdig=split(//, $recordcount);
		while ($#prtdig < 5){             #padd till there are 6 digits
			unshift (@prtdig, ' ');
		}
		foreach $a (@prtdig){
			print "$a";
		}
		print " records.\n";
		#close the tex file
		$outfile2=$rlg_out_File;
		open (OUT2, ">> $outfile2") || error_s("[Error 195] Cannot open $outfile2 $!");
		print OUT2 "\n";
		close OUT2;
		
		log_q("$recordcount records written");
	}
	
	############################################################################
	#PROCESS DATA -- TO ALERT
	############################################################################
	if($options[$choice] eq 'alert'){
		
		foreach my $record (sort keys %sort){
			
			#tie hashs referece to $this
			$this=\%{$data{$record}};
			
			#now do all the things that need to be done
			
			pages($this);
			
			pull_names($this, author);
			pull_names($this, editor);
			pull_names($this, description);
			pull_names($this, edition_details);
			
			contributors_list($this->{record_number}, author, last_first);
			contributors_listcontributors_list($this->{record_number}, editor, last_first);
			contributors_list($this->{record_number}, description, last_first);
			contributors_list($this->{record_number}, edition_details, last_first);
			
			#subjects_check($this);
			
			
			write_data($this);
		}#end foreach
		
	}
	
	############################################################################
	#PROCESS DATA -- ANALYSIS
	############################################################################
	if($options[$choice] eq 'analysis'){
		
		
		#######
		################################
		#set option
		# a =  journals - categories table
		# b =  authors - journals - categories - publishers
		#c  = subjects
 		#d   disseratoins
		#you can combine multiple options eg  $analysis_option=ab
		my $analysis_option='c';
		
		####################################################
		if ($analysis_option =~/a/i){
			$tstamp=localtime;
			print "Analysis started on $tstamp\n";
			open OUT1, ">:utf8", $journal_categories_File or error_b("[Error 728340954] Cannot open $eac_FileN $!");
			
			print OUT1 "Journal\tid\tCategory\tNone\n";
			close OUT1;
			
			
			open OUT2, ">:utf8", $journal_categories_split_File or error_b("[Error 7283gagh40954] Cannot open $eac_FileN $!"); 
			print OUT2 "Journal\tid\tCategory\tNone\n";
			
			close OUT2;
			
			
			
			
			
			foreach my $record (keys %sort_array){
				#tie hashs referece to $this
				$this=\%{$data{$record}};
				
				#skip no print items & reviews
				#script in FM exports records >300,000 <5,000,000 with printed field not empty
				unless($this->{date_pub_print} eq '1/1/1001' || $this->{date_pub_print} eq 'NO PRINT' || $this->{doc_type} eq 'Review'){
					extract_for_analysis($this);
				}    
			}#end foreach
		}
		
		####################################################
		if ($analysis_option =~/b/i){
			$tstamp=localtime;
			print "Analysis started on $tstamp with option $analysys_option\n";
			open OUT1, ">:utf8", $analysis_author_File or error_b("[Error 724] Cannot open $eac_FileN $!");
			
			print OUT1 "Contributor\tCategory\tJournal\tPubisher\tYear\tid\tNone\n";
			close OUT1;
			
			open OUT2, ">:utf8", $analysis_author_journals_File or error_b("[Error 724] Cannot open $analysis_author_journals_File $!");
			
			print OUT2 "Contributor\tCategory\tJournal\tYear\tid\tNone\n";
			close OUT2;
			
			open OUT3, ">:utf8", $analysis_author_publishers_File or error_b("[Error 724] Cannot open $analysis_author_publishers_File $!");
			
			print OUT3 "Contributor\tCategory\tPubisher\tYear\tid\tNone\n";
			close OUT3;
			
			
			open OUT4, ">:utf8", $analysis_publishers_File or error_b("[Error 724] Cannot open $analysis_publishers_FileN $!");
			
			print OUT4 "Category\tPubisher\tYear\tid\tNone\n";
			close OUT4;
			
			foreach my $record (keys %sort_array){
				#tie hashs referece to $this
				$this=\%{$data{$record}};
				
				#skip no print items 
				#script in FM exports records >300,000 <5,000,000 with printed field not empty
				unless($this->{date_pub_print} eq '1/1/1001' || $this->{date_pub_print} eq 'NO PRINT' ){
					extract_for_analysis_authors($this);
				}    
			}#end foreach
		}
		
		##########################################
		if ($analysis_option =~/c/i){
			$tstamp=localtime;
			print "Analysis started on $tstamp with option $analysys_option\n";
			open OUT1, ">:utf8", $contributor_subject_File or error_b("[Error 724] Cannot open $contributor_subject_File $!");
			
			print OUT1 "Contributor\tSubject\tYear\tid\tNone\n";
			close OUT1;
			
			open OUT2, ">:utf8", $analysis_subject_category_File or error_b("[Error 724] Cannot open $analysis_subject_category_File $!");
			
			print OUT2 "Subject\tCategory\tYear\tid\tNone\n";
			close OUT2;
			
			open OUT3, ">:utf8", $analysis_journal_subject_File or error_b("[Error 724] Cannot open $analysis_author_publishers_File $!");
			
			print OUT3 "Journal\tSubject\tYear\tid\tNone\n";
			close OUT3;
			
			
			
			
			foreach my $record (keys %sort_array){
				#tie hashs referece to $this
				$this=\%{$data{$record}};
				
				#skip no print items 
				#script in FM exports records >300,000 <5,000,000 with printed field not empty
				unless($this->{date_pub_print} eq '1/1/1001' || $this->{date_pub_print} eq 'NO PRINT' ){
					extract_for_analysis_subjects($this);
				}    
			}#end foreach
		}
		
		if ($analysis_option=~/d/i){
			
			open OUT1, ">:utf8", $analysis_dissertation_File or error_b("[Error 72254] Cannot open $analysis_dissertation_File $!");
			print OUT1 "Author\tSchool\tSubject\tTime\\Culture\tYear\tId\tNone\n";
			close OUT1;
			
			foreach my $record (keys %sort_array){
				#tie hashs referece to $this
				$this=\%{$data{$record}};
				
				#skip no print items 
				#script in FM exports records >300,000 <5,000,000 with printed field not empty
				
				if ($this->{description} =~/dissertation\s+at\s+(.*?),\s+(\d\d\d\d)/i){
					
					unless($this->{date_pub_print} eq '1/1/1001' || $this->{date_pub_print} eq 'NO PRINT' ){
						analysis_dissertation($this);
						
					}    
				}
			}#end foreach
			
		}
		
		
		$tstamp=localtime;
		print "\n\nAnalysis ended at $tstamp\n";
		
		
		
	}
	############################################################################
	if($htmlFMO=~/yes/i){ print_html() }
	
}
1;
