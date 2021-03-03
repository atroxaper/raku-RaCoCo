use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Coverable::CoverableOutliner;
use Racoco::RunProc;
use Racoco::Paths;
use Racoco::Fixture;

plan 2;

my $proc = RunProc.new;
my $path = lib-precomp-path(lib => Fixture::root-folder().add('lib'))
  .add('7011F868022706D0DB123C03898593E0AB8D8AF3')
  .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');

my $outliner = CoverableOutlinerReal.new(:moar<moar>, :$proc);
is $outliner.outline(:$path), (1, 2), 'coverable outline ok';

{
  Fixture::suppressErr;
  LEAVE { Fixture::restoreErr }
  is CoverableOutlinerReal.new(:moar<moar>, :proc(Fixture::failProc)).outline(:$path), (),
    'fail moar proc';
}

done-testing