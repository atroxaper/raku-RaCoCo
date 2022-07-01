use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Precomp::Precompiler;
use App::Racoco::ModuleNames;
use App::Racoco::RunProc;
use Fixture;
use App::Racoco::Paths;
use TestResources;

plan 6;

my ($lib, $our-precomp, $proc, $precompiler, $subtest);
sub setup($proc-arg, :$subtest, :$plan!, :$wo-resources = False) {
	plan $plan;
	if $wo-resources {
		$lib = $*CWD;
	} else {
			TestResources::prepare($subtest);
		$lib = TestResources::exam-directory.add('lib');
	}
	$our-precomp = our-precomp-path(:$lib);
	$proc = $proc-arg;
	$precompiler = Precompiler.new(:$lib, :raku<raku>, :$proc);
}

$subtest = '01-right-proc-args';
subtest $subtest, {
	setup(Fixture::fakeProc, :$subtest, :6plan, :wo-resources);
  my $file-name = 'Module'.IO.add('Module2.rakumod').Str;
  my $source-file = $lib.add($file-name);
  my $out-path = $our-precomp.add(file-precomp-path(:$lib, path => $file-name));
  $precompiler.compile(:$file-name);
  is $proc.c.elems, 1, 'one comand';
	is $proc.c.list.[0], "raku -I$lib --target=mbc --output=$out-path $source-file", 'right comand';
	is $proc.c.hash.elems, 3, 'three optioons';
	is $proc.c.hash.<out>, False, ':!out';
	is $proc.c.hash.<err>, True, ':err';
	isa-ok $proc.c.hash.<error-handler>, Block, 'error-handler ok';
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
	setup(Fixture::failProc, :$subtest, :1plan, :wo-resources);
	nok $precompiler.compile(:file-name<file>).defined, 'fail precomp ok';
}

$subtest = '04-fail-compile-default-error-handler';
subtest $subtest, {
	setup(RunProc.new, :$subtest, :2plan, :wo-resources);
	my $result;
	my $captured = Fixture::silently({ $result = $precompiler.compile(:file-name<not-exists>) });
	nok $result.defined, 'fail precomp ok';
	ok $captured.err.text ~~ /'Fail execute: raku'/, 'default error handler';
}

$subtest = '05-fail-compile-suppress-precompilation-impotence';
subtest $subtest, {
	setup(RunProc.new, :$subtest, :2plan);
	my $result;
	my $file-name = 'Module.rakumod';
	my $captured = Fixture::silently({ $result = $precompiler.compile(:$file-name) });
	nok $result.defined, 'fail precomp ok';
	ok $captured.out.text ~~ /'Module.rakumod cannot be precompiled.'/, 'default error handler';
}

$subtest = '06-dependency-with-no-precompile';
subtest $subtest, {
	setup(RunProc.new, :$subtest, :2plan);
	my $file-name = 'Module2.rakumod';
	my $out-path = $our-precomp.add(file-precomp-path(:$lib, path => $file-name));
	nok $precompiler.compile(:$file-name).defined, 'precomp ok without output file';
	nok $out-path.e, 'precomp exists';
}

done-testing