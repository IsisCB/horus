#here are rutines dealing wiht name


######################################################
sub pull_names {

#as an argument takes a reference to record hash and a field

#name things something pleasent
my $record=$_[0];
my $field=$_[1];

my @names=();          #stores the extracted names

if($field eq 'author' || $field eq 'editor' || $field eq 'book_editor'
      || $field eq 'reviewed_author' || $field eq 'reviewed_editor'  ){     #breaks the author or editor field at semicolons
    @names=split(/;/,$record->{$field});
    #author editor names must not have ; other thatn as seperator
}else{
    $record->{$field}=~s/<\$>/787098746892/g;       #substitue for dollar sings
    while ($record->{$field}=~/\$(.*?)\$/g){  #looks for things between $ signs
        push (@names, $1);
    }
    $record->{$field}=~s/787098746892/<\$>/g;        #substitute the dolar back into the field
}


extract_names($record, $field, @names);
}

##########################################################
sub extract_names {
	

#as an argument takes names in an array


#grabs the frist two arguments
my $record=shift(@_);
my $field=shift(@_);


foreach $name (@_){         #the array that was passed as the argument

#first checked if this name is already done
$jjki="$record->{record_number}"."$field"."$name";
if ($namesdoneIndex{$jjki} eq ''){
    $namesdoneIndex{$jjki}=1;
}else{
    next;
}        

     my $dame;
     my $name2;
     my $contributor;
     my $grabe;
     my $aen;
     my $last;
     my $first;
     my $order;
     my $suffix;
     my $prefix;
     my @parts;



    $original_name=$name;           #create a copy for replacing later on
    $name=~s/<com:.*?>//g;
    sqeez($name);
    $name=~s/,>/345679/g;   #so that will not missinterpret ,>
    $name=~s/\*>/787265/g;  #so that will not missinterpret *>
    


#first determinie order western, or east asian
#if the name starts with ** it is as it, an * it is asian, else it is western
if($name eq 'et al.'){
    $order='etal';
}elsif($name=~/^\*\*/){
    $order='asis';
}elsif($name=~/^\*/){
    $order='asian';
}else{
    $order='western';
}

#now break into parts
#first do it for asian order then for western (this could be mixed with the
#previous step but is not for clearity)
if($order eq 'etal'){
    #skip et al
}elsif($order eq 'asis'){
    $last=$name;
    $last=~s/^\*\*//;        #get rid of the leading stars
}elsif($order eq 'asian'){
    $name=~/\*(.*?)\s(.*)/;
    $last=$1;       #last name is between the * and the first space
    $first=$2;      #everything else is the first name
}elsif($order eq 'western'){
    $name="$name ";
    if($name=~/(\sjr\W)|(\ssr\W)|(\sIII)/i && $name!~/,.*,/){    #if it seems to have a suffix, but not two commans
        warning_q("[Warning 157] The name '$name' seems to have a suffix, but is not entered in the last, first, suffix format. (Record $record->{record_number}).");
    }
    $name=~s/\s$//;       
    if($name!~m/\*/ && $name!~m/,/){    #if ther are no markings (* or ,)
                                        #assume that the last part is the last name
        $name=~s/\s(\S*?)$/ *$1/;       #substitute the last space with a space and *
    }
    if($name=~/\*/){             #if there is an *
        $name=~/(.*)\*(.*)/;
        $last=$2;           #after the * is the last
        $first=$1;          #before is the first
        sqeez($first);      #get rid of the space
    }else{              #this is in the comma instance
        @parts=split(/,/, $name);      #seperate at commans
        if(exists($parts[3])){
            error_q("[Error 116] Name '$name' in record $fields[$recordnumberN] has more than 3 parts.");
            $last=$name;
            sqeez($last);
        }else{
            $last=$parts[0];
            sqeez($last);
            $first=$parts[1];
            sqeez($first);
            $suffix=$parts[2];
            sqeez($suffix);
        }
    }
}else{
    error_q("[Error 117] Unrecognized name format with $name in record $fields[$recordnumberN].");
}


#deal with the prefix

if ($last=~/(.*)\|(.*)/){
    $last=$2;
    $prefix=$1;
}

#replace back

foreach $n ($last, $first, $suffix, $prefix){
    $n=~s/345679/,>/g;
    $n=~s/787265/*>/g;
}

#add to the hash
#in hash %namesIndex key is record number
#value is an another hash with keys as field
#each field has tab delimted bit that are seperated by \n

# 1 the name as it appears in the field
# 2 the order of the name
# 3 the last name
# 4 the first name
# 5 the suffix
# 6 prefix



$namesIndex{$record->{record_number}}->{$field}=
    "$namesIndex{$record->{record_number}}->{$field}".
    "$original_name\t$order\t$last\t$first\t$suffix\t$prefix\n";

#temp for making stand alone list of names
#my $printName='';
#if ($prefix ne '' && $suffix ne ''){
#	$printName = "$prefix $last, $first, $suffix";
#}elsif($prefix ne ''){	
#	$printName = "$prefix $last, $first";
#}elsif($suffix ne ''){
#	$printName = "$last, $first, $suffix";
#}else{
#	
#	$printName = "$last, $first";
#}
#$printName = "$printName\t$original_name\t$order\t$last\t$first\t$suffix\t$prefix\t$record->{record_number}\t$field\n";
#use Encode;
#	use utf8;
#	binmode STDOUT, ":utf8";
#	$printName = $printName);
#print OUT "$printName";


}


}####end of the subrutine
#####################################################################


sub contributors_list {
###add to contributors list
#takes names from the %namesIndex and places in contributor field
#as argumenst take 0 hash reference, 1  outpur format

my $record_number=$_[0];
my $option=$_[1];

if ($option eq 'rlg'){

    my %folk1=make_name($record_number,edition_details,lf_rlg);   
    my %folk2=make_name($record_number,description,lf_rlg);
    my %folks=(%folk1, %folk2);
    foreach $a (keys %folks){
        unless( $seenrlg{$folks{$a}} == 1){
           $data{$record_number}->{contributors}="$data{$record_number}->{contributors}"."$folks{$a}; ";
           $seenrlg{$folks{$a}} = 1;
        }
    }
    undef(%folk1);
    undef(%folk2);
    undef(%folks);
    undef(%seenrlg);
}elsif($option eq 'final'){

    my %folk1=make_name($record_number,edition_details,lf);   
    my %folk2=make_name($record_number,description,lf);
    my %folk3=make_name($record_number, author, lf);
    my %folk4=make_name($record_number, editor, lf);

    my %folks=(%folk1, %folk2, %folk3, %folk4);
    foreach $a (keys %folks){
        unless( $seenrlg{$folks{$a}} == 1){
           $data{$record_number}->{contributors}="$data{$record_number}->{contributors}"."$folks{$a}; ";
           $seenrlg{$folks{$a}} = 1;
        }
    }
    
    undef(%folk1);
    undef(%folk2);
    #undef(%folk3);      #just added, was there a reason this was not here, 25oct2006
    #undef(%folk4);      #just added, was there a reason this was not here, 25oct2006
    undef(%folks);
    undef(%seenrlg);
}

#$data{$record_number}->{contributors}=~s/;\s$//;
}

#####################################################################################

sub make_name {
#takes a referecne to names hash and type of name to nake and returns a referece to
#a hasj with keys of the original naems, and values as formated names

my $record=$_[0];       #takes a record number instead of hash reference now
my $field=$_[1];        #if 'linked' the takes the field from field 4
my $type=$_[2];
my $link2record=$_[3];  #this is the link to the record for getting names of linked things (okk this is stupid since could have just given the record number in the first field)
my $linkedfield=$_[4];  #this is the field from the linked records
#define all the name types
if($definenametypesfirst ne '1'){
%namestypes=(
    'lf_cap'=>'LAST, first',
    'ch_ed'=>'first last (in small caps)',
    'ch_ed_sh'=>'last; et al (in small caps) (only one name)',
    'fl_cap'=>'first LAST',
    'fl_dis_rlg'=>'first Last to discription field (cap last name)',
    'lf'=>'last, first (but not for asian)',
    'lf_rlg'=>'last, first for all including asian',
    'fl_sc'=>'fist last (in samll caps)',
    'lf_sc'=>'last, first (in small caps)',
    'lf_fl_sc'=>'last, first, first last (in samll caps)',
    'lf_fl_cap'=>'last, first, first last ',
    'srt'=>'last first, last first (all lower case used for sorting) (cant use sort since it is a comand)',
    'lf_fl_in'=>'last, first, first last but first names intials only and et alfter',
    'lf_rev'=>'last, f.i. last first, initials only, no space in initials and few other things',
    'li'=>'Last initilan, no spaces.',
);
$definenametypesfirst=1;
}
if ($namestypes{$type} eq ''){
    error_q("The name type $type is not defined in the make_name subruite [Error 107]");
}    
my $new;
undef(%new_names);


#this will retrives keys from hash in insertion order
#perl cookbook 5.6
tie %new_names, "Tie::IxHash";

if ($field eq 'linked'){
    @names=split(/\n/, $namesIndex{$link2record}->{$linkedfield});
}else{
    @names=split(/\n/, $namesIndex{$record}->{$field});
}
#if more thatn 2 book editors for chapter (short), keep only the first one
if($type eq 'ch_ed_sh' && $#names > 1){

    $#names=0;
    $names[1]="original name\tetal\tet al.";
}

#if more thatn 3 book editors for chapter (long), keep only the first one
if(($type eq 'ch_ed' || $type eq 'lf_fl_in') && $#names > 2){

    $#names=0;
    $names[1]="original name\tetal\tet al.";
}

$namec=0;

foreach $name (@names){
    $namec++;
    #lower case for sorting purpusues
    if($type eq 'srt'){
        $name=lc($name);
    }
    my @parts=split(/\t/, $name);
    my $original_name=$parts[0];
    my $order=$parts[1];

    #must capitalize BEFORE converting to LaTeX
    if($type eq 'lf_cap' || $type eq 'fl_cap' || $type eq 'fl_dis_rlg' || $type eq 'lf_fl_cap'){
        $parts[2]=uc($parts[2])
    };

    my $last=$parts[2];
    my $first=$parts[3];
    my $suffix=$parts[4];
    my $prefix=$parts[5];

    $new='';

    if ($type eq 'lf_cap' || $type eq 'lf' || $type eq 'lf_rlg'){
        if ($order eq 'asis'){
            $new="$new"."$prefix"."$last";
        }elsif ( $order eq 'western'){
            $new="$new"."$prefix"."$last, $first, $suffix";
            $new=~s/,\s$//;
            $new=~s/,\s$//;     #do it twice incase no suffin and first
        }elsif ( $order eq 'asian' && $type eq 'lf_rlg'){
            $new="$new"."$last, $first";
        }elsif ( $order eq 'asian'){
            $new="$new"."$last $first";
        }elsif ($ order eq 'etal'){
            $new="$new"."et al.";
        }else{
            error_b("Order $order in $name is record $record->{record_number} not known");
        }
    }elsif($type eq 'lf_sc'  || $type eq 'lf_rev' || ( ($type eq 'lf_fl_sc' || $type eq 'lf_fl_in' || $type eq 'lf_fl_cap') && $namec==1) ){
        if($type eq 'lf_fl_in'){
            $first=initial($first);
        }
        if($type eq 'lf_rev' && $order ne 'asis'){
            $first=initial2($first);
        }
        if ($order eq 'asis'){
            $new="$new"."$prefix"."<sc>$last</sc>";
        }elsif ( $order eq 'western'){
            $new="$new"."$prefix"."<sc>$last</sc>, $first, $suffix";
            $new=~s/,\s$//;
            $new=~s/,\s$//;     #do it twice incase no suffin and first
        }elsif ( $order eq 'asian' ){
            $new="$new"."<sc>$last</sc> $first";
        }elsif ($ order eq 'etal'){
            $new="$new"."et al.";
        }else{
            error_b("Order $order in $name is record $record->{record_number} not known");
        }
    }elsif($type eq 'fl' ){
        if ($order eq 'asis'){
                $new="$new"."$prefix"."$last";
            }elsif ( $order eq 'western'){
                $new="$new"."$prefix"."$first $last, $suffix";
                $new=~s/,\s$//;
            }elsif ( $order eq 'asian' ){
                $new="$new"."$last $first";
            }elsif ($order eq 'etal'){
                $new="$new"."et al.";
            }else{
                error_b("Order $order in $name is record $record->{record_number} not known");

            }
    }elsif($type eq 'fl_sc' || $type eq 'ch_ed' || ( ($type eq 'lf_fl_sc' || $type eq 'lf_fl_in' || $type eq 'lf_fl_cap') && $namec > 1)){
        if($type eq 'lf_fl_in'){
            $first=initial($first);
        }
        if ($order eq 'asis'){
                $new="$new"."$prefix"."$last";
            }elsif ( $order eq 'western'){
                $new="$new"."$prefix"."$first".' <sc>'."$last".'</sc>, '."$suffix";
                $new=~s/,\s$//;
            }elsif ( $order eq 'asian' ){
                $new="$new".'<sc>'."$last".'</sc> '."$first";
            }elsif ($order eq 'etal'){
                $new="$new"."et al.";
            }else{
                error_b("Order $order in $name is record $record->{record_number} not known");

            }
    }elsif($type eq 'ch_ed_sh'){
        if ($order eq 'asis'){
                $new="$new"."$prefix"."<sc>$last</sc>";
            }elsif ( $order eq 'western'){
                $new="$new".'<sc>'."$last".'</sc>';
            }elsif ( $order eq 'asian' ){
                $new="$new".'<sc>'."$last".'</sc>';
            }elsif ($order eq 'etal'){
                $new="$new"."et al.";
            }else{
                error_b("Order $order in $name is record $record->{record_number} not known");
            }
    }elsif($type eq 'fl_dis_rlg'){
        if ($order eq 'asis'){
                $new="$prefix"."$last";
            }elsif ( $order eq 'western'){
                #$last=uc($last);            #need to fix the few that don't work here
                $new="$prefix"."$first $last, $suffix";
                $new=~s/,\s$//;
            }elsif ( $order eq 'asian' ){
                #$last=uc($last);            #need to fix the few that don't work here
                $new="$last $first";
            }elsif ($order eq 'etal'){
                $new="et al.";
            }else{
                error_b("Order $order in $name is record $record->{record_number} not known");

            }

     }elsif($type eq 'srt'){
       if ($order eq 'asis'){
                $new="$last";
            }elsif ( $order eq 'western'){
                $new="$last $first $suffix";
            }elsif ( $order eq 'asian' ){
                $new="$last $first";
            }elsif ($order eq 'etal'){
                $new="et al.";
            }else{
                error_b("Order $order in $name is record $record->{record_number} not known");

            }
     }elsif($type eq 'li'){
     	     $new="$last";
     	     my $initials;
     	     my $first_unicode=$first;
     	     #needs to fix so it matches unicode uppers
     	     while ($first_unicode=~/\b([A-Z])/g){
     	     	     $initials="$initials"."$1";
     	     }
     	     $new="$new $initials"
     }
     
    $new_names{$original_name}=$new;
}

return %new_names;

}

####

sub initial {
 my $first=$_[0];

            #$first="$first ";       #add white space at the end so that will match
            @fnam=@fnam2='';
            $nnw='';
            @fnam=split(/\s/, $first);
            foreach $n (@fnam){
                @fnam2=split(/-/, $n);
                $dashname='';
                foreach $m (@fnam2){
                    if($dashname == 1){
                        $nnw=~s/\s$/-/;
                    }
                    if ($m=~/^(<.*?>)/){        #if it is a special character
                        $nnw="$nnw"."$1. ";
                    }else{
                        $m=~/(\w)/;             #if regular leter
                        $nnw="$nnw"."$1. ";
                    }
                    $dashname=1;
                }
            }
            $nnw=~s/\s$//;
            #$first=~s/(\w).*?[\s-]/$1./g;   #take only initials of first names
            #$first=~s/\.(\w)/. $1/g;        #put a space between initials
return($nnw);
}


sub initial2 {
#new initial rutine for reviewx
 my $first=$_[0];

            #$first="$first ";       #add white space at the end so that will match
            @fnam=@fnam2='';
            $nnw='';
            @fnam=split(/\s/, $first);
            foreach $n (@fnam){
            #do not initial things that start with lower case
            if ($n=~/^\s*[a-z]/){
                $nnw="$nnw $n ";
            }else{    
                #do this os that John-Smith -> J.-S.
                #but John-burr -> J.
                if ($n=~/-[A-Z]/){
                    @fnam2=split(/-/, $n);
                }else{
                    $fnam2[0]=$n;
                }        
                $dashname='';
                foreach $m (@fnam2){
                    if($dashname == 1){
                        $nnw=~s/\s$/-/;
                    }
                    if ($m=~/^(<.*?>)/){        #if it is a special character
                        $nnw="$nnw"."$1.";
                    }else{
                        $m=~/(\w)/;             #if regular leter
                        $nnw="$nnw"."$1.";
                    }
                    $dashname=1;
                }
            }
            }
            $nnw=~s/\s$//g;
            #$first=~s/(\w).*?[\s-]/$1./g;   #take only initials of first names
            #$first=~s/\.(\w)/. $1/g;        #put a space between initials
return($nnw);
}

1;
