use Test;
use lib 'lib';
use App::Racoco::Report::DataPart;
use lib 't/lib';
use TestResources;
use TestHelper;

plan 4;

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
	is $part.covered-amount, 2, 'covered-amount';
	is $part.color-of(:1line), RED, '1 red';
	is $part.color-of(:2line), GREEN, '2 green';
	is $part.color-of(:4line), GREEN, '4 purple-green';
	is $part.color-of(:8line), NO, '8 no';
	is $part.hit-times-of(:1line), 0, '1-0';
	is $part.hit-times-of(:2line), 3, '2-3';
	is $part.hit-times-of(:4line), 1, '4-1';
	nok $part.hit-times-of(:8line), '8-?';
});

'04-interface-after-construct'.&test(:21plan, {
	setup();
	my $part = DataPart.new(
		'ModuleName.raku',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4)
	);
	is $part.percent, 42.8, 'percent';
	is $part.coverable-amount, 7, 'coverable-amount';
	is $part.covered-amount, 3, 'covered-amount';
	is $part.color-of(:1line), RED, '1 red';
	is $part.color-of(:2line), GREEN, '2 green';
	is $part.color-of(:3line), GREEN, '3 green';
	is $part.color-of(:4line), GREEN, '4 purple-green';
	is $part.color-of(:5line), RED, '5 red';
	is $part.color-of(:6line), RED, '6 red';
	is $part.color-of(:7line), RED, '7 red';
	is $part.color-of(:8line), RED, '8 red';
	is $part.color-of(:9line), NO, '9 no';
	is $part.hit-times-of(:1line), 0, '1-0';
	is $part.hit-times-of(:2line), 3, '2-3';
	is $part.hit-times-of(:3line), 1, '1-1';
	is $part.hit-times-of(:4line), 1, '4-1';
	is $part.hit-times-of(:5line), 0, '5-0';
	is $part.hit-times-of(:6line), 0, '6-0';
	is $part.hit-times-of(:7line), 0, '7-0';
	is $part.hit-times-of(:8line), 0, '8-0';
	nok $part.hit-times-of(:9line), '9-?';
});

done-testing