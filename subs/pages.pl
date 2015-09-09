#this sub formats pages

sub pages {

#makes page numbers in XXX--XXX format. 
#in additon to dashes and spaces
#addes missing digits to the ending page numbner if
#that one has only the changed digit

#if thereis is a second argument uses that as page
if($_[1] ne ''){
    $pages=$_[1];
}else{
    $pages=$_[0]->{pages};         #as an argument takes reference to a hash
}

$pages_back=$pages;
if ($pages=~/-/ && $pages!~/[,;]/){    #the second conditoon ingnores pages that have , or ; in them, those will have to be corrected by hand. the thrid ingores URL pages
    $pages=~s/\s//g;        #gets rid of all spaces
    $pages=~/([A-Za-z0-9]+).*-.*?([A-Za-z0-9]+)/; #grabs begingin pages and ending pages
    @start=split(//,$1);            #split into digits
    @finish=split(//,$2);
    if (@start > @finish){          #if there are mode digits in the starting page than in the ending page
        @rstart=reverse @start;
        @rfinish=reverse @finish;
        $#rfinish=$#rstart;

        for ($i=0; $i<=$#rstart; $i++){
            if ($rfinish[$i] == undef()){
                $rfinish[$i]=$rstart[$i];
            }
        }
        @finish=reverse @rfinish;
        $pages="$1--";    #sets the varaibe to openingn apge--
        foreach $digit (@finish){    #and now adds one digit at a time
            $pages="$pages"."$digit";
        }
    }else {                          #if the number of staring digits in not greater thatn ending digits
        $pages="$1--$2";
    }
}
if($pages=~/-/ && $pages!~/\d/){    #in case page numbers got lost replaces with original
    $pages=$pages_back;
}    

if ($_[1] ne ''){
    return($pages);
}else{
    $_[0]->{pages}=$pages;    
}
}
####################################


1;
