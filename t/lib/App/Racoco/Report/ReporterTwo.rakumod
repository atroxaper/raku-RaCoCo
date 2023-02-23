use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterTwo does Reporter is export;

method do(:$paths, :$data, :$properties) {
	say "Done";
}