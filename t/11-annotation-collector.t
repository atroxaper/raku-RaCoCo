use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Annotation;
use Racoco::Fixture;

plan 2;

my $sources = Fixture::root-folder();
my $lib = $sources.add('lib');

my $calculator = Fixture::testCalculator(%{
  'Module.rakumod' => (1, 2, 3),
  'Module2.rakumod' => (25, 28),
  'Module3.rakumod' => (14,),
});

{
  my $collector = AnnotationCollector.new(:$lib, :$calculator);
  my $annotations = $collector.get();
  is-deeply $annotations,
    %{
      'Module.rakumod' => (1, 2, 3).Set,
      'Module2.rakumod' => (25, 28).Set,
      'Module3.rakumod' => (14).Set,
    },
    'collector ok';
}

{
  is AnnotationCollector.new(:lib($lib.add('not-exists')), :$calculator).get(),
    %{}, 'collector on not-exist lib';
}

done-testing