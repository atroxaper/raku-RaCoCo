use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::CoverableLinesCollector;
use App::Racoco::Fixture;

plan 1;

my $sources = Fixture::root-folder();
my $lib = $sources.add('lib');

my $linesSupplier = Fixture::testLinesSupplier();
$linesSupplier.add('Module.rakumod', (1, 2, 3));
$linesSupplier.add('Module2.rakumod', (25, 28));
$linesSupplier.add('Module3.rakumod', (14,));

{
  my $collector = CoverableLinesCollector.new(:$lib, :supplier($linesSupplier));
  my %coverableLines = $collector.collect();
  is-deeply %coverableLines,
    %{
      'Module.rakumod' => (1, 2, 3).Set,
      'Module2.rakumod' => (25, 28).Set,
      'Module3.rakumod' => (14).Set,
    },
    'lines collector ok';
}

done-testing