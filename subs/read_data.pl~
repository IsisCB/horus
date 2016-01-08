#sub Read_data;

#this package needs to read the header and figure out the order of the field
#if all the required filled are present
#and if any field which are unknow are present
#it then creates an array of arrey references each one corresponding to a
#record


#this array contains field which must be presnet for the programm to proceed

%required_fields=(
    'Record ID'=>'',
);

#here are the names of expected field, if a name of exported field from
#FileMaker does not match any of those, the script will halt
#the value for each of the name is the variable which will hold that field in the array

%alowed_fields=(
    "Abstract"=>"abstract",
    "Author"=>"author",
    "CategoryNumbers"=>"categories",
    'Checked Out'=>'checkedout',
    "Description"=>"description",
    "Edition Details"=>"edition_details",
    "Editor"=>"editor",
    "Language"=>"language",
    "Link to Record"=>"link2record",       #combine the two links to book and article
    'Link Nature'=>'linkNature',
    "RecordAction"=>"record_action",
    "Record ID"=>"record_number",
    "RecordNature"=>"record_nature",
    "Source of Data"=>"source",
    "Subjects"=>"subjects",
    "Title"=>"title",
    "Bibliographers Notes"=>'bibliographer_notes',
    'Modified Time'=>'date_modified',
    'Temporary notes'=>'temp_notes',
    'Created'=>'created',
    'ModifierName'=>'modifier_name',
    'FullyEntered'=>'date_entered',
    'Proofed'=>'date_proofed',
    'SPW checked'=>'date_sub_checked',
    "Record Type"=>"doc_type",
    'record version'=>'recordVersion',
    'Published Print'=>'date_pub_print',
    'Published RLG'=>'date_pub_rlg',
    'Published Email Alert'=>'date_pub_email',
    "Year of publication"=>"year",

    'Temp ID'=>'tempid',
    'x review'=>'junk',
    'x chapter'=>'junk',
    'checkbox'=>'junk',
    
    #added 2013 May 1. 
    'Extra1'=>'extra1',
    'Extra2'=>'extra2',
    'Extra3'=>'extra3',
    'Extra4'=>'extra4',
    'Extra5'=>'extra5',
    'Extra6'=>'extra6',
    'Extra7'=>'extra7',
    'Extra8'=>'extra8',
    'Extra9'=>'extra9',
    'Extra10'=>'extra10',
    'Extra11'=>'extra11',
    'Extra12'=>'extra12',
    
);

%alowed_fields_book=(
    #book
    'Record ID Book'=>'recordLinkBook',
    "ISBN"=>"isbn",
    "Physical Details"=>"phyical_details",
    "Place Publisher"=>"place_publisher",
    "Series"=>"series",
    'Temp ID'=>'tempid',
);

%alowed_fields_article=(
    #journal article
    'Record ID Journal'=>'recordLinkJournal',
    "Journal Pages"=>"pages",
    #"JournalTitle"=>"journal",             #this is temp only
    "Journal Link"=>"journal_link",
    "Journal Volume"=>"volume",
    'DOI'=>'DOI',
    'Temp ID'=>'tempid',    
);
%alowed_fields_review=(
    #review
    'Record ID Review'=>'recordLinkReview',
    "Journal Link Review"=>"journal_link_review",
    'Journal Pages Review'=>'jrevpages',
    "Journal Volume Review"=>"volume_rev",
    'DOI Review'=>'DOIrev',
    'Temp ID'=>'tempid',    
);
%alowed_fields_chapter=(
    #chapter
    'Record ID Chapter'=>'recordLinkChapter',
    'Chapter Pages'=>'chpages',
    'Link Copy'=>'junk',
    'Temp ID'=>'tempid',    
);

%all_fields=(%alowed_fields, %alowed_fields_book, %alowed_fields_review, %alowed_fields_chapter, %alowed_fields_article);


