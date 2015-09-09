
sub subjects_report {

use DB_File;
require Text::CSV;  


#read auxilary files
#probably don't need all of them
my $journals="$ap".'Aux Files\db\journals.db';
my $journals_abb="$ap".'Aux Files\db\journals_abbreviations.db';
my $journals_issn="$ap".'Aux Files\db\journals_issn.db';
my $subjects="$ap".'Aux Files\db\subjects.db';
my $reverse_subjects="$ap".'Aux Files\db\reverse_subjects.db';
my $subjects_index="$ap".'Aux Files\db\subjects_index.db';
my $subjects_type="$ap".'Aux Files\db\subjects_type.db';
my $categories="$ap".'Aux Files\db\categories.db';
my $categories_short="$ap".'Aux Files\db\categories_short.db';
my $errorhelp="$ap".'Aux Files\subs\errorhelp.db';
my $errorinfo="$ap".'Aux Files\subs\errorinfo.db';
my $subjects_counts="$ap".'Aux Files\db\subjects_counts.db';
my $cats_corr="$ap".'Aux Files\db\cats_corr.db';
my $cats2subT="$ap".'Aux Files\db\cats2subT.db';
my $js_corr="$ap".'Aux Files\db\js_corr.db';
my $subs_corr="$ap".'Aux Files\db\subs_corr.db';
my $subs_corrT="$ap".'Aux Files\db\subs_corrT.db';
my $subs_corrM="$ap".'Aux Files\db\subs_corrM.db';
my $cats_counts="$ap".'Aux Files\db\cats_counts.db';
my $sub2cat="$ap".'Aux Files\db\sub2cat.db';
my $sub2catT="$ap".'Aux Files\db\sub2catT.db';
my $ttle_corr="$ap".'Aux Files\db\ttle_corr.db';
my $js_corrR="$ap".'Aux Files\db\js_corrR.db';
my $js_count="$ap".'Aux Files\db\js_count.db';
dbmopen %subjects, $subjects, 0666;
dbmopen %reverse_subjects, $reverse_subjects, 0666;
dbmopen %subjects_index, $subjects_index, 0666;
dbmopen %subjects_type, $subjects_type, 0666;
dbmopen %journals, $journals, 0666;
dbmopen %journals_abbreviations, $journals_abb, 0666;
dbmopen %journals_issn, $journals_issn, 0666;
dbmopen %categories, $categories, 0666;
dbmopen %categories_short, $categories_short, 0666;
dbmopen %errorinfo, $errorinfo, 0666;
dbmopen %errorhelp, $errorhelp, 0666;
dbmopen %subjects_counts, $subjects_counts, 0666;
dbmopen %cats_corr, $cats_corr, 0666;
dbmopen %cats2subT, $cats2subT, 0666;
dbmopen %js_corr, $js_corr, 0666;
dbmopen %subs_corr, $subs_corr, 0666;
dbmopen %cats_counts, $cats_counts, 0666;
dbmopen %sub2cat, $sub2cat, 0666;
dbmopen %ttle_corr, $ttle_corr, 0666;    
dbmopen %sub2catT, $sub2catT, 0666;
dbmopen %subs_corrM, $subs_corrM, 0666;
dbmopen %js_corrR, $js_corrR, 0666;
dbmopen %js_count, $js_count, 0666;

##############################################################3

system('cls');  #clear the window

#read data
($item, $type)=split(/:/, $optionsFMO);

if ($type eq 'subject'){
    
     print "____________________________________________\n";
     print "\t$subjects{$item} ["."$item"."]\n";
     print "____________________________________________\n";
     print "*Number of occurances: $subjects_counts{$item}\n";
     
     ###
     print "\n*Most common categories associated with this subject\n";
     @s2c=split(/:/, $sub2catT{$item});
     foreach $s (@s2c){
        ($cat, $count)=split(/=/, $s);
        #for individual rather then combined count do the following
        if ($cat=~/^(\d\d\d)(.*)/){
            $cc{$1}=$cc{$1} + $count;
            $cc{$2}=$cc{$2} + $count;
            #but also keep the combined
            $cc{$cat}=$count;
        }else{    
            $cc{$cat}=$count;        
        }    
     }  
     foreach $s (sort {$cc{$b} <=> $cc{$a}} keys %cc){
        #next if $s >199;
        next if $s eq '';
        next if $catitct == 25;
         $num=sprintf ("%.0f",  100*$cc{$s}/$subjects_counts{$item});
         print "   $num"."%\t= ";      
            @cdig=split(//,$s);
            if ($#cdig < 3){
                #one of the basi categories
                print "$s\t$categories_short{$s} ($cc{$s})\n";
            }else{
                $s=~/^(\d\d\d)(.*)/;
                $c1=$1;
                $c2=$2;    
                print "$c1-$c2 $categories_short{$c1}-$categories_short{$c2} ($cc{$s})\n ";
            }    
        $catitct++;
            
    }
    
    ###
    print"\n*Most co-occuring subject\n";    
    @subSuba=split(/:/, $subs_corrM{$item});
    foreach $s (@subSuba){
        ($si, $sf)=split(/=/, $s);
        #$b=(10* $sf * ($subjects_counts{$si})**(2))**(1/3);
        $coosub{$si}=$sf;
        
    }    
    $catitct=0;
    foreach $s (sort {$coosub{$b} <=> $coosub{$a}} keys %coosub){
        next if $subjects_type{$s}=~/time/i;
        next if $catitct == 15;
        $num=sprintf ("%.0f",  100*$coosub{$s}/$subjects_counts{$item});
         print "   $num"."%\t= "; 
        print "$subjects{$s} ";
        print "($coosub{$s})\n";
        $catitct++;
    } 
    
    
    ###
    print "\n*Most common source journals\n";
    @js=split(/:/, $js_corrR{$item});
    foreach $j (@js){
        ($ju, $ji)=split(/=/, $j);
        $jcor{$ju}=$ji;
    }
    $catitct=0;
    foreach $j (sort {$jcor{$b} <=> $jcor{$a}} keys %jcor){
        next if $j eq '';
        next if $catitct==15;
        $num=sprintf ("%.0f",  100*$jcor{$j}/$subjects_counts{$item});
         print "   $num"."%\t= "; 
        print "$journals{$j}";
        print " ("."$jcor{$j}".")\n";
        $catitct++;
    }        
       
    #temp test########################################
    undef(%jcor);
     print "\n*playin here\n";
    @js=split(/:/, $js_corr{8});
    foreach $j (@js){
        ($ju, $ji)=split(/-/, $j);
        $jcor{$ju}=$ji;
    }
    $catitct=0;
    foreach $j (sort {$jcor{$b} <=> $jcor{$a}} keys %jcor){
        next if $j eq '';
        next if $catitct==20;
        $num=sprintf ("%.0f",  100*$jcor{$j}/$js_count{8});
         print "   $num"."%\t= "; 
        print "$subjects{$j}";
        print " ("."$jcor{$j}".")\n";
        $catitct++;
    } 
      ############################################# 
}elsif ($type eq 'cats'){

print "____________________________________________\n";
if ($item=~/\-/){
    ($c1, $c2)=split(/-/, $item);
    print "\t$categories_short{$c1}"."-"."$categories_short{$c2} ["."$c1-$c2"."]\n";
    print "____________________________________________\n";
    $item=~s/\-//;
    print "*Number of occurances: $cats_counts{$item}\n";
}else{

 
     print "\t$categories_short{$item} ["."$item"."]\n";
     print "____________________________________________\n";
     print "*Number of occurances: $cats_counts{$item}\n";
}

#subjects co-occurance
print "\nMost common subjects for this category:\n";
print "(% of records with this category with subject, subject, number of occrances)\n\n";

     @s2c=split(/:/, $cats2subT{$item});
     foreach $s (@s2c){
        ($sub, $count)=split(/=/, $s);
         $subct{$sub}=$subct{$sub} + $count;
     }  
     foreach $s (sort {$subct{$b} <=> $subct{$a}} keys %subct){
        next if $s eq '';
        next if $subjects_type{$s} ne '2003';
        next if $catitct == 30;
         $num=sprintf ("%.0f",  100*$subct{$s}/$cats_counts{$item});
         print "   $num"."%\t= ";      
         log_p("$subjects{$s}\t$subct{$s}");
         $catitct++;
            
    }

    


}else{
         error_b("Error: Unknow request type $type in subjects_report.pl");    
  

}
dbmclose %cats2subT;
dbmclose %subs_corrT;
dbmclose %sub2catT;
dbmclose %cats_counts;
dbmclose %subjects_counts;
dbmclose %subjects;
dbmclose %reverse_subjects;
dbmclose %subjects_index;
dbmclose %subjects_type;
dbmclose %journals;
dbmclose %journals_abbreviations;
dbmclose %journals_issn;
dbmclose %categories;
dbmclose %categories_short;
dbmclose %cats_corr;
dbmclose %js_corr;
dbmclose %subs_corr;
dbmclose %sub2cat;
dbmclose %ttle_corr;
dbmclose %subs_corrM;
dbmclose %js_corrR;
dbmclose %js_count;
}

1;
