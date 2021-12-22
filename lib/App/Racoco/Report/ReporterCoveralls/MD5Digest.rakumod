use App::Racoco::Report::ReporterCoveralls::MD5;
use Digest::MD5;

unit class App::Racoco::Report::ReporterCoveralls::MD5Digest
	does MD5
	is export;

has $!md5 = Digest::MD5.new;

method md5(Str $content --> Str) {
	$!md5.md5_hex($content)
}
