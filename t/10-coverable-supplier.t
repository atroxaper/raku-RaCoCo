use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableLinesSupplier;
use App::Racoco::Fixture;

plan 4;

my ($supplier, $subtest);
sub setup(
	:$hash, :$time, :@lines,
	:$hash-c, :$time-c, :@lines-c,
	:$file-name, :$use-index = True, :$plan!
) {
	plan $plan;
	my $indexed = Coverable.new(
		:$file-name,
		timestamp => Instant.from-posix($time-c // $time),
		hashcode => $hash-c // $hash,
		lines => @lines-c // @lines
	);
	my $index = Fixture::testIndex($use-index ?? $indexed !! ());
	my $precomp = Fixture::fakePath("pre$file-name", :modified($time));
	my $precomp-supplier = Fixture::testPrecompSupplier($file-name, $precomp);
	my $hashcode-reader = Fixture::testHashcodeReader($precomp.Str, $hash);
	my $outliner = Fixture::testOutliner($precomp.Str, @lines);
	$supplier = CoverableLinesSupplier.new(:$index, :supplier($precomp-supplier), :$hashcode-reader, :$outliner);
}

$subtest = '01-from-index';
subtest $subtest, {
	setup(:file-name<info-from-index>, :1plan,
		:123time, :hash<hashcode>, lines => (1, 2, 3), lines-c => (4, 5, 6));
	is $supplier.supply(:file-name<info-from-index>), (4, 5, 6), 'from-index ok';
}

$subtest = '02-obsolete-hash';
subtest $subtest, {
	setup(:file-name<obsolete-hash>, :1plan,
		:123time, :hash<hashcode>, :hash-c<obsolete>,
		lines => (1, 2, 3), lines-c => (4, 5, 6));
	is $supplier.supply(:file-name<obsolete-hash>), (1, 2, 3), 'obsolete-hash ok';
}

$subtest = '03-obsolete-time';
subtest $subtest, {
	setup(:file-name<obsolete-time>, :1plan,
		:123time, :122time-c, :hash<hashcode>,
		lines => (1, 2, 3), lines-c => (4, 5, 6));
	is $supplier.supply(:file-name<obsolete-time>), (1, 2, 3), 'obsolete-time ok';
}

$subtest = '04-empty-index';
subtest $subtest, {
	setup(:file-name<empty-index>, :1plan,
		:123time, :hash<hashcode>, lines => (1, 2, 3),
		:!use-index);
	is $supplier.supply(:file-name<empty-index>), (1, 2, 3), 'empty-index ok';
}

done-testing