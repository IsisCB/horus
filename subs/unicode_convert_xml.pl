#tested on option rdf by sr April 1, 2014

use Encode;
use utf8;
binmode STDOUT, ":utf8";
#set option the choices are (mods, eac, rdf)

$option='rdf';


###################################################
system('cls');

#this is tab delimited conversion list. column one has the CB character mark, column 2 has the unicode character
$map1='CB Unicode Map.tsv';

###################################################################
#read in the conversion maps

open IN, "<:utf8", $map1 or die "Couldn't open file $map1: $!";
while (<IN>){
chomp;


$codes_temp1=$_;

	chopm;
	@codes_temp=split(/\t/, $codes_temp1);


#this is a temporary fix to get rig of the tags that are not converted to XML
if ($codes_temp[1]=~/empty/){

$codes_temp[1]=' ';
}
	$uni{$codes_temp[0]}=$codes_temp[1];     #unicode character
}

close IN;


###################################################################
#read the directory
if ($option eq 'mods'){
#for the MODS recods
opendir ($dir, 'C:\CB directory\Aux Files\XML') or print "Cannot open directory: $!";
}elsif($option eq 'eac'){
#for the EAC-CPF record
opendir ($dir, 'C:\CB directory\Aux Files\XML\authorities') or print "Cannot open directory: $!";
}elsif($option eq 'rdf'){
opendir ($dir, 'C:\CB directory\Aux Files\RDF') or print "Cannot open directory: $!";

}else{
print "Unknow option $option\n";
}

my @files = readdir ($dir);

foreach $infile (@files){

if ($option eq 'mods'){
#for the MODS
$outfile = '../UTF8/'."$infile";
}elsif($option eq 'eac'){
#for the EAC
$outfile = '../UTF8/authorities/'."$infile";
}elsif ($option eq 'rdf'){
$outfile = '../UTF8/RDF/'."$infile";

}else{
print "Unknow option $option\n";
}

open OUT, ">:utf8", $outfile or print "Couldn't open file $outfile: $!";

if ($option eq 'mods'){
#fro the MODS
open IN2, '../XML/'."$infile" or print "Couldn't open file $infile: $!";

}elsif ($option eq 'eac'){
#for the EAC
open IN2, '../XML/authorities/'."$infile" or print "Couldn't open file $infile: $!";
}elsif ($option eq 'rdf'){
open IN2, '../RDF/'."$infile" or print "Couldn't open file $infile: $!";

}else{
print "Unknow option $option\n";
}

while(<IN2>){
$text=$_;
$text=decode('ISO-8859-1', $text);



#print $text;

#do the conversion
#this is copeid and modified from character_convert.pl

#first gradb all the <url>
$nextcburlsubtextcnt=1;
#while($text=~/(<url>.*?<\/url>)/g){
#    $text=~s/($1)/CBURLSUBTEXT$nextcburlsubtextcnt URLEND/g;
#    $cburlsub{$nextcburlsubtextcnt}=$1;
#    $nextcburlsubtextcnt++
#}

while($text=~/(<.*?>)/g){
    #($grab=$1)=~s/""/"/;             #if already csv
     $grab=$1;
     #print "$grab ";
     if ($grab eq '<lt>' || $grab eq '<gt>' || $grab=~/<com:.*?>/){        #<lt> and <gt> should not be replaced
          #do notin
     }elsif ($uni{$grab}){

            $match2=$match=$grab;
            $match2=~s/\^/\\^/;      #otherwise will not match
            $match2=~s/\?/\\?/;      #otherwise will not match
            $match2=~s/\(/\\(/;      #otherwise will not match
            $match2=~s/\$/\\\$/;     #otherwise will not match
            $match2=~s/\*/\\*/;      #otherwise will not match
            $match2=~s/\+/\\+/;      #otherwise will not match
            $match2=~s/\./\\./;      #otherwise will not match
            #$match2=~s/"/""/;   #this is only needed if working with a csv file


              $l1ch=$uni{$grab};              
              $text=~s/$match2/$l1ch/;





      }else{

            #print "$grab is not a recognized character command";
            $error="$error\n$grab is not a recognized character command";
      }
}

#return the url things
#while($text=~/(CBURLSUBTEXT(.*?)\sURLEND)/g){
#    $mt2=$2;
#    $text=~s/($1)/$cburlsub{$mt2}/g;
#    
#}
undef(%cburlsub);

print OUT "$text";
}




close IN2;


close OUT;

}

closedir $dir;



$logfile='errors.log';
open OUT2, "> $logfile";
print OUT2 "$error";
close OUT2;
