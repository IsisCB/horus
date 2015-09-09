system ('cls');

$st=43;
$subjects_type{1}='Huif, Smitty (234-458)';
$subjects_type{2}='Huif (12 century)';
$subjects_type{3}='Hu<i,>f, Smitty (234-)';
$subjects_type{4}='Huif, Smi<t,>ty (d. 458)';
$subjects_type{5}='Huif Smitty, doopie ( -458)';
$subjects_type{6}='Huif Smitty';
$subjects_type{7}='Huif, Smitty (Fl. 234-458)';

foreach $st (keys %subjects_type){

$name_copy=$subjects_type{$st};
#get the dates
if ($name_copy =~s/\((.*?)\)$//){
 $date=$1;
 if ($date=~/(.*?)\-(.*)/ && $date!~ /[a-zA-Z]/){
 $bdate=$1;
 $ddate=$2;
 }
 if ($date=~/b.*?(\d+)/){
 	$bdate=$1;
 }
 if ($date=~/d.*?(\d+)/){
 	$ddate=$1;
 }
}

#get the name

if ($name_copy=~/(.*?),\s(.*)/){
 $fam_name=$1;
 $giv_name=$2;

}


#print "date $date\tborn $bdate\tdied $ddate\n";
print "NAME $name_copy\tFAMILY $fam_name\tGIVEN $giv_name\n";
$fam_name=$giv_name=$name_copy=$date=$bdate=$ddate='';

}
