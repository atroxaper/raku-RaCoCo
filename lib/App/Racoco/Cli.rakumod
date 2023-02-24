unit module App::Racoco::Cli;

use App::Racoco;
use App::Racoco::X;
use App::Racoco::Configuration;

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

	my $below-fail-level = App::Racoco.new(:$root, :$config)
		.calculate-coverage
		.do-report
		.how-below-fail-level;
	if $below-fail-level > 0 {
		exit $below-fail-level;
	}

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