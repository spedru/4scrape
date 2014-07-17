#
#	4scrape.pl
#	Homura Akemi !homuhomu4Q
#
#	Downloads files from a 4chan thread and doesn't quit until 404.
#
use LWP::Simple;
use JSON qw( decode_json );
use Try::Tiny;

system("color 09");
my $dirty_url = shift;
#https://boards.4chan.org/u/thread/1573393#p1573393
my $board;
my $thread;
$dirty_url =~ m%boards\.4chan\.org/(\w+)/thread/(\d+)\b?%s;
$board = $1;
$thread = $2;
system("title 4scrape/$board/$thread");

debug("[  INFO  ] Looking for thread number $thread");

while (1) {
	my $ua = LWP::UserAgent->new;
	$ua->timeout(2);
	$ua->env_proxy;
	$ua->max_redirect(0);
	my $url = 'https://a.4cdn.org/' . $board . '/res/' . $thread . '.json';
	my $response = $ua->head($url);
	if ($response->is_success) {
		debug("[  INFO  ] " . $response->status_line );
		my $content = $ua->get($url);
		if ($content->is_success) {
			debug("[  INFO  ] " . $content->status_line );
			try {
				our $decoded_json = decode_json( $content->decoded_content );
				debug("[  INFO  ] " . $decoded_json->{posts}[0]->{no});
			};

			my $replyct = $decoded_json->{posts}[0]->{replies};
			
			for (my $i = 0; $i <= $replyct; $i++) {
				
				if ($decoded_json->{posts}[$i]->{fsize}) {
					debug("[  INFO  ] Post " . $decoded_json->{posts}[$i]->{no} . " has image " . $decoded_json->{posts}[$i]->{tim} . $decoded_json->{posts}[$i]->{ext});
					open (penisfile, ">>", "wgets.txt");
					print penisfile "https://i.4cdn.org/";
					print penisfile $board;
					print penisfile "/";
					print penisfile $decoded_json->{posts}[$i]->{tim};
					print penisfile $decoded_json->{posts}[$i]->{ext};
					print penisfile "\n";
					close penisfile;
				}
			}
			system("wget -nc -i wgets.txt --directory-prefix=" . $board . "_" . $thread . " --no-check-certificate");
			system("del wgets.txt");

			$decoded_json = 0;
			$content = 0;
			
		}
	} elsif ($response->status_line =~ /404/){
		debug("[ FAILED ] " . $response->status_line );
		debug("Exiting on 404...");
		die();
	} elsif ($response->status_line =~ /403/){
		debug("[ FAILED ] " . $response->status_line );
	} elsif ($response->status_line =~ /401/){
		debug("[ FAILED ] " . $response->status_line );
	} elsif ($response->status_line =~ /500/){
		debug("[ FAILED ] " . $response->status_line );
	} elsif ($response->status_line =~ /502/){
		debug("[ FAILED ] " . $response->status_line );
	} else {
	    debug("[ FAILED ] " . $response->status_line );
	}
	debug("[  INFO  ] Resting for 90 seconds, press ^C to cancel");
	sleep(90);
}

sub debug {
	my $data = shift;
	print $data;
	print "\n";
}
