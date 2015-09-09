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


             push(@fo, $label);         #creaes an array with values as fields
        $foh{$label}=$#fo;          #creas a hash with keys as names and values as values for the array
        $required_fields{$label}='here';

    }else{
        if ($scarabaeusreaddata eq 'loose'){    #so that backup will not hang up
            log_p("The field: $header is not recognized; following records will be read incorectly");
        }else{
             error_b("[Error 133] The field '$header' is not recognized. Check the data or uppdated read_data.pl.");
        }
    }
}


#this file names are also defied in the the made_dummy_mer sub ubu print_data.pl
$outfile=$out_File;
$outfileart=$outart_File;
$outfilechap=$outchap_File;
$outfilebook=$outbook_File;
$outfilerev=$outrev_File;           

unless ($nooutput eq 'nooutput'){
    open OUT, ">:utf8", $outfile || error_b("[Error 135] Cannot open $outfile $! in readheader");
    print OUT "$mainheader,Temp ID\n";
    close OUT;

    if ($articleheader ne '') {
        open OUT, ">:utf8", $outfileart  || error_b("[Error 136] Cannot open $outfileart $! in readheader");
        print OUT "$articleheader,Temp ID\n";
        close OUT;
    }
    if ($reviewheader ne '') {
        open OUT, ">:utf8", $outfilerev  || error_b("[Error 137] Cannot open $outfilechap $! in readheader");
        print OUT "$reviewheader,Temp ID\n";
        close OUT;
    }
    if ($bookheader ne '') {
        open OUT, ">:utf8", $outfilebook || error_b("[Error 138] Cannot open $outfilebook $! in readheader");
        print OUT "$bookheader,Temp ID\n";
        close OUT;
    }
    if ($chapterheader ne '') {
        open OUT, ">:utf8", $outfilechap || error_b("[Error 139] Cannot open $outfilerev $! in readheader");
        print OUT "$chapterheader,Temp ID\n";
        close OUT;
    }
}


}

#################################################

sub read_data{
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";

#$_[0]=data
my $readonly=$_[1];
#grab the id from the read line so that it is available for other parts of the script. The id is assumed to be the first thing adn in quotes
$_[0]=~/^"(.*?)"/;
$readid=$1;
$logreadrecs="$logreadrecs"."$readid,";



$csv = Text::CSV->new();    # create a new object
$status="";
$status = $csv->parse($_[0]);         # parse a CSV string into fields
if ($status == 0){   #in case a record can't be read inform the user
    $bad_argument = $csv->error_input();
    error_q("[Error 106] This record could not be split and was skiped. $bad_argument");
    
}

@fields = $csv->fields();            # get the parsed fields


for($i=0; $i<=$#fields; $i++){

    #read the record into the %data hash, the value of each key is a anonymous hash
    #with the keys the fields
    sqeez($fields[$i]);
    $data{$fields[$foh{record_number}]}->{$fo[$i]}=$fields[$i];
    

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


#now find all reviews 
#changed the field name from 'reviewed_record' to 'reviewes' 28 may 2004 (did not chek if the old name was used anywherer)
#threr is a field `reviewes' in which record numbers of all reviews are kept

if ($fields[$foh{'doc_type'}] eq 'Review' ){
  
    my $previous=$data{ $fields[$foh{link2record}] } -> {'reviewes'};
    $data{ $fields[$foh{'link2record'}] } -> {'reviewes'}="$previous,$fields[$foh{'record_number'}]";
   }

$esseymarked=0;

#pull names here so that they are available later for everyone

$that=\%{$data{ $fields[$foh{'record_number'}] }};
pull_names($that, author);
pull_names($that, editor);
pull_names($that, description);
pull_names($that, edition_details);

	my %names='';
	my $responsibility='';
	tie %names,  "Tie::IxHash";
	%names=make_name($that->{record_number},author,li);
        foreach $name (keys %names){
        	 $responsibility="$responsibility"."$names{$name}; ";
        }
	%names=make_name($that->{record_number},editor,li);
        foreach $name (keys %names){
        	 $responsibility="$responsibility"."$names{$name} (ed.); ";
        }
        $responsibility=~ s/;\s$//;
        $that->{responsibility} = $responsibility;
        
        
#creat a hash that has verious forms of identifying this record for XML
my $fmid = $that->{record_number}; 
my $xmlRecID = sprintf("%09d", $fmid);
$xmlRecID='CBB'."$xmlRecID";
$identifierXML{ $fmid  } = $xmlRecID;
$xmlRecID =~ /(B\d\d\d\d\d)/;
$directoryXML{ $fmid  } = 'B/'."$1";

if( $that->{source} eq 'John Neu converted data' ){
	$catalogerInfo{ $that->{record_number} } = 'neu';
}elsif( $that->{source} eq 'Extracted from Book Review Data' ){
	$catalogerInfo{ $that->{record_number} } = 'neu-auto-generated-book';
}else{
	$catalogerInfo{ $that->{record_number} } = 'spw';
}
	

return "$fields[$foh{record_number}]";         #return a reference to the hash just creaed

}


1;
