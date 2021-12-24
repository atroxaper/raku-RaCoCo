use App::Racoco::ConfigFile;
use App::Racoco::Paths;
unit class App::Racoco::Properties is export;

has $!command-line is built;
has $!config-file is built;
has $!config-file-mode is built;

method new(:$lib!, :$command-line, :$mode = '_') {
	my $config-file-content = '';
	given config-file(:$lib) {
		$config-file-content = .slurp if .e;
	}
	self.bless(
		command-line => self.parse-command-line($command-line),
		config-file => ConfigFile::parse($config-file-content ~ "\n"),
		config-file-mode => $mode,
	)
}

method env-only($key) {
	%*ENV{$key}
}

method property($key) {
	$!command-line{$key} //
	self.env-only($key) //
	$!config-file{$!config-file-mode}{$key} //
	$!config-file<_>{$key} //
	Nil;
}

method parse-command-line(::?CLASS:U: $command-line --> Associative) {
	return %() without $command-line;
	$command-line.trim.split(';', :skip-empty).map({.[0].trim => .[1].trim with .split(':', :skip-empty)}).Map;
}