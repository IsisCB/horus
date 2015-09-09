#here is a list of expected commened in the category field
#each sub hash has commands for moose what to do wiht the record depending on the output
#item selected go will be prices as seperete ites


%category_comand=(
'Scope'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'nogo', 'rlg'=>'nogo', 'email'=>'nogo', 'final'=>'nogo',},
'Reprint'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'nogo', 'rlg'=>'nogo', 'email'=>'nogo', 'final'=>'nogo',},
'IsisRLG'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'go', 'rlg'=>'nogo', 'email'=>'nogo', 'final'=>'nogo',},
'Duplicate'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'nogo', 'rlg'=>'nogo', 'email'=>'nogo', 'final'=>'nogo',},
'Skip'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'nogo', 'rlg'=>'nogo', 'email'=>'nogo', 'final'=>'nogo',},
'Source Book (for Chaps & Revs)'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'go', 'rlg'=>'nogo', 'email'=>'nogo', 'final'=>'nogo',},
'Contents List Print Only (for Chpas & Arts)'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'go', 'rlg'=>'go', 'email'=>'go', 'final'=>'nogo',},
'Contents both Print and RLG (for Chpas & Arts)'=>{'one'=>'go', 'regular'=>'go', 'proof'=>'go', 'rlg'=>'go', 'email'=>'go', 'final'=>'nogo',},
);


#sort orders for differn record types and different output types
# use ! to designate text

%sort_order=(
'JournalArticle'=>{
                    'one'=>[record_number],
                    'regular'=>[record_number],
                    'proof'=>[doc_type,journal_link,volume,'pages'],
                    'rlg'=>[record_number],
                    'email'=>[],
                    'final'=>[categories,author,editor,title],
                    'conlist'=>['pages',author,editor,title],
                    'revlist'=>[author,title,'pages'],
                    'printout'=>[categories,author,editor,title],
                    'printoutALPHA'=>[author,title,'pages'],
                    },
'Book'           =>{
                    'one'=>[record_number],
                    'regular'=>[record_number],
                    'proof'=>[doc_type,author,editor,title],
                    'rlg'=>[record_number],
                    'email'=>[],
                    'final'=>[categories,author,editor,title],
                    'conlist'=>[author,editor],
                    'revlist'=>[author,editor,title],
                    'printout'=>[categories,author,editor,title],
                    'printoutALPHA'=>[author,editor,title],
                    },
'Chapter'         =>{
                    'one'=>[record_number],
                    'regular'=>[record_number],
                    'proof'=>['!Book',book_author,book_editor,book_title,chpages],
                    'rlg'=>[record_number],
                    'email'=>[],
                    'final'=>[categories,author,title,chpages],  #but this only works for seperataly entered chapters
                    'conlist'=>[chpages,record_number],
                    'revlist'=>[author,title,chpages],
                    'printout'=>[categories,author,title,chpages],  #but this only works for seperataly entered chapters
                    'printoutALPHA'=>[author,title,chpages],
                    },
'Review'          =>{
                    'one'=>[record_number],
                    'regular'=>[record_number],
                    'proof'=>['doc_type','journal_link_review','volume','pages'],
                    'rlg'=>[record_number],
                    'email'=>[],
                    #'final'=>['!Book','reviewed_author','reviewed_editor','reviewed_title','author'],
                    'final'=>['author','editor','title'],     #this is for things reviewed not for the reviews
                    'conlist'=>['jrevpages','author','author','editor'],
                    'revlist'=>['author','title','jrevpages'],
                    'printout'=>['author','editor','title'],     #this is for things reviewed not for the reviews
                    'printoutALPHA'=>['author','title','jrevpages'],
                    },                                                            

);

1;
