use App::Racoco::Report::ReporterCoveralls::MD5;
use App::Racoco::Report::ReporterCoveralls::Transport;

unit module Mocks;

class MD5Mock is MD5 {
	method md5(Str $content --> Str) {
		"｢{$content.trim.substr(^11)}...｣"
	}
}

class TransportMock does Transport {
	has $.host = 'my-host';
	has $.sended;

	method send(Str:D $obj, :$uri --> Bool) {
		$!sended = $obj;
		True
	}
}