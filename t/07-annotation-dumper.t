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
my $file = 't'.IO.add('resources').add('root-folder').add('lib')
  .add('Module3.rakumod');
my $tmp-dir = tmp-file::create-dir($*TMPDIR.add('dumper'));
my $tmp-lib = tmp-file::create-dir($tmp-dir.add('lib'));
my $maker = Maker.new(:lib($tmp-lib), :raku<raku>, :$proc);
my $out = $maker.compile($file);

my $dumper = DumperReal.new(:moar<moar>, :$proc);
is $dumper.get($out), (1, 2, 3), 'annotation dumper ok';

{
  my $err = $*ERR;
  LEAVE { $*ERR = $err; }
  $*ERR = Fixture::devNullHandle;
  is DumperReal.new(:moar<not-exists>, :$proc).get($file), (), 'bad moar';
}

done-testing