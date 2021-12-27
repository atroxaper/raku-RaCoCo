use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterTwo does Reporter is export;

method do(:$lib, :$data, :$properties) {
	say "Done";
}