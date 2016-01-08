#dealing with options

sub set_options {

my $option=$_[0];
#first see if the program was called from filemker
#when calling from filemaker use
#       perl -s moose.pl -filemaker

@options=('error(unkown option)', regular, proof, final, rlg, alert, custum, retrive, analysis,htmldb,printout,printoutALPHA,journalAnalysis,ris,make_MODS);

#if ($filemaker == 1){
if ($option eq 'one'){ 
        $choice=1;
        $the_in_File="$export_File";
        #$the_out_File are the standard set of files defined in fiel_ref.pl
      
#}elsif ($proof==1){
}elsif ($option eq 'proof'){
    $choice=2;
    $the_in_File="$export_File";
    #$outfile='trash.mer';
#}elsif ($final==1){
}elsif ($option eq 'final'){
    $choice=3;
    $the_in_File="$export_File";
    #$outfile='trash.mer';
#}elsif ($rlg==1){
}elsif ($option eq 'printout'){
    $choice=10;              
    $the_in_File="$export_File";
}elsif ($option eq 'printoutALPHA'){
    $choice=11;              
    $the_in_File="$export_File";
}elsif ($option eq 'journalAnalysis'){
    $choice=12;              
    $the_in_File="$journalAnalysis_File";
}elsif ($option eq 'rlg'){
    $choice=4;
    $the_in_File="$export_File";
    $the_out_File=$rlg_out_File;
}elsif ($option eq 'ris'){
    $choice=13;
    $the_in_File="$export_File";
    $the_out_File=$rlg_out_File;
}elsif ($option eq 'make_MODS'){
    $choice=14;
    $the_in_File="$export_File";
    $the_out_File=$rlg_out_File;


}elsif ($option eq 'analysis'){
    $choice=8;
    $the_in_File="$analysisin_File";
}elsif($option eq 'htmldb'){
    $choice=9;
    $the_in_File="$export_File";
    $the_out_File="$htmldb_out_File;"
}else{
    error_b("[Error 105] Unrecognized moose command $option");
}
    
log_q("Reading from $infile");
#log_q("Writing to $outfile");

} 


1;
