#this file contians all the things needed to make an export to OCLC
#updated 3 December 2007 C.E.

#export contents listed chapters as seperate items
#put book citation information (publisher + yaer) in description field: (await OCLC)
#get rid of the year from reviewd book title (await OCLC)
#make sure the (ed) gets added to the reviewd author field
#awiat OCLC for info on essay review. right now changed so that book title is in the essay review title
#add essay review title to the decription field
#
#There is an issue with the checking journals in and that it updates not only the jouranls tp
#be checked in but also other recrods. the problem seems to be
#in "sr_Send update to the server (Marked set)" where some layouts are unknown
##
#


sub make_rlg{
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
##1##############################################
# *Record number
# (OK)
$rlgfields[0]=$this->{record_number};

#################################################

###2#############################################
# *Record type (book, book review, journal article,
# article in a book) ["Article in a book" refers to
# Chapter designation.]
# (OK)
#################################################
if ($this->{doc_type} eq 'Chapter'){
    $rlgfields[1]='Chapter';
}elsif($this->{doc_type} eq 'Review'){
    $rlgfields[1]='Book Review';
}elsif($this->{doc_type} eq 'JournalArticle'){
   $rlgfields[1]='Journal Article';
}else{   
    $rlgfields[1]=$this->{doc_type};
}
#################################################
#3.  *Authors (most works will either have field 3 or 4)
#[Format:  last, first middle, Jr./Sr./etc. Semicolon
#separates individuals.]
#(OK)
res_rlg($rlgfields[0],rlg);
$rlgfields[2]=$this->{author};

#################################################
#4.  *Editors (most works will either have field
#3 or 4) [Format:  last, first middle, Jr./Sr./etc.
#Semicolon separates individuals.]
#(OK)
$rlgfields[3]=$this->{editor};  #ok

#################################################
#5.  *Title
#(OK)
if ($this->{doc_type} eq 'Review'){   
    $rlgfields[4]='';
}else{
    $rlgfields[4]=$this->{title};
}
#################################################
#6.  Edition details (information about the item
#that is not in the title but relevant to the content
# of the book such as translator, translated title,
#language, person introducing or compiling the work,
#etc.) [Format:  Translated titles are indicated by
#"Translated title:" with square brackets around the
#title as follows: "Translated title: [title]".
#This information usually appear first in the field,
#and can be followed by further information.]
#(OK)
%eddetfolk=make_name($rlgfields[0],edition_details,fl_dis_rlg);   
foreach $name (keys %eddetfolk){
    $name2=$name;
    $name=~s/\*/\\*/g;     #to sub for *
    $name=~s/\^/\\^/g;     #to sub for ^
    $this->{edition_details}=~s/\$$name\$/$eddetfolk{$name2}/g;      #do it globaly so that all the instances will be converted
}
$rlgfields[5]=$this->{edition_details};

#################################################
#7.  *Year
#(OK)
if ($this->{doc_type} eq 'Chapter'){
    $rlgfields[6]=$linked->{year};
}else{    
    $rlgfields[6]=$this->{year};
}
    
#################################################
#8.  Series (for books)
#(OK)
$rlgfields[7]=$this->{series};

#################################################
#9.  Physical details (for books)
#(OK)
$rlgfields[8]=$this->{phyical_details};

#################################################
#10. Place: Publisher (for books)
#[Format:  Place and publisher are separated by colon.]
#(OK)
$rlgfields[9]=$this->{place_publisher};

#################################################
#11. Journal name (journal articles or book reviews)
#(OK)
if ( $this->{journal_link} ne '' ){
    $rlgfields[10]=$journals{$this->{journal_link}};
}else{
    $rlgfields[10]=$journals{$this->{journal_link_review}};
}

#################################################
#12. Volume number (journal articles or book reviews)
#[Format: Issue numbers are marked as follows: "4, no. 1",
#meaning vol. 4, no. 1.  If there are only issue numbers,
#the field will begin with "No. 1".]
#(OK)
if ($this->{volume} ne ''){
    #convert (no) to no. no
    $this->{volume}=~s/\s*\((.*)\)/, no. $1/;
    $rlgfields[11]=$this->{volume};
}else{
    $this->{volume_rev}=~s/\s*\((.*)\)/, no. $1/;
    $rlgfields[11]=$this->{volume_rev};
}

#################################################
#13. Pages (used for all record types)
#(OK)
if ($this->{pages} ne ''){
    $rlgfields[12]=$this->{pages};
}elsif($this->{jrevpages} ne ''){
    $rlgfields[12]=$this->{jrevpages};
}else{
    $rlgfields[12]=$this->{chpages};
}

#################################################
#14. Author or editor of book under review (book reviews
# [Format: where there is only an author the names
# are listed with no modification.  Where there is
#an editor or editors each name is followed by "(ed.)".
#  Where there is both an author and an editor,
#each author is listed with "(author)" after it,
#and each editor is listed with "(ed.)" after it.
#(OK)
if ($this->{doc_type} eq 'Review'){
    $rlgfields[13]=res_rlg($link2record,revRLG);
}

#################################################
#15. Title of book under review (book reviews)
#[Format: year of publication follows after the final period]
#(OK)
if ($this->{doc_type} eq 'Review'){
    $rlgfields[14]="$linked->{title}. $linked->{year}";
}

#################################################
#16. Editors of book (article in a book)
#(OK)
if ($this->{doc_type} eq 'Chapter'){
    $rlgfields[15]=res_rlg($linked->{record_number},edRLG);
}

#################################################
#17. Title of book (article in a book)
#(OK)
if ($this->{doc_type} eq 'Chapter'){
    $rlgfields[16]=$linked->{title};
}

#################################################
#18. Place: publisher of book (article in a book)
#(OK)
if ($this->{doc_type} eq 'Chapter'){
    $rlgfields[17]=$linked->{'place_publisher'};
}

##################################################19. Contents List
#(used for articles in a book (chapters)  or for articles in 
#a special series in a journal issue) [Format: each article is 
#separated by //; information within an article is separated by 
#<::>.  The order of the sub-fields is as follows: Record 
#number<::>Authors<::>Title<::>Pages.  Note that some but not all 
#of articles are listed independently.] (OK)

my $linked_record=$this->{linked_record};
$f25=$lnkpp=$lnktitle=$contname='';
my @linkedrecords=split(/,/, $linked_record);

#first do thing for sorting
%tempcontlist='';
foreach $linkrec (@linkedrecords){
    next if $linkrec eq '';
    sort_records(\%{$data{$linkrec}},conlist);
}
foreach $linkrec (sort {$tempcontlist{$a} cmp $tempcontlist{$b}} keys  %tempcontlist){
    #need to make sure that only the records that are not skiped will be printed
    next if $linkrec eq '';

    #do not if emplty, or a review
    unless ($linkrec eq '' || $data{$linkrec}->{doc_type} eq 'Review'){
        #skip essay reviews
        if ($linkrec=~/er$/){
            next;
        }
        $f25="$f25"."$linkrec<::>";    
        my %linkauthor=make_name($linkrec,author,lf_rlg );
        foreach $linkname (keys %linkauthor){
            $contname=$linkauthor{$linkname};
            $f25="$f25"."$contname; ";
        }
        #get rid of the comma before et al.
        $f25=~s/; et al/ et al/;
        $f25=~s/;\s$//;   
        my $lnktitle=$data{$linkrec}->{title}; 
        $f25="$f25"."<::>$lnktitle";
        unless($data{$linkrec}->{pages} eq ''){ 
            $lnkpp=$data{$linkrec}->{pages};
        }  
        #or for the chapters
        unless($data{$linkrec}->{chpages} eq ''){ 
            $lnkpp=$data{$linkrec}->{chpages};
        } 
        $f25="$f25"."<::>$lnkpp//";
    }
}    
$f25=~s/\/\/$//;
$rlgfields[18]=$f25; 
#################################################
#20. ISSN or ISBN
#(OK)
if ($this->{isbn} ne ''){
    $rlgfields[19]=$this->{isbn};
}elsif ( $this->{journal_link} ne '' ){
    $rlgfields[19]=$journals_issn{$this->{journal_link}};
}elsif($this->{doc_type} eq 'Chapter'){
    $rlgfields[19]=$linked->{isbn};
}else{
    $rlgfields[19]=$journals_issn{$this->{journal_link_review}};
}

#################################################
#21. Additional contributors (OK)
contributors_list($this->{record_number},rlg);
$rlgfields[20]=$this->{contributors};
#################################################
#22. Language (OK)
$rlgfields[21]=$this->{language};
#################################################
#23. Description (OK)

%descfolk=make_name($rlgfields[0],description,fl_dis_rlg);   
foreach $name (keys %descfolk){
    $name2=$name;
    $name=~s/\*/\\*/g;     #to sub for *
    $name=~s/\^/\\^/g;     #to sub for ^
    $this->{description}=~s/\$$name\$/$descfolk{$name2}/g;      #do it globaly so that all the instances will be converted
}
#read the contents list header (should only be one)
$tocheader='';
if ($this->{'description'}=~s/<TocHeader>(.*)<\/TocHeader>//){
    $tocheader="$1";
}

################do the xref thing
 while ($this->{description}=~/(<xref>.*?\[(.*?)\]<\/xref>)/g){
        ##########
        $l=$2;
        $ndes='';
        my $title=$data{$l}->{title};
        my $year=$data{$l}->{year};
        my $jlink=$data{$l}->{journal_link};
        my $jvol=$data{$l}->{volume};
        my $jpag=$data{$l}->{pages};
        my $dtpe=$data{$l}->{doc_type};
        my $jname=$journals{$jlink};
        $title=~s/:.*//;
        res_rlg($l,fl_dis_rlg);
        if($editor ne '' && ($editor=~/\sand\s/ || $editor=~/;/)){
            $editor=~s/;/,/g;
            $editor="$editor (eds.)";
        }elsif($editor ne ''){    
            $editor="$editor (ed.)";
        }
        unless ($author eq ''){$author="$author,"}    
        unless ($editor eq ''){$editor="$editor,"}        
        if ($dtpe eq 'JournalArticle'){
            $ndes="$author $editor $title $res2 <e>$jname</e> $jvol ($year): $jpag";
        }else{
            $ndes="$author $editor <e>$title</e> $res2 ($year)";
        }
        $this->{description}=~s/<xref>.*?<\/xref>/$ndes/;
    }
sqeez( $this->{description} );   
$this->{description}=~s/;$/./;

########################add contents listing
my $linked_record=$this->{linked_record};
$f25=$lnkpp=$lnktitle=$contname='';
my @linkedrecords=split(/,/, $linked_record);

#first do thig for sorting
%tempcontlist='';
foreach $linkrec (@linkedrecords){
    next if $linkrec eq '';
    sort_records(\%{$data{$linkrec}},conlist);
}
$linkedpresent=0;
foreach $linkrec (keys  %tempcontlist){
    if($sort_array{$linkrec} ne ''){
      $linkedpresent=1;
    }  
}
$firstconitem=0;
foreach $linkrec (sort {$tempcontlist{$a} cmp $tempcontlist{$b}} keys  %tempcontlist){
    #need to make sure that only the records that are not skiped will be printed
    next if $linkrec eq '';

    #do not if empty, or a review
    unless ($linkrec eq '' || $data{$linkrec}->{doc_type} eq 'Review'){
        #skip essay reviews
        if ($linkrec=~/er$/){
            next;
        }
        if ($firstconitem==0){
            if ($tocheader ne ''){
                $f25="$tocheader";
                $f25=~s/:\s*$//;   
            }else{    
                $f25="Contents";
            }
            #if($linkedpresent==1){
            #     $f25="$f25 (items marked with * are entered separately in the database): ";
            #}else{
                  $f25="$f25".': ';
            #}      
            $firstconitem=1;
        }
        #if the record is in the sort array, then assume it is being eneterd seperately, if not not.
        #i think now that there is no difference in entering, this could be eliminated
        if($sort_array{$linkrec} eq ''){
            $f25="$f25"."  ";
            #add the author name to the contributors list
             my %contl=make_name($linkrec,author,lf_rlg);
            foreach $a (keys %contl){
                unless ($contl{$a} eq ''){
                    $this->{contributors}="$this->{contributors}"."; $contl{$a}";
                }
            }
            $rlgfields[20]=$this->{contributors};
            $rlgfields[20]=~s/^;\s//;
            #contributors get cleanup at the end
            #undef(%contl); moved to after second
        }else{
        
        #####ALSO add the author name to the contributors list
             my %contl=make_name($linkrec,author,lf_rlg);
            foreach $a (keys %contl){
                unless ($contl{$a} eq ''){
                    $this->{contributors}="$this->{contributors}"."; $contl{$a}";
                }
            }
            $rlgfields[20]=$this->{contributors};
            $rlgfields[20]=~s/^;\s//;
            #contributors get cleanup at the end
            undef(%contl);
        #####    
        
        
            $f25="$f25"." ";
        }    
        my %linkauthor=make_name($linkrec,author,fl_dis_rlg );
        foreach $linkname (keys %linkauthor){
            $contname=$linkauthor{$linkname};
            $f25="$f25"."$contname, ";
        }
        #get rid of the comma before et al.
        $f25=~s/, et al/ et al/;
        my $lnktitle=$data{$linkrec}->{title}; 
        $f25="$f25"."$lnktitle";
        unless($data{$linkrec}->{pages} eq ''){ 
            $lnkpp=$data{$linkrec}->{pages};
        }  
        #or for the chapters
        unless($data{$linkrec}->{chpages} eq ''){ 
            $lnkpp=$data{$linkrec}->{chpages};
        }
        if ($lnkpp eq ''){
             $f25="$f25"."; ";
        }else{     
            $f25="$f25".", pp. $lnkpp; ";
        }    
    }
}    
$f25=~s/;\s$/./;
$rlgfields[22]="$this->{description}";
if($f25 ne ''){
    $rlgfields[22]="$rlgfields[22]"." $f25"; 
}
################################################# #24. Subject-Personal Name
#see 25
################################################# #25. Subjects-Geographical Name 
#[Format: separated by //] (OK) 
#subject will be seperated by category
#Subject-Personal Name
#Subject-Corporate Name
#Subject-Topical
#Subject-Geographical Name

undef(@topcub);
undef(@percub);

while($this->{subjects}=~/\[(.*?)\]/g){
	$d=$1;
	if ($subjects_type{$d} eq 'Time period'){
		push(@percub, $subjects{$d});
	}elsif($subjects_type{$d} eq 'Geog. term'){
		$rlgfields[24]="$rlgfields[24]"."$subjects{$d} // ";
	}elsif($subjects_type{$d} eq 'Institutions'){
		$rlgfields[25]="$rlgfields[25]"."$subjects{$d} // ";
	}elsif($subjects_type{$d} eq 'Per. names'){
		$rlgfields[23]="$rlgfields[23]"."$subjects{$d} // ";
    }else{
        push(@topcub, $subjects{$d});
    }
}
#make topical subjects
foreach $s (sort @percub){
	$rlgfields[26]="$rlgfields[26]"."$s // ";
}
foreach $s (sort @topcub){
	$rlgfields[27]="$rlgfields[27]"."$s // ";
}
#cleanup
$rlgfields[23]=~s#\s//\s$##;
$rlgfields[24]=~s#\s//\s$##;
$rlgfields[25]=~s#\s//\s$##;
$rlgfields[26]=~s#\s//\s$##;
$rlgfields[27]=~s#\s//\s$##;


################################################# #26. Subjects-Corporate Name
################################################# 27. Subjects-Topical
#see 25
################################################# 28. Category

#also add categories
$cat1=$cat2='';
($cat1, $cat2)=split(/-/, $this->{categories});
$rlgfields[28]="$categories{$cat1} -- $categories{$cat2}";
#cleanup
$rlgfields[28]=~s/\s--\s$//;

#######################################################################3

  
undef(%seeco);
#add fields for FileMaker file


$rlgfields[29]=$this->{recordVersion};
$rlgfields[30]=$this->{date_sub_checked};
$rlgfields[31]=$this->{date_proofed};
$rlgfields[32]=$this->{date_entered};
$rlgfields[33]=$this->{record_nature};
$rlgfields[34]=$this->{record_action};
$rlgfields[35]=$this->{date_pub_print};
$rlgfields[36]=$this->{date_pub_rlg};

############################
#cleanup contribtors
@contb=split(/;/, $rlgfields[20]);
undef(%ccb);
$rlgfields[20]='';
foreach $c (@contb){
	$c=~s/^\s//;
	unless($ccb{$c} == 1){
		$rlgfields[20]="$rlgfields[20]"."$c".'; ';
		$ccb{$c}=1;
	}
}
$rlgfields[20]=~s/;\s$//;



#now that have the whole thing, print it out
#print_rlg_proof();
foreach $f (@rlgfields){
    sqeez($f);
    $line="$line\t$f";
} 
$line=~s/^\t//;   
$outfile=$rlg_out_File;
if ($rlgfirstrecord eq ''){
    open (OUT, "> $outfile") || error_b("[Error 165] Cannot open $outfile $!");
    $rlgfirstrecord=1;
}else{    
    open (OUT, ">> $outfile") || error_b("[Error 166] Cannot open $outfile $!");
}
#get rid of comments
$line=~s/<com:.*?>//g;

$line=~s/<newline>/chr(11)/eg;    
print OUT "$line\n";
close OUT;
$line='';

}

