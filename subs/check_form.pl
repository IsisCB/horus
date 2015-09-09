#checks required fields and formats

sub check_form {

my $record=$_[0];
         
unless ($record->{source} ne '') { error_q("[Error 169] The source field is required in record $record->{record_number}!")}
unless ($record->{language} ne '') { error_q("[Error 170] The language field is required in record $record->{record_number}!")}
unless ($record->{author} ne '' || $record->{editor} ne ''){warning_q("[Warning 208] Author and editor fields are empty in record $record->{record_number}");}



#now do some other checking, to help a brother out
if ($record->{doc_type} eq 'JournalArticle' && $record->{record_number}!~/er/){
    unless ( $record->{pages} ne '') {warning_q("[Warning 203] Pages field is empty in record $record->{record_number}");}  
    unless ($record->{year} ne '') {warning_q("[Warning 209] Year field is empty in record $record->{record_number}");}
}elsif($record->{doc_type} eq 'Chapter'){     
    unless ( $record->{chpages} ne '') {warning_q("[Warning 204] Pages field is empty in record $record->{record_number}");}
}elsif($record->{doc_type} eq 'Review'){     
    unless ( $record->{jrevpages} ne '') {warning_q("[Warning 205] Pages field is empty in record $record->{record_number}");}
    unless ($record->{year} ne '') {warning_q("[Warning 209] Year field is empty in record $record->{record_number}");}
}elsif($record->{doc_type} eq 'Book'){
    unless ($record->{year} ne '') {warning_q("[Warning 209] Year field is empty in record $record->{record_number}");}

}

unless($record->{doc_type} eq 'Review' || $record->{record_nature} ne '' || $record->{record_number}=~/er/){ 
    unless ( $record->{categories} ne '') {warning_q("[Warning 206] Categories field is empty in record $record->{record_number}");}
    unless ( $record->{subjects} ne '') {warning_q("[Warning 207] Subjects field is empty in record $record->{record_number}");}
    unless ($record->{title} ne '') {warning_q("[Warning 210] Title field is empty in record $record->{record_number}");}
}

}

1;
