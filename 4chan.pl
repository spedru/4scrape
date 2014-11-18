#	4chan.pl
#	Get data from a thread or post from the 4chan API and return it in text format with pretty IRC colors
#	
#	Homura Akemi / https://github.com/homura

use LWP::Simple;
use JSON qw( decode_json );	# for 4chan links
use Math::Round;
use Try::Tiny;

get_4chan_data('https://boards.4chan.org/a/res/105320016');	# Example thread

sub get_4chan_data {
	my $dirty_url = shift;
	my $board;
	my $thread;
	my $reply;
	if ($dirty_url =~ /#p/) {
		$dirty_url =~ m%boards\.4chan\.org/(\w+)/thread/(\d+)[\b#][p]?(\d+)?[\b]?%s;
		$board = $1;
		$thread = $2;
		$reply = $3;
	} else {
		$dirty_url =~ m%boards\.4chan\.org/(\w+)/thread/(\d+)\b?%s;
		$board = $1;
		$thread = $2;
	}
	debug("[  02INFO  ] Looking for thread number $thread");
	if ($reply) {
		debug("[  02INFO  ] Looking for reply number $reply");
	}
	my $ua = LWP::UserAgent->new;
	$ua->timeout(2);
	$ua->env_proxy;
	$ua->max_redirect(0);
	my $maxsize = (1024 * 1024 * 4);
	$ua->max_size($maxsize);
	my $url = 'https://a.4cdn.org/' . $board . '/res/' . $thread . '.json';
	my $response = $ua->head($url);
	if ($response->is_success) {
		debug("[  02INFO  ] " . $response->status_line );
		my $content = $ua->get($url);
		if ($content->is_success) {
			debug("[  02INFO  ] " . $content->status_line );
			try {
				our $decoded_json = decode_json( $content->decoded_content );
				open (dumpfile, ">", "json.log");
				print dumpfile Dumper($decoded_json);
				close dumpfile;
				debug("[  02INFO  ] " . $decoded_json->{posts}[0]->{no});
			};
			my $cocks;
			my $imagcocks;
			my $cocks2;
			my $match;
			if ($reply) { 
				my $replyct = $decoded_json->{posts}[0]->{replies};
				
				for (my $i = 1; $i <= $replyct; $i++) {
					if ($decoded_json->{posts}[$i]->{no} =~ /$reply/) {
						$match = $i;
					}
				}
				my $max_penis_length = (400 - (length(substr($decoded_json->{posts}[$match]->{sub}, 0, 400))));
				$max_penis_length = ($max_penis_length - length($decoded_json->{posts}[$match]->{name}));
				$max_penis_length = ($max_penis_length - length($decoded_json->{posts}[$match]->{trip}));
				$max_penis_length = ($max_penis_length - length($decoded_json->{posts}[$match]->{no}));
				my $babyshitpost = substr(clean_a_shitpost($decoded_json->{posts}[$match]->{com}), 0, $max_penis_length);
				$cocks = "Post " . $reply . " by 03" . substr($decoded_json->{posts}[$match]->{name}, 0, 400) . "03" . $decoded_json->{posts}[$match]->{trip} . " at " . $decoded_json->{posts}[$match]->{now} . " 03» 05" . substr($decoded_json->{posts}[$match]->{sub}, 0, 400) . " " . $babyshitpost;

				if ($decoded_json->{posts}[$match]->{fsize}) {
					$imagcocks .= " 03» Image " . $decoded_json->{posts}[$match]->{filename} . $decoded_json->{posts}[$match]->{ext} . " 03» " . $decoded_json->{posts}[$match]->{w} . "x" . $decoded_json->{posts}[$match]->{h};
					$imagcocks .= " 03» ";
					if ($decoded_json->{posts}[$match]->{fsize} >= 1048576) {
		    			$imagcocks .= nearest( 0.01, $decoded_json->{posts}[$match]->{fsize} / 1048576) . "MB";
				    } elsif ($decoded_json->{posts}[$match]->{fsize} >= 1024) {
				    	$imagcocks .= nearest( 0.1, $decoded_json->{posts}[$match]->{fsize} / 1024) . "KB";
				    } else {
				    	$imagcocks .= $decoded_json->{posts}[$match]->{fsize} . "B";
				    }
				}
				$cocks2 .= "Thread " . $decoded_json->{posts}[0]->{no} . " 03» "; 
			} else {
				my $max_penis_length = (400 - (length(substr($decoded_json->{posts}[0]->{sub}, 0, 400))));
				$max_penis_length = ($max_penis_length - length($decoded_json->{posts}[0]->{name}));
				$max_penis_length = ($max_penis_length - length($decoded_json->{posts}[0]->{trip}));
				$max_penis_length = ($max_penis_length - length($decoded_json->{posts}[0]->{no}));
				my $babyshitpost = substr(clean_a_shitpost($decoded_json->{posts}[0]->{com}), 0, $max_penis_length);
				$cocks = "Thread " . $thread . " by 03" . substr($decoded_json->{posts}[0]->{name}, 0, 400) . "03" . $decoded_json->{posts}[0]->{trip} . " at " . $decoded_json->{posts}[0]->{now} . " 03» 05" . substr($decoded_json->{posts}[0]->{sub}, 0, 400) . " " . $babyshitpost;
				$imagcocks .= " 03» Image " . $decoded_json->{posts}[0]->{filename} . $decoded_json->{posts}[0]->{ext} . " 03» " . $decoded_json->{posts}[0]->{w} . "x" . $decoded_json->{posts}[0]->{h};
				$imagcocks .= " 03» ";
				if ($decoded_json->{posts}[0]->{fsize} >= 1048576) {
	    			$imagcocks .= nearest( 0.01, $decoded_json->{posts}[0]->{fsize} / 1048576) . "MB";
			    } elsif ($decoded_json->{posts}[0]->{fsize} >= 1024) {
			    	$imagcocks .= nearest( 0.1, $decoded_json->{posts}[0]->{fsize} / 1024) . "KB";
			    } else {
			    	$imagcocks .= $decoded_json->{posts}[0]->{fsize} . "B";
			    }

			}
			if ($decoded_json->{posts}[0]->{bumplimit}) {
				$cocks2 .= "05";
			}
			$cocks2 .=	$decoded_json->{posts}[0]->{replies} . " replies 03»";
			if ($decoded_json->{posts}[0]->{images}) {
				if ($decoded_json->{posts}[0]->{imagelimit}) {
					$cocks2 .= " 05" . $decoded_json->{posts}[0]->{images} . " images";
				} else {
					$cocks2 .= " " . $decoded_json->{posts}[0]->{images} . " images";
				}
			}
			if ($decoded_json->{posts}[0]->{sticky}) {
				$cocks2 .= " 03» 09[STICKY]";
			}
			if ($decoded_json->{posts}[0]->{spoiler}) {
				$cocks2 .= " 03» 09[SPOILER IMAGE]";
			}
			if ($decoded_json->{posts}[0]->{closed}) {
				$cocks2 .= " 03» 05[THREAD CLOSED]";
			}
			if ($decoded_json->{posts}[0]->{filedeleted}) {
				$cocks2 .= " 03» 05[FILE DELETED]";
			}
				
			make_chats($cocks);
			make_chats($cocks2 . $imagcocks);
			$decoded_json = 0;
			$content = 0;
			
		}
	} elsif ($response->status_line =~ /404/){
		make_chats("05404 Not Found");
		debug("[ 05FAILED ] " . $response->status_line );
	} elsif ($response->status_line =~ /403/){
		make_chats("05403 Forbidden");
		debug("[ 05FAILED ] " . $response->status_line );
	} elsif ($response->status_line =~ /401/){
		make_chats("05401 Unauthorized");
		debug("[ 05FAILED ] " . $response->status_line );
	} elsif ($response->status_line =~ /500/){
		make_chats("05500 Server shat the bed");
		debug("[ 05FAILED ] " . $response->status_line );
	} elsif ($response->status_line =~ /502/){
		make_chats("05502 Forward proxy shat the bed");
		debug("[ 05FAILED ] " . $response->status_line );
	} else {
		make_chats("[ 05FAILED ] Something went wrong");
	    debug("[ 05FAILED ] " . $response->status_line );
	}
}

sub make_chats{		#	Example output sub
	my $chats = shift;
	print $chats . "\n";
}

sub debug {		#	Example debug sub
	my $chats = shift;
	print $chats . "\n";
}

sub clean_a_shitpost {
	my $shitpost = shift;
	$shitpost =~ s/<br><br>/ 03‖ /g;
	$shitpost =~ s/<br>/ 03| /g;
	$shitpost =~ s/<wbr>//g;
	$shitpost =~ s/&quot;/"/g;
	$shitpost =~ s/&#039;/'/g;
	$shitpost =~ s/&amp;/\&/g;
	$shitpost =~ s/<span class="quote">&gt;/09>/g;
	$shitpost =~ s/<span class="deadlink">/14>/g;
	$shitpost =~ s/<span class="quotelink">/12>/gi;
	$shitpost =~ s/" class="quotelink">&gt;&gt;/12>>/gi;
	$shitpost =~ s/&gt;/>/g;
	$shitpost =~ s/<\/span>//g;
	$shitpost =~ s/<s>/01,01/g;
	$shitpost =~ s/<\/s>//g;
	$shitpost =~ s/<a href="\d+#p\d+//g;
	$shitpost =~ s/<a href="\d+//g;
	$shitpost =~ s/<\/a>//g;
	$shitpost =~ s/<pre class="prettyprint">//g;
	$shitpost =~ s/<\/pre>//g;
	return $shitpost;
}
