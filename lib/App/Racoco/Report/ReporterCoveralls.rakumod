use App::Racoco::Report::Reporter;
use App::Racoco::Report::DataPart;
use App::Racoco::Report::Data;
use App::Racoco::Report::ReporterCoveralls::MD5;
use App::Racoco::Report::ReporterCoveralls::Factory;

unit class App::Racoco::Report::ReporterCoveralls does Reporter is export;

has MD5 $!md5 = Factory::create-md5();

method do(IO::Path:D :$lib, Data:D :$data) {
	# 1 collect all configurations
	# 2 collect data to send
	# 3 send
}

method make-source-files-json(:$lib, :$data) {
	$data.get-all-parts.map(-> $part {
		my $path = $lib.add($part.file-name);
		my $content = $path.slurp;
		self.coverage-line($lib, $content, $part)
	}).join(",\n");
}

method coverage-line($lib, $content, $part) {
	my $lib-name = $lib.basename;
	my $lines = $content.lines.elems;
	my $name = q/"name":"/ ~ $lib-name ~ '/' ~ $part.file-name ~ '",';
	my $source-digest = q/"source_digest":"/ ~ $!md5.md5($content) ~ '",';
	my $coverage = q/"coverage":[/ ~
		(1..$lines).map(-> $line { $part.hit-times-of(:$line) // 'null' }).join(',') ~ ']';
	join "\n", '{', $name, $source-digest, $coverage, '}';
}