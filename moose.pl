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
    #use DB_File;
#require Net::SMTP;                 #sending email

require 'subs\sqeez.pl';
require 'subs\read_aux_files.pl';
require 'subs\read_data.pl';
require 'subs\print_data.pl';
require 'subs\errors.pl';
require 'subs\sorts.pl';
require 'subs\character_convert.pl';
require 'subs\character_map.pl';
require 'subs\cyrillic_map.pl';
require 'subs\greek_map.pl';
require 'subs\ascii_map.pl';
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
#require 'subs\alert.pl';
require 'subs\babel.pl';
require 'subs\hyphenation.pl';
require 'subs\make_rlg.pl';
require 'subs\make_html.pl';
require 'subs\analysis.pl';
require 'subs\subjects_sugest.pl';

############################################################################
#READ DATA
############################################################################

#determine what is going on
read_fm_options();
set_options($option);

#read auxilary files
    
read_aux_files();

tie %namesIndex,  "Tie::IxHash";

open (IN, "< $the_in_File") || error_b("[Error 171] Cannot open $the_in_File $!");

my $howmany=-1;
$bksp=chr(8);
print "Reading       ";
while (<IN>){

    chomp;
    if($howmany==-1){
        read_header($_);              #for the first record splits fileds
    }else{
        my $record = read_data($_);                   #this will pull out all important information, sort etc
        #moved this down, becase rev sort need data form book which may not have been read yet
        push (@tosort1, $record);
        #sort_records( \%{$data{$record}} , $options[$choice]);     #creat a hash with record numbers which can be sorted approprietaly

    }
    $howmany++;
    if($howmany=~/0$/){
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

#adds categories to essay book review records in read_data.pl
addcats();   
                       
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
subjects_check($this);
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
subjects_check($this);

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
if($htmlFMO=~/yes/i){ print_html() }
#close the databases

}
1;
