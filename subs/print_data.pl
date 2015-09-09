###

sub Xprint_data{
# open the file to write to for appending !!!!
# othr files may have been oepn. or maybe waite and write the whole thing at the edn

$towrite="$towrite"."$_[0]";        #??

}

####################
sub make_mer {
# makes a array to be wrtieen into csv
$record=$_[0];      #takes a reference to a record
$tempidcount++;    #this needs to be increaed for eachrecord only once so that all the seperate tables have the same temp ID

#%fo as keys has field names and as values has numbers in the array

@table2add=(mainFM);

#see what kind of record this is
if ($record->{'doc_type'} eq 'Book'){
    push (@table2add, bookFM);
}elsif($record->{'doc_type'} eq 'Chapter'){
    push (@table2add, chapterFM);
}elsif($record->{'doc_type'} eq 'Review'){
    push (@table2add, reviewFM);
}elsif($record->{'doc_type'} eq 'JournalArticle'){
    push (@table2add, articleFM);
}else{
    error_q("[Error 145] Unknown record type $record->{'doc_type'} in $record->{'record_number'}");
}

foreach $file (@table2add){
    undef @merarray;
    foreach $f (@{$file}){                   #the arrays are made during reading in read_data.pl
     #print "$f --\n";                          # $f are field names
        if ($foh{$f} ne ''){                     #so that thing don't overwrite 0
            push (@merarray, $record->{$f});
            #log_q("$record->{$f} : $f");
            #$merarray[$foh{$f}]=$record->{$f};            #assign the field to appropriete place in the arrya
        }else{
            push (@merarray, '');
            #$merarray[$foh{$f}]='';
        }
        #add a temp id here
       
    }
     $tempid="$record->{'doc_type'} $tempidcount";

        push (@merarray, $tempid);
    write_mer($outfiles{$file}, @merarray);

    }

}

######

sub write_mer{

#as arument take an arrayt o be turned into csv
$meroutfile=shift(@_);
@merarray=@_;
#print  @merarray;
open (OUT, ">> $meroutfile")    || error_b("[Error 146] Could not open $meroutfile $!");

$csv = Text::CSV->new();    # create a new object
$status = $csv->combine(@merarray);    # combine columns into a string
#print "--$status--\n";
if ($status == 0){   #in case a record can't be read inform the user
    $bad_argument = $csv->error_input();
    error_q("[Error 147] The record could not be wirtten and was skipped \n$bad_argument");
}
$line = $csv->string();               # get the combined string    
#print "\n$line\n\n";
$cvs_format=1;
if ($actionFMO eq 'synch'){
    $convertcharaterloose='loose';
    $line=cb2l1($line);
}else{
    $line=cb2l1($line);
}
print OUT "$line\n";

close OUT;

}
##################


sub make_dummy_mer{
#prints dummy mer files wiht the name of read import files so that if there are no
#real ones, FM will not freak out and will harmlessly import the dummy ones
#this files are also defined in the the read_data.pl (look above)
   

foreach $outfileFM (keys %outfiles){
    $outfile=$outfiles{$outfileFM};
    unlink($outfile);
    open(OUT, "> $outfile") || error_b ("[Error 148] Could not open $outfile for writting $!");
    print OUT "Record ID".","."Title\n";
    print OUT "197806".","."This record is need by a script DO NOT DELETE IT-DO NOT USE IT";     #dummy record
    close OUT;
}
}

1;
