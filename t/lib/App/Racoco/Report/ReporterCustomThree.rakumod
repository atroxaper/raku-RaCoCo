use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterCustomThree does Reporter is export;

method do(:$lib, :$data, :$properties) {
	say "CustomThree: {$properties.property('command-line')}";
}