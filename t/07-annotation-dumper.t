use Test;
use lib 'lib';
use Racoco::PrecompFile;
use Racoco::Annotation;
use Racoco::UtilExtProc;
use Racoco::Paths;
use lib 't/lib';
use Racoco::Fixture;

plan 2;

my $proc = RunProc.new;
my $file = lib-precomp-path(lib => Fixture::root-folder().add('lib'))
  .add('7011F868022706D0DB123C03898593E0AB8D8AF3')
  .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');

my $dumper = DumperReal.new(:moar<moar>, :$proc);
is $dumper.get($file), (1, 2), 'annotation dumper ok';

{
  my $err = $*ERR;
  LEAVE { $*ERR = $err; }
  $*ERR = Fixture::devNullHandle;
  is DumperReal.new(:moar<moar>, :proc(Fixture::failProc)).get($file), (),
    'fail moar proc';
}

done-testing