#this packeg does error handling

sub log_q {
#for noting things in the log file without printing them to screen
$log="$log"."$_[0]\n";
}

sub log_p {
#for noting things in the log file with printing them to screen
print  "$_[0]\n";
$log="$log"."$_[0]\n";
}

sub error_s {
#for handling non fatal errors, wornings and things
$errorflag++;
$errorlog="$errorlog"."$_[0]\n";
$_[0]=~/(\d+)\]/;
$founderrors{$1}=$_[0];
}

sub error_q {
#for handling non fatal errors
$errorflag++;
$errorlog="$errorlog"."$_[0]\n";
$_[0]=~/(\d+)\]/;
$founderrors{$1}=$_[0];
}

sub warning_q {
#for handling non fatal warnings
$warningflag++;
$warlog="$warlog"."$_[0]\n";
}

sub message_q{
#for handling non fatal things
$messageflag++;
$log="$log"."$_[0]\n";
}

sub error_b {
#for handling fatal errors
$errorflag++;
$errorlog="$errorlog"."$_[0]\n";
$_[0]=~/(\d+)\]/;
$founderrors{$1}=$_[0];
closing(big);
}
sub error_202 {
#for handling fatal errors
$errorflag++;
$errorlog="$errorlog"."$_[0]\n";
$_[0]=~/(\d+)\]/;
$founderrors{$1}=$_[0];
closing(202);
}
sub error_showSymTable{
#used by character_convert. When there is a problem with characters will open
#the pdf file with special character.
#this just sets a flag
$showSymTable=1;
}

sub skiped_records_log{
 foreach $k (keys %skipr){
  unless ($prined_skiped ==1) {
    $skip_log="\nSome records were not printed out for the folling reasons:\n";
  }
  $skfile="$skip_File"."$k".".tab";
  open (OUT, "> $skfile") || print "Could not open $skfile $!\n";
  @sk=split(/,/, $skipr{$k});
  foreach $a (@sk){ 
      print OUT "$a\t \n";
      $skiprc{$k}++;
    }
 $skiprc{$k}--;   
 $prined_skiped = 1;
 $skip_log="$skip_log"."$k $skiprc{$k}\n";
 }

}

sub fcbkp{
$fcbckpl="$fcbckpl"."$_[0]\n";
}

sub make_log {

close IN;
close OUT;

#make backup

open (OUT, ">> $fcbkcp_File") || die "[Error 196] Cannot open $fcbkcp_Filee $!";
print OUT "$fcbckpl";
close OUT;

skiped_records_log();
$tstamp=localtime;
$errhead="___________________\n$tstamp running $actionFMO mode by $userFMO\n($fminfoline)\nRecord numbers read: $logreadrecs\n";
$efftail="END OF LOG\n";
#this is a perminant log
#open (OUT, ">> $alllog_File") || die "[Error 174] Cannot open $log_Filee $!";
#print OUT "$errhead";
#if ($log){
#    print OUT "\nMESSAGES:\n";
#    print OUT "$log";
#}
#if($warlog){
#    print OUT "\nWARNINGS:\n";
#    print OUT "$warlog";
#}
#if($errorlog){
#    print OUT "\nERRORS:\n";
#    print OUT "$errorlog";
#}
#if($skip_log){
#    print OUT "$skip_log";
#}
#print OUT "$errtail";
#close OUT;

#this is the log with only the last run
open (OUT, "> $lastlog_File") || die "[Error 175] Cannot open $lastlog_File $!";

#if errors print instructions
if($errorlog){
    print OUT "Errors occured while processing your file. Read the help below. ";
    print OUT "If still unable to fix the problem ask for assistance. ";
    print OUT "Please provide the text of this entire log if asking for assistance.\n\n";
    print OUT "****START OF HELP\n";
    foreach $e (keys %founderrors){
        print OUT "$founderrors{$e}\n\n";
        if ($errorinfo{$e} eq ''){
            print OUT "*No description availabe on this error.\n\n";
        }else{
            print OUT "DESCRIPTION: $errorinfo{$e}\n\n";
        }
        if ($errorhelp{$e} eq ''){
            print OUT "*No help availabe on this error\n\n";
        }else{
            print OUT "CAUSES/FIXES:\n$errorhelp{$e}\n\n";
        }
        print OUT "___________\n";
    }
    print OUT "****END OF HELP\n\n\n";
}

print OUT "$errhead";
if ($log){
    print OUT "\nMESSAGES:\n";
    print OUT "$log";
}
if($warlog){
    print OUT "\nWARNINGS:\n";
    print OUT "$warlog";
}
if($errorlog){
    print OUT "\nERRORS:\n";
    print OUT "$errorlog";
}
if($skip_log){
    print OUT "$skip_log";
}
print OUT "$errtail";#also prints out subject errors
print_error_sub();

#if errors open the error file in a new window

}

sub error_sub{
#makes a \t file with subject errrors

#first add header
unless ($doneerrorsub==1){
    $errorsubjects="Record number\t"."Subjeect number\t"."Error type\t"."New subject text\t"."Old subject text\t"."Subject type\n";
    $doneerrorsub=1;
}
    
$errorsubjects="$errorsubjects\n$_[0]";
}


sub print_error_sub{
#prints out the error_sub file
$error_sub_file=$error_sub_File;
print "_______$errorsubjects\n";
close OUT;

open (OUT, "> $error_sub_file") || die "\nCan't open $error_sub_file for writing $!\n";
print OUT "$errorsubjects";
close OUT;

}


sub ftp_error_check{

if ($ftp_error > 2){
print "There seem to be some difficulties with the FTP server. To continue press ENTER, or type N to stop: ";
if(<STDIN>=~/n/i){
 return('stop');
 #this should make the script report that not all records were dowloaded
 $notdownloaded{1}=1;
}else{
 $ftp_error=0;
}  

}
}

1;
