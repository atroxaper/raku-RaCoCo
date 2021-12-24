use App::Racoco::Report::ReporterCoveralls::Transport;
use HTTP::Tiny;

unit class App::Racoco::Report::ReporterCoveralls::TransportTinyHTTP
	does Transport
	is export;

has $.host is built(False) = 'coveralls.io';

method send(Str:D $obj, :$uri --> Bool) {
say 'try to send';
say $obj;
say 'to';
say $uri // self.uri();
	my $response = HTTP::Tiny.new.post:
		($uri // self.uri()),
		content => $obj,
		headers => %(content-type => 'application/json');
say $response;
	fail $response<status> unless $response<success>;
	True
}