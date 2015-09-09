#synchoronizes the data in the FM with the data on the server
#right now does not import a new version of the data file
#needs to be called by a script from Fm which exports
#updated.tab: rec id \t version number 
#checkedout.tab: rec id \t version number 
#file so that this script knows which records to get etc

sub synch {

#the variable allows to limit the number of records to download at a time
$recordsTOsynch=$_[0];
#if is empty assume that proceed normaly (limit to 1000)
if ($recordsTOsynch eq ''){
    $recordsTOsynch=1000;
}    

$bksp=chr(8);
#first read the updated.tab file so that will know what to do

$updated=$updated_File;
print "Reading upadeted records on your computer...";

$updatedrecords=-1;
open(IN, "< $updated") || error_b("[Error 125] Could not open for reading $updated $!");
while(<IN>){
    chomp;
    @parts=split(/\t/, $_);         # id \t version number
    $updated{$parts[0]}=$parts[1];
    $updatedrecords++;
}
close IN;
unlink($updated);
print "$updatedrecords records\n";

#do the same for journals
$updatedrecordsj=-1;
print "Reading upadeted journal records on your computer...";
open(IN, "< $j_updated_File") || error_b("[Error ] Could not open for reading $j_updated_File $!");
while(<IN>){
    chomp;
    @parts=split(/\t/, $_);         # id \t version number
    $updated{"J"."$parts[0]"}=$parts[1];
    $updatedrecordsj++;

}
close IN;
unlink($j_updated_File);
print "$updatedrecordsj records\n";


print "Reading checked out records...";
$checkedout=$checkedout_File;
$chout=-1;
$recordcount=0;
open(IN, "< $checkedout") || error_b("[Error 126] Could not open for reading $checkedout");
while(<IN>){
    chomp;
    @parts=split(/\t/, $_);         # id \t version number
    $chout{$parts[0]}=$parts[1];
    $chout++;

}
close IN;
unlink($checkedout);
print "$chout records\n";


print "Reading checked out journal records...";
$choutl=-1;
open(IN, "< $j_checkedout_File") || error_b("[Error ] Could not open for reading $j_checkedout_File");
while(<IN>){
    chomp;
    @parts=split(/\t/, $_);         # id \t version number
    $chout{"J"."$parts[0]"}=$parts[1];
    $choutl++
}
close IN;
unlink($j_checkedout_File);
print "$choutl records\n";


#compare the records rechecds checkout on the machine with the records checked out on the server
#first get the directry of the checked out records and dowload the files associted with the records

#do not connect to the server if to sych is 0
unless($recordsTOsynch==0){
log_p("Synchronizing checked out records");
getcheckoutdirectory();
#next make sure there is one to one correspondance between the local and server files
foreach $f (@checkedoutfiles){
        $fsn=$f;
        $fsn=~s/-(.*)//;
        $nottoyou=$1;
        #make sure that if checkout on the server checkout localy
        if ($f=~/-$machinenameFMO$/i){    #if the file is marked as being checkout on the server to the computer doing the synhcing
        
            foreach $ch (keys %chout){  #go through all the locally chekcout out files
                if ($ch eq $fsn){         #if the server file is one of the local checkout files
                    $checkok=1;         #mark as ok
                }    
            }
            unless ($checkok == 1){
                error_s("[Error 198] The record $fsn is checkout to the machine $machinenameFMO on the server, but is not checkout on that machine");
            }
            $checkok='';    
            $checkouttoyou{$fsn}=1;
        }else{
            $checkoutnottoyou{$fsn}=$nottoyou;
        }    
    
}


#make sure that all the localy checkout files are checkout on the server
foreach $f (keys %chout){
    if ($checkouttoyou{$f}==1){
        #all good
    }elsif($checkoutnottoyou{$f} ne ''){    
        error_s("[Error 199] Record $f is marked as checkout to you on your computer, but on the server it is marked as checkout out to $checkoutnottoyou{$f}");
    }else{
        unless ($f == 197806 || $f eq 'J458'){ #this is the goofy record
            error_s("[Error 200] Record $f is marked as checkout to you on your computer, but on the server it is not checkout at all. (It may be a newly created record which has not yet been checked in.)");    
        }
    }
}        
#make sure and delete them !!!!
foreach $f (@checkedoutfiles){
    $toremove="$downloads_Dir"."$f";
    unlink($toremove);
}
}


    
#now get the updates available on the server
unless($recordsTOsynch==0){
   getupdatesdirectory();

#and now compare which ones to get
$recordsdowloaded=0;

foreach $file (@updatefiles){

#exit if the server stops up
#don't do it here, should not be doing anyting that can hang up
#last if(ftp_error_check() eq 'stop');



    #possible problems here becasue no longer skipping named files
    # next if $file=~/^\D/;         #directories are words, files are numbers (no longer, with the J records)
    #log_p($file);
    ($serverid, $serverver)=split(/-/, $file);
    #first check if server id is older than version number, if it is then do not get it because the newer version .00
    #is included in the new cb data file.
    
    $updatedfilesread++;
    
    unless ($localversionFMO > $serverver){
        #if the file on in the server is newer, and if it is not checked out to you
        if ($updated{$serverid} < $serverver && $chout{$serverid} ne 'checked out'){  
            #first check if limit of dowloaded files is reached  
            unless($recordsdowloaded >= $recordsTOsynch ){
                get_file("Updates/$file", "$downloads_Dir"."$file");  #
                push(@filestobeupdated, "$downloads_Dir"."$file");
                $updates='yes';
                $recordsdowloaded++;
            }else{
            	#add to files not dowloaded
            	$notdownloaded{$file}=1;
            }     
        }     
    }
    #now check to make sure the checked out things work out
    if ($chout{$serverid} ne '' && $chout{$serverid} < $serverver){
        error_q("[Error 127] You have record $serverid checkdout, but a newer verions $serverver of this record exists on the server");
    }
}

#report
$notdwn=keys(%notdownloaded);
log_p("\n$updatedfilesread update records on the server");
log_p("$recordsdowloaded records updated");
if ($notdwn==0){
    log_p("ALL RECORDS UPDATED, your computer in now fully synchronized");
}else{ 
    log_p("NOT ALL RECORDS UPDATED!!!");
    log_p("$notdwn records remain to be updated (their record numbers are located in $recordstobeupdated_File)");
    
    open (OUT, "> $recordstobeupdated_File") || error_s("Could not opne $recordstobeupdated_File for writing in synch.pl");
    foreach $k (sort keys %notdownloaded){
    	print OUT "$k\n";
    }
    close OUT;

}
}

#repeat the update procedure, but for manually dowloaded files
#first get files from the manuual dowloads directory
#do this only if manual option set
if ($optionsFMO eq 'man'){
$recordsdowloadedm=$updatemnarec=0;
log_p("\nUPDATING FROM MANUAL DOWLOADS DIRECTORY");
opendir(DIR, $manualDownloads_Dir) or error_s("[Error...] could not open $manualDownloads_Dir in synch.pl");
	while (defined($file=readdir(DIR))){
		  next if ($file!~/\d/);
    $updatemnarec++;
    #read the file info and all that
    ($serverid, $serverver)=split(/-/, $file);
    #first check if server id is older than version number, if it is then do not get it because the newer version .00
    #is included in the new cb data file.
    unless ($localversionFMO > $serverver){
        #if the file  is newer, and if it is not checked out to you
        if ($updated{$serverid} < $serverver && $chout{$serverid} ne 'checked out'){
            $moveFrom="$manualDownloads_Dir"."$file";
            $moveTo="$downloads_Dir"."$file";
            system("move \"$moveFrom\" \"$moveTo\"");
            log_p("Updating with local file $file"); 
            push(@filestobeupdated, $moveTo);
            $updates='yes';
            $recordsdowloadedm++;
        }
    }
   #now delete the file if still there
   unlink("$manualDownloads_Dir"."$file");
   
}
log_p("$updatemnarec records in the manual update directory");
updateget(@filestobeupdated);
log_p("$recordsdowloadedm records updated"); this is not done yet
print "Update complete\n";
}#end manual option


unless($recordsTOsynch==0){
getcheckoutdirectory();
foreach $file (@checkedoutfiles){
    $file=~s/-.*//;
    $seen{$file}=1;
}
foreach $file (keys %checkedout){
    unless ($seen{$file}==1){
        error_q("[Error 128] Record $file is marked as checked out in your FM, but is not marked as such on the server");
    }
}

#do this for all  so that the empty import files get created
#if ($updates eq 'yes'){
 updateget(@filestobeupdated);
#}

#to finish up make a note of who you are and what you are up to 
$tstamp=localtime;
$note="$userFMO at local time $tstamp";
if ($errorflag ne ''){
    $notefile="$ap"."$machinenameFMO".'-ERRORS';
    $notefilesh="$machinenameFMO".'-ERRORS';
}else{    
    $notefile="$ap"."$machinenameFMO";
    $notefilesh=$machinenameFMO;
}


open(OUT, "> $notefile") || error_b("[Error ] Could not open $notefile for writing $!");
print OUT "$note";
close OUT;
#put it on the server    
put_file($notefile, 'Updates/status/'."$notefilesh");
unlink($notefile);
}
}
1;
