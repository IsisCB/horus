use Encode;
use utf8;
binmode STDOUT, ":utf8";


#$series='Medizingeschichte im Kontext, Bd. 6';
#$series='Biblioteca di Nuncius, Studi e testi, vol. 8';
#$series='Abhandlungen der Sächsischen Akademie der Wissenschaften zu Leipzig, Mathematisch-Naturwissenschaftliche Klasse, 63, Heft 4';

$infile='seriesIN.tab';
$outfile='seriesOUT.tab';

open IN, "<:utf8",   $infile  or die "Couldn't open file $infile $!";
open OUT, ">:utf8",   $outfile  or die "Couldn't open file $outfile $!";

while (<IN>){
chomp;
$series=$_;

system('cls');
$s_title=$s_number=$s_manual='';

if ($series!~/\d/){
  $s_title=$series;
  $s_number='';
}else{
  
  $series=~/(.*),\s*(.*?)\s*(\d*)$/;
    $m1=$1;
    $m2=$2;
    $m3=$3;
  
  if ($m2 eq '' || $m2=~/bd\.*/i  || $m2=~/^\s*?vol\.*?\s*?$/i || $m2=~/^\s*?volume\s*?$/i || $m2=~/band/i || $m2=~/no\.*/i){
    $s_title=$m1;
    $s_number=$m3;
  
  }else{
    #present options
    print "1. TITLE: $m1 **** $m3\n";
    print "2. TITLE: $m1, $m2 **** $m3\n";
    print "3. TITLE: $m1 **** $m2 $m3\n";
    print "4. TITLE: $m1, $m2 $m3\n";
    print "5. manual";
    print"\n";
    $option=<STDIN>;
    
    if ($option=~/1/){
      $s_title=$m1;
      $s_number='$m3';
    }elsif($option=~/2/){
      $s_title="$m1, $m2";
      $s_number="$m3";
    }elsif($option=~/3/){
      $s_title="$m1";
      $s_number="$m2 $m3";
    }elsif($option=~/4/){
      $s_title="$m1, $m2 $m3";
      $s_number='';
    }elsif($option=~/5/){
      $s_manual=$series;
    }else{
      $s_manual=$series;
    }
  
  } 
}
print  OUT "$series\t$s_title\t$s_number\t$s_manual\n";

}


close IN;
close OUT;
