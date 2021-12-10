use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::CoveredLinesCollector;
use App::Racoco::RunProc;
use App::Racoco::Paths;
use App::Racoco::Fixture;
use TestResources;
use TestHelper;

plan 1;

my ($lib, $coverage-log, $collector, $*subtest, $*plan);
sub setup($lib-name, :$exec = 'prove6', :$proc, :$append = False, ) {
	plan $*plan;
	TestResources::prepare($*subtest);
	$lib = TestResources::exam-directory.add($lib-name);
  $coverage-log = coverage-log-path(:$lib).IO;
  $collector = CoveredLinesCollector.new(:$exec, :$proc, :$lib);
}

'01-fake-collect'.&test(:1plan, {
	setup('lib', proc => Fixture::fakeProc);
  lives-ok { $collector.collect() }, 'collect lives ok';
});

#do-test {
#  my $collector = CoveredLinesCollector.new(:$exec, :proc(RunProc.new), :$lib);
#  my %coveredLines = $collector.collect();
#  ok $coverage-log.e, 'coverage log exists';
#  is-deeply %coveredLines,
#    %{
#      'Module2.rakumod' => (1, 2).Set,
#      'Module3.rakumod' => (1, 2, 3, 5).Set
#    },
#    'coverage ok';
#};
#
#do-test {
#	my $proc = Fixture::fakeProc;
#  $coverage-log.spurt('');
#  my $collector = CoveredLinesCollector.new(:append, :$exec, :$proc, :$lib);
#  ok $coverage-log.e, 'leave log before test';
#};
#
#do-test {
#	my $proc = Fixture::fakeProc;
#  my $collector = CoveredLinesCollector.new(:$exec, :$proc, :$lib);
#  nok $coverage-log.e, 'delete log before test';
#};
#
#do-test {
#  my $proc = Fixture::fakeProc;
#  my $collector = CoveredLinesCollector.new(:!exec, :$proc, :$lib);
#  $collector.collect();
#  nok $proc.c, 'do not test';
#};
#
#do-test {
#  my $proc = Fixture::failProc;
#  my $collector = CoveredLinesCollector.new(:$exec, :$proc, :$lib);
#  throws-like { $collector.collect() }, App::Racoco::X::NonZeroExitCode,
#    'no zero exitcode';
#};

done-testing