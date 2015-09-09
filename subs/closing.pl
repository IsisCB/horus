sub closing{

#last thing
print "____________________________________________\n";
if ($errorflag > 0){
    log_p ("$errorflag ERROR(S) detected");
}    
if ($warningflag > 0){
    log_p ("$warningflag WARNING(S) detected");
}
if ($messageflag > 0){
    log_p("$messageflag message(s) detected (look at the LOG file for specific information)");
} 
make_log();

if ($errorflag > 0){
   print "\n$errorlog";
}
if($warningflag > 0){
  #print "If you want to see the warning(s) press 'y'";
  #if (<STDIN>=~/y/i){
     print "\n$warlog";
  #}
}        

#this is safty check to make sure that things that were not checked in are still not checked in;
#the sub us in ftp_files.pl
recheckout();


if ($_[0] eq 'big' ){
     print "\nhorus.pl encounterd a FATAL ERROR and cannot go on. Press Enter, this window will close and a help file will appear";
     $bey=<STDIN>;
     exec("notepad $lastlog_File");
}elsif($_[0] eq '202'){
     print "\nThe access to the server is restricted  by the administrator. Records cannot be checked in nor out; records cannot be synchronized. It is safe to continue to work entering data or modefining records already checked out. When this error occurs a file describing the situation should be dissplayed. Attempt to reconect to the server at some later time, if problem persists contact the administror.";
     $bey=<STDIN>;
     exec("notepad $locked_File");
}else{
    if($errorlog && showSymTable==1){
        print "\n::Finished. Errors were detected. Press Enter, this window will close and a help file will appear";
        $bey=<STDIN>;
        exec("AcroRd32 $symbols_File");     #for the Adobe Acrobat Reader
        exec("Acrobat $symbols_File");      #for the full version
        exec("notepad $lastlog_File");
    }elsif($errorlog){
        print "\n::Finished. Errors were detected. Press Enter, this window will close and a help file will appear";
        $bey=<STDIN>;
        exec("notepad $lastlog_File");
    }else{
    print "\n::Finished (press Enter)";
    $bey=<STDIN>;
    }
}


}
1;
