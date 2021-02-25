use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::PrecompFile;
use Racoco::UtilExtProc;
use Racoco::Sha;
use Racoco::Fixture;
use Racoco::Constants;

plan 5;

my $original-dir = '.'.IO.absolute.IO;
END {
  &*chdir($original-dir);
  Fixture::restore-root-folder
}
my $source = 't-resources'.IO.add('root-folder');
&*chdir($source);

my $sha = Racoco::Sha::create();
my ($proc, $maker);

my $lib = 'lib'.IO;
my $dot-precomp = $DOT-RACOCO.IO.add($DOT-PRECOMP);

sub setUp(:$raku = 'raku', :$fail, :$real) {
  $proc = Fixture::fakeProc;
  $proc = Fixture::failProc if $fail;
  $proc = RunProc.new if $real;
  $maker = Maker.new(:$lib, :$raku, :$proc);
}

{
  setUp();
  my $file = 'Module'.IO.add('Module2.rakumod');
  my $arg = 'lib'.IO.add('Module').add('Module2.rakumod');
  my $output = $dot-precomp
    .add('77').add('770D15B487025165F9B99486A04A6E11285C6416');
  is $maker.compile($file), $output, 'fake precomp ok';
  is $proc.c, \("raku -Ilib --target=mbc --output=$output $arg", :!out),
    'fake run ok';
}

{
  setUp(:fail);
  nok $maker.compile('file').defined, 'fail precomp ok';
}

{
  setUp(:real);
  my $file = 'Module3.rakumod'.IO;
  my $output = $dot-precomp
    .add('5F').add('5FB62D3D27EB6AAE0FD30F0E99F9EB7D3907F2F8');
  is $maker.compile($file), $output, 'precomp ok';
  ok $output.e, 'precomp exists';
}

done-testing