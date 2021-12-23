use Test;
use lib 'lib';
use App::Racoco::Properties;
use lib 't/lib';
use TestResources;
use TestHelper;

plan 3;

my $lib;
sub setup($lib-name = 'lib') {
	plan $*plan;
	TestResources::prepare($*subtest);
	$lib = TestResources::exam-directory.add($lib-name);
}

'01-parse-command-line'.&test(:3plan, {
	setup();
	my $actual := Properties.parse-command-line('foo:bar;one :t w o ;');
	is $actual.elems, 2, 'parsed elems';
	is $actual<foo>, 'bar', 'parsed no spases';
	is $actual<one>, 't w o', 'parsed with spases';
});

'02-all-properties'.&test(:6plan, {
	setup();
	%*ENV<from-command-line> = 'env: overridden';
	%*ENV<from-env> = 'env value';
	my $properties = Properties.new(
		:$lib,
		mode => 'good-section',
		command-line => 'from-command-line:command-line value',
	);

	is $properties.env-only('from-command-line'), 'env: overridden', 'env => command-line';
	is $properties.property('from-command-line'), 'command-line value', 'command-line > env';
	is $properties.property('from-env'), 'env value', 'env > config';
	is $properties.property('from-top-section'), 'top value', 'top > Any';
	is $properties.property('from-good-section'), 'good value', 'good > top';
	nok $properties.property('not-exists'), 'not exists';
});

'03-empty-config'.&test(:2plan, {
	setup();
	my $properties = Properties.new(:$lib);
	nok $properties.property('not-exists'), 'not exists config';
	nok $properties.env-only('not-exists'), 'not exists env';
});