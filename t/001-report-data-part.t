use Test;
use lib 'lib';
use App::Racoco::Report::DataPart;
use lib 't/lib';
use TestResources;
use TestHelper;

plan 3;

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

'01-read-from-str'.&test(:4plan, {
	setup();
	my $part;
	lives-ok { $part = DataPart.read('ModuleName.raku | 43% | 1 0 2 3 3 1 | 4 1') }, 'read from str with purple';
	ok $part, 'read defined with purple';
	lives-ok { $part = DataPart.read('ModuleName.raku | 100% | 1 3 4 0 3 4 5 0') }, 'read from str';
	ok $part, 'read defined';
});

'02-construct'.&test(:2plan, {
	setup();
	my $part;
	my $coverable = set 1, 2, 3, 5;
	my $covered = bag 2, 2, 2, 3, 4;
	lives-ok { $part = DataPart.new('ModuleName.rakumod', :$coverable, :$covered) }, 'constructed';
	ok $part, 'constructed defined';
});

'03-interface-after-read'.&test(:11plan, {
	setup();
	my $part = DataPart.read('ModuleName.raku | 42.8% | 1 0 2 3 | 4 1');
	is $part.percent, 42.8, 'percent';
	is $part.coverable-amount, 2, 'coverable-amount';
	is $part.covered-amount, 2, 'coverable-amount';
	is $part.color-of(:1line), RED, '1 red';
	is $part.color-of(:2line), GREEN, '2 green';
	is $part.color-of(:4line), GREEN, '5 purple-green';
	is $part.color-of(:8line), NO, '8 no';
	is $part.hit-times-of(:1line), 0, '1-1';
	is $part.hit-times-of(:2line), 3, '2-3';
	is $part.hit-times-of(:4line), 1, '4-1';
	nok $part.hit-times-of(:8line), '8-?';
});

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