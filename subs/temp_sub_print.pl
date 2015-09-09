sub make_related_item{
	
	
	my $xlink_display_label=$_[0];
	my $xlink_type=$_[1];
	my $xlink_val=$_[2];
	my $xlink_title=$_[3];
	my $xlink_author=$_[4];
	my $xlink_editor=$_[5];
	my $xlink_volume=$_[6];
	my $xlink_pages=$_[7];
	my $xlink_year=$_[8];
	my $xlink_series_number=$_[9];

	
	$xlink_pages=~s/--/-/;
	
	$text_MODS="$text_MODS"."\t".'<relatedItem displayLabel="'."$xlink_display_label".'" type="'."$xlink_type".'" xlink:href="'."$xlink_val".'">'."\n";
	
	my $lnktitle=unicode_convert($data{$linkrec}->{title}, xml);
	my $author=unicode_convert($data{$rev}->{author}, xml);
	my $lnkpp='';
	unless($data{$linkrec}->{pages} eq '' || $data{$linkrec}->{pages}=~/<com/){ 
		$lnkpp=unicode_convert($data{$linkrec}->{pages}, xml);
		
	}  
	#or for the chapters
	unless($data{$linkrec}->{chpages} eq '' || $data{$linkrec}->{chpages}=~/<com/){ 
		$lnkpp=unicode_convert($data{$linkrec}->{chpages}, xml);
		

	if ($xlink_title ne ''){  
		$text_MODS="$text_MODS"."\t\t<titleInfo>\n";
		$text_MODS="$text_MODS"."\t\t\t<title>";
		
		$text_MODS="$text_MODS"."$xlink_title";
		
		$text_MODS="$text_MODS"."</title>\n";
		
		if ($xlink_series_number ne ''){
			$text_MODS="$text_MODS"."\t\t\t".'<partNumber>'."$xlink_series_number".'</partNumber>'."\n";
		}
		$text_MODS="$text_MODS"."\t\t</titleInfo>\n";
	}
	
	#if want to seperate the authors or editors
	# tie %linkauthor, "Tie::IxHash";
	# %linkauthor=make_name($linkrec,author,lf);      
	# foreach $linkname (keys %linkauthor){
	
	
	if ($xlink_author ne ''){
		$text_MODS="$text_MODS"."\t".'<name type="personal">'."\n";
		$text_MODS="$text_MODS"."\t\t".'<displayForm>'."$xlink_author".'</displayForm>'."\n";
		if ($xlink_author =~/;/){
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>authors</roleTerm></role>'."\n";
		}else{
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>author</roleTerm></role>'."\n";
		}
		$text_MODS="$text_MODS"."\t".'</name>'."\n";	
		
	}
	
	if ($xlink_editor ne ''){
		$text_MODS="$text_MODS"."\t".'<name type="personal">'."\n";
		$text_MODS="$text_MODS"."\t\t".'<displayForm>'."$xlink_editor".'</displayForm>'."\n";
		if ($xlink_editor =~/;/){
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>editors</roleTerm></role>'."\n";
		}else{
			$text_MODS="$text_MODS"."\t\t".'<role><roleTerm>editor</roleTerm></role>'."\n";
		}
		$text_MODS="$text_MODS"."\t".'</name>'."\n";	
		
	}
	
	if ($xlink_vol ne '' || $xlink_pages ne ''){
		$text_MODS="$text_MODS"."\t\t<part>\n";
	}
	
	if ($xlink_vol ne ''){
		$text_MODS="$text_MODS"."\t\t\t".'<detail type="volume">'."\n";
		$text_MODS="$text_MODS"."\t\t\t\t".'<number>';    
		$text_MODS="$text_MODS"."$vol";
		$text_MODS="$text_MODS".'</number>'."\n";    
		$text_MODS="$text_MODS"."\t\t\t".'</detail>'."\n";
	}
	
	if ($xlink_pages ne ''){
		$text_MODS="$text_MODS"."\t\t\t".'<extent unit="pages">'."\n";
        	$text_MODS="$text_MODS"."\t\t\t\t".'<list>';
        	$text_MODS="$text_MODS"."$xlink_pages";
        	$text_MODS="$text_MODS".'</list>'."\n";
        	$text_MODS="$text_MODS"."\t\t\t".'</extent>'."\n";
        }
        
        if ($xlink_vol ne '' || $xlink_pages ne ''){
        	$text_MODS="$text_MODS"."\t\t</part>\n";
        }        			
        
        
        if ($xlink_year ne ''){
		$text_MODS="$text_MODS"."\t<originInfo>\n";	
		
		$text_MODS="$text_MODS"."\t\t".'<dateCreated>';
		$text_MODS="$text_MODS"."$xlink_year";
		$text_MODS="$text_MODS".'</dateCreated>'."\n";
		
		
		$text_MODS="$text_MODS"."\t</originInfo>\n";
	}
	$text_MODS="$text_MODS"."\t".'</relatedItem>'."\n";
}
