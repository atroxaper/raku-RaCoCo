unit module Racoco::Cli;

use Racoco::RunProc;
use Racoco::Precomp::PrecompSupplier;
use Racoco::Precomp::PrecompHashcodeReader;
use Racoco::Coverable::CoverableIndex;
use Racoco::Coverable::CoverableOutliner;
use Racoco::Coverable::CoverableLinesSupplier;
use Racoco::CoverableLinesCollector;
use Racoco::CoveredLinesCollector;
use Racoco::Report::Report;
use Racoco::Report::ReporterHtml;
use Racoco::Report::ReporterBasic;
use Racoco::X;

my %config =
  lib => 'lib',
  raku-bin-dir => $*EXECUTABLE.parent.Str,
  exec => 'prove6',
  reporter => ReporterBasic;

multi sub get(:$lib) {
  my $result = ($lib // %config<lib>);
  return $result.IO if $result.IO ~~ :e & :d;
  Racoco::X::WrongLibPath.new(path => $result).throw
}

multi sub get(:$exec) {
  $exec // %config<exec>
}

multi sub get(:$raku-bin-dir, :$name) {
  my $result = ($raku-bin-dir // %config<raku-bin-dir>);
  unless $result.IO ~~ :e & :d {
    Racoco::X::WrongRakuBinDirPath.new(path => $result).throw
  }
  my $moar = $result.IO.add($name);
  unless $moar.e {
    Racoco::X::WrongRakuBinDirPath.new(path => $result).throw
  }
  $moar.Str
}

multi sub get(:$reporter, :$html) {
  return ReporterHtml if $html;
  return ReporterBasic;
}

sub print-simple-coverage(Report $report) {
  say "Coverage: {$report.percent}%"
}

our sub MAIN(:lib($lib-dir), :$raku-bin-dir, :exec($exec-command), :$html) is export {
  my $lib = get(lib => $lib-dir);
  my $moar = get(:name<moar>, :$raku-bin-dir);
  my $raku = get(:name<raku>, :$raku-bin-dir);
  my $exec = get(exec => $exec-command);
  my $reporter-class = get(:reporter, :$html);

  my $proc = RunProc.new;
  my $covered-collector = CoveredLinesCollector.new(:$exec, :$lib, :$proc);
  my $precomp-supplier = PrecompSupplierReal.new(:$proc, :$lib, :$raku);
  my $index = CoverableIndexFile.new(:$lib);
  my $outliner = CoverableOutlinerReal.new(:$proc, :$moar);
  my $hashcode-reader = PrecompHashcodeReaderReal.new;
  my $coverable-supplier = CoverableLinesSupplier.new(
    supplier => $precomp-supplier, :$index, :$outliner, :$hashcode-reader);
  my $coverable-collector = CoverableLinesCollector.new(
    supplier => $coverable-supplier, :$lib);

  my %covered-lines = $covered-collector.collect();
  my %coverable-lines = $coverable-collector.collect();
  my $reporter = $reporter-class.make-from-data(:%coverable-lines, :%covered-lines);
  $reporter.write(:$lib);
  print-simple-coverage($reporter.report);
}