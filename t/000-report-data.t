use Test;
use lib 'lib';
use App::Racoco::Report::DataPart;
use App::Racoco::Report::Data;
use lib 't/lib';
use TestResources;
use TestHelper;

plan 1;

my ($lib);
sub setup($lib-name) {
	plan $*plan;
	TestResources::prepare($*subtest);
	$lib = TestResources::exam-directory.add($lib-name);
}

'01-read-from-file'.&test(:6plan, {
	setup('lib');
	my ($data, $part);
	lives-ok { $data = Data.read(:$lib) }, 'read from file';
	ok $data, 'read defined';
	$part = $data.for(file-name => 'ModuleName1.rakumod');
	is $part, 'ModuleName1.rakumod | 42.8% | 1 0 2 3 3 1 5 0 6 0 7 0 8 0 | 4 1', 'part 1';
	$part = $data.for(file-name => 'ModuleName2.rakumod');
	is $part, 'ModuleName2.rakumod | 28.5% | 1 0 2 3 3 1 5 0 6 0 7 0 8 0', 'part 2';
	$part = $data.for(file-name => 'ModuleName3.rakumod');
	is $part, 'ModuleName3.rakumod | 0% | 1 0 2 0 3 0', 'part 3';
	nok $data.for(file-name => 'NotExists'), 'not exists';
});

#'read-not-exist'.&test(:1plan, {
#	setup();
#
#});
#
#'read-bad-header'.&test(:1plan, {
#	setup();
#
#});

#'read-carrupt'.&test(:1plan, {
#	setup();
#
#});

done-testing