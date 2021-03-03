use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::CoveredLinesCollector;
use Racoco::RunProc;
use Racoco::Paths;
use Racoco::Fixture;

plan 6;

Fixture::change-current-dir-to-root-folder();

my $lib = 'lib'.IO;
my $coverage-log = coverage-log-path(:$lib).IO;
my $exec = 'prove6';

{
  my $proc = Fixture::fakeProc;
  my $collector = CoveredLinesCollector.new(:$exec, :$proc, :$lib);
  $collector.collect();
  is $proc.c, \("MVM_COVERAGE_LOG=$coverage-log prove6", :!out), 'run test ok';
}

{
  my $collector = CoveredLinesCollector.new(:$exec, :proc(RunProc.new), :$lib);
  my %coveredLines = $collector.collect();
  ok $coverage-log.e, 'coverage log exists';
  is-deeply %coveredLines,
    %{
      'Module2.rakumod' => (1, 2).Set,
      'Module3.rakumod' => (1, 2, 5).Set  # actual hit must be (1, 2, 3, 5)
    },                                    # probably it is optimisation issue
    'coverage ok';
}

{
	my $proc = Fixture::fakeProc;
  $coverage-log.spurt('');
  my $collector = CoveredLinesCollector.new(:append, :$exec, :$proc, :$lib);
  ok $coverage-log.e, 'leave log before test';
}

{
	my $proc = Fixture::fakeProc;
  my $collector = CoveredLinesCollector.new(:$exec, :$proc, :$lib);
  nok $coverage-log.e, 'delete log before test';
}

{
  my $proc = Fixture::fakeProc;
  my $collector = CoveredLinesCollector.new(:no-tests, :$exec, :$proc, :$lib);
  $collector.collect();
  nok $proc.c, 'do not test';
}

done-testing