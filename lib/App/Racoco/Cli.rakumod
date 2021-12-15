unit module App::Racoco::Cli;

use App::Racoco::RunProc;
use App::Racoco::Precomp::PrecompSupplier;
use App::Racoco::Precomp::PrecompHashcodeReader;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::CoverableLinesCollector;
use App::Racoco::Precomp::PrecompLookup;
use App::Racoco::Precomp::Precompiler;
use App::Racoco::CoveredLinesCollector;
use App::Racoco::Report::Reporter;
use App::Racoco::Report::Data;
use App::Racoco::Paths;
use App::Racoco::Misc;
use App::Racoco::X;

multi sub get(:$lib) {
  return $lib.IO.absolute.IO if $lib.IO ~~ :e & :d;
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

sub print-simple-coverage(Data $report) {
  say "Coverage: {$report.percent}%"
}

sub check-fail-level(Int $fail-level, Data $report) {
  if $report.percent < $fail-level {
    exit max(1, ($fail-level - $report.percent).Int);
  }
}

subset BoolOrStr where Bool | Str;

sub calculate-report(:$covered-collector, :$coverable-collector) {
  my %covered = $covered-collector.collect();
  my %coverable = $coverable-collector.collect();
  Data.new(:%coverable, :%covered)
}

sub read-report(:$lib) {
  Data.read(:$lib)
}

sub reporter-classes($reporter, :$html, :$color-blind) {
  my @result;
  my @reporter = ($reporter // '').split(',').grep(*.chars).Array;
  if $color-blind && $html {
    @reporter.push: 'html-color-blind' if $html;
  } elsif $html {
    @reporter.push: 'html' if $html;
  }

  for @reporter -> $r-name {
    my $r-compunit-name = Reporter.^name ~ $r-name.split('-').map(*.tc).join('');
    try require ::($r-compunit-name);
    my $require = ::($r-compunit-name);
    if $require ~~ Failure {
      $require.so;
      note "Cannot use $r-compunit-name package as reporter.";
      next;
    }
    @result.push: $r-compunit-name;
  }
  @result
}

sub fix-compunit-deprecation-message() {
  note "--fix-compunit no longer makes sense and is deprecated";
}

our sub MAIN(
  Str :lib($lib-dir) = 'lib',
  Str :$raku-bin-dir,
  BoolOrStr :$exec = 'prove6',
  Str :$reporter,
  Bool :$html = False,
  Bool :$color-blind = False,
  Bool :$silent = False,
  Bool :$append = False,
  Int() :$fail-level = 0,
  Bool :$fix-compunit
) is export {
  fix-compunit-deprecation-message() if $fix-compunit.DEFINITE;

  my $lib = get(lib => $lib-dir);
  my $moar = get(:name<moar>, :$raku-bin-dir);
  my $raku = get(:name<raku>, :$raku-bin-dir);
  my @reporter-classes = reporter-classes($reporter, :$html, :$color-blind);

  my $proc = RunProc.new;
  my $covered-collector = CoveredLinesCollector.new(
      :$exec, :$lib, :$proc, print-test-log => !$silent, :$append);
  my $precomp-supplier = PrecompSupplierReal.new(
    lookup => PrecompLookup.new(:$lib, compiler-id => compiler-id(:$raku, :$proc)),
		precompiler => Precompiler.new(:$lib, :$raku, :$proc)
  );
  my $index = CoverableIndexFile.new(:$lib);
  my $outliner = CoverableOutlinerReal.new(:$proc, :$moar);
  my $hashcode-reader = PrecompHashcodeReaderReal.new;
  my $coverable-supplier = CoverableLinesSupplier.new(
      supplier => $precomp-supplier, :$index, :$outliner, :$hashcode-reader);
  my $coverable-collector = CoverableLinesCollector.new(
      supplier => $coverable-supplier, :$lib);

  my $report = $exec === False
      ?? read-report(:$lib)
      !! calculate-report(:$covered-collector, :$coverable-collector);

  print-simple-coverage($report);
  $report.write(:$lib);
  @reporter-classes.map({ ::($_).new.do(:$lib, data => $report) });
  check-fail-level($fail-level, $report);

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
		--exec=<command-string|false>  command, which need to be executed to run tests or false to not run tests and use coverage data from the previous run
		--raku-bin-dir=<path>          path to directory with raku and moar binaries, which supposed to be used in the --exec
		--fail-level=<int>             minimum possible coverage percent for success exit
		--silent                       hide test result output
		--append                       do not clean coverage data before run tests and append its result to the previous one
		--html                         produce simple html page to visualize results
		--color-blind                  use more readable colors than green/red pare
	END
}