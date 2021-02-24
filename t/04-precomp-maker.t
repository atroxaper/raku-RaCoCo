use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::PrecompFile;
use Racoco::UtilTmpFile;
use Racoco::UtilExtProc;
use Racoco::Sha;
use Racoco::Fixture;
use Racoco::Constants;

plan 3;

constant tmp-file = Racoco::UtilTmpFile;
LEAVE { tmp-file::clean-up }
my $sha = Racoco::Sha::create();

my ($proc, $maker);

my $root = tmp-file::register-dir($*TMPDIR.add('maker'));

sub setUp(:$raku = 'raku', :$fail) {
  $proc = Fixture::fakeProc;
  $proc = Fixture::failProc if $fail;
  $maker = Maker.new(:lib($root.add('libb')), :$raku, :$proc);
}

{
  my $file = 'Module'.IO.add('Module2.rakumod');
  my $output = $root.add($DOT-RACOCO).add($DOT-PRECOMP).add('5B')
    .add('5B09525FBA2FACE03A1FCACDEF4904C2194F0307');
  setUp();
  is $maker.compile($file.Str), $output, 'precomp ok';
  is $proc.c,
    \('raku', '-Ilibb', '--target=mbc', "--output=$output", $file.Str),
    'precomp';
}

{
  setUp(:fail);
  nok $maker.compile('file').defined, 'precomp nok';
}

done-testing