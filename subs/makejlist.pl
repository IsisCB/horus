
sub makejlist{

#read a list of journas to be skipped
open(IN, "< $Js2BSkipped_File") || error_s("Can't open $Js2BSkipped_File in makejlist.pl");
while (<IN>){
chomp;
$js2BSkipped_db{$_}=1;
}
close IN;

print OUT "$jlisthead";

#first reverse the abbreviation hash
foreach $k (keys %journals_abbreviations){
    if ($journals_abbreviations{$k} ne ''){
        $jstor=cb2sc($journals_abbreviations{$k});
    }else{
       $jstor=cb2sc($journals{$k});
    }    
    $sortjs{$jstor}=$k;
}
#now print it
foreach $j (sort  keys %sortjs){
    $jid=$sortjs{$j};
    
    
    next if $journals{$jid} eq '';
    next if $js2BSkipped_db{$jid}==1;
    print OUT '\begin{cbindex}';
    unless($jsseen{$jid} eq ''){
        print OUT '*';
    } 
    $abb=cb2tx($journals_abbreviations{$jid});
    $abb=~s/\.\s/.\\ /g;     #sub periods for non-sentence ending periods 
    $jfn=cb2tx($journals{$jid});
    if( $abb ne ''){
        print OUT '\textit{';   
        print OUT "$abb} ";
    }
    print OUT "$jfn";        
    sqeez($journals_issn{$jid});
    unless ($journals_issn{$jid} eq ''){
        print OUT " ($journals_issn{$jid})";
    }
    print OUT '\end{cbindex}';
    print OUT "\n";    

}


print OUT "$jlisttail";
}

1;
