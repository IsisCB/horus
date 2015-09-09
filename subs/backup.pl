


sub backup{
     my $bkp_file='../Backup/backup.mer';
     my $one=$_[0];


     open BKP, ">>:utf8",  $bkp_file || error_b("could not open $bkp_file $! in backup.pl $!");
     open IN, "<:utf8", $one || error_s("could not open $one to back it up $!");
     my $tm=time();
     while (<IN>){
        chomp;
        my $bkpstamp=',":::'."$tm.$fm_com{'user'}.$machinename".'bkp:::"';
        #if ($_=~/^"/){          #do this only for data rows, nort for header rows
             print BKP "$_"."$bkpstamp\n";
        #}else{
        #     print BKP "$_\n";
        #}            
     }
     close BKP;
     close IN;
}


sub backup_file {

#takes the temp.mer file and sames it 

my $tobkp=$_[0];
my $tosave=$_[1];

$tm=time();


$tosave=~s/fp5$/$fm_com{'action'}.$tm.$fm_com{'user'}.$machinename.mer/;

copy('temp.mer', "../Backup/$tosave") || error_s("Counld not backup temp.mer in backup.pl");

}

1;
