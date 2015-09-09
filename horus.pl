#this script reads the file FileMaker option file
#and runs the other scripts as needed
####################################################
#OPTIONS
#####################################################
$testMODE=1;    #1=test mode ON; 0=test mode OFF
                #in test mode some files are not deleted              
###OPTIONS                
#uncomment to turn off worning about illegal characters (do this if you are using things useing < > bracets)    
$convertcharaterloose = 'loose';
####################################################

system('cls');  #clear the window
#require 'subs\hi.pl';
#hi();
use lib 'C:\CB directory\Aux Files';

require 'subs\errors.pl';
require 'subs\file_refs.pl';
require 'subs\backup.pl';
require 'subs\fm_read_options.pl';
require 'subs\ftp_files.pl';
require 'subs\sqeez.pl';
require 'subs\print_data.pl';
require 'subs\character_convert.pl';
require 'subs\character_map.pl';
require 'subs\ascii_map.pl';
require 'subs\names.pl';
require 'subs\closing.pl';

$ltme=localtime;
log_q("$ltme");

use File::Copy;
require Net::FTP;
#require Net::SFTP::foreign;
require Text::CSV;

read_fm_options();

#make dummy import mer files
make_dummy_mer();
#this is try fix for vista
chdir $ap; 

#decide what to do
read_fm_commands($actionFMO);
#does its thing

#cleanup and things
unless ($testMODE==1){
  unlink("$fminfo_File");
  unlink("$export_File");
  unlink("$tocheckout_File");
  unlink("$j_tocheckout_File");
  unlink("$j_checkin_File");
  unlink("$checkin_File");
}
unless ($actionFMO eq 'analysis'){
    closing();
}    


