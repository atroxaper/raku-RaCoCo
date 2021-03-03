use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Precomp::Precompiler;
use Racoco::RunProc;
use Racoco::Fixture;
use Racoco::Paths;

plan 5;

Fixture::change-current-dir-to-root-folder();

my ($proc, $precompiler);

my $lib = 'lib'.IO;
my $our-precomp = our-precomp-path(:$lib).IO;

multi sub setUp(:$fake) {
	precompiler(Fixture::fakeProc);
}

multi sub setUp(:$fail) {
	precompiler(Fixture::failProc);
}

multi sub setUp(:$real) {
	precompiler(RunProc.new);
}

sub precompiler($proc-arg) {
  $proc = $proc-arg;
  $precompiler = Precompiler.new(:$lib, :raku<raku>, :$proc);
}

{
  setUp(:fake);
  my $file-name = 'Module/Module2.rakumod';
  my $source-file = 'lib'.IO.add('Module').add('Module2.rakumod');
  my $out-path = $our-precomp.add('77')
  	.add('770D15B487025165F9B99486A04A6E11285C6416');
  is $precompiler.compile(:$file-name), $out-path, 'fake precomp ok';
  is $proc.c,
  	\("raku -I$lib --target=mbc --output=$out-path $source-file", :!out),
    'fake run ok';
}

{
  setUp(:fail);
  nok $precompiler.compile(:file-name<file>).defined, 'fail precomp ok';
}

{
  setUp(:real);
  my $file-name = 'Module3.rakumod';
  my $out-path = $our-precomp.add('5F')
  	.add('5FB62D3D27EB6AAE0FD30F0E99F9EB7D3907F2F8');
  is $precompiler.compile(:$file-name), $out-path, 'precomp ok';
  ok $out-path.e, 'precomp exists';
}

done-testing