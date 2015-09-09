#this sub send email alerts


sub send_mail{

$server='smtp.central.cox.net';

$smtp = Net::SMTP->new($server);
die "Couldn't connect to server" unless $smtp;

my $MailFrom = "sts\@ou.edu";
my $MailTo = "sts\@ou.edu";

$smtp->mail( $MailFrom );
$smtp->to( $MailTo );

# Start the mail
$smtp->data();

# Send the message
$smtp->datasend("To: mailing-list\@mydomain.com");
$smtp->datasend("From: MyMailList\@mydomain.comt\n");
$smtp->datasend("Subject: Updates To My Home Page\n");
$smtp->datasend("\n");

$smtp->datasend("Hello World!\n\n");

# Send the termination string
$smtp->dataend();

$smtp->quit();
}

1;