######################################################
sub res_rlg {

$record_num=$_[0];
$revres=$_[1];          #to indicate that the thing is to be for the rev with initials only, or essyrev description
$author=$editor=$res='';


#print responsibility

undef(%author);
undef(%editor);
tie %author,  "Tie::IxHash";
tie %editor,  "Tie::IxHash";

if($revres eq 'revRLG' || $revres eq 'rlg'){
    %author=make_name($record_num,author,lf_rlg);
    %editor=make_name($record_num,editor,lf_rlg);
}elsif($revres eq 'fl_dis_rlg'){
    %author=make_name($record_num,author,fl_dis_rlg);
    %editor=make_name($record_num,editor,fl_dis_rlg);
}

#hold your horses, those things need to be in order

#first get back the names with all the info
@authorstab=split(/\n/, $namesIndex{$record_num}->{author});
@editorstab=split(/\n/, $namesIndex{$record_num}->{editor});

foreach $a (keys %author){
    $author = "$author"."; $author{$a}";
    $seenrlg{$author{$a}}=1;    #so that will not print in additional contributors
}

foreach $a (keys %editor){
    $editor = "$editor"."; $editor{$a}";
    $seenrlg{$editor{$a}}=1;    #so that will not print in additional contributors
}
$author=~s/^;\s//;
$editor=~s/^;\s//;
#if fixing the main names, just replace the field contents and quit
if($revres eq 'rlg'){
    $this->{author}=$author;
    $this->{editor}=$editor;
    return(1);
}elsif ($revres eq 'revRLG'){
     if ($author ne '' && $editor eq ''){             #if author is present
         $res=$author;
     }elsif($author ne '' && $editor ne ''){     #if author and editor
         foreach $a (keys %author){
         #    $res = "$res"."$author{$a} (author); ";
              $res = "$res"."$author{$a}; ";
         }
         foreach $a (keys %editor){
         #    $res = "$res"."$editor{$a} (ed.); ";
              $res = "$res"."$editor{$a} <responsibility: editor>; ";      
         }
     }elsif ($editor ne '' && $author eq ''){
         foreach $a (keys %editor){
         #    $res = "$res"."$editor{$a} (ed.); ";
              $res = "$res"."$editor{$a} <responsibility: editor>; ";         
         }
     }
     $res=~s/;\s$//;
     return($res);
}elsif ($revres eq 'edRLG'){
    foreach $a (keys %editor){
        $res = "$res"."$editor{$a}; ";
     }
     $res=~s/;\s$//;
     return($res);
}
}