##################################################################
sub read_header{

#$_[0]=data;
my $nooutput=$_[1];

#takes the first line and determines the field things
@headers=split(/,/,$_[0]);
undef(@fo);
undef(%foh);
undef(%required_fields);
undef($label);
#new 3 feb 2005
undef(@mainFM);
undef(@articleFM);
undef(@bookFM);
undef(@chapterFM);
undef(@reviewFM);


        #DO NOT MODIFY THIS WITHOUT CHANGIN THE IMPORT ORDER IN FILEMAKER
        $mainheader='Record ID,record version,Title,Author,Temp ID,Record Type,Editor,Year of publication,Edition Details,Description,Subjects,CategoryNumbers,Language,Abstract,Source of Data,Created,Modified Time,Checked Out,ModifierName,RecordAction,RecordNature,FullyEntered,Proofed,SPW checked,Published Print,Published RLG,Published Email Alert,Bibliographers Notes,Temporary notes,Link to Record,Link Nature,x review,x chapter,checkbox,Temp ID,Temp ID,Temp ID,Temp ID,Title,Author,Editor,Year of publication,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Extra11,Extra12,';
        $bookheader='Record ID Book,Place Publisher,Physical Details,Series,ISBN';
        $chapterheader='Record ID Chapter,Chapter Pages,Link Copy';
        $articleheader='Record ID Journal,Journal Link,Journal Volume,Journal Pages,DOI';
        $reviewheader='Record ID Review,Journal Link Review,Journal Volume Review,Journal Pages Review,DOI Review';
        $journalheader='Journal Id,record version,Main Title,Other titels,ISSN,Language,Frequency,Comment,Call number 1,Call number 2,Call number 3,Location,Print copy,In the guide,Current subscription,Home Page,TOC page,Full text access,Publisher,Editorial contact,Importance rank,Abbriviation,Last Checked,Type,Pagination,in the neu list,Last modified';
        @hEader=(main, book, chapter, article, review);
        foreach $he (@hEader){
            $n6="$he"."header";
            $n7="$he"."FM";
            @fids=split(/,/, $$n6);
            foreach $f (@fids){
                push(@$n7, $all_fields{$f});
            }
         }       
    

foreach $header (@headers){
    if ($all_fields{$header} ne ''){
        #this chages the names of fields which appear alrad to linked whatever
        #therefore for the export the original field must be exported for first (even if it is always empty)
        #and then the linked field can be exported

        if ($foh{$all_fields{$header}}){
            $label='linked_'."$all_fields{$header}";
        }else{
            $label=$all_fields{$header};
        }


        #if ($foh{$alowed_fields{$header}}){
        #    $label='linked_'."$alowed_fields{$header}";
        #}else{
        #    $label=$alowed_fields{$header};
        #}

        push(@fo, $label);         #creaes an array with values as fields
        $foh{$label}=$#fo;          #creas a hash with keys as names and values as values for the array
        $required_fields{$label}='here';

        #create different headers for the different fields
        #also create arrays for the different tables to be used in printing the data
        #unless ($nooutput eq 'nooutput'){
        #    if ($alowed_fields{$header} ne ''){
        #        $mainheader="$mainheader"."$header,";
        #        push(@mainFM, $label);
        #     }elsif($alowed_fields_article{$header} ne ''){
        #        $articleheader="$articleheader"."$header,";
        #        push(@articleFM, $label);
        #     }elsif($alowed_fields_chapter{$header} ne ''){
        #        $chapterheader="$chapterheader"."$header,";
        #        push(@chapterFM, $label);
        #     }elsif($alowed_fields_book{$header} ne ''){
        #        $bookheader="$bookheader"."$header,";
        #        push(@bookFM, $label);}
        #     elsif($alowed_fields_review{$header} ne ''){
        #        $reviewheader="$reviewheader"."$header,";
        #        push(@reviewFM, $label);
        #     }
        #}
        #changed this so that the output order is independet of the read files. 
        #now they are defined at the beginign of the sub
    }else{
        if ($scarabaeusreaddata eq 'loose'){    #so that backup will not hang up
            log_p("The field: $header is not recognized; following records will be read incorectly");
        }else{
             error_b("[Error 133] The field '$header' is not recognized. Check the data or uppdated read_data.pl.");
        }
    }
}

#instead of this use a sub and check the array of required fields
foreach $k ( keys %required_fields){
    unless ($required_fields{$k} eq 'here') {
        error_b("[Error 134] '$k' is a required field and is not present");
    }
}

#this file names are also defied in the the made_dummy_mer sub ubu print_data.pl
$outfile=$out_File;
$outfileart=$outart_File;
$outfilechap=$outchap_File;
$outfilebook=$outbook_File;
$outfilerev=$outrev_File;           

unless ($nooutput eq 'nooutput'){
    open(OUT, "> $outfile") || error_b("[Error 135] Cannot open $outfile $! in readheader");
    print OUT "$mainheader,Temp ID\n";
    close OUT;

    if ($articleheader ne '') {
        open(OUT, "> $outfileart") || error_b("[Error 136] Cannot open $outfileart $! in readheader");
        print OUT "$articleheader,Temp ID\n";
        close OUT;
    }
    if ($reviewheader ne '') {
        open(OUT, "> $outfilerev") || error_b("[Error 137] Cannot open $outfilechap $! in readheader");
        print OUT "$reviewheader,Temp ID\n";
        close OUT;
    }
    if ($bookheader ne '') {
        open(OUT, "> $outfilebook") || error_b("[Error 138] Cannot open $outfilebook $! in readheader");
        print OUT "$bookheader,Temp ID\n";
        close OUT;
    }
    if ($chapterheader ne '') {
        open(OUT, "> $outfilechap") || error_b("[Error 139] Cannot open $outfilerev $! in readheader");
        print OUT "$chapterheader,Temp ID\n";
        close OUT;
    }
}


}

