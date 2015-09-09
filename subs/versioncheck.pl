
sub versioncheck{

open (OUT, "> $version_File") || error_b("[Error 190]  could not open $version_File");
go_ftp();
$ftp->cwd('Current Work')  || error_b("[Error 188] Couldn't change directory to 'Current Work'");
my $dir='.';          #the directory of which to take a listing
@curwork = $ftp->ls("$dir");

foreach $f (@curwork){

    if ($f=~/^CB\sData\.(.*)\.zip/){
    $v2b=$1;
         unless ($v2b=~/source/i){       #skip source files
             $v2b=~s/\.//g;          #get rid of the dots
             $v2b=~s/^20+//;         #get rid of 20 or 200
             $v2b="$v2b"."1";        #this assumes that this is version 1 of the day
             if ($v2b > $cbv){       #check if this is the newest cb data file on the server
                 $cbv=$v2b;
             }    
        } 
    }
}        
#now chekc if running the newest version or not    
print "$cbv -- local $localversionFMO -- updated $updatedFMO\n";
if ($cbv == $localversionFMO){
   print OUT "$localversionFMO\t$updatedFMO";
   close OUT;
}elsif($cbv == $updatedFMO){
    print OUT "$cbv\tNo";     #version numbr \t and No to allert that not updated
    close OUT;
    log_p("New version of CB_Data file $cbv available.");
    log_p("This script is proceeding normaly.\n");
}else{
    print OUT "$cbv\tNew";     #version numbr \t and New to data
    close OUT;
    error_q("[Error 189] New version - $cbv - of CB Data available on the server. Rerun synchronize again. When possible, dowload the new version of CB Data.");    
    print OUT "$localversionFMO\t$updatedFMO";
    stop_ftp();
    closing();
    die;
} 

$ftp->cwd('..')  || error_b("[Error 192] Couldn't change directory to '..'");
    
}

1;