###
sub print_rlg_proof{

$outfile2=$tex_File;
if ($rlgproof eq ''){
    open (OUT2, "> $outfile2") || error_s("[Error 193] Cannot open $outfile2 $!");
    print OUT2 "$head_rlg_proof\n";
    $rlgproof=1;
}else{
    open (OUT2, ">> $outfile2") || error_s("[Error 194] Cannot open $outfile2 $!");
    #print OUT2 '\noindent';
    print OUT2 '\begin{rlg}'; 
    #print OUT2 "\n";
    #print OUT2 '\setlenght{\itemsep}{0em}';
    #print OUT2 "\n";    
    for ($i=1; $i<25; $i++){
        next if $rlgfields[$i] eq '';
        if ($rlgfields[1] eq 'Book' && ($i==8 || $i==9 || $i==6 || $i==19)){
            next;
        }elsif($rlgfields[1] eq 'Journal Article' && ($i==10 || $i==11 || $i==6 || $i==12 || $i==19)) {
            next;
        }        
        print OUT2 '\item[\texttt{';
        print OUT2 "$rlg_export_fields[$i]";
        print OUT2 '}] ';
        $pt=cb2tx($rlgfields[$i]);
        print OUT2 "$pt";
        if ($i==1){ #print record id after the doc type
            print OUT2 " ("."$rlgfields[0]".")";
        }    
   }
   if ($rlgfields[1] eq 'Book'){
        print OUT2 '\item[\texttt{details}]';
        $pt="$rlgfields[8]".' // '."$rlgfields[9]".' // '."$rlgfields[6]".' // '."$rlgfields[19]\n";
        $pt=cb2tx($pt);
        print OUT2 "$pt";
    }elsif($rlgfields[1] eq 'Journal Article'){
        print OUT2 '\item[\texttt{journal}]';
        $pt="$rlgfields[10] <b>"."$rlgfields[11]"."</b> ("."$rlgfields[6]".") $rlgfields[12]".' // '."$rlgfields[19]\n";
        $pt=cb2tx($pt);
        print OUT2 "$pt";
    }   
   print OUT2 '\end{rlg}';   
   print OUT2 '\hrule \vspace{1em}';  
}
close OUT2;        
}

1;
