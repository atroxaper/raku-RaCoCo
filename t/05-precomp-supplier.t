use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Precomp::PrecompSupplier;
use App::Racoco::Paths;
use App::Racoco::Fixture;
use App::Racoco::TmpDir;
use TestResources;

plan 1;

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
	setup('Module.rakumod', 'lib', :$subtest, :1plan);
	my $expected = lib-precomp-path(:$lib)
		.add(Fixture::compiler-id()).add('B8')
		.add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576').IO;
	is $supplier.supply(:$file-name), $expected, 'precomp ok'
}

#my $lib = $sources.add('lib');

#my $module2-path = our-precomp-path(:$lib).add('C4')
#  .add('C42D08C62F336741E9DBBDC10EFA8A4673AA820F').IO;
#my $module3-path = our-precomp-path(:$lib).add('5F')
#  .add('5FB62D3D27EB6AAE0FD30F0E99F9EB7D3907F2F8').IO;
#TmpDir::register-dir($module3-path.parent);
#
#
#is $supplier.supply(:file-name<Module.rakumod>), $module1-path, 'precomp ok';
#is $supplier.supply(:file-name<Module2.rakumod>), $module2-path, 'our precomp ok';
#is $supplier.supply(:file-name<Module3.rakumod>), $module3-path, 'compile ok';

done-testing