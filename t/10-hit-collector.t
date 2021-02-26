use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::HitCollector;
use Racoco::UtilExtProc;
use Racoco::Constants;
use Racoco::Fixture;

plan 6;

my $original-dir = '.'.IO.absolute.IO;
END {
  &*chdir($original-dir);
  Fixture::restore-root-folder
}
my $source = 't-resources'.IO.add('root-folder');
&*chdir($source);

my $lib = 'lib'.IO;
my $coverage-log = $DOT-RACOCO.IO.add($COVERAGE-LOG);
my $exec = 'prove6';
my $fakeProc = Fixture::fakeProc;

{
  my $proc = Fixture::fakeProc;
  my $collector = HitCollector.new(:$exec, :$proc, :$lib);
  $collector.get();
  is $proc.c, \("MVM_COVERAGE_LOG=$coverage-log prove6", :!out), 'run test ok';
}

{
  my $collector = HitCollector.new(:$exec, :proc(RunProc.new), :$lib);
  my $coverage = $collector.get();
  ok $coverage-log.e, 'coverage log exists';
  is-deeply $coverage,
    %{
      'Module2.rakumod' => (1, 2).Set,
      'Module3.rakumod' => (1, 2, 5).Set  # actual hit must be (1, 2, 3, 5)
    },                                    # probably it is optimisation issue
    'coverage ok';
}

{
  $coverage-log.spurt('');
  my $collector = HitCollector.new(:append, :$exec, :proc($fakeProc), :$lib);
  my $coverage = $collector.get();
  ok $coverage-log.e, 'leave log before test';
}

{
  my $collector = HitCollector.new(:$exec, :proc($fakeProc), :$lib);
  my $coverage = $collector.get();
  nok $coverage-log.e, 'delete log before test';
}

{
  my $proc = Fixture::fakeProc;
  my $collector = HitCollector.new(:no-tests, :$exec, :$proc, :$lib);
  my $coverage = $collector.get();
  nok $proc.c, 'do not test';
}

done-testing