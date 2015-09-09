
require 'subs\read_data.pl';
require 'subs\print_data.pl';
require 'subs\ftp_files.pl';

sub updateget{
#takes  absolute  path
@infiles=@_;

open (OUT, "> $j_out_File") || error_q("[Error ] Cannot open $j_out_File for writting $!");

#deal very differently with journal updates, and other.
#with regular updates, has a subrutie do the printing etc
#with journal updates, prints on the go

foreach $infile (@infiles){
    $jrec=0;
      open (IN, "< $infile") || error_q("[Error 119] Cannot open $infile $!");

      my $howmany=-1;

      while (<IN>){
          chomp;
          if($howmany==-1){     #for the header of each update file
          #changed it so that reads for every file seperatly so that if the files have different order things will be alright
              if ($_=~/^J/){        #if this is a journal record don't bother
                $jrec++;
                #for the first record print the header
                unless ($jhp == 1){
                    print OUT "$_\n";
                    $jhp=1;
                }    
                
              }else{        #if not a journal record
                $jrec=0;    
                  read_header($_);              #for the first record splits fileds  
              }  
          }else{        #for the body of each file
            if($jrec > 0){
                print OUT "$_\n";
            }else{    
                my $record = read_data($_);                   #this will pull out all important information, sort etc (and why is this needed for updates?)
                push(@uprecords, $record);
            }    
          }
          $howmany++;
      }
      close IN;
      unlink ($infile) || error_q("[Warning 120] Could not delete $infile");

}
unless ($jhp == 1){
    print OUT "$journalheader\n";       #in read_data
    print OUT "458,,NO PRINT--USED BY SCRIPTS--DO NOT DELETE";
}
close OUT;    

#once all the files were read print them to one file in multiple tables

#this is now
#push @uprecords, ' ';       #add an empty record to array so that make_mer will run
#                            #and make a set of records with just headers so that the
#                            #filemaker script will run w/o errors

foreach $record (@uprecords){
    #make_mer must take a reference
    unless ($record=~/J/){
        make_mer(\%{$data{$record}});
    }    
}

}


##################3


sub updatesend{

$journalheader='Journal Id,record version,Main Title,Other titels,ISSN,Language,Frequency,Comment,Call number 1,Call number 2,Call number 3,Location,Print copy,In the guide,Current subscription,Home Page,TOC page,Full text access,Publisher,Editorial contact,Importance rank,Abbriviation,Last Checked,Type,Pagination,in the neu list,Last modified,Checked Out';
#first read the journals file, fix it and add it to the main file

$jefile="$j_export_File";
if (  open (IN, "< $jefile")  ){
     $jct=0;
     while(<IN>){
         #skip the first record
         if ($jct == 0){
             $jct=1;
             next;
         }    
         #add J to the record number
         $line=$_;
         if($line=~s/^"/"J/){
             $jf="$jf"."$line";
         }else{    
             $jf="$jf"."J"."$line";
         }    
     }
}
close IN;
unlink($jefile);

#read the infile

$efile="$export_File";
#append the export file with the journal info
unless ($jf eq ''){
    open (OUT, ">> $efile") || error_b("[Error ] Cannot open $efile for appending $!");
    print OUT "\n"."$jf";
    close OUT;
}

open (IN, "< $efile") || error_b("[Error 121] Cannot open $efile for reading $!");

my $howmany=-1;

unless ($ftpstatus eq 'on'){
    go_ftp();
}
$ftp->cwd('Updates');

@updatefiles = $ftp->ls('.');
foreach $file (@updatefiles){
    if ($file=~/(.*)-(.*)/){  #rec numberb -  version number
        $recnum=$1;
        $vnum=$2;
        $currentupdates{$1}=$file;
    }
}
#temp diagnostic
#use Cwd;
   
while (<IN>){

#exit if the server stops up
last if(ftp_error_check() eq 'stop');


    chomp;
    if($howmany==-1){
        $header=$_;
    }else{
         $csv = Text::CSV->new();    # create a new object
         $status="";
         my $line=l12cb($_, line);
         $status = $csv->parse($line);         # parse a CSV string into fields
         if ($status == 0){   #in case a record can't be read inform the user
         $bad_argument = $csv->error_input();
             error_q("[Error 183] This record could not be split and was skiped. $bad_argument $line");
         }else{
             $line=~/"(.*?)","(.*?)"/;         #get the record number and version number need to make the
             $recid=$1;
             $filename="$recid".'-'."$2";
             
             #$dir = cwd;   #diag
             #print "\n\nHERE $dir\n\n";   #diag
             #log_p("before error 122 $dir");

             open (OUT, "> $filename") || error_b("[Error 122] Could not open $filename for writting $!");
             if ($filename=~/J/){
                print OUT "$journalheader\n";       #also in  read_data.pl
             }else{
                 print OUT "$header\n";
             }    
             print OUT "$_\n";
             close OUT;
             if($currentupdates{$recid} ne ''){
                 $ftp->rename($currentupdates{$recid}, "bkp/$currentupdates{$recid}");    #move the file to a bkp directory
             }
             my $putstat=put_file($filename);
             if ($putstat eq 'ok'){
                $oktocheckin{$recid}=1;
             }else{
                $stillcheckedout{$recid}=1;
             }      
             unlink($filename) || log_p ("cannot unlink file $filename");
         }    
    }
    $howmany++;
}
close IN;
unlink ($efile) || error_q("[Warning 123] Could not delete $efile");

open (OUT, "> $oktocheckin_File");
foreach $f (keys %oktocheckin){
    print OUT "$f\tok\n";
}
foreach $f (keys %stillcheckedout){
    print OUT "$f\tNOT\n";
}
close IN;    

#stop_ftp();

}

####################3


sub updatecheck {
#checks for updates for records in a file, and then downloads any available

#the infile can be specified when the sub is called

$infile=$_[0];
$infile2=$_[1];

#append the file
open (IN, "< $infile2");
open (OUT, ">> $infile") || error_b("[Error ] Could not open for appending $infile $! ");
while(<IN>){
    print OUT "J"."$_";
}
close OUT;
close IN;    


open (IN, "< $infile") || error_b("[Error 124] Could not open for reading $infile $! ");

while (<IN>){
    chomp;
    ($rec, $ver)=split(/\t/, $_);
    $versionnumbers{$rec}=$ver;
    check4updates($rec, $ver);        #in the perl_starup.pl
}
close IN;
#unless ($_[0] ne '') {unlink ($infile)};   #shouldnr this be eq not ne

updateget(@filestobeupdated);

}

1;