#################################################

sub read_data{

#$_[0]=data
my $readonly=$_[1];
#grab the id from the read line so that it is available for other parts of the script. The id is assumed to be the first thing adn in quotes
$_[0]=~/^"(.*?)"/;
$readid=$1;
$logreadrecs="$logreadrecs"."$readid,";
#convert chacters and tell to escape "
my $convert=l12cb($_[0], line);
#while still together find all linked recordes imbeded in the data
#xrefs are now only in description so could move down
while ($convert=~/<xref>.*?\[(.*?)\]<\/xref>/g){
    unless( $linkedrecords{$1} ){
         $linkedrecords{$1}="$linkedrecords{$1}"."$readid (via xref),";
    }     
}    


$csv = Text::CSV->new();    # create a new object
$status="";
$status = $csv->parse($convert);         # parse a CSV string into fields
if ($status == 0){   #in case a record can't be read inform the user
    $bad_argument = $csv->error_input();
    error_q("[Error 106] This record could not be split and was skiped. $bad_argument");
    #unless ($scarabaeusreaddata eq 'loose'){$wait=<STDIN>};     #don't wait in backup mode
}

@fields = $csv->fields();            # get the parsed fields


for($i=0; $i<=$#fields; $i++){

    #read the record into the %data hash, the value of each key is a anonymous hash
    #with the keys the fields
    sqeez($fields[$i]);
    $data{$fields[$foh{record_number}]}->{$fo[$i]}=$fields[$i];
    #log_p("$fields[$foh{record_number}] : $fo[$i] : $fields[$i]");

}

#exit if readonly, this if the data in to be read only and not
#furhter processed for producing a pring out
if ($readonly eq 'readonly'){
    return "$fields[$foh{record_number}]";         #return a reference to the hash just creaed
    exit;
}

#collect journal ids
$jsseen{$fields[$foh{journal_link}]}=1;
$jsseen{$fields[$foh{journal_link_review}]}=1;

#there is a field `linked_record' that has all the linked records are entered in

unless ($fields[$foh{link2record}] eq ''){

    #needs to make sure that only the records which are not skipped go in here
    if( $fields[$foh{record_nature}] eq '' || $fields[$foh{record_nature}]=~/contents/i ){
        my $previous=$data{ $fields[$foh{link2record}] } -> {'linked_record'};
        $data{ $fields[$foh{link2record}] } -> {'linked_record'}="$previous,$fields[$foh{'record_number'}]";
 
    }    
}
#creates a hash of linked records so that it can be compared wiht the list of records that are present
# and the remiang record can be found
$linkedrecords{$fields[$foh{record_number}]}='exists';
unless( $linkedrecords{$fields[$foh{link2record}]} ){
         $linkedrecords{$fields[$foh{link2record}]}="$linkedrecords{$fields[$foh{link2record}]}"."$fields[$foh{record_number}],";
} 


#now find all reviews and regular essey reviews
#changed the field name from 'reviewed_record' to 'reviewes' 28 may 2004 (did not chek if the old name was used anywherer)
#threr is a field `reviewes' in which record numbers of all reviews are kept
#thre is also a field essay_reviewes which contias the essay reviews.
if ($fields[$foh{'doc_type'}] eq 'Review' ){
    #if it is an essay review
    if ($fields[$foh{'description'}]=~/^Essay review/i){
         my $previous=$data{ $fields[$foh{'link2record'}] } -> {'essay_reviewes'};
        $data{ $fields[$foh{'link2record'}] } -> {'essay_reviewes'}="$previous,$fields[$foh{'record_number'}]";
        #also needs to create records from essay reviews
        $esrevid="$fields[$foh{'journal_link_review'}]-"."$fields[$foh{'volume_rev'}]-"."$fields[$foh{'jrevpages'}]".'er';         #creaes a new id for the essay revies
        #needs to clean up the new id
        $esrevid=~s/\s//g;
        $esrevid=~s/,//g;
        $data{$esrevid}={%{$data{ $fields[$foh{'record_number'}] }}};   #make a referece to it
        $data{$esrevid}->{'record_number'}=$esrevid;            #change the record number        
        $data{$esrevid}->{'doc_type'}='JournalArticle';            #change the doc type 
        $data{$esrevid}->{'checkedout'}='';                     #set to blanc so that in moose.pl will be cought and not print
        $esseyrefs{$esrevid}="$esseyrefs{$esrevid}".","."$fields[$foh{'record_number'}]";  #keeps track of all the individual records compisin the rev
        $essayreviewsseen{$esrevid}=1;
        #also addthe link2rev to for later use
        $previous=$data{ $fields[$foh{'link2record'}] } -> {'linked_record'};
        $data{ $fields[$foh{'link2record'}] } -> {'linked_record'}="$previous,$esrevid";
        $essayrevbook{$esrevid} = "$essayrevbook{$esrevid},"."$data{$esrevid}->{'link2record'}";
    }elsif($fields[$foh{'description'}]=~/^Letter to the editor/i){
        my $previous=$data{ $fields[$foh{link2record}] } -> {'lett2ed'};
        $data{ $fields[$foh{'link2record'}] } -> {'lett2ed'}="$previous,$fields[$foh{'record_number'}]";
    }else{
        my $previous=$data{ $fields[$foh{link2record}] } -> {'reviewes'};
        $data{ $fields[$foh{'link2record'}] } -> {'reviewes'}="$previous,$fields[$foh{'record_number'}]";
    }
   }

$esseymarked=0;

#look for theme issues. Is this still used??
if ($fields[$foh{'edition_details'}]=~s/<themetitle>(.*?)<\/themetitle>/$1/){
    $themeissues{$fields[$foh{'record_number'}]}="$1";
}

#pull names here so that they are available later for everyone

$that=\%{$data{ $fields[$foh{'record_number'}] }};
pull_names($that, author);
pull_names($that, editor);
pull_names($that, description);
pull_names($that, edition_details);

#also pull names from the essay review records
unless ($esrevid eq ''){
     $that=\%{$data{ $esrevid }};
     pull_names($that, author);
     pull_names($that, editor);
     pull_names($that, description);
     pull_names($that, edition_details);
     $esrevid='';
}

return "$fields[$foh{record_number}]";         #return a reference to the hash just creaed

}

