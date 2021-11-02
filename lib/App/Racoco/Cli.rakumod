unit module App::Racoco::Cli;

use App::Racoco::RunProc;
use App::Racoco::Precomp::PrecompSupplier;
use App::Racoco::Precomp::PrecompHashcodeReader;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::CoverableLinesCollector;
use App::Racoco::CoveredLinesCollector;
use App::Racoco::Report::Report;
use App::Racoco::Report::ReporterHtml;
use App::Racoco::Report::ReporterBasic;
use App::Racoco::Paths;
use App::Racoco::X;

multi sub get(:$lib) {
  return $lib.IO if $lib.IO ~~ :e & :d;
  App::Racoco::X::WrongLibPath.new(path => $lib).throw
}

multi sub get(:$raku-bin-dir, :$name) {
  my $result = ($raku-bin-dir // $*EXECUTABLE.parent.Str);
  unless $result.IO ~~ :e & :d {
    App::Racoco::X::WrongRakuBinDirPath.new(path => $result).throw
  }
  my $app = $result.IO.add($name ~ ($*DISTRO.is-win ?? '.exe' !! ''));
  unless $app.e {
    App::Racoco::X::WrongRakuBinDirPath.new(path => $result).throw
  }
  $app.Str
}

multi sub get(:$reporter, :$html) {
  return ReporterHtml if $html;
  return ReporterBasic;
}

sub print-simple-coverage(Report $report) {
  say "Coverage: {$report.percent}%"
}

sub check-fail-level(Int $fail-level, Report $report) {
  if $report.percent < $fail-level {
    exit max(1, ($fail-level - $report.percent).Int);
  }
}

subset BoolOrStr where Bool | Str;

sub calculate-reporter(:$covered-collector, :$coverable-collector, :$reporter-class) {
  my %covered-lines = $covered-collector.collect();
  my %coverable-lines = $coverable-collector.collect();
  $reporter-class.make-from-data(:%coverable-lines, :%covered-lines)
}

sub read-reporter(:$reporter-class, :$lib) {
  $reporter-class.read(:$lib)
}

sub rmdir($path, :$rm-path) {
  return unless $path ~~ :d & :e;
  for $path.dir() -> $sub-path {
    rmdir($sub-path, :rm-path) if $sub-path.d;
    $sub-path.unlink;
  }
  $path.rmdir if $rm-path;
}

sub rm-precomp(:$lib) {
  my $path = lib-precomp-path(:$lib);
  rmdir($path, :!rm-path) if $path.e;
}

sub check-ambiguous-precomp(:$lib) {
  my $path = lib-precomp-path(:$lib);
  if $path.e and $path.dir().grep(*.d).elems > 1 {
    App::Racoco::X::AmbiguousPrecompContent.new(:$path).throw
  }
}

our sub MAIN(
  Str :lib($lib-dir) = 'lib',
  Str :$raku-bin-dir,
  BoolOrStr :exec($exec-command) = 'prove6',
  Bool :$html = False,
  Bool :$color-blind = False,
  Bool :$silent = False,
  Bool :$append = False,
  Int() :$fail-level = 0,
  Bool :$fix-compunit = False
) is export {
  my $lib = get(lib => $lib-dir);
  my $moar = get(:name<moar>, :$raku-bin-dir);
  my $raku = get(:name<raku>, :$raku-bin-dir);
  my $exec = $exec-command;
  my $reporter-class = get(:reporter, :$html);

  rm-precomp(:$lib) if $fix-compunit;
  check-ambiguous-precomp(:$lib);

  my $proc = RunProc.new;
  my $covered-collector = CoveredLinesCollector.new(
    :$exec, :$lib, :$proc, print-test-log => !$silent, :$append);
  my $precomp-supplier = PrecompSupplierReal.new(:$proc, :$lib, :$raku);
  my $index = CoverableIndexFile.new(:$lib);
  my $outliner = CoverableOutlinerReal.new(:$proc, :$moar);
  my $hashcode-reader = PrecompHashcodeReaderReal.new;
  my $coverable-supplier = CoverableLinesSupplier.new(
    supplier => $precomp-supplier, :$index, :$outliner, :$hashcode-reader);
  my $coverable-collector = CoverableLinesCollector.new(
    supplier => $coverable-supplier, :$lib);

  my $reporter = $exec === False
    ?? read-reporter(:$reporter-class, :$lib)
    !! calculate-reporter(:$covered-collector, :$coverable-collector, :$reporter-class);
  $reporter.color-blind = $color-blind if $html;
  $reporter.write(:$lib);
  print-simple-coverage($reporter.report);
  check-fail-level($fail-level, $reporter.report);

  CATCH {
    when App::Racoco::X::NonZeroExitCode {
      exit .exitcode;
    }
  }
}

sub USAGE() is export {
  print q:to/END/;
	Usage: racoco [options]

	Options:
		--lib=<path>                   path to directory with coverable source files
		--raku-bin-dir=<path>          path to directory with raku and moar binaries
		--exec=<command-string|false>  command, which need to be executed to run tests or false to not run tests and use coverage data from the previous run
		--fail-level=<int>             minimum possible coverage percent for success exit
		--silent                       hide test result output
		--append                       do not clean coverage data before run tests and append its result to the previous one
		--html                         produce simple html page to visualize results
		--color-blind                  use more readable colors than green/red pare
		--fix-compunit                 erase <library>/.precomp directory before run tests
	END
}