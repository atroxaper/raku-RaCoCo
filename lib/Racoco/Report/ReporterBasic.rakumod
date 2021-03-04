unit module Racoco::Report::ReporterBasic;

use Racoco::Paths;
use Racoco::Report::Report;
use Racoco::Report::Reporter;

class ReporterBasic does Reporter is export {
  has Report $.report;

  method make-from-data(:%coverable-lines, :%covered-lines --> Reporter) {
    my @fileReportData
      = self!calc-file-report-data(:%coverable-lines, :%covered-lines);
    self.bless(report => Report.new(:@fileReportData));
  }

  method !calc-file-report-data(
    :%coverable-lines, :%covered-lines --> Positional
  ) {
    %coverable-lines.map(-> $c {
      self!create-file-report-data(
        file-name => $c.key,
        coverable => $c.value.Set,
        covered => (%covered-lines{$c.key} // ()).Set
      )
    }).List
  }

  method !create-file-report-data(:$file-name, :$coverable, :$covered) {
    FileReportData.new(
      :$file-name,
      green => $coverable ∩ $covered,
      red => $coverable ∖ $covered,
      purple => $covered ∖ $coverable
    )
  }

  method write(:$lib --> IO::Path) {
    my $report-basic-path = report-basic-path(:$lib);
    my $serialized-report = self!serialise-report();
    $report-basic-path.spurt: $serialized-report;
    $report-basic-path
  }

  method !serialise-report(--> Str) {
    my $serialized-data = $!report.all-data
      .map({ self!serialise-file-report-data($_) })
      .join("\n");
    $!report.percent ~ "%\n" ~ $serialized-data
  }

  method !serialise-file-report-data(FileReportData $file-report-data --> Str) {
    my @lines;
    @lines.push: $file-report-data.file-name;
    @lines.push: $file-report-data.percent ~ '%';
    @lines.push: 'green ' ~ $file-report-data.green.keys.sort.List;
    @lines.push: 'red ' ~ $file-report-data.red.keys.sort.List;
    @lines.push: 'purple ' ~ $file-report-data.purple.keys.sort.List;
    @lines.map(*.trim).join("\n")
  }
}