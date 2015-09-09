#here read options from filemaker


sub read_fm_options{


#read the file from FM
$fminfo=$fminfo_File;
open IN, "<:utf8", $fminfo || error_b("[Error 167] Could not open the $fminfo for reading $!");
while (<IN>){
    chomp;
    @fminfo=split(/\t/, $_);
    $fminfoline=$_;
}
close IN;

$nextrecordFMO=$fminfo[0];
$machinenameFMO=$fminfo[1];
$localversionFMO=$fminfo[2];   #contiants version of master
@updatedrecordsFMO=split(/;/, $fminfo[3]);      #contianes record numbers of updated records since the master
#split into hash
foreach $rec (@updatedrecordsFMO){
    ($recn, $vernum)=split(/-/, $rec);
    $updates{$recn}=$vernum;
}
$userFMO=$fminfo[4];
$actionFMO=$fminfo[5];
if ($actionFMO=~/(.*?):(.*)/){
    $actionFMO=$1;
    $optionsFMO=$2;
}    
$outputfileFMO=$fminfo[6];
$htmlFMO=$fminfo[7];
$pdfFMO=$fminfo[8];
$updatedFMO=$fminfo[9];
$sfactorFMO=$fminfo[10];

}

1;
