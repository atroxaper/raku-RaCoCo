use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::PrecompFile;
use Racoco::UtilTmpFile;
use Racoco::UtilExtProc;
use Racoco::Sha;
use Racoco::TestExtProc;

plan 3;

constant tmp-file = Racoco::UtilTmpFile;
LEAVE { tmp-file::clean-up }
my $sha = Racoco::Sha::create();

my ($proc, $maker);

sub setUp(:$raku = 'raku', :$fail) {
  $proc = FakeProc.new;
  $proc = FailProc.new if $fail;
  $maker = Maker.new(:lib('libb'.IO), :$raku, :$proc);
}

{
  my $file = 'Module'.IO.add('Module2.rakumod');
  my $output = '.racoco'.IO.absolute.IO.add('.precomp').add('5B')
    .add('5B09525FBA2FACE03A1FCACDEF4904C2194F0307');
  tmp-file::register-dir('.racoco');
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