#################################################################
sub read_fm_commands{

 $fmw=$_[0];

log_p("Running $fmw mode.");

if ($fmw eq 'one' || $fmw eq 'cleanup'){
     #first backup
     #backup('subs\one.mer');
     require 'moose.pl';
    if ($outputfileFMO ne ''){
        $tex_Name=$outputfileFMO;
    }else{    
        $tex_Name='one';
    } 
     make_tex_files($tex_Name);

     unlink("$tex_File");          #delete previous tex file
     unlink("$dvi_File");          #delete previous dvi file
     moose(one);
     system("latex  --quiet --output-directory=\"$pdf_Dir\" \"$tex_File\"");;
     #system("latex   --output-directory=\"$pdf_Dir\" \"$tex_File\"");;
     if($pdfFMO=~/yes/i){
        log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
        system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     }
     unless ($testMODE==1){
          unlink("$tex_File");
          unlink("$aux_File");
          unlink("$log_File");
          unlink("$toc_File");   
    }  
}elsif ( $fmw eq 'final' ){
    require 'moose.pl';
    require 'subs\make_tex.pl';
    read_print_records();
    if ($outputfileFMO ne ''){
        $tex_Name=$outputfileFMO;
    }else{    
        $tex_Name='final';
    } 
    make_tex_files($tex_Name);
    moose(final);
    print "Running LaTeX: ";
    system("latex  --quiet --output-directory=\"$pdf_Dir\" \"$tex_File\"");
    if($pdfFMO=~/yes/i){ 
        log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
        system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     } 
    my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
          unlink("$tex_File");
          unlink("$aux_File");
          unlink("$log_File");
          unlink("$toc_File");
    }
}elsif ( $fmw eq 'printout' ){
    require 'moose.pl';
    require 'subs\make_tex.pl';
    read_print_records();
    if ($outputfileFMO ne ''){
        $tex_Name=$outputfileFMO;
    }else{    
        $tex_Name='final';
    } 
    make_tex_files($tex_Name);
    moose(printout);
    print "Running LaTeX: ";
    system("latex  --quiet --output-directory=\"$pdf_Dir\" \"$tex_File\"");
    if($pdfFMO=~/yes/i){ 
        log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
        system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     } 
    my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
           unlink("$tex_File");
           unlink("$aux_File");
           unlink("$log_File");
           unlink("$toc_File");
    }
}elsif ( $fmw eq 'printoutALPHA' ){
    require 'moose.pl';
    require 'subs\make_tex.pl';
    read_print_records();
    if ($outputfileFMO ne ''){
        $tex_Name=$outputfileFMO;
    }else{    
        $tex_Name='final';
    } 
    make_tex_files($tex_Name);
    moose(printoutALPHA);
    print "Running LaTeX: ";
    system("latex  --quiet --output-directory=\"$pdf_Dir\" \"$tex_File\"");
    if($pdfFMO=~/yes/i){ 
        log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
        system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     } 
    my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
          unlink("$tex_File");
          unlink("$aux_File");
          unlink("$log_File");
          unlink("$toc_File");  
    }  
}elsif ( $fmw eq 'proof' ){
    require 'moose.pl';
    require 'subs\make_tex.pl';
    read_print_records();
    if ($outputfileFMO ne ''){
        $tex_Name=$outputfileFMO;
    }else{    
        $tex_Name='proof';
    } 
    make_tex_files($tex_Name);
    moose(proof);
    log_p("output file $tex_File");
    print "Running LaTeX: ";
    system("latex  --quiet --output-directory=\"$pdf_Dir\" \"$tex_File\"");
    if($pdfFMO=~/yes/i){ 
        log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
        system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     }
    #my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
          unlink("$tex_File");
          unlink("$aux_File");
          unlink("$log_File");
          unlink("$toc_File");
    }
}elsif ($fmw eq 'startup'){
    require 'subs\perl_startup.pl';
    startup();
}elsif ($fmw eq 'checkout'){
    require 'subs\versioncheck.pl';
    require 'subs\perl_startup.pl';  
    require 'subs\update.pl';
    versioncheck();
    updatecheck($tocheckout_File, $j_tocheckout_File);
    $updateschecked=1;
    checkout();         #in the perl_startup directury
    #run update thing
    #update(@filestobeupdated);
}elsif ($fmw eq 'checkin'){
    require 'subs\versioncheck.pl';
    require 'subs\update.pl';
    require 'subs\perl_startup.pl';
    versioncheck();
    checkin();
}elsif ($fmw eq 'updateget'){
    require 'subs\versioncheck.pl';
    require 'subs\perl_startup.pl';
    require 'subs\update.pl';
    versioncheck();
    updatecheck();
}elsif ($fmw eq 'synch'){
    #this part allows the used to specify how many record to dowload at a time
    #check if running in trouble mode
    if ($optionsFMO eq 'man'){
        print "\nRunning Manual option for sych.\n";
        print "To update all records press Enter.\n";
        print "To limit the number of records to be updated at this time, enter the number.\n";
        print "To updated only the records in the Manual Dowload Directory, enter 0 (does not connect to FTP).\n";
        print "Enter your choice:";
        $recordsTOsynch=<STDIN>;
        chomp($recordsTOsynch);
    }
    $lockedserverfree=1;
    require 'subs\versioncheck.pl';
    require 'subs\perl_startup.pl';
    require 'subs\update.pl';
    require 'subs\synch.pl';
    unless($recordsTOsynch eq '0'){
       versioncheck();
    }   
    synch($recordsTOsynch);    #in sych.pl
}elsif ($fmw eq 'updatesend'){
    #split file into multiple files and put each one on the server wiht appropriate name
    require 'subs\versioncheck.pl';
    require 'subs\update.pl';
    versioncheck();
    updatesend();
}elsif ($fmw eq 'rlg'){
    require 'moose.pl';
    #make_tex_files('rlg');
    moose(rlg);
    #print "Running LaTeX: ";
    #system("latex  --quiet \"$tex_File\"");
    #if($pdfFMO=~/yes/i){ 
    #    log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
    #    system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     #} 
    #my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
         unlink("$tex_File");
         unlink("$aux_File");
         unlink("$log_File");
         unlink("$toc_File");
    }
}elsif ($fmw eq 'make_MODS'){
    require 'moose.pl';
    #make_tex_files('rlg');
    moose(make_MODS);
    #print "Running LaTeX: ";
    #system("latex  --quiet \"$tex_File\"");
    #if($pdfFMO=~/yes/i){ 
    #    log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
    #    system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     #} 
    #my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
         unlink("$tex_File");
         unlink("$aux_File");
         unlink("$log_File");
         unlink("$toc_File");
    }    
}elsif ($fmw eq 'ris'){
    
    require 'moose.pl';
    #make_tex_files('rlg');
    moose(ris);
    #print "Running LaTeX: ";
    #system("latex  --quiet \"$tex_File\"");
    #if($pdfFMO=~/yes/i){ 
    #    log_q("pdfFMP set to '$pdfFMO'. Runing PDFLaTeX, reading $tex_File writing to $pdf_Dir"); 
    #    system("PDFLaTeX  --output-directory=\"$pdf_Dir\" \"$tex_File\"");
     #} 
    #my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
         unlink("$tex_File");
         unlink("$aux_File");
         unlink("$log_File");
         unlink("$toc_File");
    }

}elsif ($fmw eq 'analysis'){
    require 'subs\analysis.pl';
    require 'moose.pl';
    moose(analysis);
    print "\n\n::FINISHED (press enter)";
    $bey=<STDIN>;
}elsif ( $fmw eq 'htmldb' ){
    require 'moose.pl';
    require 'subs\make_tex.pl';
    read_print_records();
    if ($outputfileFMO ne ''){
        $tex_Name=$outputfileFMO;
    }else{    
        $tex_Name='htmldb';
    } 
    make_tex_files($tex_Name);
    moose(htmldb);
    my $filename=$fm_com{'filename'};
    unless ($testMODE==1){
         unlink("$tex_File");
         unlink("$aux_File");
         unlink("$log_File");
         unlink("$toc_File");
    }
}elsif ( $fmw eq 'subjects' ){
    require 'subs\itty1.pl';
    itty1_just_subjects();
}elsif ( $fmw eq 'report' ){
    require 'subs\subjects_report.pl';
    subjects_report();
}elsif ($fmw eq 'journalAnalysis'){
    #use DB_File;
    require 'subs\journals_analysis.pl';
    journals_analysis();
    unless ($testMODE==1){
        unlink($reviewsAnalysis_File);
        unlink($journalAnalysis_File);
    }
}else{
    error_b("[Error 168] Unknow option $fmw");
}

}#end of sub
1;
