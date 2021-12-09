use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Precomp::PrecompLookup;
use App::Racoco::Paths;
use App::Racoco::X;
use App::Racoco::Fixture;
use TestResources;

plan 3;

my ($sources, $lib, $file-name, $lookup, $subtest);
sub setup($file, $lib-name, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$sources = TestResources::exam-directory;
	$lib = $sources.add($lib-name);
	$file-name = $file;
	$lookup = PrecompLookup.new(:$lib);
}

$subtest = '01-lookup-in-precomp';
subtest $subtest, {
	setup('Module.rakumod', 'lib', :$subtest, :4plan);
	my $expected = lib-precomp-path(:$lib).add(Fixture::compiler-id())
    .add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');
  my $actual = $lookup.lookup(:$file-name);
  isa-ok $actual, IO::Path, 'lookup is io';
  ok $actual.e, 'lookup exists';
  ok $actual.Str.starts-with($lib), 'lookup under lib';
  is $actual, $expected, 'lookup ok';
}

$subtest = '02-lookup-not-exist';
subtest $subtest, {
	setup('NotExists.rakumod', 'lib', :$subtest, :1plan);
	nok $lookup.lookup(:$file-name).DEFINITE, 'cannot lookup precomp file';
}

$subtest = '03-lookup-two-precomp-dir';
subtest $subtest, {
	setup('any.rakumod', 'lib', :$subtest, :1plan);
	throws-like { $lookup.lookup(:$file-name) },
  	App::Racoco::X::AmbiguousPrecompContent,
  	'two precomp contents', message => / {$lib.Str} /;
}

done-testing