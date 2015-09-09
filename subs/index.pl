
sub add2index{
#as an argument takes a reference to hash, and the record count to with add the inted
$idx=$_[0];
$indexnum=$_[1];
$id=$_[2];

# %indexentry as key has values to be alphabetized as values, to be printed
# %indexref as key has values to be alphabetized as values item references
#@names=split(/;/, $namesIndex->{$id});
@names=split(/;/, $idx->{contributors});
foreach $e (@names){
 $alpha=cb2sc($e);
 $e=cb2tx($e);
 sqeez($e);
 next if ($e=~/^et al/);
 sqeez($alpha);
 $indexentry{$alpha}=$e;
 $indexref{$alpha}="$indexref{$alpha}".","."$indexnum";
}

$hjui=$idx->{subjects};
while($hjui=~/\[(.*?)\]/g){
$e=$1;
#because there are duplicate enteries and the whole -- thing
#if the subjects are the same get a referecne to the same number
$sterm=lc($subjects_index{$e});   #get the lower case fo the fixed subject
next if $sterm eq '';
if($reverse_subjects{$sterm} ne ''){
    $sterm=$reverse_subjects{$sterm};   #gives standard number
    $sterm=$subjects_index{$sterm};     #get the index formated for this entry
}else{
    $sterm=$subjects_index{$e};
}    
 $alpha=cb2sc($sterm);      #for sorting
 $sterm=cb2tx($sterm);      #for display
 $subindexentry{$alpha}=$sterm;
 $subindexref{$alpha}="$subindexref{$alpha}".","."$indexnum";
 
 #make see references for entries which have ;s in them
 if($sterm=~/;/ && $didsee{$sterm} eq ''){
    @stermpts=split(/;/, $sterm);
    @alphapts=split(/;/, $alpha);
    for($i=1; $i<=$#stermpts; $i++){ 
         sqeez($stermpts[$i]);
         sqeez($alphapts[$i]);
         #make the first letter captial
         $stermpts[$i]=~s/^\\aa/\\AA/;
         $stermpts[$i]=~s/^\\ae/\\AE/;
         $stermpts[$i]=~s/^\\oe/\\OE/;
         $stermpts[$i]=~s/^\\aa/\\AA/;
         unless ($stermpts[$i]=~/^\\/){
            $stermpts[$i]=~s/^(\w)/uc($1)/e;
         }   
         $subindexentry{$alphapts[$i]}=$stermpts[$i];
         $subindexref{$alphapts[$i]}='\textit{see} '."$sterm";
    }
    $didsee{$sterm}=1;    
  }  
}


}
###

sub makeindex{
#sorts everything in the index and print it out
$type=$_[0];    #author or subject


print OUT "$authorindexhead" if $type eq 'author';
print OUT "$subjectindexhead" if $type eq 'subject';

if($type eq 'subject'){
    #this is not pretty and looses the whole author index
    #much better would be to define a third hash to be used here and then copy an approriet one
    #or maybe just do it by reference, but this works for now   
    %indexentry=%subindexentry;
    %indexref=%subindexref;
}
    
foreach $e (sort keys %indexentry){
next if $e!~/\w/;       #next if empty
 
#print letter things
$e=~/(\w)/;    #grab frist letter
$nlet=uc($1);
unless($nlet eq $currentletter){
 print OUT '\vspace{\baselineskip} ';
 print OUT '{\large \textbf{\textsf{';
 print OUT "$nlet}}}\n\n";
 $currentletter=$nlet;
} 

print OUT '\begin{cbindex}';
print OUT "$indexentry{$e}";

@items=( split(/,/, $indexref{$e}) );
$next=$first='';
$last=-2;
foreach $e (@items){
  next if $e eq '';
  next if $last eq $e;    #next if the same
  if ($e=~/^R/ && $type eq 'subject'){next};     #next if subject is from a review
    if (($last +1) == $e){
        if ($first eq ''){
            $first=$last;
         }   
     }elsif($first ne ''){
        if(($first+1)== $last){
            $refs="$refs, $last, $e";
        }else{
            $refs="$refs--\\hspace{0pt}$last, $e";
        }
        $first='';
     }else{   
        $refs="$refs, $e";
     } 
     $last=$e;
}
#if the last item was in the series
if ($first ne ''){
     if(($first+1)== $last){
         $refs="$refs, $last";
     }else{
         $refs="$refs--\\hspace{0pt}$last";
     }
    $first='';
}     
 undef($last);
$refs=~s/,//; 
print OUT $refs;
undef($refs);
print OUT '\end{cbindex}';
print OUT "\n";
}

print OUT "$authorindextail" if $type eq 'author';
print OUT "$subjectindextail" if $type eq 'subject';
}


1;
