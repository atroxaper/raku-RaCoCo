use Test;
use lib 'lib';
use App::Racoco::Report::DataPart;
use lib 't/lib';
use TestResources;
use TestHelper;

plan 2;

my ($*plan, $*subtest);
sub setup() {
	plan $*plan;
}

sub files(*@raw) {
	@raw.map(-> $file-name, $numbers {
		my ($coverable, $covered) = $numbers.split('|')
			.map(*.trim.split(' ', :skip-empty).Bag).List;
		$file-name => ($coverable.Set, $covered);
	}).List;
}

'01-read-from-str'.&test(:2plan, {
	setup();
	my $part;
	lives-ok { $part = DataPart.read('ModuleName.raku | 43% | 1 0 2 3 3 1 | 4 1') }, 'read from str';
	ok $part, 'read defined';
});

'02-construct'.&test(:1plan, {
	setup();
	my $part;
	my $coverable = set 1, 2, 3, 5;
	my $covered = bag 2, 2, 2, 3, 4;
	lives-ok { $part = DataPart.new(:$coverable, :$covered) }, 'constructed';
	ok $part, 'constructed defined';
});

#'02-validate-read'.&test(:1plan, {
#	setup();
#	my $part = DataPart.read('ModuleName.raku | 43% | 1 0 2 3 3 1 5 0 | 4 1');
#	is $part.percent, 66.6, 'percent';
#});

#'01-'.&test(:1plan, {
#	setup();
#	ok True;
#	my %boo = files('foo', '1 2 3 | 2 2 2 3 4', 'bar', '4 5 6|');
#	say %boo;
#	my ($coverable, $covered) = %boo<foo>;
#	say 'purple';
#	say $covered.grep({!$coverable{.key}});
#
#});

done-testing