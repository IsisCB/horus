
sub make_MODS{
	
	use Encode;
	use utf8;
	binmode STDOUT, ":utf8";
	
	
	$recordID=$this->{record_number};
	$xmlFileDir="$xmlDirectory"."$directoryXML{$recordID}";
	$citation='';
	
	unless (-d $xmlFileDir){
		
		mkdir ($xmlFileDir) or error_s("[Error ] Cannot make directory $xmlFileDir $!");
        }
	
	$mods_FileN="$xmlFileDir".'/'."$identifierXML{$recordID}".'.xml';
	open OUT, ">:utf8", $mods_FileN or error_s("[Error 195] Cannot open $mods_FileN $!");
	
	$link2record=$this->{link2record};
	$linked=\%{$data{$link2record}};
	
	$isThesis='no';
	if($this->{doc_type} eq 'Book' && $this->{series}=~/dissertation/i){
		$isThesis='yes';
	}
	
	$text_MODS='';
	
	mods_print_head();
	mods_make_title();
	mods_make_names();
	
	$text_MODS="$text_MODS"."\t<typeOfResource>text</typeOfResource>\n";
	
	mods_make_genre();
	mods_make_originInfo();
	mods_make_language();
	mods_make_physicalDescription();
	mods_make_abstract();
	mods_make_tableOfContents();
	mods_make_notes();
	mods_make_subject();
	
	
	
}

1;
