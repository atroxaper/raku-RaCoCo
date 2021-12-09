use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::Paths;
use App::Racoco::Fixture;

plan 1;

my ($supplier, $subtest);
sub setup(
	:$hash, :$time, :@lines,
	:$hash-c, :$time-c, :@lines-c,
	:$file-name, :$plan!
) {
	plan $plan;
	my $indexed = Coverable.new(
		:$file-name,
		timestamp => Instant.from-posix($time-c // $time),
		hashcode => $hash-c // $hash,
		lines => @lines-c // @lines
	);
	my $index = Fixture::testIndex($indexed);
	my $precomp = Fixture::fakePath("pre$file-name", :modified($time));
	my $precomp-supplier = Fixture::testPrecompSupplier($file-name, $precomp);
	my $hashcode-reader = Fixture::testHashcodeReader($precomp.Str, $hash);
	my $outliner = Fixture::testOutliner($precomp.Str, @lines);
	$supplier = CoverableLinesSupplier.new(:$index, :supplier($precomp-supplier), :$hashcode-reader, :$outliner);
}

$subtest = '01-info-from-index';
subtest $subtest, {
	setup(:file-name<info-from-index>, :1plan,
		:123time, :hash<hashcode>, lines => (1, 2, 3), lines-c => (4, 5, 6));
	is $supplier.supply(:file-name<info-from-index>), (4, 5, 6), 'from-index ok';
}

#
#{
#  setUp(:path<bad-hash>, :123time, :hash<hashcode>, lines => (1, 2, 3),
#    index-lines => (4, 5, 6), index-hash => 'obsolete');
#  is $supplier.supply(:file-name<bad-hash>), (1, 2, 3), 'bad-hash ok';
#}
#
#{
#  setUp(:path<bad-time>, :123time, :hash<hashcode>, lines => (1, 2, 3),
#    index-lines => (4, 5, 6), index-time => 122);
#  is $supplier.supply(:file-name<bad-time>), (1, 2, 3), 'bad-time ok';
#}
#
#{
#  setUp(:path<no-index>, :123time, :hash<hashcode>, lines => (1, 2, 3),
#    :no-index);
#  is $supplier.supply(:file-name<no-index>), (1, 2, 3), 'no-index ok';
#}

done-testing