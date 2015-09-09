#this creats varius forms of the latex file

sub make_tex {
#as options takes reference to the hash and an option to
require 'subs\tex_parts.pl';

my $record=$_[0];
my $outfile=$_[1];
open (OUT, ">> $outfile") || error_b ("[Error 158] Cannot open $outfile $!");
unless ( $print_tex_head == 1) {
#if this is the first record on this run, deletes the old file and creas a new one
    close OUT;
    unlink($outfile);
    unlink($ids_File);
    open (OUT, ">> $outfile") || error_b ("[Error 159] Cannot open $outfile $1");
    if($options[$choice] eq 'final'){
        print OUT "$head_final";
        print OUT "$hyphenation";
        print OUT "$introduction";
        makejlist();
    }elsif($options[$choice] eq 'proof' || $options[$choice] eq 'one' || $options[$choice] eq 'regular' || $options[$choice] eq 'printout' || $options[$choice] eq 'printoutALPHA'){
        print OUT "$head_one";
    }
    print OUT "$mainmatter";
    $print_tex_head=1;
}


fix_contributors($record);
$description=cb2tx($description);    
#print "$edition_details\n";
$edition_details=cb2tx($edition_details);
#print "$edition_details\n";
    if ( $record->{journal_link} ne '' && $record->{journal_link} ne '1013'){
        if($journals_abbreviations{$record->{journal_link}} ne '' && $sfactorFMO >= 0){
             $journal=cb2tx($journals_abbreviations{$record->{journal_link}});
             #if there are perdiods in the abbreviation make sure they are not treated as sentence 
             $journal=~s/\.\s/.\\ /g;
        }else{
            $journal=cb2tx($journals{$record->{journal_link}});    
        }    
    }else{      #($record->{journal_link_review} ne '' && $record->{journal_link_review} ne '1013')
        if($journals_abbreviations{$record->{journal_link_review}} ne ''&& $sfactorFMO >= 0){
             $journal=cb2tx($journals_abbreviations{$record->{journal_link_review}});
             $journal=~s/\.\s/.\\ /g;
        }else{
            $journal=cb2tx($journals{$record->{journal_link_review}});    
        }    
    }

my $year=cb2tx($record->{year});
   if ($record->{volume} ne ''){
 $volume=cb2tx($record->{volume});
   }else{        #this is esle so that in case there is nothing nothing will show ( $record->{volume_rev} ne '' )
 $volume=cb2tx($record->{volume_rev});
   }
   if ($record->{title} ne ''){
$title=cb2tx($record->{title});   
   }else{
$title=cb2tx($record->{mtitle});
    }
    if ($record->{pages} ne ''){
 $pages=cb2tx($record->{pages});
    }elsif($record->{jrevpages} ne ''){
 $pages=cb2tx($record->{jrevpages});
    }else{              #($record->{chpages} ne '')
 $pages=cb2tx($record->{chpages});
    } 
my $phyical_details=cb2tx($record->{phyical_details});
my $place_publisher=cb2tx($record->{place_publisher});
if ($sfactorFMO >= 1 ){
    $place_publisher=~s/University/Univ./g;
}    
my $isbn=cb2tx($record->{isbn});
my $language=cb2tx($record->{language});
my $source=cb2tx($record->{source});
my $record_number=cb2tx($record->{record_number});
    if($record->{subjects} ne ''){
$subjects=cb2tx($record->{subjects});
    }else{
$subjects=cb2tx($record->{msubjects});
    }
    if($record->{categories} ne ''){
$categories=cb2tx($record->{categories});
    }else{
$categories=cb2tx($record->{mcategories});    
    }
my $series=cb2tx($record->{series});
my $linked_record=cb2tx($record->{linked_record});
my $reviews=$record->{reviewes};
my $essay_reviews=$record->{essay_reviewes};
my $link2record=$record->{link2record};
$linked=\%{$data{$link2record}};
my $book_title=cb2tx($linked->{title});
my $book_editor='';

if($options[$choice] eq 'final'){
    printsection($categories);
}

#fix fields
unless ($options[$choice] eq 'htmldb'){
    $isbn=~s/issn/\\textsc{issn}/gi;
}    
unless($phyical_details eq ''){
    $phyical_details=punc($phyical_details, '.');
}
$pages=pages('', $pages);

if($options[$choice] eq 'proof' || $options[$choice] eq 'one' || $options[$choice] eq 'regular'){ 
    ac("\n\n".'\noindent\begin{footnotesize}\textbf{'."$itemnumber{$record_number} ($record_number)".'.}\hspace{0.5em}');
}elsif($options[$choice] eq 'htmldb'){  
    ac("\n");
}else{      #final
   # ac('\begin{raggedright}');
    ac("\n\n".'%'."$record_number\n".'\noindent\begin{footnotesize}\textbf{'."$itemnumber{$record_number}".'.}\hspace{0.5em}');
}


#journal article
#############################################################
if ($record->{doc_type} eq 'JournalArticle'){


res("$record_number");

unless($title=~s/^>// || $title eq 'Essay review'){ #do not add quotes for special titles
    ac('``');
    $title=punc("$title",'.');       
    $title=quote_fix($title);
    $title=language_assign($title,$language);
    ac("$title");       
    ac("'' ");
}else{
   $title=punc("$title",'.');       
   ac("$title");       
   ac(" ");
}
unless ($res2 eq ''){ac("$res2 ")};
#if only edition detail and the item is not linked, nor it is marked as part of theme issue
if ($edition_details ne '' && $itemnumber{$link2record} eq '' && $themeissues{$link2record} eq '') {
    $edition_details=punc("$edition_details",'.');
    ac("$edition_details");
#else if linked record but not marked as part of theme issue    
}elsif($edition_details ne '' && $itemnumber{$link2record} ne '' && $themeissues{$link2record} eq '') {
    $edition_details="$edition_details [ref.~$itemnumber{$link2record}].";
    ac("$edition_details");

}
unless ($themeissues{$link2record} eq ''){
    $thtitle=cb2tx($themeissues{$link2record});
    ac(" Part of $thtitle");  
    if ( $itemnumber{$link2record} ne '' ){
        ac(" [ref.~$itemnumber{$link2record}]");
    }
    ac('.');
}
if ($journal ne ''){
    $journal='\textit{'."$journal".'}';
}
if ($year ne ''){
    $year="("."$year".")";
}
if ($pages ne ''){
    $pages=": $pages";
}
ac(" $journal $volume "."$year");
ac("$pages.");

}

#book
#############################################################
if ($record->{doc_type} eq 'Book'){

res("$record_number");

$title=punc("$title", '.');
$title=language_assign($title,$language);
ac('\textit{'."$title");
ac("} ");
unless ($res2 eq ''){ac("$res2 ")};
unless ($edition_details eq '' ) {
    $edition_details=punc("$edition_details", '.');
    ac("$edition_details ");
}
unless ($series eq '') {
    $series=punc("$series", '.');
    ac("$series ");
}
unless ($phyical_details eq '' ) {
    ac('('."$phyical_details".') ')};
ac("$place_publisher");
unless ($year eq '' ) {ac(", $year")};
ac('.');
unless ($isbn eq '') {
    if ($options[$choice] eq 'htmldb'){
        ac (" ISBN: $isbn");
    }else{
        ac(" \\textsc{isbn}: $isbn.");
    }
}
}

#chapter
#############################################################
if ($record->{doc_type} eq 'Chapter'){

res("$record_number");

$title=punc("$title", '.');
$title=quote_fix($title);
$title=language_assign($title,$language);
ac('``'."$title");
ac("'' ");
unless ($res2 eq ''){ac("$res2 ")};
unless ($edition_details eq '' ) {
    $edition_details=punc("$edition_details", '.');
    ac("$edition_details ");
}
if ($sfactorFMO >= 0 ){
    $book_title=~s/:.*//;              #get rid of subtitile
    #close open quatations (will not work when there are apostrophies in the title)
    $e=" $book_title";   #the leading space is needed
    $e=~s/'(\S)/$1/g;
    while ($e=~s/\s`/ /){
                unless ($e=~s/'//){
                    $book_title="$book_title"."'";
                }
    }
    #do this so that any choped of }s will be added
            $e=$book_title;
            while ($e=~s/{//){
                unless ($e=~s/}//){
                    $book_title="$book_title"."}";
                }
            }                
}
#####if the book is referenced used short citation
tie %book_editors,  "Tie::IxHash";
$bookeditor='';
%book_editors='';
if ( $itemnumber{$link2record} ne '' && $sfactorFMO >= 0){
    %book_editors=make_name($record_number,linked,ch_ed_sh,$link2record,editor);
}else{       
    %book_editors=make_name($record_number,linked,ch_ed,$link2record,editor);
}    
foreach $be (keys %book_editors){
    $book_editors{$be}=cb2tx($book_editors{$be});
    $book_editor="$book_editor"."$book_editors{$be}<>aNd<>";
}
$book_editor=~s/<>aNd<>$//;                     #get rid of the last one
$book_editor=~s/(.*)<>aNd<>(.*?)$/$1 and $2/;          #change the next to last one to "and"
$book_editor=~s/<>aNd<>/, /g;                   #chagne all the other ones to commans
$book_editor=~s/and\set\sal/et al/;             #if there is et al then get rid of the and
#if there is no editor
$book_author='';
if ($book_editor eq ''){
     %book_authors='';
     tie %book_authors,  "Tie::IxHash";
     if ( $itemnumber{$link2record} ne '' && $sfactorFMO >= 0){
         %book_authors=make_name($record_number,linked,ch_ed_sh,$link2record,author);
     }else{       
         %book_authors=make_name($record_number,linked,ch_ed,$link2record,author);
     }    
     foreach $be (keys %book_authors){
         $book_authors{$be}=cb2tx($book_authors{$be});
         $book_author="$book_author"."$book_authors{$be}<>aNd<>";     
     }   
     $book_author=~s/<>aNd<>$//;                     #get rid of the last one
     $book_author=~s/(.*)<>aNd<>(.*?)$/$1 and $2/;          #change the next to last one to "and"
     $book_author=~s/<>aNd<>/, /g;                   #chagne all the other ones to commans
     $book_author=~s/and\set\sal/et al/;             #if there is et al then get rid of the and   
}

        #if the sqeeze factor is over 0 and if either authro or editor exists and if it is a referenced item
if($sfactorFMO > 0 && ($book_author ne '' || $book_editor ne '') && $itemnumber{$link2record} ne ''){
    ac('In ');
}else{    
    ac('In \textit{'."$book_title".'}');
}    
if($book_editor ne '' && $sfactorFMO > 0 && $itemnumber{$link2record} ne ''){        
    ac("$book_editor");
}elsif($book_editor ne ''){
    ac(", edited by $book_editor");
}
if($book_author ne '' && $sfactorFMO > 0 && $itemnumber{$link2record} ne ''){     #since the author should be only generated if there is no editor things should be ok here
    ac("$book_author");
}elsif($book_author ne ''){
    ac(", by $book_author");
}   
if ( $itemnumber{$link2record} ne '' ){
    unless ($linked->{'year'} eq ''){ac(" ($linked->{year})");}
    ac(" [ref.~$itemnumber{$link2record}]");
}else{
    #if not in this volue print place publisher
    ac (' (');
    my $nhchpp=cb2tx($linked->{'place_publisher'});
    $nhchpp=~s/University/Univ.\\/g;        #make sure the . does not get treated as a sentence ending one
    unless ($linked->{'place_publisher'} eq ''){ac("$nhchpp")};
    unless ($linked->{'year'} eq ''){ac(", "."$linked->{year}");}
    ac(')');
    #fix a bit
    $cite=~s/\(,/(/;
    $cite=~s/\(\)//;
}
unless ($pages eq ''){    
   ac(", $pages");
}   
ac(".");
}


############################################################

#description etc
$desmark=0;
undef(@lkeder);

unless ($description eq '' ) {


#####take care fo XREF things###################################################


    #essay reviewd items get added to description field as <xref> items
    while ($description=~/(<xref>(.*?)\[(.*?)\]<\/xref>)/g){
        ##########
        $l=$3;
        $erflag=$2;
        $ndes='';
        $jname=$jpag=$jvol='';
        my $dtpe=$data{$l}->{doc_type};
        if ($dtpe ne ''){
            #add to the thingee
            $idsaddon="$idsaddon"."$l\t"."x"."$itemnumber{$record_number}\n";
        }
        my $title=$data{$l}->{title};
        my $year=$data{$l}->{year};
        my $language=$data{$l}->{language};
        if ($year ne ''){
                $year="("."$year".")";    
        }     
        $title=~s/:.*//;
        #fix any possible missing quotes
        $e=$title;
        while ($e=~s/<q>//){
            unless ($e=~s/<\/q>//){
                $title="$title"."</q>";
            }
        }    
        #chagne to tx now so that the missing } can be solved  
        $title=cb2tx($title);
        #do this so that any choped of }s will be added
        $e=$title;
        while ($e=~s/{//){
            unless ($e=~s/}//){
                $title="$title"."}";
            }
        }    
        res($l,essayrev);       #this should be sentence style that is fl
        if($editor ne '' && ($editor=~/\sand\s/ || $editor=~/et\sal/) ){
            $eds=' (eds.), ';
        }elsif($editor ne ''){    
            $eds=' (ed.), ';
        }else{
            $eds='';
        }
        unless ($author eq ''){$author="$author,"}    
        unless ($editor eq ''){$editor="$editor"}        
        if( $author ne '' && $res2 ne '' ){    #this is to avoid printing the editor twice
            $editor=$eds='';
        }    
        if ($dtpe eq 'JournalArticle'){
            
            if ( $data{$l}->{journal_link} ne '1013'){
                if($journals_abbreviations{$data{$l}->{journal_link}} ne ''){
                     $jname=cb2tx($journals_abbreviations{$data{$l}->{journal_link}});
                     #in is a fix for the &s getting escaped twice
                     $jname=~s/\\&/&/g;
                }else{
                    $jname=cb2tx($journals{$data{$l}->{journal_link}});    
                    #in is a fix for the &s getting escaped twice
                     $jname=~s/\\&/&/g;
                }
                $jname="<e>$jname</e>";
            }
            $jvol=$data{$l}->{volume};    
            $jpag=$data{$l}->{pages};
            if ($jpag ne ''){
                $jpag=": $jpag";
            }
        
            $ndes1=cb2tx("$author $editor $eds");
            $ndes2=cb2tx("$res2 $jname $jvol $year"."$jpag");
            $title=language_assign($title,$language);
            $title=quote_fix($title);
            $ndes="$ndes1 ``"."$title"."'' $ndes2";
            
        }elsif( $dtpe eq 'Review'){
            if ( $data{$l}->{journal_link_review} ne '1013'){
                if($journals_abbreviations{$data{$l}->{journal_link_review}} ne ''){
                     $jname=cb2tx($journals_abbreviations{$data{$l}->{journal_link_review}});
                }else{
                    $jname=cb2tx($journals{$data{$l}->{journal_link_review}});    
                }
                $jname="<e>$jname</e>";
            }
            $jvol=$data{$l}->{volume_rev};
            $jpag=$data{$l}->{jrevpages};
            if ($jpag ne ''){
                $jpag=": $jpag";
            }
            
            $ndes=cb2tx("$author $res2 $jname $jvol $year"."$jpag");
            #$title=quote_fix($title);
            #$ndes="$ndes1 ``"."$title"."'' $ndes2";
        }elsif( $dtpe eq 'Chapter'){
            $jpag=$data{$l}->{chpages};               
            $ndes=cb2tx("$author");
            #$ndes2=cb2tx(" $year"."$jpag");
            #$title=quote_fix($title);
            
            #make a long citation if the book from which the chapter is take is not the same as the book of the citing thing

            if($data{$l}->{'link2record'} ne $link2record && $data{$l}->{'link2record'} ne $record_number){
            
            ####


            $title=punc("$title", '.');
            $title=quote_fix($title);
            $title=language_assign($title,$language);
            $ndes="$ndes".' ``'."$title"."'' ";

            $book_title=$data{ $data{$l}->{link2record} } ->{'title'};

            unless ($res2 eq ''){ac("$res2 ")};
                $book_title=~s/:.*//;              #get rid of subtitile
                #close open quatations (will not work when there are apostrophies in the title)
                $e=$book_title;
                        while ($e=~s/`//){
                            unless ($e=~s/'//){
                                $book_title="$book_title"."'";
                            }
                        }
                #do this so that any choped of }s will be added
                        $e=$book_title;
                        while ($e=~s/{//){
                            unless ($e=~s/}//){
                                $book_title="$book_title"."}";
                            }
                        }    
                        
                        tie %book_editors,  "Tie::IxHash";
            $bookeditor='';
            %book_editors='';

                %book_editors=make_name($record_number,linked,ch_ed_sh,$data{$l}->{link2record},editor);
                
            foreach $be (keys %book_editors){
                $book_editors{$be}=cb2tx($book_editors{$be});
                $book_editor="$book_editor"."$book_editors{$be}<>aNd<>";
            }
            $book_editor=~s/<>aNd<>$//;                     #get rid of the last one
            $book_editor=~s/(.*)<>aNd<>(.*?)$/$1 and $2/;          #change the next to last one to "and"
            $book_editor=~s/<>aNd<>/, /g;                   #chagne all the other ones to commans
            $book_editor=~s/and\set\sal/et al/;             #if there is et al then get rid of the and
            #if there is no editor
            $book_author='';
            if ($book_editor eq ''){
                 %book_authors='';
                 tie %book_authors,  "Tie::IxHash";
                 
                     %book_authors=make_name($record_number,linked,ch_ed_sh,$data{$l}->{link2record},author);
                     
                 foreach $be (keys %book_authors){
                     $book_authors{$be}=cb2tx($book_authors{$be});
                     $book_author="$book_author"."$book_authors{$be}<>aNd<>";     
                 }   
                 $book_author=~s/<>aNd<>$//;                     #get rid of the last one
                 $book_author=~s/(.*)<>aNd<>(.*?)$/$1 and $2/;          #change the next to last one to "and"
                 $book_author=~s/<>aNd<>/, /g;                   #chagne all the other ones to commans
                 $book_author=~s/and\set\sal/et al/;             #if there is et al then get rid of the and   
            }

                    #if the sqeeze factor is over 0 and if either authro or editor exists and if it is a referenced item
            if(($book_author ne '' || $book_editor ne '') && $itemnumber{$data{$l}->{link2record}} ne ''){
                $ndes="$ndes".'In ';
            }else{    
                $book_title=cb2tx($book_title);
                $ndes="$ndes".'In \textit{'."$book_title".'}';
            }    
            if($book_editor ne ''  && $itemnumber{$data{$l}->{link2record}} ne ''){        
                $ndes="$ndes"."$book_editor";
            }elsif($book_editor ne ''){
                $ndes="$ndes".", edited by $book_editor";
            }
            if($book_author ne ''  && $itemnumber{$data{$l}->{link2record}} ne ''){     #since the author should be only generated if there is no editor things should be ok here
                $ndes="$ndes"."$book_author";
            }elsif($book_author ne ''){
                $ndes="$ndes".", by $book_author";
            }   
            if ( $itemnumber{$data{$l}->{link2record}} ne '' ){
                $ndes="$ndes"." [ref.~$itemnumber{$data{$l}->{link2record}}]";
            }else{
                $yr=$data{$data{$l}->{link2record}}->{year};
                unless ($yr eq ''){$ndes="$ndes"." ("."$yr".')';}
             
             }    
            $ndes="$ndes".", $jpag";            

            ####

            }else{      #short citation
                unless($jpag eq ''){ 
                    $title=punc("$title", ',');
                }
                $title=language_assign($title,$language);
             $title=quote_fix($title); 
                $ndes="$ndes ``"."$title"."'' $jpag";
            }    
        }else{ #book
            $ndes1=cb2tx("$author $editor $eds <e>");
            $ndes2=cb2tx("</e> $res2 $year");
            $ndes="$ndes1"."$title"."$ndes2";
        }
        
#########now ignore all the above and decide if it is needed
        if ( $itemnumber{$l} ne '' && $sfactorFMO > 0){
            #redo the author
            
            $book_author=$book_editor='';
            tie %book_editors, "Tie::IxHash";
            tie %book_authors, "Tie::IxHash";
            %book_editors=make_name("$l",'editor','ch_ed_sh','','editor');    
            foreach $be (keys %book_editors){
                $book_editors{$be}=cb2tx($book_editors{$be});
                $book_editor="$book_editor"."$book_editors{$be} and ";
            }
            $book_editor=~s/\sand\s$//;
            $book_editor=~s/and\set\sal/ et al.\\ /;        #changed "et al" to "et al.\\ "
            
            %book_authors=make_name("$l",'author','ch_ed_sh');    
            foreach $be (keys %book_authors){   
                $book_authors{$be}=cb2tx($book_authors{$be});
                $book_author="$book_author"."$book_authors{$be} and ";
            }
            
            $book_author=~s/\sand\s$//;
            $book_author=~s/and\set\sal/ et al.\\ /;        #changed "et al" to "et al.\\ "
            if($book_author ne ''){
                $ndes="$book_author";
            }else{
                $ndes="$book_editor";
            }

            #however, if there is not author put title
            sqeez($ndes);
            if($ndes eq ''){
                #needs to get the title in italics
                $ndes='\emph{'."$title".'}';
            }        
            $ndes="$ndes [ref.~$itemnumber{$l}]";    
        }elsif($itemnumber{$l} ne ''){

            $ndes="$ndes [ref.~$itemnumber{$l}]";        
        }else{       
            if( $erflag=~/essayrev/ ){
                #do not add for essay review items
            }else{    
                #add to the index
                $link4idx=\%{$data{$l}};
                contributors_list($link4idx->{record_number}, final);
                add2index($link4idx,$itemnumber{$record_number});   
            }        
        }
        $description=~s/<xref>.*?<\/xref>/$ndes/;
    }

    #add the list of books at the end of the description, but maybe it should be ad the begining?

        ########3
    if ($sfactorFMO > 0 ){
        ac('\begin{isisdescription}\begin{scriptsize}'."$description");
    }else{    
        ac('\begin{isisdescription}'."$description");
    }
    $desmark++;
    };
    
    
