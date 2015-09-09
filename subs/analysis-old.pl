#require id, rectype, subject, cats, journa id, journal pages (do not export not printed items)

sub analysis{
#grab the subject id
while($this->{subjects}=~/\[(.?)\]/g){
    push(@sub_this, $1);
}    

foreach $s (@sub_this){
    $acats{ $this->{categories} }->{$s}++;
    unless ($this->{recordLinkJournal} eq '') { $ajsub{ $this->{recordLinkJournal} }->{$s}++  }
    foreach $ss (@sub_this){
        $asubs{$s}->{$ss}++;
    }
}

$ajcat{ $this->{recordLinkJournal} } -> { $this->{categories} }++;

undef(@sub_this);
}


sub print_analysis {

open(OUT, "> $analysisout_File") || error_b("[Error ] could not open $analysisout_File $!");
foreach $k (keys %acats){
    print OUT "$k\n";
    foreach $n (keys %{acats->$k}){
        print OUT "\t$n\t$acats{$k}->{$n}\n";
    }
}
close OUT;    
}
1;
