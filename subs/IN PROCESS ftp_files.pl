#conects to the ftp server
#also has ruties for transfering things



sub go_ftp{

unless($ftpstatus eq 'on'){     #do not connect if connected
    unless( $ftp = Net::SFTP::Foreign->new("ouwww.ou.edu", timeout=>15, user =>'isis', password =>'thecb1') ){
        log_p("Could not connect to ouwww.ou.edu. $sftp->error"); 
        error_b("[Error 112] Could not connect to ouwww.ou.edu. $sftp->error");
        #needs to make sure check in will be undone
    }else{
        log_q("Connected to ouwww.ou.edu");        
        #unless ( $ftp->login(isis, thecb1) ){   #user name and passward specified here
        #    log_p("Could not loging to ouwww.ou.edu as isis");
        #    error_b("[Error 113] Could not login to ouwww.ou.edu as isis");
        #}else{
        #   log_p("Logged in to ouwww.ou.edu as isis");
        #   $ftpstatus='on';
        #   $ftp->binary();
#
#        }
 
    }
    #make sure the it not locked down
    $error=$ftp->get('locked.txt', $locked_File);
    $m=$ftp->message;
    if ($error==1 || $m!~/Transfer complete./ || $lockedserverfree==1){
            #if failed here then things are good
    }else{
        stop_ftp();
        error_202("[Error 202] The server is locked by the administrator"); 
    }       
    
}
}
############################################
sub stop_ftp{

$ftp->quit();
$ftpstatus='off';

}

#################################################################

sub put_file{

my $toput=$_[0];        #file to put on the server
my $toputwhere=$_[1];
my $quiet=$_[2];

log_q("Uploading $toput...");
print("Uploading $toput...") unless $quiet ne '';

if ($toputwhere ne ''){
    $error=$ftp->put($toput, $toputwhere);
    $m=$ftp->message;
    unless($ftp->size($toputwhere)){
        error_q("[Error 179] FTP transfer FAILED. '$toputwhere' has 0 bites on the server. Server possibly full.");
    }else{
        if ($error==1 || $m!~/Transfer complete./){
             error_q("[Error 108] FTP transfer not sucessfull. '$toput' not placed in '$toputwhere' on the server");
             log_p("TRANSFER NOT SUCESSFUL!");
             log_p($m);
             $ftp_error++;
             return('failed');
         }else{
             log_p('OK') unless $quiet ne '';
             return('ok');
         }
    }
}else{
    $error=$ftp->put($toput);
    $m=$ftp->message;
    unless($ftp->size($toput)){
        error_q("[Error 180] FTP transfer FAILED. '$toput' has 0 bites on the server. Server possibly full.");
    }else{
         if ($error==1 || $m!~/Transfer complete./){
             error_q("[Error 109] FTP transfer not sucessfull. '$toput' not placed on the server");
             log_p("TRANSFER NOT SUCESSFUL!");
             log_p($m);
             $ftp_error++;
             return('failed');
         }else{
             log_p('OK') unless $quiet ne '';
             return('ok');
         }
    }
}

}

#################################################################

sub get_file{

my $toget=$_[0];        #file to get from the server
my $togetwhere=$_[1];
my $quiet=$_[2];

log_q("Downloading $toget...");
print("Downloading $toget...") unless $quiet ne '';

if ($togetwhere ne ''){
    $error=$ftp->get($toget, $togetwhere);
    $m=$ftp->message;
    if ($error==1 || $m!~/Transfer complete./){
        error_q("[Error 110] FTP transfer not sucessfull. '$toget' not downloaded into '$togetwhere' on this machine");
        log_p("TRANSFER NOT SUCESSFUL!");
        log_p($m);
        $ftp_error++;
        return('failed');
    }else{
        log_p('OK') unless $quiet ne '';
    }
    #
}else{
    $error=$ftp->get($toget);
    $m=$ftp->message;
    if ($error==1 || $m!~/Transfer complete./){
        error_q("[Error 111] FTP transfer not sucessfull. '$toput' not downloaded onto this machine");
        log_p("TRANSFER NOT SUCESSFUL!");
        log_p($m);
        $ftp_error++;
        return('failed');
    }else{
        log_p('OK') unless $quiet ne '';
    }
}

}

################################################################

sub recheckout{
#this is used for when there are errors and the proper chink in procedure does not work
#so that all the records are recheckout agina in FM

unless ($checkoutfiledone==1){      #don't do this if it was already done

        #re checout the files
        open (IN, "< $checkin_File");
        while(<IN>){
            chomp;
            $stillcheckedout{$_}=1;
        }
        close IN;
        unlink($checkin_File);
                
        open(OUT, "> $checkedout_File") || error_b("[Error 186x] Could not open $checkedout_File for writting $!");
        #so that the file will not be empty
        print OUT "197806\t\n";

        foreach $f (keys %stillcheckedout){
            print OUT "$f\tchecked out\n";
        }    
        close OUT;

}
}
1;
