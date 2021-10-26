use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::Paths;
use App::Racoco::Fixture;

plan 4;

Fixture::restore-root-folder();

my $supplier;

sub setUp(
  :$no-index,
  :$path!, :$hash!, :$index-hash, :$time!, :$index-time, :@lines!, :@index-lines
) {
	my $indexed = Coverable.new(
    file-name => $path,
    timestamp => Instant.from-posix($index-time // $time),
    hashcode => $index-hash // $hash,
    lines => @index-lines // @lines
  );

  my $index = Fixture::testIndex;
  my $precomp-supplier = Fixture::testPrecompSupplier;
  my $hashcode-reader = Fixture::testHashcodeReader;
  my $outliner = Fixture::testOutliner;
  $supplier = CoverableLinesSupplier.new(:$index, :supplier($precomp-supplier), :$hashcode-reader, :$outliner);
  my $precomp = Fixture::fakePath("pre$path", :modified($time));
  $index.add($path, $indexed) unless $no-index;
  $precomp-supplier.add($path, $precomp);
  $hashcode-reader.add($precomp.Str, $hash);
  $outliner.add($precomp.Str, @lines);
}

{
  setUp(:path<from-index>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    index-lines => (4, 5, 6));
  is $supplier.supply(:file-name<from-index>), (4, 5, 6), 'from-index ok';
}

{
  setUp(:path<bad-hash>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    index-lines => (4, 5, 6), index-hash => 'obsolete');
  is $supplier.supply(:file-name<bad-hash>), (1, 2, 3), 'bad-hash ok';
}

{
  setUp(:path<bad-time>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    index-lines => (4, 5, 6), index-time => 122);
  is $supplier.supply(:file-name<bad-time>), (1, 2, 3), 'bad-time ok';
}

{
  setUp(:path<no-index>, :123time, :hash<hashcode>, lines => (1, 2, 3),
    :no-index);
  is $supplier.supply(:file-name<no-index>), (1, 2, 3), 'no-index ok';
}

done-testing