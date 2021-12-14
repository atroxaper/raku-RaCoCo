use Test;
use lib 'lib';
use App::Racoco::Misc;
use lib 't/lib';
use TestResources;
use TestHelper;

plan 2;

my ($lib);
sub setup($lib-name) {
	plan $*plan;
	if $lib-name {
		TestResources::prepare($*subtest);
		$lib = TestResources::exam-directory.add($lib-name);
	}
}

'01-percent'.&test(:6plan, {
	setup(Nil);
	is percent(2, 7), 28.5, '2/7';
	is percent(4, 7), 57.1, '4/7';
	is percent(1, 7), 14.2, '1/7';
	is percent(1, 2), 50, '1/2';
	is percent(30, 2), 100, '30/2';
	is percent(3, 0), 100, '3/0';
});

'02-collect-all-module-names-in'.&test(:1plan, {
	setup('lib');
	my $expected = set
		'Root.rakumod',
		'Root'.IO.add('RootSubmod.rakumod').Str,
		'Root'.IO.add('RootSubmod2.pm6').Str,
		'Root'.IO.add('RootSubmod').add('RootSubmodSub.rakumod').Str;
	ok collect-all-module-names-in(:$lib).Set === $expected, 'good collect';
});

done-testing;
