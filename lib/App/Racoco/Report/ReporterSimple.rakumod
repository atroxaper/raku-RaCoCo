use App::Racoco::Report::Reporter;

unit class App::Racoco::Report::ReporterSimple does Reporter is export;

method do(:$paths, :$data, :$config) {
  say "Coverage: {$data.percent}%"
}