sub printsection {
#as an argument takes category line

my $cats=$_[0];
$cats="$cats".'//';   #adds so that in case there is no // there will be
$cats=~/(.*?)\/\//;
my $cat=$1;
$print_sec_desC=0;

@secheads=split(/-/,$cat);

$sechead=$secheads[0];          #numerical valu
$subsechead=$secheads[1];
$secnames=cb2tx($categories_short{$sechead});      #name and short name
$lsecnames=cb2tx($categories{$sechead});
$ssecnames=cb2tx($categories_short{$subsechead});
$lssecnames=cb2tx($categories{$subsechead});

if ($secnames eq '' || $lsecnames eq '' ){    #if cannot find appropriet section prints error message
    warning_q("[Warning 100] Unknow subject category $sechead in record $number");
}else{
    if ( $sechead < 7 && $chapter1 == 0){
        print OUT '\chapter{';                #if so makes a chapter
        print OUT "Tools for Historians of Science\}\n";
        print OUT '\markboth{Tools for Historians}{}';
        print OUT "\n";
        $chapter1=1;
        $linecheck=1;
    }
    if ($sechead > 9 && $sechead < 20 && $chapter2==0){
        print OUT '\chapter{';                #if so makes a chapter
        print OUT "Theoretical Approaches to Understanding Science\}\n";
        print OUT '\markboth{Theoretical Approaches}{}';
        print OUT "\n";
        $chapter2=1;
        $linecheck=1;
    }
    if ($sechead > 19 && $sechead < 40 && $chapter3==0){
        print OUT '\chapter{';                #if so makes a chapter
        print OUT "Thematic Approaches to the Study of Science\}\n";
        print OUT '\markboth{Thematic Approaches}{}';
        print OUT "\n";
        $chapter3=1;
        $linecheck=1;
    }
    if ($sechead > 39  && $sechead < 100 && $chapter4==0){
        print OUT '\chapter{';                #if so makes a chapter
        print OUT "Aspects of Scientific Practice and Organization\}\n";
        print OUT '\markboth{Aspects of Practice}{}';
        print OUT "\n";
        $chapter4=1;
        $linecheck=1;
    }
    if ($sechead > 99 && $sechead < 200 && $chapter5==0){
        print OUT '\chapter{';                #if so makes a chapter
        print OUT "Disciplinary Classification\}\n";
        print OUT '\markboth{Disciplines}{}';
        print OUT "\n";
        $chapter5=1;
        $linecheck=1;
    }
    if ($sechead > 199 && $sechead < 300 && $chapter6==0){
        print OUT '\chapter{';                #if so makes a chapter
        print OUT "Classification by Geographical Area and Cultural Influence\}\n";
        print OUT '\markboth{}{}';
        print OUT "\n";
        $chapter6=1;
        $linecheck=1;
    }
    if ($sechead > 299 && $chapter7==0){
        print OUT '\chapter{';                #if so makes a chapter
        print OUT "Chronological Classification\}\n";
        print OUT '\markboth{}{}';
        print OUT "\n";
        $chapter7=1;
        $linecheck=1;
    }

    if($sechead ne $oldsechead){        #if section is new do a new section head
        ####add spce to toc
        $hhjl=$sechead+1;
        @secnums=split(//,$hhjl);       #split section umber to digits
        @rsecnums=reverse @secnums;
        if($rsecnums[1] ne $oldsecnumr && $rsecnums[2] == 1){       #do this only for the 100's
            #add to contents a break
            print OUT '\addtocontents{toc}{\vspace{1em}}';
            $oldsecnumr=$rsecnums[1];
        }
        if( $rsecnums[2] == 2 || $rsecnums[2] == 3){       #do this only for the 100's
            #add to contents a break
            print OUT '\addtocontents{toc}{\vspace{1em}}';
            $oldsecnumr=$rsecnums[0];
        }

        ######
        #when first encountering section 200, redfine \section
        if ($sechead > 199 && $seen200!=1){
            print OUT '\renewcommand{\section}{\secdef\sectionl\sectionl}';
            print OUT "\n";
            print OUT '\newcommand{\sectionl}[1]{';
            print OUT '\vspace{1em}\noindent\parbox{\columnwidth}{\setlength{\rightskip}{0pt plus 3cm}\rule[-2pt]{\columnwidth}{0.5pt}\par';
            print OUT '{\sffamily\small\uppercase{#1}}\par\rule[8pt]{\columnwidth}{0.5pt}}}';
            print OUT "\n";
            $seen200=1;
        }      
        print OUT '\setcounter{section}{';
        print OUT "$sechead\}\n";
        print OUT '\section*{';
        print OUT "$sechead.\\hspace{0.5em}$lsecnames}\n";
        print OUT '\markboth{';
        print OUT "$secnames";
        print OUT '}{';
        print OUT "$secnames}";
        print OUT "\n";
        
        print OUT '\addcontentsline{toc}{section}{\protect\numberline{';
        print OUT "$sechead}";
        if($sechead < 200){
            print OUT "$secnames}\n";
        }else{  
            print OUT "\\textbf{$secnames}}\n";    
            print OUT '\vspace{-2.5ex}';
            #run the section description so that the description for whole sections will print
            print_sec_desc('sec');
        }
        
        #
        #print OUT '\paragraph{}';
        #print OUT "\n";
        #print OUT '\noindent\nopagebreak';
        #print OUT '\rule[7pt]{\columnwidth}{0.5pt}';
        #print OUT "\n";
        #print OUT '\paragraph{}
        #print OUT '\nopagebreak';
        #print OUT '\vspace{-8pt}';
        #print OUT "\n\\paragraph{}\n";
        #
        $newsection=1;
        $print_sec_desC=1;

        $oldsechead=$sechead;
        $oldsubsechead=999;     #set to somethign that will not come up so that wiht new section a new subsection will be set
    }
    if ($subsechead ne "" && $sechead > 199){
        if($subsechead != $oldsubsechead){
                  
            print OUT '\setcounter{subsection}{';
            print OUT "$subsechead\}\n";

             print OUT '\vspace{-5pt}\nopagebreak';
            print OUT '\subsection*{';
            print OUT "$sechead-$subsechead.\\hspace{0.5em}$lssecnames\}\n";
            $oldsubsechead=$subsechead;
             #
             #print OUT '\nopagebreak';
             #print OUT '\paragraph{}\nopagebreak';
             #print OUT '\rule[10pt]{5cm}{0.3pt}\nopagebreak';
             #print OUT '\paragraph{}\nopagebreak';
             #print OUT '\vspace{3pt}\nopagebreak';
             #
             print OUT '\addcontentsline{toc}{subsection}{\protect\numberline{';
             print OUT "$subsechead.}$ssecnames}\n";
             print OUT "\n\\paragraph{}\n";
             $newsection=0;
             $print_sec_desC=1;
        }
    }
    
    
    
    
    #this is that there is no extra paragraph betwen suection and subsection headings
    if($newsection==1){
       print OUT "\n\\paragraph{}\n";
     
    }
    
    if($print_sec_desC==1){
      #see if there is description to be added
       print_sec_desc();
    }
}
$secat=$categories[0];
}


sub print_sec_desc{


$full="$sechead"."-"."$subsechead";

if($_[0] eq 'sec'){

     $sech="$sechead-";
     if($cat_des{$sech} ne ''){
          #	print OUT '\vspace{-5pt}\nopagebreak \emph{\small (';
          #last used#	print OUT '\paragraph{}\nopagebreak \emph{\small (';
          print OUT '\vspace{-5pt}\paragraph{}\nopagebreak \emph{\footnotesize ('; 
          	print OUT "$cat_des{$sech}";
          #	print OUT ')}\paragraph{}'."\n\n";
          	print OUT ')}\paragraph{}\vspace{-5pt}\nopagebreak';
     }

}else{
#playing around here: changes size from small to footnotesize
#changed vspace rom -5pt to -6pt

     if ($cat_des{$full} ne ''){
     	print OUT '\vspace{-6pt}\nopagebreak \emph{\footnotesize (';
     	print OUT "$cat_des{$full}";
     	print OUT ')}\paragraph{}'."\n\n";


     }elsif($cat_des{$subsechead} ne ''){
     	print OUT '\vspace{-6pt}\nopagebreak \emph{\footnotesize (';
     	print OUT "$cat_des{$subsechead}";
     	print OUT ')}\paragraph{}'."\n\n";

     }elsif($cat_des{$sechead} ne ''){
     	print OUT '\vspace{-6pt}\nopagebreak \emph{\footnotesize (';
     	print OUT "$cat_des{$sechead}";
     	print OUT ')}\paragraph{}'."\n\n";

}
}
}

1;
