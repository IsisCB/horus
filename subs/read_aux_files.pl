#determines if auxilary files are new and if so reads them


sub read_aux_files {

#use auxfile.pl unless it does not exist then create one

#(stat($sjc_File))[9] ||   make_hash ("$sjc_File", \%aux_file, aux_file);

require 'local\auxfile.pl';
require 'subs\sqeez.pl';



#the journals.tab requires: ID number \t name \t abbriviation \t ISSN \t importnace rank \n
my $journalsfile=$journals_File;

#contains %journal with ID as key adn value    name 
#contains %journal_abbreviations with ID as key adn value    abbriviations
#contains %journal_issn with ID as key adn value  issn
#contains %journal_rank with ID as key and valu as rank

###########journals
#check if the file has been modefied since last read
#if it has make a new jourlals.pl

#if ( (stat($journalsfile))[9] > $aux_files{$journalsfile}){
if (1>0){    #for forcing to make new sub file (testing only) 
    open IN, "<", $journalsfile || error_b("[Error 140] Cannot open $journalsfile $!");
    #log_p('New journals file found. Making new journals databases.');
    #empty the hashes
    %journals=();
    %journals_abb=();
    %journals_iss=();
    %journals_rank=();
    %journals_pagination=();
    while (<IN>){
        chomp;
        
        my @parts=split(/\t/,$_);
        unless($parts[1]=~/^no\sprint/i || $parts[1]=~/^duplicate/i){
            unless ($parts[1] eq '') {$journals{$parts[0]}=$parts[1]}    
            unless ($parts[2] eq '') {$journals_abbreviations{$parts[0]}=$parts[2]}
            unless ($parts[3] eq '') {$journals_issn{$parts[0]}=$parts[3]}
            unless ($parts[4] eq '') {$journals_rank{$parts[0]}=$parts[4]}
            unless ($parts[5] eq '') {$journals_pagination{$parts[0]}=$parts[5]}
            
        }
        
       
    }
    close IN;    
    $aux_files{$journalsfile}=(stat($journalsfile))[9];
    
}

#subjects.tab requires ID number \t subject \t subject type \t type sort order \t index print subject
#only good subjects need to be exported
my $subjectsfile=$subjects_File;
my %subjects_hash;
my %reverse_subjects_hash;
my %subject_index_hash;

#creats %subjects with key id value subject
#creats %reverse_subjects with key lower case subhect, value id


############subjects
#check if the file has been modefied since last read
#if it has make a new subjects.pl etc

#if ( (stat($subjectsfile))[9] > $aux_files{$subjectsfile}){
#if (1>0){    #for forcing to make new sub file 
print "fmw $fmw\n";
unless($fmw eq 'one'){   #so that will only do this when more than one record are moosed
    open IN, "<:utf8", $subjectsfile || error_b("[Error 141] Cannot open $subjectsfile $!");
    #log_p('New subjects file found. Making new subjects databases. This may take few minutes.');
    log_p('Reading thesaurus files');
    %subjects=();
    %reverse_subjects=();
    %subjects_index=();
    %subjects_type=();
    while (<IN>){
        chomp;
        #the expected order is 
        #ThesaurusID  \t Subject \t TypeOfTerm \t TypeSortOrder \t ScopeNote \t ClassificationCode
        my @parts=split(/\t/,$_);  
        #take care of encoding
        sqeez($parts[0]);
        sqeez($parts[1]);
        
        $subjects{$parts[0]}="$parts[1]";        
        $subjects_type{$parts[0]}="$parts[2]"; 
        $eacClassificationCode{$parts[5]}=$parts[0];
        
        #make a reverse hash, but first check for duplicates
        #the keys will be in lower case
        #skip Journals so then don't override accidently actaul subjects
        unless ($parts[2] eq 'Journal'){    
        	$reverse_subjects{lc($parts[1])}=$parts[0];
        }
        
        
        #deal with journals
        if ($parts[2] eq 'Journal'){
        	#the only thing that will happen is that the journalID will be grabed
        	$parts[4]=~/Journal ID="(\d+)"/;
        	$journalIDmap{ $1} = $parts[0];
        }
        
        #make xml directory
        my $authoIDx = sprintf("%09d", $parts[0]);  
	$authoIDx='CBA'."$authoIDx";
	$authoIDx =~ /(A\d\d\d\d\d)/;
	$directoryXMLa{ $parts[0]  } = 'A/'."$1";
	$identifierXMLa{ $parts[0] }= $authoIDx;
                
        
      
 
        
        #make  a hahs contineing index entries
        #
        if ($fmw eq 'final'){   #do this only for final printout
        if( $parts[4] eq '' && $parts[2]=~/Time period/i){  #probably can skip others as well
            next;
        }elsif( $parts[4] eq '' && $parts[2] ne 'Per. names'){
            $subjects_index{$parts[0]}=$parts[1];
        }elsif( $parts[4] eq ''){
            my $name=$parts[1];
            $name=~s/\(.*?\)$//;
            sqeez($name);
            $subjects_index{$parts[0]}=$name;
        }else{
            $subjects_index{$parts[0]}=$parts[4];
        }
        #clean up the -- things
        $subjects_index{$parts[0]}=~s/^--//;
        sqeez($subjects_index{$parts[0]});
       }    
    }
    close IN;
        
    $aux_files{$subjectsfile}=(stat($subjectsfile))[9];
    
}


#########categories
#expects category numbr \t full name \t short name
my $categoriesfile=$cats_File;

#creates %categories key numbrer, value long name
#creates %categories_short key numbrer, value short name

#if ( (stat($categoriesfile))[9] > $aux_files{$categoriesfile}){
if (1>0){    #for forcing to make new sub file (testing only 

    open IN, "<:utf8", $categoriesfile || error_b("[Error 143] Cannot open $categoriesfile $!");
    #log_p('New categories file found. Making new categories databases.');
    %categories=();
    %categories_short=();
    while (<IN>){
        chomp;
   
        my @parts=split(/\t/,$_);
        $categories{$parts[0]}=$parts[1];
        
        if ($parts[2] =~/[a-z]/){
        	$categories_short{$parts[0]}=$parts[2];
        	
        }
    }
    close IN;
    
    foreach my $cat (keys %categories){
    	    next if $categories{$cat} eq '';
    	    next if $categories{$cat} =~/OMIT/;
    	    if ($cat < 200){
    	    	    push(@ae, $cat);
    	    }elsif($cat < 400){
    	    	    push(@fg, $cat);
    	    }
    }
    
   # open (CAT, "> categoriesEAC.tab") || error_b("[Error ] Cannot open categoriesEAC.tab $!");
   # foreach my $cat1 (@fg){
   # 	    foreach my $cat2 (@ae){
   # 	    	    my $catNo="$cat1-$cat2";
   # 	    	    my $catName="$categories{$cat1} - $categories{$cat2}";
   # 	    	    print CAT "$catNo\t$catName\tspw\n";
   # 	    }
   # }
   # foreach my $cat2 (@ae){
   # 	    print CAT "$cat2\t$categories{$cat2}\tspw\t\n";
   # }
   # close CAT;
    
    $aux_files{$categoriesfile}=(stat($categoriesfile))[9];
    
}

#### horus errors
#expects id \d description \d cause
#if ( (stat($horuserrors_File))[9] > $aux_files{$horuserrors_File}){
if (1>0){    #for forcing to make new sub file (testing only 
    open IN, "<:utf8", $horuserrors_File || error_b("[Error 182] Cannot open $categoriesfile $!");
    #log_p('New errors file found. Making new errors databases.');
    %errorinfo=();
    %errorhelp=();
    while (<IN>){
        chomp;
 
        my @parts=split(/\t/,$_);
        $parts[1]=~s/<newline>/\n/g;
        $parts[2]=~s/<newline>/\n/g;
        $errorinfo{$parts[0]}=$parts[1];
        $errorhelp{$parts[0]}=$parts[2];
    }
    close IN;
    
    $aux_files{$horuserrors_File}=(stat($horuserrors_File))[9];
    
}

### allowed subject terms
#expects subject term \n

#first if file exists
#if(-e $subtype_File){
# if ( (stat($subtype_File))[9] > $aux_files{$subtype_File}){
if (1>0){    #for forcing to make new sub file (testing only 

    open IN, "<:utf8", $subtype_File || error_s("[Error 182.1] Cannot open $subtype_File $!");
    #log_p('New Allowed Subjects Term File found.');
     while (<IN>){
        chomp;
        $a_sub=lc($_);
        $allowedsubterm{$a_sub}=1;
        #log_p("READ AUX -- $_ -- $a_sub -- $allowedsubterm{$a_sub} \n");
    }    
   close IN;
    $aux_files{$subtype_File}=(stat($subtype_File))[9];
}   
#if it does not exist, then read the standard hash
#}else{  #if there is no
#%allowedsubterm=(
# #all lower case
# 'per. names'=>'1',
# 'time period'=>'1',
# '2003'=>'1',
# 'geog. term'=>'1',
# 'titles'=>'1',
# 'institutions'=>'1',
# #'mw subj.'=>'1',
# #'mw aspct.'=>'1',
# ''=>'1',    #so that unknow subject will not be tagged as not allowable type
#);
#}


####
make_hash ("$sjc_File", \%aux_files, aux_files);


#####temp make cat_des
#$cat_des_File="$ap".'Aux Files\cat_des.tab';
#
#open (IN, "< $cat_des_File") || error_s("Cannot open $cat_des_File $! in read_aux_files.pl");
#while (<IN>){
#chomp;
#($t1, $t2)=split(/\t/, $_);
#$cat_des{$t1}=$t2;
#}
#close IN;



}           #end of sub
#################################################

sub make_hash {
#this sub make a filename and a hash reference and prits that hash to a file

my $file=$_[0];
my $hash=$_[1];    
my $hash_name=$_[2];

open OUT, ">:utf8", $file || error_b(" [Error 144] Cannot open $file $!");

print OUT '%'."$hash_name = (\n";

#now print all the elements of the hash
foreach $e (keys %$hash){
    
    #escape all '
    $e=~s/'/\\'/g;
    $$hash{$e}=~s/'/\\'/g;
    
    print OUT "'$e' => '${$hash}{$e}',\n";

}
print OUT ");\n1;";

close OUT;
log_q("Created $file");

}

1;
