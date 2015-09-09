#takes care of subject checking etc

sub subjects_check{

$record=$_[0];          #hash reference

my @subjects=split(/\/\//, $record->{subjects});
$new_subject='';
%subseen=();

foreach $subject (@subjects){
    next unless $subject=~/\S/;          #next unless there is somthing other than white spaces
    $part1=$part2=$part='';
    
    if($subject=~/\[Neu\]/){
     	#do this to skip over the combined Neu subjects
    }elsif( $subject=~/(.*?)(--.*)/){        #grab the two possible parts   
        $part1=clean_subject($1, $record);
        $part2=clean_subject($2, $record);
        if($part2=~/^\s*--/){
            $part="$part1 $part2";
        }else{
            $part="$part1 // $part2";
        }
    }else{
        $part=clean_subject($subject, $record);
    }
		$part=~/\[(.*)\]/;
		if($subseen{$1}==1 && $1 ne '**'){
		   #message_q("[Message 181] Subject '$part' in record $record->{record_number} was a duplicate of a subject with a number $1 ($subjects{$1}) and was deleted.");
			}else{
    $subseen{$1}=1;            
    $new_subject="$new_subject"."$part // ";
			}
}

$new_subject=subject_sort($new_subject);

$new_subject=~s#\s//\s*$##;        #get rid of trailing //


$record->{subjects}=$new_subject;

}
###########################################################

sub clean_subject{
#gets called by subjects_check

my $subject=$_[0];
my $record=$_[1];           #reference to the record for errors

#get rid of previous error markings
$subject=~s/\[\*\*\]//;

sqeez($subject);

#if there is a number
my $minor=0;
if($subject=~/\[Neu\]/){
     	#do this to skip over the combined Neu subjects
     return "$subject";
}elsif ($subject=~/(.*?)\[(.*?)\]/){            #grab the number
    sqeez(my $term=$1);
    my $subterm=$orginalterm=$2;
    #check the subject type
    if ($subterm=~s/m//){$minor=1};
    my $type=lc($subjects_type{$subterm});
    #the %allowedsubterm is below
    if ($allowedsubterm{$type} eq ''){
         warning_q("[Warning 102] Subject '$subjects{$subterm}' of the forbiden or unknown '$type' type in record $record->{'record_number'}");
         error_sub("$record->{'record_number'}\t$subterm\tType error\t$subjects{$subterm}\t\t$type");
         $subjecterror++;
         return "$subjects{$subterm}".'[**]['."$orginalterm"."]";
    #if the subject word is the same in lower case, just replace with hashed value
    }elsif(lc($term) eq  lc($subjects{$subterm})){
        return "$subjects{$subterm}"." ["."$orginalterm"."]";
        
    #if the subject terms is different, replace and note
    }elsif ($subjects{$subterm}){
        #message_q("[Message 103] Subject '$term' replaced by '$subjects{$subterm} [ $subterm ]' in record $record->{record_number}");    
        #error_sub("$record->{'record_number'}\t$subterm\tSubject replaced\t$subjects{$subterm}\t$term\t$type");
        $subjecterror++;
        return "$subjects{$subterm}"." ["."$orginalterm"."]";
    
    #if no term found for the number, report
    }else{
        #warning_q("[Warning 129] Unknown subject '$subject' in record $record->{record_number}");
        #error_sub("$record->{'record_number'}\t$subterm\tUnknow subject number\t\t$subject\t");
        $subjecterror++;
        unless ($subject=~s/(.*?)\[/$1 [**][/){
             $subject="$subject [**]";
        }     
        return "$subject";
    }    
    
#if there is no number        
}else{
    sqeez($subject);
    $lc_subject=lc($subject);
    if ($ref=$reverse_subjects{$lc_subject}) {
        return "$subjects{$ref}"." ["."$ref"."]";

    #if can't find nothing
    }else{
        #warning_q("[Warning 130] Unknown subject '$subject' in record $record->{record_number}");
        #error_sub("$record->{'record_number'}\t\tUnknow subject text\t\t$subject\t");
        $subjecterror++;
        return "$subject [**]";
    }    
}

}

#############################################################


sub subject_sort {

$f1=$f2=$f3=$f4=$f5=$f6='';
#
while ($_[0]=~/(.*?\[(.*?)\].*?\/\/)/g){
    if ( lc($subjects_type{$2}) eq '2003'){
        $f1="$f1"."$1";
    }elsif ( lc($subjects_type{$2}) eq 'geog. term'){
        $f2="$f2"."$1";        
    }elsif ( lc($subjects_type{$2}) eq 'time period'){
        $f3="$f3"."$1";    
    }elsif ( lc($subjects_type{$2}) eq 'institutions'){
        $f4="$f4"."$1";    
    }elsif ( lc($subjects_type{$2}) eq 'per. names'){
        $f5="$f5"."$1";    
    }else{
        $f6="$f6"."$1";
    }    
}    

return("$f1$f2$f3$f4$f5$f6");

}


################################

sub subject_stats{
#collect statistics 



}

%allowedsubterm=(
#all lower case
'per. names'=>'1',
'time period'=>'1',
'2003'=>'1',
'geog. term'=>'1',
'titles'=>'1',
'institutions'=>'1',
''=>'1',    #so that unknow subject will not be tagged as not allowable type
);

1;
