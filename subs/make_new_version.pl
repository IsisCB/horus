
sub make_new_version {

go_ftp();

#first lock the directory by renaming it
$ftp->rename(Updates, Updates-locked);


}
1;
