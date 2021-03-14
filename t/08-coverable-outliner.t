use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::RunProc;
use App::Racoco::Paths;
use App::Racoco::Fixture;

plan 2;

my $proc = RunProc.new;
my $path = lib-precomp-path(lib => Fixture::root-folder().add('lib'))
  .add('7011F868022706D0DB123C03898593E0AB8D8AF3')
  .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');

my $outliner = CoverableOutlinerReal.new(:moar<moar>, :$proc);
if !$*DISTRO.is-win {
	is $outliner.outline(:$path), (1, 2), 'coverable outline ok';
} else {
	skip "Can't use moar --dump in tests on Windows", 1;
}

{
  Fixture::suppressErr;
  LEAVE { Fixture::restoreErr }
  is CoverableOutlinerReal.new(:moar<moar>, :proc(Fixture::failProc)).outline(:$path), (),
    'fail moar proc';
}

done-testing