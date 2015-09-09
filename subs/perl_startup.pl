#have no idea what this is and what this does. there are some checkout 
#things here that i am not sure if they are correct
####################################################################


require 'subs\ftp_files.pl';

sub startup{
#for getting updates

####################
#read info from filemaker

$chkoutfile=$checkedout_File;   

open (IN, "< $chkoutfile") || error_b("[Error 149] Could not open $chkoutfile for reading $!");
while (<IN>){
    chomp;
    $checkedout{$_}=1;
}
close IN;

########################################
#dowlaod new CB Data

unless ($ftpstatus eq 'on'){
    go_ftp();
}
$ftp->cwd('Updates/status')    or print "Couldn't change directory to Updates/status\n";
get_file('status.mif');
open (IN, "< status.mif") || error_b("[Error 150] Could not open status.mif for reading $!");
while(<IN>){
    chomp;
    $dbversion=$_;
}
close IN;


$ftp->cwd('../../Current Work')    or print "Couldn't change directory to ../../n";
if ($localversionFMO == $dbversion){
    print "No new updates for the CB Data file.\n";
}elsif($localversionFMO < $dbversion ){
    get_file('CB Data.fp7', '../Current Work/CB Data.fp7');
    if ($geterror == 1){
        log_p("\n\nSelect an option:\n");
        log_p("\t1. Continue and update individaul records.\n");
        log_p("\t2. Attempt the dowload again.\n");
        #... do a loop herer to
    }
    $localstatus[0]=$dbversion;
}else{
    log_p("Your version of the CB Data.fp7 $localversionFMO appears newer thatn the verion availabl $dbversion");
    #....
}

check4updates();

}


#########
    
sub getupdatesdirectory{
#checkd for updates based on the version of master and update files

unless ($ftpstatus eq 'on'){
    go_ftp();
}    
$ftp->cwd('Updates')  || error_b("[Error 187] Couldn't change directory to Updates in getupupdatesdirectory");

my $dir='.';          #the directory of which to take a listing

@updatefiles = $ftp->ls("$dir");
if($updatefiles[0] eq ''){ $updatefiles[0]='xxxx'}
$ftp->cwd('..')  || log_p("Couldn't change directory to root in getupdatesdirectory");
}


###########
sub getcheckoutdirectory{

unless ($ftpstatus eq 'on'){
    go_ftp();
} 
$ftp->cwd('Updates/checkedout')or print "Couldn't change directory to Updates/checkedout\n";

my $dir='.';          #the directory of which to take a listing
@checkedoutfiles = $ftp->ls("$dir");
$total=@checkedoutfiles;
########################################
#commenthgin this section out for modifed checked out check procedure
########################################
#$recordcount=0;
##if called with option to download,  dowload the files and put them in the dowloads directory
#if ($_[0] ne ''){
#    foreach $f (@checkedoutfiles){
#        get_file($f,"$downloads_Dir"."$f",quiet);
#        #get_file($f,"$downloads_Dir"."$f");
#    $recordcount++;
#    system('cls');
#    print "Running sych\n";
#    print "\tReading checked out files $recordcount (record $f) out of $total\n";
#    }
#system('cls');        
#print "Running sych\n\n";
#}
########################################

$ftp->cwd('../..')  || log_p("Couldn't change directory to root in getupdatesdirectory");
}