############################################################################################3
##add contents list, TOC


my @linkedrecords=split(/,/, $linked_record);

#first do thig for sorting
%tempcontlist='';
foreach $linkrec (@linkedrecords){
    next if $linkrec eq '';
    sort_records(\%{$data{$linkrec}},conlist);
}
foreach $linkrec (sort {$tempcontlist{$a} cmp $tempcontlist{$b}} keys  %tempcontlist){
    #need to make sure that only the records that are not skiped will be printed
    next if $linkrec eq '';
    unless($desmark > 0){
        if($sfactorFMO > 0){
            ac('\begin{isisdescription}\begin{scriptsize}');
        }else{
            ac('\begin{isisdescription}');
        }
        $desmark++;
    }
    #do not if emplty, or a review
    unless ($linkrec eq '' || $data{$linkrec}->{doc_type} eq 'Review'){
        #skip essay reviews
        if ($linkrec=~/er$/){
            push(@lkeder,$linkrec);
            next;
        }
        #add to the thingee
        $idsaddon="$idsaddon"."$linkrec\t"."x"."$itemnumber{$record_number}\n";    
        
###########for the most short
        if($sfactorFMO > 1 && $itemnumber{$linkrec} ne '' ){
            
            $book_author=$book_editor='';
            tie %book_editors, "Tie::IxHash";
            tie %book_authors, "Tie::IxHash";
            %book_editors=make_name("$linkrec",'editor','ch_ed_sh',$linkrec,'editor');    
            foreach $be (keys %book_editors){
                $book_editors{$be}=cb2tx($book_editors{$be});
                $book_editor="$book_editor"."$book_editors{$be} and ";
            }
            $book_editor=~s/\sand\s$//;
            $book_editor=~s/and\set\sal/ et al/;
            %book_authors=make_name("$linkrec",'author','ch_ed_sh');    
            foreach $be (keys %book_authors){   
                $book_authors{$be}=cb2tx($book_authors{$be});
                $book_author="$book_author"."$book_authors{$be} and ";
            }
            $book_author=~s/\sand\s$//;
            $book_author=~s/and\set\sal/ et al/;
            if($book_author ne ''){
                $contname="$book_author";
            }else{
                $contname="$book_editor";
            }
        
            
        
              #if still nothing go to title
              if  ($contname eq ''){  
                   my $lnktitle=cb2tx($data{$linkrec}->{title}); 
                   $contname=quote_fix($lnktitle);
              }     
             ac(" $contname ");
             ac(" [ref.~$itemnumber{$linkrec}]");
###########for the short        
        }elsif($sfactorFMO > 0 && $itemnumber{$linkrec} ne '' ){
###########for the long
        }else{
            $conlisttoc='';
            tie %linkauthor, "Tie::IxHash";
             %linkauthor=make_name($linkrec,author,fl_sc);      
             foreach $linkname (keys %linkauthor){
                 $contname=cb2tx($linkauthor{$linkname});
                 $conlisttoc="$conlisttoc"."$contname".'<>aNd<>';
             }
                #will check is there are 4 names, if so will et al them
             $chckcnt=( $conlisttoc=~/aNd<>/g )[3];
             if($chckcnt ne ''){
                $conlisttoc=~s/(.*?)<>aNd<>.*/$1 et al./;
             }

            $conlisttoc=~s/<>aNd<>$//;                     #get rid of the last one
            $conlisttoc=~s/(.*)<>aNd<>(.*?)$/$1 and $2/;          #change the next to last one to "and"
            $conlisttoc=~s/<>aNd<>/, /g;                   #chagne all the other ones to commans
            $conlisttoc=~s/and\set\sal/et al/;             #if there is et al then get rid of the and   

             unless($conlisttoc eq '' ){
              ac(" $conlisttoc, ");
             } 
             my $lnktitle=cb2tx($data{$linkrec}->{title}); 
         
             unless($data{$linkrec}->{pages} eq '' || $data{$linkrec}->{pages}=~/<com/){ 
                 $lnkpp=cb2tx($data{$linkrec}->{pages});
                 $lnktitle=punc("$lnktitle", ',');
             }  
             #or for the chapters
             unless($data{$linkrec}->{chpages} eq '' || $data{$linkrec}->{chpages}=~/<com/){ 
                 $lnkpp=cb2tx($data{$linkrec}->{chpages});
                 $lnktitle=punc("$lnktitle", ',');
             } 
             $lnktitle=quote_fix($lnktitle); #moved this from before adding , so that the comma goes inside the '
             $lnktitle=language_assign($lnktitle,$language);
             ac("``$lnktitle''") ;   
             unless($lnkpp eq ''){ac(" $lnkpp")}
             $lnkpp='';

             if ( $itemnumber{$linkrec} ne '' ){
                 ac(" [ref.~$itemnumber{$linkrec}]");
             }else{
                 #if it does not have a link number, then it is not printed and need
                 #to be added to the index
                 $link4idx=\%{$data{$linkrec}};
                 contributors_list($link4idx->{record_number}, final);
                 add2index($link4idx,$itemnumber{$record_number});
             }    
           
        }
        ac("; ");
    }
    
}   
$cite=~s/;\s$/./;    #replace last ; with a . if there is one
$cite=~s/''\.$/.''/;  #move the period inside the '' if ends the toc (i think it should go outside, however) 
#print link2rec references 
#unless ($itemnumber{ $data{$link2rec}->{'record_number'} } eq '' && $record->{doc_type} ne 'Chapter'){
#    ac("Related records [ref.~$itemnumber{ $data{$link2rec}->{'record_number'} }].");
#}

