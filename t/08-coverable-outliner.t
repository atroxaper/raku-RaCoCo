use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::CoverableOutliner;
use App::Racoco::RunProc;
use App::Racoco::Paths;
use App::Racoco::Fixture;
use TestResources;

plan 1;

my ($lib, $outliner, $subtest);
sub setup($lib-name, $proc, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
	$outliner = CoverableOutlinerReal.new(:moar<moar>, :$proc);
}

$subtest = '01-real-outline';
subtest $subtest, {
	setup('lib', RunProc.new, :$subtest, :1plan);
	my $path = lib-precomp-path(:$lib).add(Fixture::compiler-id())
    .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');
	is $outliner.outline(:$path), (1, 2), 'coverable outline ok';
}


#Fixture::restore-root-folder();
#
#
#
#if !$*DISTRO.is-win {
#
#} else {
#	skip "Can't use moar --dump in tests on Windows", 1;
#}
#
#{
#  Fixture::suppressErr;
#  LEAVE { Fixture::restoreErr }
#  is CoverableOutlinerReal.new(:moar<moar>, :proc(Fixture::failProc)).outline(:$path), (),
#    'fail moar proc';
#}

done-testing