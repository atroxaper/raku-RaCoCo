use Test;
use lib 'lib';
use App::Racoco::Report::DataPart;
use App::Racoco::Report::Data;
use App::Racoco::Paths;
use App::Racoco::X;
use lib 't/lib';
use TestResources;
use TestHelper;

plan 8;

my ($lib);
sub setup($lib-name?) {
	plan $*plan;
	if $lib-name {
		TestResources::prepare($*subtest);
		$lib = TestResources::exam-directory.add($lib-name);
	}
}

'01-read-from-file'.&test(:6plan, {
	setup('lib');
	my ($data, $part);
	lives-ok { $data = Data.read(:$lib) }, 'read from file';
	ok $data, 'read defined';
	$part = $data.for(file-name => 'ModuleName1.rakumod');
	is $part, 'ModuleName1.rakumod | 37.5% | 1 0 2 3 3 1 5 0 6 0 7 0 8 0 | 4 1', 'part 1';
	$part = $data.for(file-name => 'ModuleName2.rakumod');
	is $part, 'ModuleName2.rakumod | 28.5% | 1 0 2 3 3 1 5 0 6 0 7 0 8 0', 'part 2';
	$part = $data.for(file-name => 'ModuleName3.rakumod');
	is $part, 'ModuleName3.rakumod | 0% | 1 0 2 0 3 0', 'part 3';
	nok $data.for(file-name => 'NotExists'), 'not exists';
});

'02-read-not-exist'.&test(:1plan, {
	setup('lib');
	throws-like { Data.read(:$lib) }, CannotReadReport,
		'read from not existed file', message => / $lib /;
});

'03-read-bad-header'.&test(:3plan, {
	setup('lib');
	my ($data);
	lives-ok { $data = Data.read(:$lib) }, 'read from file';
	ok $data, 'read defined';
	nok $data.for(file-name => 'ModuleName1.rakumod'), 'not exists';
});

'04-read-corrupt'.&test(:5plan, {
	setup('lib');
	my ($data);
	lives-ok { $data = Data.read(:$lib) }, 'read from file';
	ok $data, 'read defined';
	ok $data.for(file-name => 'ModuleName1.rakumod'), 'part 1 read';
	ok $data.for(file-name => 'ModuleName2.r'), 'part 2 read';
	nok $data.for(file-name => ''), 'part 3 not read';
});

'05-get-all-parts'.&test(:4plan, {
	setup('lib');
	my $parts := Data.read(:$lib).get-all-parts;
	ok $parts ~~ Positional, 'all parts are Positional';
	is $parts.elems, 2, 'read only two from corrupt';
	is $parts[0], 'ModuleName1.rakumod | 37.5% | 1 0 2 3 3 1 5 0 6 0 7 0 8 0 | 4 1';
	is $parts[1], 'ModuleName2.r | 100%';
});

'06-write-to-file'.&test(:2plan, {
	setup('lib');
	lives-ok { Data.read(:$lib).write(:$lib) }, 'write';
	is report-data-path(:$lib).slurp, report-data-path(:$lib).parent.add('expected.txt').slurp, 'good write';
});

'07-construct'.&test(:2plan, {
	setup('lib');
	my %coverable =
		'ModuleName1.rakumod', set(1, 2, 3, 5, 6, 7, 8),
		'ModuleName2.r', set(),
		'ModuleName3.rakumod', set(1, 2);
	my %covered = 'ModuleName1.rakumod', bag(2, 2, 2, 3, 4), 'ModuleName2.r', bag();
	my ($data);
	lives-ok { $data = Data.new(:%coverable, :%covered) }, 'construct';
	$data.write(:$lib);
	is report-data-path(:$lib).slurp, report-data-path(:$lib).parent.add('expected.txt').slurp, 'good write';
});

'08-percent'.&test(:1plan, {
	setup('lib');
	is Data.read(:$lib).percent, 27.7, 'percent';
});

done-testing