###
sub addcats{
#adds categories frombook to their essay revies

%essayreviewsseen;

foreach $a (keys %essayreviewsseen){

    my $link=$data{$a} -> {'link2record'};      #this is from the last review read
    if ($data{$a} -> {categories} eq ''){    
        $data{$a} -> {mcategories} = $data{$link} -> {categories};
    }
    if ($data{$a} -> {subjects} eq ''){    
        $data{$a} -> {msubjects} = $data{$link} -> {subjects};
        message_q("[Message 104] Subjects from '$link' were added to the essay review '$a'");
    }
    if ($data{$a} -> {title} eq ''){    
        #$ntitle='>Essay review of <e>';     #the > is so that no quotes will be printed since it is not a real title
        #my @links=split(/,/, $essayrevbook{$data{$a} -> {'record_number'}} );
        #foreach $l (@links){
        #    my $title=$data{$l}->{title};
        #    $title=~s/:.*//;
        #    unless ($title eq ''){
        #        $ntitle="$ntitle"."$title, ";
        #    }    
        #}
        #$ntitle=~s/,\s$//;    
        #$data{$a} -> {mtitle}="$ntitle</e>";
        $ntitle='Essay review';
        $data{$a} -> {mtitle}="$ntitle";
    }
    #now make a description by repeating the above
    $des=$data{$a} -> {description};
    $des=~s/^essay review\.*\s*//i;        #get rid of the initial essay review, but keep the rest.
    
    $neds='';
    $ndes="Essay review of";
    $rn=$data{$a} -> {'record_number'};
    my @links=split(/,/, $essayrevbook{$rn} );
    foreach $l (@links){
        next if $l eq '';
        $ndes="$ndes"." <xref> essayrev [$l]</xref>;";
    }
    $ndes=~s/;$/./;    
    #add the list of books at the end of the description, but maybe it should be ad the begining?
    $data{$a} -> {mdescription}="$des $ndes";
    #the the record id of the initail
    @comre=split(/,/, $esseyrefs{$a});
    foreach $c (@comre){
        $data{$c}->{mdescription}="$ndes";
    }    
    sort_records( \%{$data{$a}} , $options[$choice]);   
}
}

1;
