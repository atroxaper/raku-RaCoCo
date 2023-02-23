unit module App::Racoco::Cli;

use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::Coverable::Precomp::PrecompHashcodeReader;
use App::Racoco::Coverable::Precomp::PrecompLookup;
use App::Racoco::Coverable::Precomp::PrecompSupplier;
use App::Racoco::Coverable::Precomp::Precompiler;
use App::Racoco::CoverableLinesCollector;
use App::Racoco::CoveredLinesCollector;
use App::Racoco::Misc;
use App::Racoco::Paths;
use App::Racoco::Properties;
use App::Racoco::Report::Data;
use App::Racoco::Report::Reporter;
use App::Racoco::RunProc;
use App::Racoco::X;
use App::Racoco::Configuration;

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

sub calculate-report(:$covered-collector, :$coverable-collector) {
  my %covered = $covered-collector.collect();
  my %coverable = $coverable-collector.collect();
  Data.new(:%coverable, :%covered)
}

sub read-report(:$paths) {
  Data.read(:$paths)
}

our sub MAIN(
  Str $config-file-section = '_',
  :$lib is copy = 'lib',
  Str :$raku-bin-dir is copy,
  :$exec is copy,
  Str :$reporter is copy,
  Bool :$silent is copy,
  Bool :$append is copy,
  Int() :$fail-level is copy,
  Str :$properties,
) is export {
	my $root = $*CWD;
	my Configuration $config = ConfigurationFactory
		.args(:$lib, :$raku-bin-dir, :$exec, :$reporter, :$silent, :$append, :$fail-level).or
		.property-line($properties).or
		.env.or
		.ini(configuration-file-content(:$root), section => $config-file-section).or
		.ini(configuration-file-content(:$root), section => '_').or
		.defaults;

	my Paths $paths = make-paths-from(:$config, :$root);

  my $p = Properties.new(:$lib, command-line => $properties, mode => $config-file-section);

  $raku-bin-dir = $config<raku-bin-dir>;
  my $moar = get(:name<moar>, :$raku-bin-dir);
  my $raku = get(:name<raku>, :$raku-bin-dir);

  $exec = $config<exec>;

  my @reporter-classes = $config{ReporterClassesKey.of: 'reporter'};

  $silent = $config{BoolKey.of: 'silent'};

  $append = $config{BoolKey.of: 'append'};

  $fail-level = $config{IntKey.of: 'fail-level'};

  my $report;
  if $exec {
    my $previous-report = $append ?? read-report(:$paths) !! Nil;
    my $proc = RunProc.new;
    my $covered-collector = CoveredLinesCollector.new(
        :$exec, :$paths, :$proc, print-test-log => !$silent, :$append
		);
    my $precomp-supplier = PrecompSupplierReal.new(
        lookup => PrecompLookup.new(:$paths, compiler-id => compiler-id(:$raku, :$proc)),
        precompiler => Precompiler.new(:$paths, :$raku, :$proc)
		);
    my $index = CoverableIndexFile.new(:$paths);
    my $outliner = CoverableOutlinerReal.new(:$proc, :$moar);
    my $hashcode-reader = PrecompHashcodeReaderReal.new;
    my $coverable-supplier = CoverableLinesSupplier.new(
        supplier => $precomp-supplier, :$index, :$outliner, :$hashcode-reader
		);
    my $coverable-collector = CoverableLinesCollector.new(
        supplier => $coverable-supplier, :$paths
		);
    $report = Data.plus(
      calculate-report(:$covered-collector, :$coverable-collector),
      $previous-report
    )
  } else {
    $report = read-report(:$paths);
  }

  print-simple-coverage($report);
  $report.write(:$paths);
  @reporter-classes.map({ $_.new.do(:$paths, data => $report, properties => $p) });
  check-fail-level($fail-level, $report);

  CATCH {
    when App::Racoco::X::NonZeroExitCode {
      exit .exitcode;
    }
  }
}

sub clean-execs-args(@args --> Str) {
  return '' if @args.elems == 0;
  return 'fail' if @args.elems > 1;
  return @args[0] eq '-l' ?? '--exec=prove6 -l'
      !! @args[0] eq '-I' ?? '--exec=prove6 -I.'
      !! @args[0];
}

sub clean-reporters-args(@reporters --> Str) {
  return '' if @reporters.elems == 0;
  my $unique = @reporters.Set;
  my @collect;
  if True ~~ all($unique<--html --color-blind>) {
    push @collect, 'html-color-blind';
  } elsif $unique<--html> {
    push @collect, 'html'
  }
  push @collect, $unique.keys.grep(*.starts-with('--reporter=')).map(*.substr(11)).unique.Slip;
  my $join = @collect.grep(*.chars).sort.join(',');
  return so($join) ?? '--reporter=' ~ $join !! '';
}

our sub ARGS-TO-CAPTURE(&main, @args --> Capture) is export {
  my @new-args;
  my @execs;
  my @reporters;
  for @args -> $_ {
    when '-l' { push @execs, $_ }
    when '-I' { push @execs, $_ }
    when /^'--exec'/ { push @execs, $_ }
    when /^'--/exec'/ { push @execs, $_ }

    when /^'--reporter='/ { push @reporters, $_ }
    when '--html' { push @reporters, $_ }
    when '--color-blind' { push @reporters, $_ }

    default { push @new-args, $_ }
  }
  @new-args = (
    clean-execs-args(@execs),
    clean-reporters-args(@reporters),
    |@new-args
  ).flat.grep(*.chars).Array;
  &*ARGS-TO-CAPTURE(&main, @new-args);
}

our sub GENERATE-USAGE(&main, |c) is export {
  q:to/END/;
	Usage: racoco [options]

	Options:
		configuration-name             name of section in racoco.ini file to use as properties
		--exec=<command-string|false>  command, which needs to be executed to run tests or false to not run tests and use coverage data from the previous run ('prove6' by default)
		-l                             short-cut for --exec='prove6 -l t'
		-I                             short-cut for --exec='prove6 -I.'
		--lib=<path>                   path to directory with target source files ('./lib' by default)
		--raku-bin-dir=<path>          path to directory with raku and moar binaries, which supposed to be used in the --exec ($*EXECUTABLE.parent by default)
		--fail-level=<int>             minimum possible coverage percent for success exit (0 by default)
		--silent                       hide the tests result output (false by default)
		--append                       append the previous run result to the new one (false by default)
		--html                         produce a simple HTML page to visualize results
		--color-blind                  use with --html option to make more readable colors than green/red pare
		--reporter=<reporter-name>     name of a custom result reporter
		--properties                   pass custom properties here if you know what you do
	END
}