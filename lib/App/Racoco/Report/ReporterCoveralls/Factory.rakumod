use App::Racoco::Report::ReporterCoveralls::MD5;
use App::Racoco::Report::ReporterCoveralls::MD5Digest;
use App::Racoco::Report::ReporterCoveralls::Transport;
use App::Racoco::Report::ReporterCoveralls::TransportTinyHTTP;
unit module App::Racoco::Report::ReporterCoveralls::Factory is export;

my $*create-md5;
our sub create-md5(--> MD5) {
	$*create-md5 // MD5Digest.new
}

my $*create-transport;
our sub create-transport(--> Transport) {
	$*create-transport // TransportTinyHTTP.new
}