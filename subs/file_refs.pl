#used to define all the file references
#when calling subrutines with file names, use full names

#auxilary files defined in moose.pl

#this variable sets the absolute path
$ap='C:\CB directory\\';

#file exported from FM, used as the_in_File (as defined in set_options.pl) as the input file for moose
$export_File="$ap".'Aux Files\export.mer';                      #input
$j_export_File="$ap".'Aux Files\journals.mer';                  #input

#output files for reimporting into FM
$out_File="$ap".'Aux Files\oneback.mer';
$outart_File="$ap".'Aux Files\oneback_art.mer';
$outchap_File="$ap".'Aux Files\oneback_chap.mer';
$outbook_File="$ap".'Aux Files\oneback_book.mer';
$outrev_File="$ap".'Aux Files\oneback_rev.mer';
$j_out_File="$ap".'Aux Files\onebackJ.mer';
%outfiles=( 
       'mainFM'=>"$out_File",
       'articleFM'=>"$outart_File",
       'chapterFM'=>"$outchap_File",
       'bookFM'=>"$outbook_File",
       'reviewFM'=>"$outrev_File",     
); 


$fminfo_File="$ap".'Aux Files\import export files\fminfo.tab';                  #input
$tocheckout_File="$ap".'Aux Files\import export files\tocheckout.tab';          #input
$j_tocheckout_File="$ap".'Aux Files\import export files\tocheckoutJ.tab';       #input
$print_File="$ap".'Aux Files\printset.tab';
$updated_File="$ap".'Aux Files\updated.tab';                                    #input
$j_updated_File="$ap".'Aux Files\updatedJ.tab';                                 #input
$checkedout_File="$ap".'Aux Files\import export files\checkedout.tab';          #input
$j_checkedout_File="$ap".'Aux Files\import export files\checkedoutJ.tab';
$checkin_File="$ap".'Aux Files\checkin.tab';                                    #input
$j_checkin_File="$ap".'Aux Files\checkinJ.tab';                                 #input
$subjects_File="$ap".'Aux Files\local\subjects.tab';
$journals_File="$ap".'Aux Files\local\journals.tab';
$cats_File="$ap".'Aux Files\local\categories.tab';
$sjc_File="$ap".'Aux Files\local\auxfile.pl';
$subtype_File="$ap".'Aux Files\local\subject_type_allowed.txt';
$toget_File="$ap".'Aux Files\recordstoget.tab';
$alllog_File="$ap".'Aux Files\local\MOOSE.LOG';
$lastlog_File="$ap".'Aux Files\local\LAST.LOG';
$error_sub_File="$ap".'Current Work\Saved Sets\thesaurus_errors.tab';
$rlg_out_File="$ap".'Aux Files\rlg.tab';
$horuserrors_File="$ap".'Aux Files\subs\horuserrors.tab';
$oktocheckin_File="$ap".'Aux Files\import export files\oktocheckin.tab';
$stillcheckedout_File="$ap".'Aux Files\import export files\stillcheckedout.tab';
$version_File="$ap".'Aux Files\version.tab';
$mods_File="$ap".'Aux Files\IsisDP\MODS\CBB';
$mods_J_File="$ap".'Aux Files\IsisDP\MODS\CBJ';
$authoritiesFile="$ap".'Aux Files\IsisDP\authoritesFile.tab';
$eac_File="$ap".'Aux Files\IsisDP\EAC\\';
$rdf_File="$ap".'Aux Files\IsisDP\RDF\isis_authorities.ttl';
$rdf_File_thes="$ap".'Aux Files\IsisDP\RDF\isis_authorities_thes.ttl';
$fcbkcp_File="$ap".'Aux Files\local\linkBKP.log';
$ids_File="$ap".'Aux Files\local\ids.tab';
$locked_File="$ap".'Aux Files\locked.txt';
$journalAnalysis_File="$ap".'Aux Files\import export files\journals.tab';       #input
$reviewsAnalysis_File="$ap".'Aux Files\import export files\reviews.tab';       #input
$journalAnalysisReport_File="$ap".'Aux Files\local\journal_report.txt';
$recordstobeupdated_File="$ap".'Aux Files\local\recordsToBeUpdated.txt';
$hi_File="$ap".'Aux Files\subs\0ddcc10.txt';
$Js2BSkipped_File="$ap".'Aux Files\local\JournalIDsToBeSkipped.txt';

$journal_categories_File="$ap".'Aux Files\IsisDP\Analysis\journal_categories.txt';
$journal_categories_split_File="$ap".'Aux Files\IsisDP\Analysis\journal_categories_split.txt';
$analysis_author_File="$ap".'Aux Files\IsisDP\Analysis\analysis_authors.txt';
$analysis_author_journals_File="$ap".'Aux Files\IsisDP\Analysis\analysis_authors_journals.txt';
$analysis_author_publishers_File="$ap".'Aux Files\IsisDP\Analysis\analysis_authors_publishers.txt';
$analysis_publishers_File="$ap".'Aux Files\IsisDP\Analysis\analysis_publishers.txt';
$contributor_subject_File="$ap".'Aux Files\IsisDP\Analysis\analysis_contributor_subject.txt';
$analysis_subject_category_File="$ap".'Aux Files\IsisDP\Analysis\analysis_subject_category.txt';
$analysis_journal_subject_File="$ap".'Aux Files\IsisDP\Analysis\analysis_journal_subject.txt';
$analysis_dissertation_File="$ap".'Aux Files\IsisDP\Analysis\analysis_dissertations.txt';


$htmldb_out_File="$ap".'Aux_Files\htmldb.tab';

$analysisin_File="$ap".'Aux Files\export.mer';
$analysisout_File="$ap".'Aux Files\analysis.txt';

$skip_File="$ap".'Current Work\Saved Sets\\';

$symbols_File="$ap".'Documentation\CB_SpecialTextCodes.pdf';


$downloads_Dir="$ap".'Aux Files\downloads\\';
$manualDownloads_Dir="$ap".'Aux Files\manual download\\';

sub make_tex_files{
#makes names for all the files used by LaTeX and friends
my $name=$_[0];
$tex_File="$ap".'Aux Files\\'."$name".'.tex';
$toc_File="$ap".'Aux Files\\'."$name".'.toc';
$aux_File="$ap".'Aux Files\\'."$name".'.aux';
$log_File="$ap".'Aux Files\\'."$name".'.log';
$dvi_File="$ap".'Aux Files\\'."$name".'.dvi';
$pdf_File="$ap".'Aux Files\\'."$name".'.pdf';
$pdf_Dir="$ap".'Aux Files';
$txt_File="$ap".'Aux Files\\'."$name".'.txt';
$html_File="$ap".'Aux Files\\'."$name".'html.tex';
}

1;
