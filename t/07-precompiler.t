use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Precomp::Precompiler;
use App::Racoco::RunProc;
use App::Racoco::Fixture;
use App::Racoco::Paths;
use TestResources;

plan 3;

my ($lib, $our-precomp, $proc, $precompiler, $subtest);
sub setup($proc-arg, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add('lib');
	$our-precomp = our-precomp-path(:$lib);
	$proc = $proc-arg;
	$precompiler = Precompiler.new(:$lib, :raku<raku>, :$proc);
}

$subtest = '01-fake-compile';
subtest $subtest, {
	setup(Fixture::fakeProc, :$subtest, :2plan);
  my $file-name = 'Module'.IO.add('Module2.rakumod').Str;
  my $source-file = $lib.add($file-name);
  my $out-path = $our-precomp.add('77')
    .add('770D15B487025165F9B99486A04A6E11285C6416');
  is $precompiler.compile(:$file-name), $out-path, 'fake precomp ok';
  is $proc.c,
  	\("raku -I$lib --target=mbc --output=$out-path $source-file", :!out),
    'fake run ok';
}

$subtest = '02-real-compile';
subtest $subtest, {
	setup(RunProc.new, :$subtest, :2plan);
  my $file-name = 'Module3.rakumod';
  my $out-path = $our-precomp.add('5F')
  	.add('5FB62D3D27EB6AAE0FD30F0E99F9EB7D3907F2F8');
  is $precompiler.compile(:$file-name), $out-path, 'precomp ok';
  ok $out-path.e, 'precomp exists';
}

$subtest = '03-fail-compile';
subtest $subtest, {
	setup(Fixture::failProc, :$subtest, :1plan);
	nok $precompiler.compile(:file-name<file>).defined, 'fail precomp ok';
}

done-testing