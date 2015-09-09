#first read the old ones read the the notes
#this is a tem scrip, delete it


$infile="FM2.tab";
$outfile="matched4.tab";


#read the data
open(IN, "< $infile") || die ("boo $infile");
open(OUT, "> $outfile") || die ("boo $outfile");
while(<IN>){
chomp;
($id, $author, $editor)=split(/\s\s/, $_);
 if ($author=~/(.*?)\(\s*et\s+al.*eds.*\)/){
  $aN='';
  $eN="$1".'; et al.';
}elsif($author=~/(.*?)\(\s*et\s+al.*\)/){
 $aN="$1".'; et al.';
}
if ($author=~/(.*?);\s*et\al/){
 $aN="$1".'; et al.';
} 
if ($editor=~/(.*?);\s*et\al/){
 $eN="$1".'; et al.';
}

if($editor=~/(.*?)\(\s*et\s+al.*\)/){
 $eN="$1".'; et al.';
}

print OUT "$author\t$editor\t$id\n$aN\t$eN\n\n";
} #end while
close IN;
close OUT;
