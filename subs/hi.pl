sub hi {

$nu=int( rand(14390));
$hi_File='C:\CB directory\Aux Files\subs\0ddcc10.txt';
open (IN, "< $hi_File") || print "Oops";
while (<IN>){
if ($.==$nu  || $.==($nu+1)){
	print "$_";
$tyu++;
}
if ($tyu==2){ last }
}
close IN;
print "____________________________________________\n";
}

1;
