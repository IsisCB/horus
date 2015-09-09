

sub subjects_suggest{
#takes reference to a records and suggests subjects
$this=$_[0];

$subSugC=0;
@sub2add='';
@subSuban='';   #17 nov 2006

#cleanup
$cats_corr{''}=$js_corr{''}=$subs_corr{''}='';
    
#make category code
($cats=$this->{categories})=~s/\D//g;

#not sure if this should go before the subject sugges, in whcih case
#the new cattegory will be used to suggest subjects
#or if this should be run after subjects in which case either only old subjects will be used
#or old and new
#if($cats eq ''){        #if there is no category suggest one
    category_suggest($this);
#}    

$ttle=$this->{title};
$ttle=~s/[^A-Za-z\s]//g;
$ttle="$ttle ";
while($ttle=~/(\w\w\w\w\w).*?\s/g){
    $tw=lc($1);
    @ttSuba=split(/:/, $ttle_corr{$tw});
    #log_p("$tw - $ttle_corr{$tw}");
    push(@subSuban, @ttSuba);
}    

@subCatan=split(/:/, $cats_corr{$cats});
@subJan=split(/:/, $js_corr{$this->{journal_link}});
foreach $s (keys %subseen){
    @subSuba=split(/:/, $subs_corr{$s});
    push(@subSuban, @subSuba);
}
push(@subSuban, @subCatan, @subJan);    



print "\n\n";
#now sum up all the differen indeces
foreach $s (@subSuban){
    ($subI, $val)=split(/-/, $s);
    $sSug{$subI}=$sSug{$subI}+$val;
}    
    
$minVal=0.1;
$subSugC=0;
    
foreach $s (sort {$sSug{$b} <=> $sSug{$a}} keys %sSug){    
    #skip if the subject is alread used || subject is empty || or already printed 9
    unless ($subseen{$s} ne '' || $subjects{$s} eq '' ||  $subSugC > 8 ){
        $subSugC++;
        if ($subSugC == 1){
            #if ($howmany > 1){
                log_p("$this->{doc_type} RECORD. TITLE: $this->{title}");
            #}    
            log_p("\nSuggested subjects for this record are")
        }    
        #check if over min val
        if ($sSug{$s} > $minVal){
            log_p("$subSugC.  $subjects{$s} [$s] ($sSug{$s})");
            push(@sub2add, $s);
        }    
    }
        
}    
log_p('A.  Add all of the above');
log_p("\nTo add any of the subjects selct their numbers:");
$subjects2add=<STDIN>;
chomp($subjects2add);
@sub2addCH=split(//, $subjects2add);
$addSub='';
foreach $s (@sub2addCH){
    if ($s=~/a/i){
        $si=1;
        while($si < 10){
            $addSub="$addSub".'// '."$subjects{$sub2add[$si]} [$sub2add[$si]] ";
            $si++;
        }    
    }else{
        $addSub="$addSub".'// '."$subjects{$sub2add[$s]} [$sub2add[$s]] ";
    }
    
}    

    $this->{subjects}="$this->{subjects}"."$addSub";
 
}

sub category_suggest{
#takes reference to a records and suggests categories based on  subjects
$this=$_[0];
@sub2catS=@sub2Cat='';

foreach $s (keys %subseen){
    @sub2catS=split(/:/, $sub2cat{$s});
    push(@sub2Cat, @sub2catS);
}

foreach $s (@sub2Cat){
    ($subI, $val)=split(/-/, $s);
    $cSug{$subI}=$cSug{$subI}+$val;
}   

$minVal=0.2;
$subSugCT=0;
$nogosubsug=0;

#check for already done
foreach $s (sort {$cSug{$b} <=> $cSug{$a}} keys %cSug){    
    # if the third sugested subject is bigger
    $subSugCT++;
    if($subSugCT < 4 && $s eq $cats){
        $nogosubsug=1;
    }
}
unless ($nogosubsug == 1){    
foreach $s (sort {$cSug{$b} <=> $cSug{$a}} keys %cSug){    
    unless ($subSugC > 4 ){
        $subSugC++;
        if ($subSugC == 1){
            #if ($howmany > 1){
                log_p("$this->{doc_type} RECORD. TITLE: $this->{title}");
            #}    
            log_p("\nSuggested categories for this record are")
        }    
        #check if over min val
        if ($cSug{$s} > $minVal){
            #break up the categores
            @cdig=split(//,$s);
            if ($#cdig < 3){
                #one of the basi categories
                log_p("$subSugC. $s $categories_short{$s} ($cSug{$s})");
            }else{
                $s=~/^(\d\d\d)(.*)/;
                $c1=$1;
                $c2=$2;    
                log_p("$subSugC. $c1-$c2 $categories_short{$c1}-$categories_short{$c2} ($cSug{$s})");
                $s="$c1-$c2";
            }    
            push(@cat2add, $s);
        }    
    }        
}    


log_p("\nTo add a category selct a numbers:");
$subjects2add=<STDIN>;
chomp($subjects2add);
unless ($subjects2add eq ''){
    $subjects2add=~/^(\d)/;     
    $cat2ADD=$1-1;     
    $this->{categories}=$cat2add[$cat2ADD];     
    #and do this so that the category will be used      
    ($cats=$this->{categories})=~s/\D//g;    
}
}
}

1;
