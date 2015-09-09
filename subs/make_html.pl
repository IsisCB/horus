
sub make_html{
#takes a latex citation and converts it to html and plain text

my $cite=$_[0];

#first dump the junk from the begining
$cite=~s/\\noindent\\begin{footnotesize}//;
$cite=~s/\\end{footnotesize}//;
$cite=~s/\\vspace{.*?}//g;
$cite=~s/\\begin{isisdescription}/\n\n/;
$cite=~s/\\end{isisdescription}//;

$html="$html"."$cite\n\n";

}

sub print_html{

my $head='\documentclass[12pt]{article}'."\n".'\begin{document}'."\n\n";
my $tail='\end{document}';

$html="$head \n $html \n $tail";
open (OUT, "> $html_File") || error_q("[Error 176] Could not open $html_File for writing");
print OUT "$html";
close OUT;    
system("tth -w \"$html_File\"");
#unlink($html_File);

}


1;
