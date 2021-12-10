use Test;
use lib 'lib';
use App::Racoco::ProjectName;
use lib 't/lib';
use App::Racoco::Fixture;
use TestHelper;
use TestResources;

plan 2;

my ($lib, $*subtest, $*plan);
sub setup($lib-name) {
	plan $*plan;
	TestResources::prepare($*subtest);
	$lib = TestResources::exam-directory.add($lib-name);
}

'01-from-meta'.&test(:1plan, {
	setup('lib');
	is project-name(:$lib), 'Test::Project';
});

'02-from-path'.&test(:1plan, {
	setup('lib');
	is project-name(:$lib), 'exam';
});

done-testing