###
sub check4updates{

#i think if no argument is passed then it check for ALL updades

#if an argument is passed to the rutine then
#$_[0] is the record number
#and  $_[1] is the version numnber
#and no other records will be checked
#run through the directory and see which files need to be dowloaded

#first make sure that the updates directory was read
if ($updatefiles[0] eq ''){
    getupdatesdirectory();
}
#$version_check is the version to be updatesd
#$vnum is server version

#this goes through each of the availabe updates on the server and decides if it needs to be dowloaded
foreach $file (@updatefiles){
    #possible errors here, becasue no longer skipping words..
    #trying something new to fix it
    next if ($file=~/^\D/ && $file!~/^J/);         #directoryes are words, files are numbers
    #log_p("$file - perl startup");
    $file=~/(.*)-(.*)/;  #rec numberb -  version number
    $recnum=$1; #on the server
    $vnum=$2;   #on the server
    #now see if the update is relavant and/or installed
    if($_[0] ne ''){         #if an argument is passed that record will be checked
        if($_[0] eq $recnum){
            $version_check=$_[1];
        }else{
            $version_check=9999999;          #so that the next step will not happen
        }
    }elsif ($actionFMO eq 'startup'){
        $version_check= $localstatus[0];
    }elsif($versionnumbers{$recnum} ne ''){
        $version_check=$versionnumbers{$recnum};
    }else{
        $version_check=9999999;          #so that the next step will not happen
    }
    if ($version_check < $vnum){   #if newer than master file, or record version
                                    #the problem here is  that the after a verion update all reacords
                                    #have ending .00 and as such do not get exported so there is no way to check the old 
                                    #version number and they get dowloaded
                            
        unless ( get_file("Updates/$file", "$downloads_Dir"."$file") ne 'failed'){
            error_b("[Error 151] Dowloading updade file $file failed. Please try again");
        }    
        push(@filestobeupdated, "$downloads_Dir"."$file");
        $updates='yes';
    }
}


}


#########################3



sub checkout {
#checks if record has been checked out or if there are updates

#needs record number and version number which some has

#first get the files to be updated
$infile =$tocheckout_File;
if (  open (IN, "< $j_tocheckout_File")  ){
     open (OUT, ">> $infile") || error_b("[Error ] Could not open $infile for appending $!");
     while (<IN>){
         print OUT "J"."$_";
     }
     close OUT;
}
close IN;
unlink($j_tocheckout_File);
    
open (IN, "< $infile") || error_b("[Error 152] Could not open $infile for readeing $!");
while (<IN>){
    chomp;
    @parts=split(/\t/,$_);
    $tocheckout{$parts[0]}=$parts[1];
}
close IN;
unlink($infile);

unless ($ftpstatus eq 'on'){
    go_ftp();
}
getupdatesdirectory();
$ftp->cwd('Updates/checkedout')or print "Couldn't change directory to Updates/checkedout\n";

my $dir='.';          #the directory of which to take a listing
@checkedoutfiles = $ftp->ls("$dir");
unless ($checkedoutfiles[0] ne ''){$checkedoutfiles[0]='whatever'}

foreach $rec (keys %tocheckout){
#exit if the server stops up
last if(ftp_error_check() eq 'stop');

    $oktotake=1;
    foreach $chrec (@checkedoutfiles){
        if ($chrec=~/^$rec-(.*)/){        #chanted form ^$rec$ to ^$rec-
            $alreadycheckedout{$rec}=$1;
            #$alreadycheckedout{$rec}='unknown';
            get_file($chrec,'','quiet');
            open(IN, "< $chrec");
            while(<IN>){ 
            #    chomp;
                $alreadycheckedout{$rec}=$_;
            }
            close IN;
            unlink($chrec);    
            log_q("Record $rec is already checked out to $alreadycheckedout{$rec}");
            $oktotake=0;
        }elsif($chrec=~/^$rec$/){    #for backwards compatibility
            $alreadycheckedout{$rec}='unknown';
            get_file($chrec,'','quiet');
            open(IN, "< $chrec");
            while(<IN>){ 
            #    chomp;
                $alreadycheckedout{$rec}=$_;
            }
            close IN;
            unlink($chrec);    
            log_q("Record $rec is already checked out to $alreadycheckedout{$rec}");
            $oktotake=0;
        }
    }
    if($oktotake==1){
        #check it out
        #first check for updates
        unless ($updateschecked==1){    #some (all?) things already do this by the time the script gets here
            $ftp->cwd('..') or log_p("Could not change directory to .. in checkout");
            check4updates($rec, $tocheckout{$rec});
            $ftp->cwd('checkedout')  or log_p("Could not chagne directory to checkedout in checkout");
        }
        $choutfilenmame="$rec-$machinenameFMO";
        open (OUT, "> $choutfilenmame") || error_b("[Error 153] Could not create a file $rec inorder to check out the record");  #changed filename from $rec
        $tstamp=localtime;
        print OUT "$userFMO @ $machinenameFMO on $tstamp";
        close OUT;
        put_file($choutfilenmame,'','quiet');  #if this step fail, checks out to FM anyhow (but not on the server)
        unlink $rec;
        unlink $choutfilenmame;   #2009.05.26
        log_p("$rec checked out OK");
        push(@canget, $rec);
        $beenhere=1;
    }

}

#print report
#prepere files for FM
#print "\n";
#this lest the safty script know that things went well and the checkout script did its thing
#otherwise the recheckout sub will prevent the record from being checked out
$checkoutfiledone=1;
#make a file that will check out the records in FM
$checkoutfile=$checkedout_File;

unlink($checkoutfile);    #to make sure that an old file will not be imported

open (OUT ,"> $checkoutfile") || error_b ("[Error 154] Could not open $checkoutfile for writting $!");

foreach $rec (@canget){
    next if $rec=~/J/;
    print OUT "$rec\tchecked out\n";
    #log_p("$rec checked out OK");
}

close OUT;

open (OUT ,"> $j_checkedout_File") || error_b ("[Error ] Could not open $j_checkedout_File for writting $!");

foreach $rec (@canget){
    next unless $rec=~s/J//;
    print OUT "$rec\tchecked out\n";
    #log_p("$rec checked out OK");
}

close OUT;

print "\n";
foreach $rec (keys %alreadycheckedout){
    log_p("$rec is already checked out to $alreadycheckedout{$rec}");
}


}  #end of sub


