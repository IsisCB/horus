###sorting thing here

sub sort_records{

#there will be multiple kinds of sorts, hopefully specified from somehwere
#the sort rutine must first selects items whcih will be sorted (printed)
#so that for the final chapters and reviews will not be sorted because (?) they
#will be pulled out when the print out is being created

#sort for final: category, author or editor, title (wihtout article)
#sort for proof: journal title, journal volume, pages,  

my $record=$_[0];           #hash reference
my $output=$_[1];           #type of output
my $stop=0;

$sort='';
if ($output eq 'regular' || $output eq 'one' || $output eq 'analysis'){
    $sort_array{ $record->{record_number} } = $record->{record_number};
    return();
}    


if ($record->{record_nature} ne '' && $output ne 'conlist'){      # && $output ne 'conlist'  , no they need not be in the sort!
    $stop=1;
    $skipr{'Record nature'}="$skipr{'Record nature'}".","."$record->{record_number}";
}
#make sure record action is not full    
if ($output eq 'final' && $record->{record_action} ne ''){
    $stop=1;
    $skipr{'Record Action not empty'}="$skipr{'Record Action not empty'}".','."$record->{record_number}";
}
if ( $output eq 'rlg'  && $record->{record_action} ne '' && $record->{record_action} ne 'RLG Correct' ){
    $stop=1;
    $skipr{'Record Action not empty'}="$skipr{'Record Action not empty'}".','."$record->{record_number}";
}  
if ($output eq 'final' && $journals{ $record->{journal_link_review} }=~/NO\sPRINT/){
    $stop=1;
    $skipr{'NO PRINT journal'}="$skipr{'NO PRINT journal'}".','."$record->{record_number}";
}
if ($output eq 'final' && $journals{ $record->{journal_link} }=~/NO\sPRINT/){
    $stop=1;
    $skipr{'NO PRINT journal'}="$skipr{'NO PRINT journal'}".','."$record->{record_number}";
}  

#if printing final or rlg do not print things already published
if ($output eq 'final' && $record->{date_pub_print} ne '' && $optionsFMO ne 'printed'){
    $stop=1;
    $skipr{'Already published in print'}="$skipr{'Already published in print'}".','."$record->{record_number}";
}
 
if ($output eq 'rlg' && $record->{date_pub_rlg} ne '' && $record->{record_action} ne 'RLG Correct'){
    $stop=1;
    $skipr{'Already published in RLG'}="$skipr{'Already published in RLG'}".','."$record->{record_number}";
};

#skip computer generated essay reviews
if ($output eq 'rlg' && $record->{'record_number'}=~/er/){
    $stop=1;
};
#but make sure that they are checked and that
if (($output eq 'final' || $output eq 'rlg' || $output eq 'htmldb') && $record->{date_sub_checked} eq ''){
    $stop=1;
    $skipr{'Not spw checked'}="$skipr{'Not spw checked'}".","."$record->{record_number}";
};
if (($output eq 'final' || $output eq 'rlg' || $output eq 'htmldb') && $record->{date_proofed} eq ''){
    $stop=1;
    $skipr{'Not proofed'}="$skipr{'Not proofed'}".","."$record->{record_number}";
};
if (($output eq 'final' || $output eq 'rlg' || $output eq 'htmldb') && $record->{date_entered} eq ''){
    $stop=1;
    $skipr{'Not fully entered'}="$skipr{'Not fully entered'}".","."$record->{record_number}";
};
if (($output eq 'final' || $output eq 'proof' || $output eq 'htmldb') && $recordstoprint{$record->{record_number}} ne '1'){
    unless ( $record->{'record_number'}=~/er/ ){
        $stop=1;
        $skipr{'Linked only records'}="$skipr{'Linked only records'}".","."$record->{record_number}";
    }
}

#do not sort reviews, but make note of reviewed things
#also make sure to sort when for revs
#also do not skip for conlist because then it overwrittes the sort order for the reiview
if ($record->{doc_type} eq 'Review' && $output ne 'revlist' && $output ne 'rlg' && $stop==0){
    $stop=1;
    unless ($output eq 'conlist'){
    #check to make sure the reviewd item is fine
        $linkedrev=\%{ $data{$record->{link2record}} };
        if($linkedrev->{date_sub_checked} eq ''){
            log_p("d  $linkedrev->{record_number}");
            #$hhju1++;
        }elsif($linkedrev->{record_action} ne 'RLG Correct' && $linkedrev->{record_action} ne ''){
            log_p("Here Here: a $linkedrev->{record_number} . $record->{link2record}");
            #$hhju2++;
       }elsif($linkedrev->{record_nature} eq 'Skip' || $linkedrev->{record_nature} eq 'Scope' || $linkedrev->{record_nature} eq 'Duplicate'){
            log_p("n $linkedrev->{record_number} . $record->{link2record}");
            #$hhju3++;
        }else{
            $revieweditems{$record->{link2record}}=1;
            #log_p("$hhju1 $hhju2 $hhju3 $hhju4   $linkedrev->{record_number} . $record->{link2record}      ||");
       }    
    }    
}
#for a printout, reset to 0 to make sure it print. might want to skip reviews
if($output eq 'printout' || $output eq 'printoutALPHA'){
    $stop=0;
}
    
unless ($stop==1){
#add create here the sort string and add it to sort array
#for each record type and for each output type create a sort order
#should this be done throu an array??

   $skipr{'Printed'}="$skipr{'Printed'}".","."$record->{record_number}";
    foreach $s (@{$sort_order{$record->{doc_type} }->{$output} }){   #in category_comand.pl
        $bit='';
        if (($z=$s)=~/^!/) {
            $z=~s/!//;
            #do this if is supposed to put text, instead of a field
            $bit = $z;
        }else{
            #if names make sure and arange them 
            if ($s eq 'author' || $s eq 'editor'){
                tie %srtnames,  "Tie::IxHash";
                %srtnames=make_name($record->{record_number},$s,srt);
                foreach $nm (keys %srtnames){
                    $bit="$bit"." $srtnames{$nm}";
                }
                $bit=~s/^\s//;    
            }elsif($s eq 'pages') {
                $bit = sort_pages("$record->{pages}" , 'pages');
            }elsif($s eq 'chpages') {
                $bit = sort_pages("$record->{chpages}" , 'pages');
            }elsif($s eq 'jrevpages') {
                $bit = sort_pages("$record->{jrevpages}" , 'pages');            
            }elsif($s eq 'categories') {
                #auto generated bookreviews get the mcategries thins instead of reg cats
                if ($record->{$s} eq ''){
                    $bit = sort_pages("$record->{mcategories}" , 'categories');                
                }else{    
                    $bit = sort_pages("$record->{$s}" , 'categories');
                }
            }else{
                $bit = $record->{$s};
            }    
        }    
        $bit=cb2sc($bit);              #before adding convert into SC
        #do not add a blanc space if nothing there
        unless ($bit eq '' ) {$sort="$sort"."$bit ";}
        $bit='';
    }
    if ($output eq 'conlist' || $output eq 'revlist'){           #creaet a differnt array for contenlist and revs so the real one is not overdiddeen
        $tempcontlist{$record->{record_number}}= $sort;
    }else{ 
        $sort_array{ $record->{record_number} } = $sort;
        
    }    
}           #end unless

#also make a second array for sorting of reviews

$sort='';
foreach $s (@{$sort_order{Review}->{$output} }){   #in category_comand.pl
          $bit='';
          if ($s eq 'author' || $s eq 'editor'){
              tie %srtnames,  "Tie::IxHash";
              $hhj=$record->{record_number};
              %srtnames=make_name($hhj,$s,srt);
              foreach $nm (keys %srtnames){
                  $bit="$bit"." $srtnames{$nm}";
              }
          }else{   
            $bit = $record->{$s};
          }  
          $bit=cb2sc($bit);              #before adding convert into SC
          sqeez ($bit);
          unless ($bit eq '' ) {$sort="$sort"."$bit ";}
}


$sort_rev_array{ $record->{record_number} }=$sort;      

}           #end sub

 
##################################################
sub sort_pages {

#this rutine pads pages with 0 so that they can be sorted
#or does the same for categories
#as artguments takes
#it returns the padded numbe


my $pages=$_[0];            #the value of the field
my $type=$_[1];             #values of 'pages' 'categories'

my @digits;
my $page;

if ($pages eq ''){
    return '';
}    

if($type eq 'pages'){
    
    #check if there is ff.
    if ($pages=~s/ ff\.//){
    	$ff_temp=1;
    }
    
    $pages=~/([^-]*)-*/;
    sqeez ($temp = $1 );
    @digits=split(//, $temp);           #split at digits
    if ($#digits > 5){
        warning_q("[Warning 118] String '$1' in page number field '$pages' could not be processed for sorting (possibly in record $this->{record_number}).");
    }    

    #checks is the digits are roman
    #if they are assume that they shoudl go befoe other digits
    if (isroman($temp)){ 
        $arabic = arabic($temp);
        @roman=split(//, $temp);        
        @digits=(0,0,0,0,0,0);
    }
    while ($#roman < 2){             #padd till there are 3 digits
        unshift (@roman, '0');
    }
    while ($#digits < 5){             #padd till there are 6 digits
        unshift (@digits, '0');
    }
    #now add the roman to the end of digits so the result shoudl be that all
    #arabic will have 000 at the end and all roman will start with 000000
    push(@digits,@roman);
    undef(@roman);
        
}elsif($type eq 'categories'){

    #needs to match \d one, tow or three times - 0 or one \d zer to three times
    $pages=~s/(.*?)\s*\/.*/$1/;          #grab only the firs category
    #unless($pages=~/^\d{1,3}-?\d{0,3}$/){error_b("Unknown category $pages in sub sort_pages")}
    my @cats=split (/-/, $pages);
    @main_cat=split(//, $cats[0]);
    @sub_cat=split(//, $cats[1]);
    
    while ($#main_cat < 2){             #padd till there are 6 digits
        unshift (@main_cat, '0');
    }
    
    while ($#sub_cat < 2){             #padd till there are 6 digits
        unshift (@sub_cat, '0');
    }
            
    push(@digits, @main_cat);
    #for cateories needs to ignore the subcategory if the first one is <200
    if($cats[0] < 200){
        push(@digits, (0, 0, 0));
    }else{    
        push(@digits, @sub_cat);
    }    

}else{
    error_q("[Error 131] Unknown type $type in sub sort_pages");
}         

#now make a scaler agains

foreach $d (@digits){
    $page="$page"."$d";
}
if ($ff_temp==1){
    $page="$page ff.";
    $ff_temp=0;
}    
return $page;
}


1;
