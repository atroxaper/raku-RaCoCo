use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::ProjectName;
use App::Racoco::Fixture;
use TestResources;

plan 2;

my ($lib, $subtest);
sub setup($lib-name, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
}

$subtest = '01-from-meta';
subtest $subtest, {
	setup('lib', :$subtest, :1plan);
	is project-name(:$lib), 'Test::Project';
}

$subtest = '02-from-path';
subtest $subtest, {
	setup('lib', :$subtest, :1plan);
	is project-name(:$lib), 'exam';
}

done-testing