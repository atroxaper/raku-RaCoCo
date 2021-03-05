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

  method write(IO::Path :$lib --> IO::Path) {
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

  method read(IO::Path :$lib --> Reporter) {
    my $report-basic-path = report-basic-path(:$lib);
    return Nil unless $report-basic-path.e;

    my @fileReportData;
    my @lines = $report-basic-path.lines;
    loop (my $i = 1; $i < @lines.elems; $i+=5) {
      @fileReportData.push: self!read-report-data(@lines, $i);
    }
    self.bless(report => Report.new(:@fileReportData));
  }

  method !read-report-data(@lines, $i --> FileReportData) {
    FileReportData.new(
      file-name => @lines[$i],
      green => self!read-color(@lines, $i + 2),
      red => self!read-color(@lines, $i + 3),
      purple => self!read-color(@lines, $i + 4),
    )
  }

  method !read-color(@lines, $i --> Set) {
    @lines[$i].split(' ').[1..^*].map(*.Int).Set
  }
}