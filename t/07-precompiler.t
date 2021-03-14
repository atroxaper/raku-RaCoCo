use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Precomp::Precompiler;
use App::Racoco::RunProc;
use App::Racoco::Fixture;
use App::Racoco::Paths;

plan 5;

my ($proc, $precompiler, $lib, $our-precomp);

multi sub setUp(:$fake) {
	setUp(Fixture::fakeProc);
}

multi sub setUp(:$fail) {
	setUp(Fixture::failProc);
}

multi sub setUp(:$real) {
	setUp(RunProc.new);
}

multi sub setUp($proc-arg) {
  $lib = 'lib'.IO;
  $our-precomp = our-precomp-path(:$lib).IO;
  $proc = $proc-arg;
  $precompiler = Precompiler.new(:$lib, :raku<raku>, :$proc);
}

Fixture::need-restore-root-folder();
sub do-test(&code) {
  indir(Fixture::root-folder, &code)
}

do-test {
  setUp(:fake);
  my $file-name = 'Module'.IO.add('Module2.rakumod').Str;
  my $source-file = 'lib'.IO.add('Module').add('Module2.rakumod');
  my $out-path = $our-precomp.add('77')
  	.add('770D15B487025165F9B99486A04A6E11285C6416');
  is $precompiler.compile(:$file-name), $out-path, 'fake precomp ok';
  is $proc.c,
  	\("raku -I$lib --target=mbc --output=$out-path $source-file", :!out),
    'fake run ok';
};

do-test {
  setUp(:fail);
  nok $precompiler.compile(:file-name<file>).defined, 'fail precomp ok';
};

do-test {
  setUp(:real);
  my $file-name = 'Module3.rakumod';
  my $out-path = $our-precomp.add('5F')
  	.add('5FB62D3D27EB6AAE0FD30F0E99F9EB7D3907F2F8');
  is $precompiler.compile(:$file-name), $out-path, 'precomp ok';
  ok $out-path.e, 'precomp exists';
};

done-testing