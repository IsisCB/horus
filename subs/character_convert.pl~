#sub character_convert{
#subrutine to convert from any one of the four used encodings to any other
#the four are
#   Latin-1  (L1)
#   CB private code  (CB)
#   LaTeX code   (TX)
#   ASCII 128      (SC) 
#   also posibble combination of L1 and CB  marked as DC
#
#is called with three argments 
#   $_[0] is the data to be converted
#
#if given a field addes information about its encoding to the begingn of the field
#also accepts information about encoding of incoming data from third optional
#arguemnt, as a defolt takes Latin-1 + CB prive code 
#
#probably will be easiet if everyhting is procesed in CB
#untill needs to be exported then gets outputed
#must be ready for non-latin alphabets cyrylic, greek etc
########################################################

sub l12cb {
#as argument takes the text to be converted
#DC->CB L1->CB
#create a hash with L1 maped to CB, split at charctere and do the conversion
#requires 'ascii_map.pl'  find a place to make the request

#test this by making a file with all characters and exporting it from file maker

my $split_line;
my $character;
my $asci_number;
my $newline;

@split_line=split(//,$_[0]);        #split the argument give to the sub into individual character
foreach $character (@split_line){                  
        $asci_number=ord($character);            #convert charters into ASCII values
        #because " is a specail character in .csv need to escape ones in converion if reading from file
        #but don't do it if was already done [^"]
        if ($_[1] eq 'line'){$ascii{$asci_number}=~s/([^"])">/$1"">/;}     
        
        #makes the conversion %ascii is located in 'subs/ascii_map.pl'
        #if the character does not have a covnersion (tabs ets) leave it be
        if($ascii{$asci_number}){
            $converted_character=$ascii{$asci_number};  
        }else{
            $converted_character=chr($asci_number);
        }
        $newline="$newline"."$converted_character";
}
#here replace what was given with the new thing make sure this work

#put umplauts ontop of letters
#$newline=~s/(\w)<bksp><"">/<$1"">/g;
#change ~ to <~>
$newline=~s/~([^>])/<~>$1/g;

return $newline;
}
########################################end sub L12CB

sub cb2l1 {
#as argument takes the text to be converted 
#CB->L1




#first gradb all the <url>
$nextcburlsubtextcnt=1;
while($_[0]=~/(<url>.*?<\/url>)/g){
    $_[0]=~s/($1)/CBURLSUBTEXT$nextcburlsubtextcnt URLEND/g;
    $cburlsub{$nextcburlsubtextcnt}=$1;
    $nextcburlsubtextcnt++
}    

while($_[0]=~/(<.*?>)/g){
    ($grab=$1)=~s/""/"/;             #if already csv
if ($grab eq '<lt>' || $grab eq '<gt>' || $grab=~/<com:.*?>/){        #<lt> and <gt> should not be replaced
    #do notin
}elsif ($character_map{$grab}){
        if($character_map{$grab}->{l1}){       #replace if know what to replace with
            $match2=$match=$grab;
            $match2=~s/\^/\\^/;      #otherwise will not match
            $match2=~s/\?/\\?/;      #otherwise will not match
            $match2=~s/\(/\\(/;      #otherwise will not match
            $match2=~s/\$/\\\$/;     #otherwise will not match
            $match2=~s/\*/\\*/;      #otherwise will not match
            $match2=~s/\+/\\+/;      #otherwise will not match
            $match2=~s/\./\\./;      #otherwise will not match
            $match2=~s/"/""/;
            $l1ch=chr($character_map{$match}->{l1});
            #log_p("$match2 $match $l1ch");
        
            $_[0]=~s/$match2/$l1ch/;
         }
}else{
        unless ($convertcharaterloose eq 'loose'){
            my $possid="$this->{record_number}, $linked->{record_number}, $readid";
            error_q("[Error 114] $grab is not a recognized character command. Possible record numbers which include the text: $possid. Found in the follwing text: $_[0]");
            error_showSymTable();
        }else{
            #when there is no error reporting, at least note in the log
            my $possid="$this->{record_number}, $linked->{record_number}, $readid";
            message_q("[Error 201] $grab is not a recognized character command. Possible record numbers which include the text: $possid. Found in the follwing text: $_[0]");
        }     
    }            
}
#return the url things
while($_[0]=~/(CBURLSUBTEXT(.*?)\sURLEND)/g){
    $mt2=$2;
    $_[0]=~s/($1)/$cburlsub{$mt2}/g;
}    
undef(%cburlsub);
$return=$_[0];
}
####################################end sub CB2L1

sub cb2tx {
#as argument takes the text to be converted 
#CB->TX

my $text=$_[0];

#first convert greek and cyrillic language environments to letters

#cyrillic
while($text=~/(<cyr>(.*?)<\/cyr>)/g){        #first locate the text to be converted
     #now split into letters and convert each letter                                   
    $old_c_line_f=$1;   #including the tags
    $old_c_line=$2;     #just inside the tags
    @cyr_let=split(//, $old_c_line);
    foreach $l (@cyr_let){
        if ($l eq '<'){         #if there is a special character comming
            $cyr_line="$cyr_line"."$l";
            $langEvSpCh=1;
        }elsif($l eq '>'){          #the end of the special character
            $cyr_line="$cyr_line"."$l";
            $langEvSpCh=0;
        }elsif($langEvSpCh==1){         #just reprint the specail character
            $cyr_line="$cyr_line"."$l";
        }elsif ($cyrillic_map{$l} ne ''){       #now do conversion
            $cyr_line="$cyr_line"."$cyrillic_map{$l}";
         }else{
            $cyr_line="$cyr_line"."$l";
         }      
    }
    #create a hash of things to be replaced
    $langEnv2rep{$old_c_line_f}=$cyr_line;
    $cyr_line=$old_c_line_f=$old_c_line='';
}

#greek
while($text=~/(<grk>(.*?)<\/grk>)/g){        #first locate the text to be converted
     #now split into letters and convert each letter                                   
    $old_c_line_f=$1;   #including the tags
    $old_c_line=$2;     #just inside the tags
    @cyr_let=split(//, $old_c_line);
    foreach $l (@cyr_let){
        if ($l eq '<'){         #if there is a special character comming
            $cyr_line="$cyr_line"."$l";
            $langEvSpCh=1;
        }elsif($l eq '>'){          #the end of the special character
            $cyr_line="$cyr_line"."$l";
            $langEvSpCh=0;
        }elsif($langEvSpCh==1){         #just reprint the specail character
            $cyr_line="$cyr_line"."$l";
        }elsif ($greek_map{$l} ne ''){       #now do conversion
            $cyr_line="$cyr_line"."$greek_map{$l}";
         }else{
            $cyr_line="$cyr_line"."$l";
         }      
    }
    #create a hash of things to be replaced
    $langEnv2rep{$old_c_line_f}=$cyr_line;
    $cyr_line=$old_c_line_f=$old_c_line='';
}

#now perform all the replacement
foreach $e (keys %langEnv2rep){
    $text=~s/$e/$langEnv2rep{$e}/;
}    

undef(%langEnv2rep);

#deal with < and > in <url> envrs
#$text=~s/(<url>.*?)<(.*?<\/url>)/$1CBLESSTHANCODESUB$2/g;
#$text=~s/(<url>.*?)>(.*?<\/url>)/$1CBGREATERTHANCODESUB$2/g;
#first gradb all the <url>
$nextcburlsubtextcnt=1;
foreach($text=~/<url>(.*?)<\/url>/g){
    $text=~s/($1)/CBURLSUBTEXT$nextcburlsubtextcnt URLEND/g;
    $cburlsub{$nextcburlsubtextcnt}=$1;
    $nextcburlsubtextcnt++;
}    

#escape all LaTeX special characters. this will result in 
# $ # ~ if they are followed by > are part of a sepcail chacter so don't escape them

#$text=~s#\\#\$\\backslash\$#g;
$text=~s/&/\\&/g;     
$text=~s/_[^>]/\\_/g;   
$text=~s/\$[^>]/\\\$/g; 
$text=~s/%/\\%/g;
$text=~s/#[^>]/\\#/g;   
$text=~s/{/\\{/g;
$text=~s/}/\\}/g;
$text=~s/~[^>]/\\~/g;     
$text=~s/\^[^>]/\\^/g;

#Take care of nesting quotes
#first put an extra space \, between quotes next to each other (adds extra small space)
$text=~s/<q><q>/<q>\\,<q>/g;
$text=~s/<\/q><\/q>/<\/q>\\,<\/q>/g;
#now replace inside quotes with single quotes
$ct=0;
while($text=~/(<q>|<\/q>)/g){
    if ($1 eq '<q>'){
        $ct++;
        if ($ct==1){
            $text=~s/<q>/``/;
        }else{
            $text=~s/<q>/`/;
        }        
    }else{
        $ct--;    
        if ($ct==0){
            $text=~s/<\/q>/''/;
        }else{
            $text=~s/<\/q>/'/;
        }
    }
        
}       #end of quote replace deal


#get rid of comments
$text=~s/<com:.*?>//g;

while($text=~/(<.*?>)/g){
    if($1 eq '<lt>' || $1 eq '<gt>' || $1=~/<com:.*?>/){
        #do notin, if they get replaced here then the whilel loop catches them and bad things happen        
        #the $1=~<com:.*?> is to match comments
    }elsif ($character_map{$1}){
        if($character_map{$1}->{tx}){       #replace if know what to replace with
            $match2=$match=$1;
            $match2=~s/\^/\\^/;      #otherwise will not match
            $match2=~s/\?/\\?/;      #otherwise will not match
            $match2=~s/\(/\\(/;      #otherwise will not match
            $match2=~s/\$/\\\$/;     #otherwise will not match
            $match2=~s/\*/\\*/;      #otherwise will not match
            $match2=~s/\+/\\+/;      #otherwise will not match
            if($character_map{$1}->{tx} eq 'nada'){
                 $text=~s/$match2//;
            }else{      
               $text=~s/$match2/$character_map{$match}->{tx}/;
            }   
         }
    }else{
        unless ($convertcharaterloose eq 'loose'){
         my $errorch=$1;
         my $possid="$this->{record_number}, $linked->{record_number}, $readid";
         error_q("[Error 115] $errorch is not a recognized character command. Possible record numbers which include the text: $possid. Found in the follwing text: $text");
        error_showSymTable();
        }else{
            #when there is no error reporting, at least note in the log
            my $possid="$this->{record_number}, $linked->{record_number}, $readid";
            message_q("[Error 201a] $grab is not a recognized character command. Possible record numbers which include the text: $possid. Found in the follwing text: $_[0]");
        }
    }            
}
#now do a global replace for <lt> and <gt>
$text=~s/<lt>/\$<\$/g;
$text=~s/<gt>/\$>\$/g;
#add < and > to urls
#$text=~s/\\url{(.*?)}/\\url{<$1>}/g;
#$text=~s/(\\url{.*?)CBLESSTHANCODESUB(.*?})/$1<$2/g;
#$text=~s/(\\url{.*?)CBGREATERTHANCODESUB(.*?})/$1>$2/g;

#return the url things
while($text=~/(CBURLSUBTEXT(.*?)\sURLEND)/g){
    $mt2=$2;
    $text=~s/($1)/$cburlsub{$mt2}/g;
}    
undef(%cburlsub);

return($text);
}
########################end sub CB2TX


sub print_test {

#finshi this so that some form of a test file is printed

open (OUT, "> charater_test.txt") || print "hell no";
#foreach $k (sort {$a <=> $b} keys %ascii){
for ($k=1; $k<256; $k++){
    print OUT "$k\t$ascii{$k}\t";
    $te= chr($k);
    print OUT "$te\n";
}


}
####################################

sub cb2sc {
#as argument takes the text to be converted 
#CB->SC
#converts things to ASCII 128, for alphabetaziatione etc
#turns things into lowerc case
#gets rid phunky stuff
my $tc=$_[0];

$tc=~s/(<.*?>)/$character_map{$1}->{sc}/g;
$tc=lc($tc);
return ($tc);
}
########################end sub CB2TX




1;
