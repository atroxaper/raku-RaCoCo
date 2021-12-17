use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::CoverableLinesCollector;
use App::Racoco::Fixture;
use TestResources;

plan 1;

my ($lib, $collector, $subtest);
sub setup($lib-name, @suplier-data, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
	my $supplier = Fixture::testLinesSupplier(|@suplier-data);
	$collector = CoverableLinesCollector.new(:$lib, :$supplier);
}

$subtest = '01-iter-and-collect-fake';
subtest $subtest, {
	setup('lib', :$subtest, :1plan, (
	  'Sub'.IO.add('Module.rakumod').Str, (1, 2, 3),
    'Sub'.IO.add('Submodule.rakumod').Str, (25, 28),
    'Module.rakumod', (14,)
  ));

  is-deeply $collector.collect(),
    %{
      'Sub'.IO.add('Module.rakumod').Str => (1, 2, 3).Set,
      'Sub'.IO.add('Submodule.rakumod').Str => (25, 28).Set,
      'Module.rakumod' => (14).Set,
    },
    'lines collector ok';
}

done-testing