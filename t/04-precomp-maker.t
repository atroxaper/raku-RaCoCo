use Test;
use lib 'lib';

use Racoco::PrecompFileFind;
use Racoco::UtilTmpFile;
use Racoco::UtilExtProc;
use Racoco::Sha;

plan 5;

constant tmp-file = Racoco::UtilTmpFile;
LEAVE { tmp-file::clean-up }
my $sha = Racoco::Sha::create();

my $proc;
my $maker;
class FakeProc does ExtProc {
  has $.c;
  method run(|c) {
    $!c = c;
    return class :: { method exitcode { 0 } }
  }
}

class FailProc does ExtProc {
  method run(|c) { return class :: { method exitcode { 1 } } }
}

sub setUp(:$precomp-path, :$raku, :$fail) {
  $proc = FakeProc.new;
  $proc = FailProc.new if $fail;
  $maker = Maker.new(|(:$proc, :$precomp-path, :$raku)\
      .grep(*.value.defined).Map)
}

{
  my $file = 'module'.IO.add('module2.rakumod');
  my $output = '.racoco'.IO.add('.precomp').add($sha.uc($file));
  tmp-file::register-dir('.racoco');
  setUp();
  is $maker.compile('libb', $file.Str), $output, 'defalut precomp ok';
  is $proc.c,
    \('raku', '-Ilibb', '--target=mbc', "--output=$output", $file.Str),
    'default precomp';
}

{
  setUp(:fail);
  nok $maker.compile('libb', 'file').defined, 'make precomp nok';
}

{
  my $raku = 'path/raku';
  my $file = 'module'.IO.add('module2.rakumod');
  my $precomp-path = $*TMPDIR.add('.precomp');
  tmp-file::register-dir($precomp-path);
  my $output = $precomp-path.add($sha.uc($file));
  setUp(:$raku, :$precomp-path);
  is $maker.compile('libb', $file.Str), $output, 'custom precomp ok';
  is $proc.c,
    \($raku, '-Ilibb', '--target=mbc', "--output=$output", $file.Str),
    'custom precomp';
}

done-testing