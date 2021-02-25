use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Annotation;
use Racoco::Constants;
use Racoco::Fixture;

plan 4;

my $calc;

sub setUp(
  :$no-index,
  :$path!, :$hash!, :$index-hash, :$time!, :$index-time, :@lines!, :@index-lines
) {
  my $index = Fixture::testIndex;
  my $provider = Fixture::testProvider;
  my $hashcodeGetter = Fixture::testHashcodeGetter;
  my $dumper = Fixture::testDumper;
  $calc = Calculator.new(:$index, :$provider, :$hashcodeGetter, :$dumper);

  my $indexed = Fixture::anno(
    $path, $index-time // $time, $index-hash // $hash, @index-lines // @lines
  );
  my $precomp = Fixture::fakePath("pre$path", :modified($time));
  $index.add($path, $indexed) unless $no-index;
  $provider.add($path, $precomp);
  $hashcodeGetter.add($precomp.Str, $hash);
  $dumper.add($precomp.Str, @lines);
}

{
  setUp(:path<from-index>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    index-lines => (4, 5, 6));
  is $calc.calc-and-update-index('from-index'), (4, 5, 6), 'from-index ok';
}

{
  setUp(:path<bad-hash>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    index-lines => (4, 5, 6), index-hash => 'obsolete');
  is $calc.calc-and-update-index('bad-hash'), (1, 2, 3), 'bad-hash ok';
}

{
  setUp(:path<bad-time>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    index-lines => (4, 5, 6), index-time => 122);
  is $calc.calc-and-update-index('bad-time'), (1, 2, 3), 'bad-time ok';
}

{
  setUp(:path<no-index>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    :no-index);
  is $calc.calc-and-update-index('no-index'), (1, 2, 3), 'no-index ok';
}

done-testing