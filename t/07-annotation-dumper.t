use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::PrecompFile;
use Racoco::Annotation;
use Racoco::UtilExtProc;
use Racoco::UtilTmpFile;
use Racoco::Fixture;

plan 2;

constant tmp-file = Racoco::UtilTmpFile;
LEAVE { tmp-file::clean-up }

my $proc = RunProc.new;
my $file = 't'.IO.add('resources').add('root-folder').add('lib1')
  .add('Module3.rakumod');
my $tmp-dir = tmp-file::create-dir($*TMPDIR.add('dumper'));
my $tmp-lib = tmp-file::create-dir($tmp-dir.add('lib'));
my $maker = Maker.new(:lib($tmp-lib), :raku<raku>, :$proc);
my $out = $maker.compile($file);

my $dumper = Dumper.new(:moar<moar>, :$proc);
is $dumper.dump($out), (1, 2, 3), 'annotation dumper ok';

{
  my $err = $*ERR;
  LEAVE { $*ERR = $err; }
  $*ERR = Fixture::devNullHandle;
  nok Dumper.new(:moar<not-exists>, :$proc).dump($file), 'bad moar';
}

done-testing