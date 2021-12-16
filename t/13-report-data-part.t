use Test;
use lib 'lib';
use App::Racoco::Report::DataPart;
use lib 't/lib';
use TestHelper;

plan 9;

sub setup() {
	plan $*plan;
}

'01-read-from-str'.&test(:4plan, {
	setup();
	my $part;
	lives-ok { $part = DataPart.read('ModuleName.rakumod | 43% | 1 0 2 3 3 1 | 4 1') }, 'read from str with purple';
	ok $part, 'read defined with purple';
	lives-ok { $part = DataPart.read('ModuleName.rakumod | 100% | 1 3 4 0 3 4 5 0') }, 'read from str';
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

'03-interface-after-read'.&test(:12plan, {
	setup();
	my $part = DataPart.read('ModuleName.rakumod | 42.8% | 1 0 2 3 | 4 1');
	is $part.file-name(), 'ModuleName.rakumod', 'file-name';
	is $part.percent, 66.6, 'percent';
	is $part.coverable-amount, 3, 'coverable-amount';
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
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4)
	);
	is $part.percent, 37.5, 'percent';
	is $part.coverable-amount, 8, 'coverable-amount';
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

'05-to-str'.&test(:3plan, {
	setup();
	my $part = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4)
	);
	is $part, 'ModuleName.rakumod | 37.5% | 1 0 2 3 3 1 5 0 6 0 7 0 8 0 | 4 1', 'Str with purple';
	$part = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3)
	);
	is $part, 'ModuleName.rakumod | 28.5% | 1 0 2 3 3 1 5 0 6 0 7 0 8 0', 'Str';
	$part = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3),
		covered => bag()
	);
	is $part, 'ModuleName.rakumod | 0% | 1 0 2 0 3 0', 'Str no covered';
});

'06-cmp'.&test(:2plan, {
	setup();
	my $part1 = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4)
	);
	my $part2 = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4)
	);
	my $part3 = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4, 7)
	);
	is $part1, $part2, 'eq';
	isnt $part1, $part3, 'ne';

});

'07-bad-percent'.&test(:1plan, {
	setup();
	my $part = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(),
		covered => bag(2, 2, 2, 3, 4)
	);
	is $part.percent, 100, 'bad-percent';
});

'08-plus-construct'.&test(:1plan, {
	setup();
	my $part1 = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4, 9)
	);
	my $part2 = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 4, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 3, 4)
	);
	my $expected = DataPart.new(
		'ModuleName.rakumod',
		coverable => set(1, 2, 3, 4, 5, 6, 7, 8),
		covered => bag(2, 2, 2, 2, 2, 2, 3, 3, 4, 4, 9)
	);
	is DataPart.plus($part1, $part2), $expected, 'plus works';
});

'09-plus-read'.&test(:1plan, {
	setup();
	my $part1 = DataPart.read(
		'ModuleName.rakumod | 0% | 1 1 2 2 3 3 4 4 | 5 5',
	);
	my $part2 = DataPart.read(
		'ModuleName.rakumod | 0% | 6 6 7 7 8 8 9 9 | 10 10',
	);
	my $expected = DataPart.read(
		'ModuleName.rakumod | 100% | 1 1 2 2 3 3 4 4 6 6 7 7 8 8 9 9 | 5 5 10 10',
	);
	is DataPart.plus($part1, $part2), $expected, 'plus works';
});

#'09-plus-different-names'.&test(:1plan, {
#	setup();
#
#});

#'09-plus-with-nil'.&test(:1plan, {
#	setup();
#
#});



done-testing