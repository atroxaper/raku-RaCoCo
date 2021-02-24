use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::PrecompFile;
use Racoco::Fixture;
use Racoco::Constants;
use Racoco::UtilTmpFile;

plan 3;

constant tmp-file = Racoco::UtilTmpFile;
LEAVE { tmp-file::clean-up }

my $source = 't'.IO.absolute.IO.add('resources').add('root-folder');
my $lib = $source.add('lib1');
my $raku = 'raku';
my $proc = Fixture::fakeProc;
my $module1-path = $source.add('lib1').add($DOT-PRECOMP)
  .add('7011F868022706D0DB123C03898593E0AB8D8AF3').add('B8')
  .add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');
my $module2-path = $source.add($DOT-RACOCO).add($OUR-PRECOMP).add('C4')
  .add('C42D08C62F336741E9DBBDC10EFA8A4673AA820F');
my $module3-path = $source.add($DOT-RACOCO).add($OUR-PRECOMP).add('5F')
  .add('5FB62D3D27EB6AAE0FD30F0E99F9EB7D3907F2F8');
tmp-file::register-dir($module3-path.parent);
my $provider = Provider.new(:$lib, :$raku, :$proc);

is $provider.get('Module.rakumod'), $module1-path, 'precomp ok';
is $provider.get('Module2.rakumod'), $module2-path, 'our precomp ok';
is $provider.get('Module3.rakumod'), $module3-path, 'made ok';

done-testing