

sub sqeez {

#this is a subrutine that is used by most others
#it gets rid of extra spaces in fields

$_[0]=~s/^\s+//;        #get rid of leading spacec
$_[0]=~s/(<newline>|\s)*$//g;    #get rid of trailing spaces and returns      
$_[0]=~s/\s+/ /g;        #replace multiple spaces wiht a single one
}

1;
