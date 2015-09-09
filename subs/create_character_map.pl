#this script will create a hash with CB codes and correspondin other codes

open OUT, ">:utf8", character_map.pl || die "Cannot opern the fiel character_map.pl $!";

#requie hash of acii character and theri representaitons in CB
require 'ascii_map.pl';


#reverse the  ascii hash
foreach $key (keys %ascii){
    $iicsa{$ascii{$key}}=$key;
}


#here is an array of all letters and an array of diachritical marks
#that can be applied to all the letters
@leters=qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
@operations=qw(# ^  \\' ` ~ = * " _ \( , .);
@latexcodes=qw(v ^ \\' ` ~ = . " b k c d);


#
print OUT '%character_map=(';
print OUT "\n";


foreach $l (@leters){
    $i=0;
    foreach $o (@operations){
        $code="<$l$o".">";
        print OUT "'";
        print OUT "$code";            #the CB code
        print OUT "'=>{l1 =>'";
        print OUT "$iicsa{$code}";      #asci code
        print OUT "', sc=>'";
        print OUT "$l";               #plain text
        print OUT "', tx=>'";
        print OUT "\\$latexcodes[$i]"."{"."$l"."}";      #latex code
        print OUT "',},";
        print OUT "\n";   


        #do the same for upper case
        $ul=uc($l);
        $code="<$ul$o".">";
                print OUT "'";
        print OUT "$code";            #the CB code
        print OUT "'=>'{l1 =>'";
        print OUT "$iicsa{$code}";      #asci code
        print OUT "', sc=>'";
        print OUT "$ul";               #plain text
        print OUT "', tx=>'";
        print OUT "\\$latexcodes[$i]"."{"."$ul"."}";      #latex code
        print OUT "',},";
        print OUT "\n";  
        
        $i++;
    }
}        
