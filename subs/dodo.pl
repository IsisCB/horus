#script for reading files from DAI and converting them to 
#ready for FM files 

#to be called from FM.

#Did you save the input fila as >>dis.txt<< in the Sciript\subs directory?


#This script does some crude fixes fo the data, but that needs to be
#monitored and checked


use locale;
use lib 'C:\CB directory\Aux Files\subs';
$ap='C:\CB directory\\';
require 'errors.pl';

$infile="$ap".'Aux Files\subs\dis.txt';
$outfile="$ap".'Aux Files\subs\dis.tab';

open (IN, "< $infile") || error_b("coundn't open $infile for reading");
open (OUT, "> $outfile") || error_b("cound't open $outfile for writing");

#print OUT export order (not for a tab file)
#print OUT "Journal_Link\tJournal_Volume\tPages\tYear of Publication \tTitle\tAuthor\tBibliographer's_Notes\tDescription\tAbstract\tSource_of_Data\n";

while (<IN>){
    chomp;
    if($_=~/\s*?(Title|Pub\sNo|Author|Degree|School|Date|Pages|Adviser|ISBN|Source|Subject|Abstract):(.*)/){
        $field=$1;
        sqeez($record{$field}=$2);
        $record{$field}=htmlconvert($record{$field});
    }elsif($_=~/-----/){ 
        #change case of school
        $record{School} =~ s/(\w+)/\u\L$1/g;
        $record{School} =~s/Of/of/g;      #fix the commong problems 
        $record{School} =~s/At/at/g;
        $record{School} =~s/The\s/the /g;
        $des="Dissertation at $record{School}, $record{Date}.";
        unless ($record{Adviser}=~/\.$/) {$record{Adviser}="$record{Adviser}."}  #add a period unless one is already there
        $des="$des Advisor: $record{Adviser} UMI order no. $record{'Pub No'}. $record{'Pages'} pp.";
        if( $record{Source}=~/DAI-A/ ) {
            print OUT "353\t";   #journal ID for DAI-A
        }elsif($record{Source}=~/DAI-B/ ) {
            print OUT "354\t";   #journal ID for DAI-B    
        }elsif($record{Source}=~/DAI-C/ ) {
            print OUT "380\t";   #journal ID for DAI-C
        }else{
            print "Count not determine journal tile in $record{Source}";
            print OUT "\t";
        }
        $record{Source}=~/DAI-[ABC]\s(\d*?)\/.*?p\.\s(\d*?),\D*?(\d\d\d\d)/;
        print OUT "$1\t";            #voluem
        print OUT "$2\t";      #pages
        print OUT "$3\t";       #year 
        print OUT "$record{Title}\t";
        $record{Author}=~s/;$//;     #get rid of the trailing ;
        print OUT "$record{Author}\t";
        print OUT "$record{Subject}\t";        #go into bib notes
        print OUT "$des\t";
        print OUT "$record{Abstract}\t";
        print OUT "Erlen DAI contribution\t";
        
        #close record
        print OUT "\n";
        undef(%record);
    }else{
        sqeez($tx=$_);
        $tx=htmlconvert($tx);
       
        $record{$field}="$record{$field} $tx"
    }


}


print "\n\tThe script finished sucesfully (press Enter)";
$bey=<STDIN>;

##############
sub sqeez {

#this is a subrutine that is used by most others
#it gets rid of extra spaces in fields

$_[0]=~s/^\s+//;        #get rid of leading spacec
$_[0]=~s/\s+$//;        #get rid of trailing spaces
$_[0]=~s/\s+/ /;        #replace multiple spaces wiht a single one
}
sub htmlconvert {

my $tx=$_[0];

$tx=~s/&ldquo;/<q>/g;
$tx=~s/&rdquo;/<\/q>/g;
$tx=~s/&lsquo;/<q>/g;      #ingnore the difference between doubel and singel quotes
$tx=~s/&rsquo;/<\/q>/g;
$tx=~s/&ndash;/--/;
$tx=~s/<\/italic>/<\/e>/g;
$tx=~s/<italic>/<e>/g;
$tx=~s/&mdash;/---/g;
$tx=~s/&nbsp;/<>/g;        

return($tx);

}


1;
