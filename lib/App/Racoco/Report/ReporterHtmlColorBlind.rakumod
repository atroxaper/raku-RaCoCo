use App::Racoco::Report::Reporter;
use App::Racoco::Report::ReporterHtml;

unit class App::Racoco::Report::ReporterHtmlColorBlind does Reporter is export;

has ReporterHtml $!reporter;

submethod TWEAK() {
  $!reporter = ReporterHtml.new;
  $!reporter.color-blind = True;
}

method do(:$lib, :$data, :$properties) {
  $!reporter.do(:$lib, :$data);
}