use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Precomp::PrecompSupplier;
use App::Racoco::Paths;
use App::Racoco::Fixture;
use TestResources;

plan 3;

my ($lib, $file-name, $proc, $supplier, $subtest);
sub setup($file, $lib-name, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
	$file-name = $file;
	$proc = Fixture::fakeProc;
	$supplier = PrecompSupplierReal.new(:$lib, :raku<raku>, :$proc);
}

$subtest = '01-supply-precomp-in-lib';
subtest $subtest, {
	setup('Module.rakumod', 'lib', :$subtest, :2plan);
	my $expected = lib-precomp-path(:$lib)
		.add(Fixture::compiler-id()).add('B8')
		.add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576').IO;
	is $supplier.supply(:$file-name), $expected, 'precomp ok';
	nok $proc.c, 'cold proc';
}

$subtest = '02-supply-compile';
subtest $subtest, {
	setup('Module.rakumod', 'lib', :$subtest, :2plan);
	my $expected = our-precomp-path(:$lib).add('B8')
		.add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576').IO;
	is $supplier.supply(:$file-name), $expected, 'compile ok';
	ok $proc.c, 'hot proc';
}

$subtest = '03-supply-our-pecomp-but-compile';
subtest $subtest, {
	setup('Module.rakumod', 'lib', :$subtest, :2plan);
	my $expected = our-precomp-path(:$lib).add('B8')
		.add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576').IO;
	is $supplier.supply(:$file-name), $expected, 'compile ok';
	ok $proc.c, 'hot proc';
}

done-testing