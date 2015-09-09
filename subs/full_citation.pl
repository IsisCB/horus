#creates full citation and the such


sub full_citation {

$record=$_[0];
my $link2record=$record->{link2record};
my $linked=\%{$data{$link2record}};
$tstamp=localtime;
$full_citation_check="$record->{doc_type}|"."$record->{record_number}|"."$record->{author}|"."$record->{editor}|"."$record->{title}|"."$record->{journal_link}|"."$record->{journal_link_review}|"."$record->{journal}|"."$record->{pages}|"."$record->{jrevpages}|"."$record->{chpages}|"."$link2record|"."$linked->{title}|"."$linked->{editor}|"."$linked->{author}";
$full_citation="$full_citation_check"."::::"."$tstamp by $userFMO";
$record->{bibliographer_notes}=~/{full\scitation}(.*?):::/;
$full_citation_old=$1;
unless($full_citation_old eq $full_citation_check){
#if($record->{bibliographer_notes}=~/{full\scitation}/){
#    $record->{bibliographer_notes}=~s/{full\scitation}.*{full\scitation}/{full citation}$full_citation {full citation}/;
#}else{
    $record->{bibliographer_notes}="$record->{bibliographer_notes}"."<newline>{full citation}$full_citation {full citation}";
#}
}
fcbkp($full_citation);
}
1;
