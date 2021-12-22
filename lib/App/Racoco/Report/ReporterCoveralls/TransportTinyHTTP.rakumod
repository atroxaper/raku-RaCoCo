use App::Racoco::Report::ReporterCoveralls::Transport;
unit class App::Racoco::Report::ReporterCoveralls::TransportTinyHTTP
	does Transport
	is export;

	has $.host is built(False) = 'coveralls.io';

