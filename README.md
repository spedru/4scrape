4scrape
=======

Downloads files from a 4chan thread until 404.

4scrape.pl takes one argument, the thread URL.  It will always use HTTPS, regardless of whether you use it in the URL.

Dependencies:
- wget in system path
- Perl modules LWP::Simple, JSON, Try::Tiny

Linux users will probably have to edit a few things to get it working.