#########################

sub checkin{

#first read the file from the update sub

$ok2chin=$oktocheckin_File;
open (IN, "< $ok2chin") || error_b("[Error 185] Could not open $ok2chin file for reading $!");
while (<IN>){
    chomp;
    ($oknum, $oktyp)=split(/\t/, $_);
    if ($oktyp eq 'ok'){
        $oktocheckin{$oknum}=1;
    }elsif($oktyp eq 'NOT'){
        $stillcheckedout{$oknum}=1;
    }
}
close IN;
unlink($ok2chin);

$checkfile=$checkin_File;
#append journal records to regular records

if( open (IN, "< $j_checkin_File") ){
     open (OUT, ">> $checkfile") || error_b("[Error ] Could not open $checkfile for appending $!");
     while(<IN>){
         print OUT "J"."$_";
     }
     close OUT;
     unlink($j_checkin_File);
}    
close IN;
open (IN, "< $checkfile") || error_b("[Error 155] Could not open $checkfile for reading $!");

while(<IN>){
    chomp;
    #only if the update send was sucessfull
    if($oktocheckin{$_}==1){
        $tocheckin{$_}=1;
    }    
}
close IN;
unlink($checkfile);

unless ($ftpstatus eq 'on'){
    go_ftp();
}
$ftp->cwd('Updates/checkedout')  or error_q("[Error 184] Couldn't change directory to Updates/checkedout while attempting to  checkin");

my $dir='.';          #the directory of which to take a listing

@checkedout = $ftp->ls("$dir");

foreach $file (@checkedout){
    #mod to fit new schema
    $filesn=$file;
    $filesn=~s/-.*//;
    if ($tocheckin{$filesn} ==1 ){
        if ( $ftp->delete($file) ){
            log_p("Checked in record $filesn");
        }else{
            Warning_q("[Warning 156] Could not delete $file. The file is still checkedout on the server!");
            $stillcheckedout{$file}=1;
        }
    }
}
#stop_ftp();

#make still checked out file

open(OUT, "> $checkedout_File") || error_b("[Error 186] Could not open $checkedout_File for writting $!");
$checkoutfiledone=1;
#so that the file will not be empty
print OUT "197806\t\n";

foreach $f (keys %stillcheckedout){
    next if $f=~/J/;
    print OUT "$f\tchecked out\n";
}    
close OUT;

#now do it for journals
open(OUT, "> $j_checkedout_File") || error_b("[Error ] Could not open $j_checkedout_File for writting $!");
$checkoutfiledone=1;
#so that the file will not be empty
print OUT "458\t\n";

foreach $f (keys %stillcheckedout){
    next unless $f=~s/J//;
    print OUT "$f\tchecked out\n";
}    
close OUT;

}

1;