####################################################################################
#if there is a REVIEW print a link, or an essay review 
if ($revitemnumber{$record_number} ne '' || $#lkeder>-1){
    unless($desmark > 0){
        if($sfactorFMO > 0){
            ac('\begin{isisdescription}\begin{scriptsize}');
        }else{
            ac('\begin{isisdescription}');
        }
        $desmark++;
    }else{    #if there is already something start a new paragraph for the reviews
        ac("\n\n");   
    }
    #make a list of essay reviews
    $erev='';
    foreach $r (@lkeder){
        $erev="$erev"."$itemnumber{$r}, ";
    }
    if ($data{$record_number} -> {'reviewes'} ne ''){
        $erev="$erev"."$revitemnumber{$record_number}";
    }    
    $erev=~s/,\s$//;    
    ac(" Reviews: [ref.~$erev]");
}

##if option for printing subjects turned on, print subject
if ($optionsFMO eq 'sub'){
unless($desmark > 0){
        if($sfactorFMO > 0){
            ac('\begin{isisdescription}\begin{scriptsize}');
        }else{
            ac('\begin{isisdescription}');
        }
        $desmark++;
    }
    $subjects=~s/\/\/\s*$//;
    ac('\texttt{--'."$subjects"."}");

}
###############
if($desmark > 0){
    if ($sfactorFMO > 0 ){
        ac('\end{scriptsize}\end{isisdescription}'."\n\n");
    }else{
        ac('\end{isisdescription}'."\n\n");
    }
}    

