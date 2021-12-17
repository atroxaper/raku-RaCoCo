use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Precomp::Precompiler;
use App::Racoco::ModuleNames;
use App::Racoco::RunProc;
use Fixture;
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
  my $out-path = $our-precomp.add(file-precomp-path(:$lib, path => $file-name));
  is $precompiler.compile(:$file-name), $out-path, 'fake precomp ok';
  is $proc.c,
  	\("raku -I$lib --target=mbc --output=$out-path $source-file", :!out),
    'fake run ok';
}

$subtest = '02-real-compile';
subtest $subtest, {
	setup(RunProc.new, :$subtest, :2plan);
  my $file-name = 'Module3.rakumod';
  my $out-path = $our-precomp.add(file-precomp-path(:$lib, path => $file-name));
  is $precompiler.compile(:$file-name), $out-path, 'precomp ok';
  ok $out-path.e, 'precomp exists';
}

$subtest = '03-fail-compile';
subtest $subtest, {
	setup(Fixture::failProc, :$subtest, :1plan);
	nok $precompiler.compile(:file-name<file>).defined, 'fail precomp ok';
}

done-testing