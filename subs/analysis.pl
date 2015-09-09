#require id, rectype, subject, cats, journa id, journal pages (do not export not printed items)
#(also used for analysis)

#However, before the system  will work you need to create all the 
#indexes which is done by running horus in the analysis mode (a 
#monument to programing inefficiency). To run in analysis mode, first 
#show all the records which you want included (probably should be all 
#spw approved records),  go to the 'Settings' layout in FrontEnd, 
#select 'analysis' for horus.pl action and depress the 'manual 
#export' button, go watch "Gone with the Wind" (or the Godfather 
#Trilogy, or  Tarkovsky's Solaris--for real, it took 4h to run, 
#probably can be done overnight).

#makes db files 


#################################################################################

#first clear all the databases, they must be created a new

sub make_subj_counts{

$msc++;
if($msc=~/00$/){
    print "\n$msc";
}    

while($this->{subjects}=~/\[(.*?)\]/g){
    $type=lc($subjects_type{$1});

    #the %allowedsubtermA is below
    unless($allowedsubtermA{$type} eq ''){
        push(@sub_this, $1);
    }    
}    

#first get rid of any non-digits from the category names as a cleanup
#also need to do somethign abotu the 2002 cats which are different
$cats=$this->{categories};
unless ($cats=~/[a-z]/i){         #if it has a letter than it is a Joy cat    
    #first get rid  of anything past //
    $cats=~s#//.*##;
    #get rid of third part if there is one
    if($cats=~/\-.*\-/){
        $cats=~s/(.*)\-.*$/$1/;
    }
    #in the count include seperate cats
    if($cats=~/(.*?)-(.*)/){
        $cats_counts{$1}++;
        $cats_counts{$2}++;
    }    
    $cats=~s/\D//g;
    #count the number of categoreis
    $cats_counts{$cats}++;
}else{
    $cats='';
}
    
$js_count{$this->{journal_link}}++;    

foreach $s (@sub_this){
    #count the number of occurances
    $subjects_counts{$s}++;
    #now note the subject in correlation tables
    $cats_corrT{ $cats }->{$s}++;
    $js_corrT{$this->{journal_link}}->{$s}++;
    #do subjects correlations   
    foreach $ss (@sub_this){
        next if $ss == $s;
        $subs_corrP{$ss}->{$s}++;
    }
    #now do title correlation
    #$ttle=$this->{title};
    #$ttle=~s/[^A-Za-z\s]//g;
    #$ttle="$ttle ";
    #while($ttle=~/(\w\w\w\w\w).*?\s/g){
    #    $tw=lc($1);
    #    $ttle_corrT{$tw}->{$s}++;
    #    $tts_count{$tw}++;
    #}

}
undef(@sub_this);
}


