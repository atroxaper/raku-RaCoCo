use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Precomp::PrecompLookup;
use App::Racoco::ModuleNames;
use App::Racoco::Paths;
use App::Racoco::X;
use App::Racoco::Fixture;
use TestResources;
use TestHelper;

plan 4;

say $*EXECUTABLE.parent.Str;

my ($sources, $lib, $file-name, $lookup);
sub setup($file, $lib-name) {
	plan $*plan;
	TestResources::prepare($*subtest);
	$sources = TestResources::exam-directory;
	$lib = $sources.add($lib-name);
	$file-name = $file;
	$lookup = PrecompLookup.new(:$lib, compiler-id => -> {Fixture::compiler-id});
}

'01-lookup-in-precomp'.&test(:4plan, {
	setup('Module.rakumod', 'lib');
	my $expected = lib-precomp-path(:$lib).add(Fixture::compiler-id())
    .add(file-precomp-path(:$lib, path => $file-name));
  my $actual = $lookup.lookup(:$file-name);
  isa-ok $actual, IO::Path, 'lookup is io';
  ok $actual.e, 'lookup exists';
  ok $actual.Str.starts-with($lib), 'lookup under lib';
  is $actual, $expected, 'lookup ok';
});

'02-lookup-not-exist'.&test(:1plan, {
	setup('NotExists.rakumod', 'lib');
	nok $lookup.lookup(:$file-name).DEFINITE, 'cannot lookup precomp file';
});

'03-lookup-two-precomp-dir'.&test(:1plan, {
	setup('Module.rakumod', 'lib');
	my $expected = lib-precomp-path(:$lib).add(Fixture::compiler-id())
    .add(file-precomp-path(:$lib, path => $file-name));
  my $actual = $lookup.lookup(:$file-name);
  is $actual, $expected, 'lookup ok';
});

'04-lookup-our-precomp'.&test(:1plan, {
	setup('Module2.rakumod', 'lib');
	my $expected = our-precomp-path(:$lib).add(file-precomp-path(:$lib, path => $file-name));
  is $lookup.lookup(:$file-name).IO, $expected, 'lookup in our precomp';
});

done-testing