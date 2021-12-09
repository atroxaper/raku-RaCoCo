use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Precomp::PrecompLookup;
use App::Racoco::Paths;
use App::Racoco::Sha;
use App::Racoco::X;
use App::Racoco::Fixture;
use App::Racoco::TmpDir;
use TestResources;

plan 2;

Fixture::restore-root-folder();

my $sources = Fixture::root-folder();
my ($file-name, $lib, $lookup);

sub setUp($file, $lib-name) {
  $file-name = $file;
  $lib = $sources.add($lib-name);
  $lookup = PrecompLookup.new(:$lib);
}

my $subtest;
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
  ok $actual.relative.Str.starts-with($lib), 'lookup under lib';
  is $actual, $expected, 'lookup ok';
}

$subtest = '02-lookup-not-exist';
subtest $subtest, {
	setup('NotExists.rakumod', 'lib', :$subtest, :1plan);
	nok $lookup.lookup(:$file-name).DEFINITE, 'cannot lookup precomp file';
}

#{
#  my $lib = $sources.add('two-precomp-lib');
#  my $lookup = PrecompLookup.new(:$lib);
#  throws-like { $lookup.lookup(file-name => 'any.rakumod') },
#  	App::Racoco::X::AmbiguousPrecompContent,
#  	'two precomp contents', message => /$lib/;
#}
#
#{
#  setUp('Module.rakumod', 'no-precomp-lib');
#  my $actual = $lookup.lookup(:$file-name);
#  nok $actual.DEFINITE, 'cannot lookup .precomp dir';
#
#  my $precomp-path = lib-precomp-path(:$lib);
#  my $expected = $precomp-path.add(Fixture::compiler-id())
#  	.add('B8').add('B8FF02892916FF59F7FBD4E617FCCD01F6BCA576');
#  LEAVE { TmpDir::rmdir($precomp-path) }
#  $expected.parent.mkdir;
#  $expected.spurt: '';
#
#  $actual = $lookup.lookup(:$file-name);
#  is $actual, $expected, 'lookup in created .precomp dir';
#}
#
#{
#  setUp('Module2.rakumod', 'lib');
#  my $expected = our-precomp-path(:$lib).add('C4')
#      .add('C42D08C62F336741E9DBBDC10EFA8A4673AA820F');
#  is $lookup.lookup(:$file-name).IO, $expected, 'lookup in our precomp';
#}

done-testing