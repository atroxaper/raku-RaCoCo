use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterCustomOne does Reporter is export;

method do(:$lib, :$data) {
	say "CustomOne: {$data.percent}%";
}