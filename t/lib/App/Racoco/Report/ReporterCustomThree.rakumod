use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterCustomThree does Reporter is export;

method do(:$paths, :$data, :$config) {
	say 'CustomThree: ' ~ $config<command-line>;
}