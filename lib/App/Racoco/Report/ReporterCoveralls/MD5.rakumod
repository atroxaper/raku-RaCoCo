use Digest::MD5;
unit class App::Racoco::Report::ReportCoveralls::MD5
	is export;

has $!md5 = Digest::MD5.new;

method md5(Str $content --> Str) {
	$!md5.md5_hex($content)
}