sub make_sub_values{

foreach $s (keys %subjects_counts){

$makeindexct++;
if($makeindexct=~/00$/){
    print "\n$makeindexct";
}

    
    $count=$subjects_counts{$s};
    foreach $k (keys %cats_corrT){
        unless ($k eq ''){
            #this is the number of occurences of a subject in a category
            $bit=$cats_corrT{$k}->{$s};
            
            #this is the number of  occurences of a category
            $ccat=$cats_counts{$k};
            if ($bit ne ''){
                #create a hash of raw values
                $sub2catT{$s}="$sub2catT{$s}".":$k=$bit";
                
                if ($k=~/^(\d\d\d)(.*)/){
                $cats2subT{$1}="$cats2subT{$1}".":$s=$bit";
                $cats2subT{$2}="$cats2subT{$2}".":$s=$bit";
                #but also keep the combined
                $cats2subT{$k}="$cats2subT{$k}".":$s=$bit";
                    }else{    
                $cats2subT{$k}="$cats2subT{$k}".":$s=$bit";      
                    }    
            
                #normazliation factor
                $norm=($ccat/5)**(1/2);
                $corv=$norm * $bit/$ccat;
                unless($corv < 0.01){
                    $cats_corr{$k}->{$s}=$corv;
                }
            }
            if ($count ne ''){
                $norm=($ccat/10)**(1/2);
                $corv=$norm * $bit/$count;
                unless($corv < 0.01){
                    $sub2cat{$s}->{$k}=$corv;
                }
            }    
                
        }
    }
    #now do journals
    foreach $j (keys %js_corrT){
        $but=$js_corrT{$j}->{$s};
        $jcounts=$js_count{$j};
        if ($but ne '' && $jcounts != 0){
                #normazliation factor
                $norm=($jcounts/15)**(1/2);
                $corv=$norm * $but/$jcounts;
                #unless($corv < 0.01){
                    #$js_corr{$j}->{$s}=$corv;
                    $js_corr{$j}->{$s}=$but;
                    if ($s==4873){
                    $js_corr{$j}->{$s}=$but;  #This is crazy do not know why this works, but without it does not work, don't know if any ather subjects are also a problem
                    #$ghy=$js_corr{$j};
                    #$hhgh=$ghy->{$s};
                    #print "** $s -- $j -- $but-"."$hhgh"."--\n"}
                    }
                #}  
        }
    }  
    #now for subjects
    foreach $s2 (keys %subs_corrP){
        #skip time and geo terms, since they are too common and screw things up
        if ($subjects_type{$s}=~/time/i || $subjects_type{$s}=~/geo/i){
            next;
        }    
        $bt=$subs_corrP{$s}->{$s2};
        $scounts=$subjects_counts{$s2};
        if ($bt ne '' && $scounts != 0){
            $subs_corrM{$s}="$subs_corrM{$s}".":"."$s2=$bt";
            #normazliation factor   
            $corv=(($scounts/10)**(1/3)) * ($bt/$scounts);
            unless($corv < 0.01){
                $subs_corr{$s2}->{$s}=$corv;
            }
        }
    }
    
    #do title words
    # foreach $t (keys %ttle_corrT){
    #    $but=$ttle_corrT{$t}->{$s};
    #    $ttcounts=$tts_count{$t};
    #    if ($but ne '' && $ttcounts != 0 && $ttcounts < 2000){
    #            #normazliation factor
    #            $norm=($ttcounts/10)**(1/3);
    #            $corv=$norm * $but/$ttcounts;
    #            unless($corv < 0.01){
    #                $ttle_corr{$t}->{$s}=$corv;
    #            }    
    #    }
    #}          
}

#now sort things, find the 15 most popular subjects 
#and get rid of anonymous hashes which do not get recorded in the .db file
foreach $c (keys %cats_corr){  
    $bb=$cats_corr{$c};
    foreach $s (sort {$bb->{$b} <=> $bb->{$a}} keys %{$bb}){
        if($digc < 20 ){
            $tt=$bb->{$s};
            $dig="$dig:"."$s-$tt";   
            $digc++;
        }    
    }
    #create a hash with category as key and value=subjec-perc:sub-perc etc
    $cats_corr{$c}=$dig;
    $digc=0;
    $dig='';
}     

#journals
foreach $c (keys %js_corr){
    $ba=$js_corr{$c};
    foreach $s (sort {$ba->{$b} <=> $ba->{$a}} keys %{$ba}){
        if($digc < 20 ){
            #print "$subjects{$s}\n";
            $tt=$ba->{$s};
            $dig="$dig:"."$s-$tt";
            if($tt < 0.005){
                $digc=21;
            }else{    
                $digc++;
            } 
        }    
    }
    #create a hash with journal as key and value=subjec-perc:sub-perc etc
    $js_corr{$c}=$dig;
    $digc=0;
    $dig='';
}   

#subjectss
foreach $c (keys %subs_corr){
    $bb=$subs_corr{$c};
    foreach $s (sort {$bb->{$b} <=> $bb->{$a}} keys %{$bb}){
        if($digc < 15 ){
            $tt=$bb->{$s};
            $dig="$dig:"."$s-$tt";
            if($tt < 0.01){
                $digc=21;
            }else{    
                $digc++;
            } 
        }    
    }
    #create a hash with category as key and value=subjec-perc:sub-perc etc
    $subs_corr{$c}=$dig;
    $digc=0;
    $dig='';
}

#subejct to category     
foreach $c (keys %sub2cat){
    $bb=$sub2cat{$c};
    foreach $s (sort {$bb->{$b} <=> $bb->{$a}} keys %{$bb}){
        if($digc < 15 ){
            $tt=$bb->{$s};
            $dig="$dig:"."$s-$tt";
            if($tt < 0.01){
                $digc=21;
            }else{    
                $digc++;
            } 
        }    
    }
    #create a hash with category as key and value=subjec-perc:sub-perc etc
    $sub2cat{$c}=$dig;
    $digc=0;
    $dig='';
}
#title words     
#foreach $c (keys %ttle_corr){
#    $bb=$ttle_corr{$c};
#    foreach $s (sort {$bb->{$b} <=> $bb->{$a}} keys %{$bb}){
#        if($digc < 15 ){
#            $tt=$bb->{$s};
#            $dig="$dig:"."$s-$tt";
#            if($tt < 0.01){
#                $digc=21;
#            }else{    
#                $digc++;
#            } 
#        }    
#    }
#    #create a hash with category as key and value=subjec-perc:sub-perc etc
#    $ttle_corr{$c}=$dig;
#    $digc=0;
#    $dig='';
#}

#make journals reverse table
foreach $s (keys %subjects_counts){
    $tag='';
    foreach $j (keys %js_corrT){
        $bt=$js_corrT{$j}->{$s};
        $tag="$tag"."$j=$bt:";
    }
    $js_corrR{$s}=$tag;    
}

}

%allowedsubtermA=(
#all lower case
'per. names'=>'1',
'time period'=>'1',
'2003'=>'1',
'geog. term'=>'1',
'titles'=>'1',
'institutions'=>'1',
);

1;
