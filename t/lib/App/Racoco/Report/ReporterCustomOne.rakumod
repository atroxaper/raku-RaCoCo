use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterCustomOne does Reporter is export;

method do(:$paths, :$data, :$config) {
	say "CustomOne: {$data.percent}%";
}