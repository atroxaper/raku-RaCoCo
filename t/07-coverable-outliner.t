use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::RunProc;
use App::Racoco::Paths;
use Fixture;
use TestResources;

plan 2;

my ($lib, $path, $outliner, $subtest);
sub setup($lib-name, $proc, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
	$path = $lib.parent.add('precompiled');
	$outliner = CoverableOutlinerReal.new(:moar<moar>, :$proc);
}

$subtest = '01-real-outline';
subtest $subtest, {
	setup('lib', RunProc.new, :$subtest, :1plan);
	is $outliner.outline(:$path), (1, 2), 'coverable outline ok';
}

$subtest = '02-fail-outline';
subtest $subtest, {
	setup('lib', Fixture::failProc, :$subtest, :1plan);
	my $actual;
	Fixture::silently({ $actual = $outliner.outline(:$path) });
  is $actual, (), 'fail moar proc';
}

done-testing