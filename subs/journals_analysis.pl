sub journals_analysis{
###############################################################################
#OPTIONS
###############################################################################
$gapTH3=30;  #minimla size of a page gap to be reported for journals with rank 3
$gapTH2=100; #rank 2
$gapTH1=200; #rank 1
$endTH=0.2;   #worn if a volume is shorted by this much from the longes volume of a journal
@yearsToCheck=('2000','2001','2002','2003','2004','2005','2006'); #enter the years you want to check
###############################################################################


#reads the journal information
#journal id \t vol \t year \y \pages (from both journals and reviews)
#and looks for wholes

#first look at the tracking records create a hash for each journal with volumes as keys and in the value the traing ingot ALL, PART
#then look at pages, skip if tracking record covers
#first look at pages. create a hash for each journal with volumes as keys and in the value store a array on page nums

#then go throu all. if there is gap of 40 pages altet.
#for each volume keep a track of the largest page. if some volume has less than say 30% that lenght alert.
my $journals="$ap".'Aux Files\db\journals.db';
my $journals_rank="$ap".'Aux Files\db\journals_rank.db';
dbmopen %journals, $journals, 0666;
dbmopen %journals_rank, $journals_rank, 0666;
#open journal table
print "Reading Data...";

open(IN, "< $reviewsAnalysis_File") || die ("Could not open $reviewsAnalysis_File for reading $i");
open(OUT, ">> $journalAnalysis_File") || die ("Could not open $journalAnalysis_File for appending $i");
while(<IN>){
    chomp;
    print OUT "$_\t"."rev\n";
}    
close IN;
close OUT;
open(IN, "< $journalAnalysis_File") || die ("Could not open $journalAnalysis_File for reading $i");

while(<IN>){
    chomp;
    $id=$vol=$year=$pages='';
    ($id, $vol, $year, $pages, $rev)=split(/\t/, $_);  
    ($ymt=$year)=~s/\..*//;
    #standardize the nomenclature for non continious journal
    #also catch if the journal has some issues that are marked with issue nomber and other that are not
    if($vol=~s/(\d)([,:n].*?)(\d)/$1, no. $3/){
        if ($jPagination{$id} eq 'CT'){
            $jPagError{$id}=1;
         }
        $jPagination{$id}='NC';
    }else{
          $jPagination{$id}='CT';
    }             
    if ($year=~/T/i && $rev eq ''){
        $jT{$id}->{$vol}=$pages;
        $jv{$id}->{$vol}=$ymt;
        $jy{$id}->{$ymt}=$vol;
    }elsif($year=~/T/i){   #reviews
        $jTr{$id}->{$vol}=$pages;
        $jvr{$id}->{$vol}=$ymt;
        $jyr{$id}->{$ymt}=$vol;   
    }else{
        #don't bother with counting pages if a Tracking record exists
        unless ($jT{$id}->{$vol} ne '' &&  $jTr{$id}->{$vol} ne '' ){
            $j{$id}->{$vol}="$j{$id}->{$vol}"."\t"."$pages";
            $jv{$id}->{$vol}=$ymt;
            $jy{$id}->{$year}=$vol;
        } 
    }
}
close IN;            
print "DONE\n";

#do analysis
print "Analyzing data...";

#foreach journal
foreach $k (keys %j){
    #foreach volume
    foreach $l (keys %{$j{$k}}){
        undef(@cont);
        @pgs=split(/\t/, $j{$k}->{$l});
        
        #foreach article
        foreach $p (@pgs){
            @ppgs=split(/;/, $p);
            foreach $pp (@ppgs){
                if ($pp=~/no/i){
                    #do something
                }else{
                    if ( $pp=~/(\d+).*\-.*?(\d+)/ ){
                        $start=$1;
                        $stop=$2;
                        while($start < $stop){
                            $cont[$start]=1;
                            $start++;
                        }
                     }else{
                        #assume it is a single page
                        $pp=~/(\d+)/;
                        $cont[$1]=1;
                     }   
                }
            } 
       }                    
    
    
       #look for holes
       $first=$beg=$end=0;
       $c=1;
       foreach $p (@cont){
           if ($p eq '' && $first==0){
               $first=1;
               $beg=$c;
           }elsif($p eq '' && $first==1){
               $end=$c;
           }elsif($p==1 && $first==1){
               if(($end - $beg) > $gapTH3){     #need to change this so that different rankings get treated differently
                   unless ($jT{$k}->{$l} ne '' &&  $jTr{$k}->{$l} ne ''){
                        page_gap($k,$l,$beg,$end);       #id, vol, beg page of gap, end page of gap
                    }
               }
               #$first=$beg=$end=0; 
               $first=0;
           }
           #keep track of the largest page number for the journals
           if($c > $last{$k} ){
               $last{$k}=$c;    
           }
           $v_last{$k}->{$l}=$c;    
           $c++;
        }

    }
     #now look for a gap at the end of volume
     foreach $l (keys %{$v_last{$k}}){
         $gap=1- ( ($v_last{$k}->{$l}) / ($last{$k}) );
         if ($gap > $endTH ){
            unless ($jT{$k}->{$l} ne '' &&  $jTr{$k}->{$l} ne ''){
                 end_gap($k, $l, $gap);
            }     
         }
      }
      #check if whole years are missing      
      foreach $l (keys %{$jT{$k}}){
        if ($jT{$k}->{$l}=~/PART/i || $jTr{$k}->{$l}=~/PART/i){
            part_gap($k, $l);
        }
      }  
      foreach $y (@yearsToCheck){
        if ($jy{$k}->{$y} eq ''){
            year_gap($k, $y);
        }
     }
     if ($jPagError{$k} ==1){
        jlog('Some records in this jurnal are marked with continious pagination, but others are not', $k);
    }
}
print "DONE\n";
dbmclose %journals_rank;
dbmclose %journals;

#print out report

open (OUT, "> $journalAnalysisReport_File") || print "Could not open $journalAnalysisReport_File for writing $!";
$ltme=localtime;
print OUT "Anlysis performed on $ltme\n\n";
print OUT "\n====================\n";
print OUT "RANK 3 Journals \n\n";
print OUT "$toprint3";
print OUT "\n====================\n";
print OUT "RANK 2 Journals \n\n";
print OUT "$toprint2";
print OUT "\n====================\n";
print OUT "RANK 1 Journals \n\n";
print OUT "$toprint1";
print OUT "\n====================\n";
print OUT "OTHER Journals \n\n";
print OUT "$toprint";
close OUT;

unlink("$reviewsAnalysis_File");
unlink("$journalAnalysis_File");

print "\n::Finished (press Enter)";
    $bey=<STDIN>;
    
exec("notepad $journalAnalysisReport_File");


}# end of sub