##list things for proof
if($options[$choice] eq 'proof' || $options[$choice] eq 'one' || $options[$choice] eq 'regular'){
   ($cat1, $cat2, $cat3)=split(/-/, $categories); 
   $cat1=cb2tx($categories_short{$cat1});
   $cat2=cb2tx($categories_short{$cat2});
   $cat3=cb2tx($categories_short{$cat3});
  ac("\n\n \\noindent \\textsc{$cat1 - $cat2 ($categories).}"); 
  ac(" \\textit{$subjects.} \\textsc{$language. $source}");
  #ac("\n\n".'Lanugage: \textbf{'."$language".'}');
  #ac("\n\n".'Source: \textsc{'."$source".'}');
}
ac("\n\n".'\vspace{2ex}');   #the two \n\n are necessary to have the smaller lineseperation
###################################################
###################################################
##### now print the record
    #print OUT '\begin{footnotesize}';
    $cite=~s/'''/'\\hspace{1pt}''/g;
    print OUT "$cite \\end{footnotesize}";
    #print OUT '\end{footnotesize}';
    close OUT;
    open (OUT, ">> $ids_File") || die ("Cound not opne $ids_File $!");
    print OUT "$record_number\t$itemnumber{$record_number}\n";
    print OUT "$idsaddon";
    $idsaddon='';
    close OUT;
    #make html and text citation
    if($htmlFMO=~/yes/i){ make_html($cite) }
    $cite='';   #changed this from $cite

}  # end of make_tex
########################################
sub make_tex_rev{

require 'subs\tex_parts.pl';

my $record=$_[0];
my $outfile=$_[1];

open (OUT, ">> $outfile") || error_b ("[Error 160] Cannot open $outfile $!");
unless ( $print_tex_head == 1) {
#if this is the first record on this run, deletes the old file and creas a new one
    close OUT;
    unlink($outfile);
    open (OUT, ">> $outfile") || error_b ("[Error 161] Cannot open $outfile $!");
    print OUT "$head_final";
    print OUT "$mainmatter";
    $print_tex_head=1;
}
my $title=cb2tx($record->{title});
my $year=cb2tx($record->{year});
my $record_number=$record->{record_number};
my $reviews=$record->{reviewes};
my $essay_reviews=$record->{essay_reviewes};
my $lett2ed=$record->{lett2ed};

#start printing
if($options[$choice] eq 'proof' || $options[$choice] eq 'one' || $options[$choice] eq 'regular'){ 
    ac("\n\n".'\noindent\begin{footnotesize}\textbf{R'."$record_number".'.}\hspace{0.5em}');
}else{  
    ac("\n\n".'\noindent\begin{footnotesize}\textbf{'."$revitemnumber{$record_number}".'.}\hspace{0.5em}');
}



#instead of doing the fullblown name, do a simple one
res("$record_number",rev);
#tie %revauthor, "Tie::IxHash";         
#%revauthor=make_name($record_number,author,lf_fl_in);    #lf_fl_sc
#foreach $revname (keys %revauthor){
#    $revauthor{$revname}=cb2tx($revauthor{$revname});
#    $rrnn="$rrnn"."$revauthor{$revname}; ";
#}
#$rrnn=~s/;\s$/, /;
#ac("$rrnn");
#$rrnn='';
#
##editors
#tie %revauthor, "Tie::IxHash";         
#%revauthor=make_name($record_number,editor,lf_fl_in);    #lf_fl_sc
#foreach $revname (keys %revauthor){
#    $revauthor{$revname}=cb2tx($revauthor{$revname});
#    $rrnne="$rrnne"."$revauthor{$revname}; ";
#}
#$rrnne=~s/;\s$/ /;
#ac("$rrnn");
#$rrnn='';
#if ($rrnn ne '' && $rrnne ne ''){
#    $rrnn=~s/,\s$/ /;
#    ac("$rrnn edited by $rrnne")
#}elsif($rrnn ne ''){
#    ac("$rrnn");
#}elsif($rrnne ne ''){
#    if($rrnne=~/;/){
#        ac("$rrnne (Eds.) ");            
#    }else{
#        ac("$rrnne (Ed.) "); 
#    }
#}
#$rrnn=$rrnne='';
           
$title=~s/:.*//;              #get rid of subtitile
#do this so that any choped of }s will be added
        $e=$title;
        while ($e=~s/{//){
            unless ($e=~s/}//){
                $title="$title"."}";
            }
        }
        
$title=punc("$title",'.');
ac('\textit{'."$title".'}');
ac(" $year");
ac('.');
if ( $itemnumber{$record_number} ne '' ){
    ac(" [ref.~$itemnumber{$record_number}]");
}


##add reviews
$firstrev=1;

#first sort things
@reviewlinks=split(/,/, $reviews);
%tempcontlist='';
foreach $revlink (@reviewlinks){
    next if $revlink eq '';
    sort_records(\%{$data{$revlink}},'revlist');
}
foreach $revlink (sort {$tempcontlist{$a} cmp $tempcontlist{$b}} keys  %tempcontlist){

    unless ($revlink eq ''){
        $hrevlink=\%{$data{$revlink}};

        if($firstrev==1){
            if($sfactorFMO > 0){
                ac("\n\n".'\begin{isisdescription}\begin{scriptsize}');
            }else{
                ac("\n\n".'\begin{isisdescription}');
            }
            $firstrev=0;
        }
        res("$revlink",rev);
#        tie %revauthor, "Tie::IxHash";         
#        %revauthor=make_name($revlink,author,lf_fl_in);    #lf_fl_sc
#        foreach $revname (keys %revauthor){
#            $revauthor{$revname}=cb2tx($revauthor{$revname});
#            $rrnn="$rrnn"."$revauthor{$revname}; ";
#        }
#        $rrnn=~s/;\s$/, /;
#        ac("$rrnn");
        $rrnn='';
        if($journals_abbreviations{$data{$revlink}->{journal_link_review}} ne ''){
             $journal=cb2tx($journals_abbreviations{$data{$revlink}->{journal_link_review}});
        }else{
            $journal=cb2tx($journals{$data{$revlink}->{journal_link_review}});    
        }    
        ac('\textit'."{$journal".'} ');
        $revv=cb2tx($data{$revlink}->{volume_rev});
        $revy=cb2tx($data{$revlink}->{year});
        $revpgs=cb2tx($data{$revlink}->{jrevpages});
        $revpgs=pages('', $revpgs);
        unless($revv eq ''){ $revv=" $revv"};
        ac("$revv ($revy)".": $revpgs. ");
        undef $contributors_list;
        contributors_list($hrevlink->{record_number}, final);
        add2index($hrevlink,$revitemnumber{$record_number});
    }
}

#now essay reviews
my @reviewlinks=split(/,/, $essay_reviews);
$firstessay=1;

%tempcontlist='';
foreach $revlink (@reviewlinks){
    next if $revlink eq '';
    sort_records(\%{$data{$revlink}},'revlist');
}

foreach $revlink (sort {$tempcontlist{$a} cmp $tempcontlist{$b}} keys  %tempcontlist){
    unless ($revlink eq ''){
    
        $hrevlink=\%{$data{$revlink}};
        
        if($firstrev==1){
            if($sfactorFMO > 0){
                ac("\n\n".'\begin{isisdescription}\begin{scriptsize}');
            }else{
                ac("\n\n".'\begin{isisdescription}');
            }
             $firstrev=0;
        }
        if($firstessay==1){
            ac (' Essay reviews: ');
            $firstessay=0;
        }
        res("$revlink",rev);
       # tie %revauthor, "Tie::IxHash";         
#        %revauthor=make_name($revlink,author,lf_fl_in);    #lf_fl_sc
#        foreach $revname (keys %revauthor){
#            $revauthor{$revname}=cb2tx($revauthor{$revname});
#            $rrnn="$rrnn"."$revauthor{$revname}; ";
#        }
#        $rrnn=~s/;\s$/, /;
#        ac("$rrnn");
#        $rrnn='';
        if($journals_abbreviations{$data{$revlink}->{journal_link_review}} ne ''){
             $journal=cb2tx($journals_abbreviations{$data{$revlink}->{journal_link_review}});
        }else{
            $journal=cb2tx($journals{$data{$revlink}->{journal_link_review}});    
        }    
        ac('\textit'."{$journal".'} ');
        $revv=cb2tx($data{$revlink}->{volume_rev});
        $revy=cb2tx($data{$revlink}->{year});
        $revpgs=cb2tx($data{$revlink}->{jrevpages});
        $revpgs=pages('', $revpgs);
        unless($revv eq ''){ $revv=" $revv"};
        ac("$revv ($revy)".": $revpgs. ");
        
        #should they be indexed twince for review and the articel?
        #NOPE
        #undef $contributors_listf;
        #contributors_list($hrevlink->{record_number}, author, last_first);
        #add2index($hrevlink,$revitemnumber{$record_number});

    }
}

#now letters to the editor
$lett2edct=0;
#first sort things
@reviewlinks=split(/,/, $lett2ed);
%tempcontlist='';
foreach $revlink (@reviewlinks){
    next if $revlink eq '';
    sort_records(\%{$data{$revlink}},'revlist');
}
foreach $revlink (sort {$tempcontlist{$a} cmp $tempcontlist{$b}} keys  %tempcontlist){

    unless ($revlink eq ''){
        $hrevlink=\%{$data{$revlink}};

        if($firstrev==1){   
            if($sfactorFMO > 0){
               ac("\n\n".'\begin{isisdescription}\begin{scriptsize}');
            }else{
                ac("\n\n".'\begin{isisdescription}');
            }
             $firstrev=0;
        }
        if($lett2edct==0){
            ac('Letters to the editor: ');
            $lett2edct=1;
        }    
        tie %revauthor, "Tie::IxHash";         
        if( $sfactorFMO > 0 ){
            %revauthor=make_name($revlink,author,lf_rev);
        }else{
            %revauthor=make_name($revlink,author,lf_fl_sc);    #lf_fl_sc
        }
        foreach $revname (keys %revauthor){
            $revauthor{$revname}=cb2tx($revauthor{$revname});
            $rrnn="$rrnn"."$revauthor{$revname}; ";
        }
        $rrnn=~s/;\s$/, /;
        ac("$rrnn");
        $rrnn='';
        if($journals_abbreviations{$data{$revlink}->{journal_link_review}} ne ''){
             $journal=cb2tx($journals_abbreviations{$data{$revlink}->{journal_link_review}});
        }else{
            $journal=cb2tx($journals{$data{$revlink}->{journal_link_review}});    
        }    
        ac('\textit'."{$journal".'} ');
        $revv=cb2tx($data{$revlink}->{volume_rev});
        $revy=cb2tx($data{$revlink}->{year});
        $revpgs=cb2tx($data{$revlink}->{jrevpages});
        $revpgs=pages('', $revpgs);
        unless($revv eq ''){ $revv=" $revv"};
        ac("$revv ($revy)".": $revpgs. ");
        undef $contributors_list;
        contributors_list($hrevlink->{record_number}, final);
        add2index($hrevlink,$revitemnumber{$record_number});
    }
}

if ($firstrev==0){
    if ($sfactorFMO > 0 ){
        ac('\end{scriptsize}\end{isisdescription}'."\n\n");
    }else{
        ac('\end{isisdescription}'."\n\n");
    }
}
print OUT "$cite \\end{footnotesize}";
print OUT "\n\n".'\vspace{0.75ex}';   #the two \n\n are necessary to have the smaller lineseperation

$cite='';

close OUT;
open (OUT, ">> $ids_File") || die ("Cound not opne $ids_File $!");
print OUT "$record_number\t$revitemnumber{$record_number}\n";
close OUT;

}
#######################

sub make_tex_end{

#print tail of the latex file

my $outfile=$_[0];

open (OUT, ">> $outfile") || error_b ("[Error 162] Cannot open $outfile $!");

print OUT "$backmatter";

if($options[$choice] eq 'final' || $options[$choice] eq 'proof'){
    makeindex('author');
    makeindex('subject');
}

print OUT "\n$enddocument_one";
close OUT;
}

############################################################
############################################################
############################################################

sub ac {
#this add to citation and takes care of eliminating spurius things

$toadd=$_[0];

$cite="$cite"."$toadd";
}

#########################
sub punc{

$toadd=$_[0];
$punc=$_[1];
sqeez($toadd);
$toadd=~s/('*)$//;
my $holdquote=$1;
if ($punc ne '' && $toadd!~/[\?\.!]$/ ) { $toadd="$toadd"."$punc";}       #do not add second period etc
$toadd="$toadd"."$holdquote";
$holdquote='';
#even if not adding punctualtion, but the puncuation includes a trailing space, add that space
if($punc=~/\s$/){$toadd="$toadd ";}

#if the puncuation is a period assume that it is a sentence ending period
#and therefore make sure it gets as such even if it follows a initial
#if($punc=~/\./){ $toadd=~s/\.\s*$/\\@. / }    this messes if thre are '' following th periond
return($toadd);
}
#####

sub ac_ed {
# creates (ed.) or (eds.)

my $editor=$_[0];

if ($editor=~/textsc.*textsc/ || $editor=~/et\sal/){         #if there are two \textsc{} then it measn two names, but will only work for this format 
    ac(' (Eds.)');
}elsif($editor ne ''){
    ac(' (Ed.)');
}
}
##
###############################################
sub res {

$record_num=$_[0];
$revres=$_[1];          #to indicate that the thing is to be for the rev with initials only, or essyrev description
$author=$editor='';

#print responsibility

undef(%author);
undef(%editor);
tie %author,  "Tie::IxHash";
tie %editor,  "Tie::IxHash";

if($revres eq 'rev'){
    %author=make_name($record_num,author,lf_fl_in);
    %editor=make_name($record_num,editor,lf_fl_in);
}elsif($revres eq 'essayrev'){
    %author=make_name($record_num,author,fl_sc);
    %editor=make_name($record_num,editor,fl_sc);
}elsif($revres eq 'revRLG'){
    %author=make_name($record_num,author,lf_rlg);
    %editor=make_name($record_num,editor,lf_rlg);
}elsif($options[$choice] eq 'htmldb'){
    %author=make_name($record_num,author,lf_fl_cap);
    %editor=make_name($record_num,editor,lf_fl_cap);
}else{
    %author=make_name($record_num,author,lf_fl_sc);
    %editor=make_name($record_num,editor,lf_fl_sc);
}

#hold your horses, those things need to be in order

#first get back the names with all the info
@authorstab=split(/\n/, $namesIndex{$record_num}->{author});
@editorstab=split(/\n/, $namesIndex{$record_num}->{editor});

$auc=0;
$ausize=keys(%author);
foreach $a (keys %author){
    if($auc==0){
        $author=$author{$a};
        $chname=($authorstab[$auc]=~/\tasian\t/);        #check only for the first name
    }elsif($auc==1  && $ausize==2 && ($chname==1  || $revres eq 'essayrev') ){
        $author = "$author"." and $author{$a}";
    }elsif($ausize==($auc+1)){
        $author = "$author".", and $author{$a}";
    }else{    
    $author = "$author".", $author{$a}";
    }
    $auc++;
}   
$author=~s/and et al/et al/; 
#get rig of the comma before et al unless the names are in reverse order
#this assumes that entreies which have more than two parts have the secondond and on part in fl order
#and so the comm get choped. if there is multple author entry that is all in lf then the comman will not worl well
unless( $ausize==2 && $revres=~/lf/){
    $author=~s/, et al/ et al/;
}
$auc=0;
$ausize=keys(%editor);
foreach $a (keys %editor){
    if($auc==0){
        $editor=$editor{$a};
        $chname=($editorstab[$auc]=~/\tasian\t/);
    }elsif($auc==1 && ($chname==1 || $revres eq 'essayrev') && $ausize==2){
        $editor = "$editor"." and $editor{$a}";
    #}elsif($auc==1 && $ausize==2){
    #    $editor = "$editor"." and $editor{$a}";
    }elsif($ausize==($auc+1)){
        $editor = "$editor".", and $editor{$a}";
    }else{    
    $editor = "$editor".", $editor{$a}";
    }
    $auc++;
}

$editor=~s/and et al/et al/; 
#get rid of the comma before et al unless the names are in reverse order
#this assumes that entreies which have more than two parts have the secondond and on part in fl order
#and so the comm get choped. if there is multple author entry that is all in lf then the comman will not worl well
unless( $ausize==2 && $revres=~/lf/){
    $editor=~s/, et al/ et al/;
}
unless($revres eq 'essayrev'){      #don;t do this for essay review descirions
    $author=cb2tx($author);
    $editor=cb2tx($editor);
}
$res2='';

#if author is present
if ($author ne ''){
    #ac('\textbf{'."$author", '.');
    unless($revres eq 'essayrev'){
        $author=punc("$author",'.');   
        ac("$author");
    }
    
    #if author and editor
    if ($editor ne ''){
        #redo the names so they all will be in first last order
        $editor='';
        %editor=make_name($record_num,editor,fl_sc);
        $auc=0;
        $ausize=keys(%editor);
        foreach $a (keys %editor){
            if($auc==0){
                $editor=$editor{$a};
                $chname=($editorstab[$auc]=~/\tasian\t/);
            #I am not sure why this is not for all
            #}elsif($auc==1 && ($chname==1 || $revres eq 'essayrev') && $ausize==2){
            #    $editor = "$editor"." and $editor{$a}";
            }elsif($auc==1 && $ausize==2){
                $editor = "$editor"." and $editor{$a}";            
            }elsif($ausize==($auc+1)){
                $editor = "$editor".", and $editor{$a}";
            }else{    
                $editor = "$editor".", $editor{$a}";
            }
            $auc++;
        }
        
        $editor=~s/,\s$//;
        unless($revres eq 'essayrev'){$editor=cb2tx($editor)}
        #and now do the thing
        
        $editor=~s/and et al/et al/; 
        #get rig of the comma before et al unless the names are in reverse order
        #this assumes that entreies which have more than two parts have the secondond and on part in fl order
        #and so the comm get choped. if there is multple author entry that is all in lf then the comman will not worl well
        unless( $ausize==2 && $revres=~/lf/){
            $editor=~s/, et al/ et al/;
        }    

        $res2=' Edited by '."$editor".'.';
    }
    
    unless($revres eq 'essayrev'){ac(' ')}
}

#if editor only
if ($editor ne '' && $author eq ''){
    #ac('\textbf{'."$editor");
    unless($revres eq 'essayrev'){
        $editor=punc("$editor",'.');   
        ac("$editor");
        ac_ed($editor);
        ac(' ');
    }    
}

}
####

sub fix_contributors{
#substitutes names in the edition details and description fields

my $record=$_[0];
    if ($record->{'mdescription'} ne ''){
$description=$record->{'mdescription'};
    }else{
$description=$record->{'description'};    
    }
$edition_details=$record->{'edition_details'};
$record_num=$record->{'record_number'};

#make the names
%descfolk=make_name($record_num,description,fl_sc);   
%eddetfolk=make_name($record_num,edition_details,fl_sc);   


foreach $name (keys %eddetfolk){
$name2=$name;
$name=~s/\*/\\*/g;     #to sub for *
$name=~s/\^/\\^/g;     #to sub for ^
$name=~s/\(/\\(/g;     #to sub for (
$name=~s/\)/\\)/g;     #to sub for )
$name=~s/\[/\\[/g;     #to sub for [
$name=~s/\]/\\]/g;     #to sub for ]
$edition_details=~s/\$$name\$/$eddetfolk{$name2}/g;      #do it globaly so that all the instances will be converted
}


foreach $name (keys %descfolk){
$name2=$name;
$name=~s/\*/\\*/g;
$name=~s/\^/\\^/g;     #to sub for ^
$name=~s/\(/\\(/g;     #to sub for (
$name=~s/\)/\\)/g;     #to sub for )
$name=~s/\[/\\[/g;     #to sub for [
$name=~s/\]/\\]/g;     #to sub for ]
    $description=~s/\$$name\$/$descfolk{$name2}/g;
    #print "$descfolk{$name2}\n";
}

}


#########################33

sub quote_fix{

#replaces double qotes with single quates and adds spaces where appropriate

my $word=$_[0];


$word=~s/``/`/g;
$word=~s/''/'/g;
$word=~s/\\Q>/``/g;
$word=~s#\\/Q>#''\\hspace{1pt}#g;
#$word=~s/^`/\\hspace{1pt}`/;
#$word=~s/'$/'\\hspace{1pt}/;
$word=~s/^`/\\,`/; #\, adds a little space
$word=~s/'$/'\\,/;

return($word);
}

##################################333
sub make_rev_chap{


my $outfile=$_[0];

open (OUT, ">> $outfile") || error_b ("[Error 163] Cannot open $outfile $!");

print OUT "\n";
print OUT "$bookreviewshead\n";
#print OUT '\chapter*{Book Reviews}';
#print OUT '\markboth{Book Reviews}{Book Reviews}';
#print OUT '\smark{Book Reviews}';
#print OUT "\n";

close OUT
}

###################

sub language_assign{

my $text=$_[0];
my $lng=lc($_[1]);

#maches only the begining so that if multiple languages will match the first one
if ($lng=~/^english/){
    return($text);
}elsif($babel{$lng} ne ''){
    $text='\selectlanguage{'."$babel{$lng}".'}'."$text".'\selectlanguage{english}';
}else{
    warning_q("[Warning 164] Language $lng does not have a Babel assigment in perl. Look at the babel.pl file");
    return($text);
    }


}

sub read_print_records{
#reads a file which determines which records to print
open(IN, "< $print_File") || error_q("[Error 178] Could not open $print_File for reading $!");
while(<IN>){
    chomp;
$_=~/(.*?)\t/;
$recordstoprint{$1}=1;
}
close IN;
#unlink($print_File);
}
1;