sub page_gap{
$id=$_[0];
$vol=$_[1];
$beg=$_[2];
$end=$_[3];
jlog("$vol ($jv{$id}->{$vol}) gap betwen pages $beg - $end","$id"); 

}

sub end_gap{
$id=$_[0];
$vol=$_[1];
$gap=$_[2];

jlog("$vol ($jv{$id}->{$vol}) potential gap at the end of the volume","$id"); 
}

sub part_gap{
$id=$_[0];
$vol=$_[1];

jlog("$vol ($jv{$id}->{$vol}) is not fully entered","$id"); 
}

sub year_gap{
$id=$_[0];
$year=$_[1];

jlog("There are no entries for year $year","$id"); 
}

sub jlog{
#seperate by rank level
$text=$_[0];
$id=$_[1];

  
if ($journals_rank{$_[1]}==3){
unless ($id==$lastid){
    $lastid=$id;
    $toprint3="$toprint3"."\n".'***'."$journals{$id}\n";
    #$toprint3="$toprint3"."__________________\n";
} 
    $toprint3="$toprint3"."$_[0]\n";
}elsif ($journals_rank{$_[1]}==2){
unless ($id==$lastid){
    $lastid=$id;
    $toprint2="$toprint2"."\n".'***'."$journals{$id}\n";
    #$toprint2="$toprint2"."__________________\n";
} 
    $toprint2="$toprint2"."$_[0]\n";
}elsif ($journals_rank{$_[1]}==1){
unless ($id==$lastid){
    $lastid=$id;
    $toprint1="$toprint1"."\n".'***'."$journals{$id}\n";
    #$toprint1="$toprint1"."__________________\n";
} 
    $toprint1="$toprint1"."$_[0]\n";
}else{
unless ($id==$lastid){
    $lastid=$id;
     $toprint="$toprint"."\n".'***'."$journals{$id}\n";
     #$toprint="$toprint"."__________________\n";
} 
    $toprint="$toprint"."$_[0]\n";
}

}

1;
