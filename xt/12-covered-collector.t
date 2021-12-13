use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::CoveredLinesCollector;
use App::Racoco::RunProc;
use App::Racoco::Paths;
use App::Racoco::Fixture;
use TestResources;
use TestHelper;

plan 9;

my ($sources, $lib, $coverage-log, $collector);
sub setup($lib-name, :$exec = 'prove6', :$proc, :$append = False, :outloud($print-test-log) = False) {
	plan $*plan;
	TestResources::prepare($*subtest);
	$sources = TestResources::exam-directory;
	$lib = $sources.add($lib-name);
  $coverage-log = coverage-log-path(:$lib).IO;
  $collector = CoveredLinesCollector.new(:$exec, :$proc, :$lib, :$append, :$print-test-log);
}

sub collect() {
	my %covered-lines;
	indir($sources, { %covered-lines = $collector.collect() });
	%covered-lines;
}

'01-fake-collect'.&test(:1plan, {
	setup('lib', proc => Fixture::fakeProc);
  lives-ok { $collector.collect() }, 'collect lives ok';
});

'02-real-collect'.&test(:4plan, {
	setup('lib', proc => RunProc.new);
  my %covered-lines = collect();
  ok $coverage-log.e, 'coverage log exists';
  is %covered-lines.elems, 2, 'covered elems';
  ok %covered-lines<Module2.rakumod>.Set === set(1, 2), 'covered module 2';
  ok %covered-lines<Module3.rakumod>.Set === set(1, 2, 3, 5), 'covered module 3';
});

'03-append-log'.&test(:2plan, {
	setup('lib', proc => RunProc.new, :append);
	my $expected = "previous content";
	$coverage-log.spurt("$expected$?NL");
	collect();
	my $lines = $coverage-log.slurp.lines;
	ok $lines.elems > 0, 'write log';
	is $lines[0], $expected, 'append log';
});

'04-rewrite-log'.&test(:2plan, {
	setup('lib', proc => RunProc.new);
	my $expected = "previous content";
	$coverage-log.spurt("$expected$?NL");
	collect();
	my $lines = $coverage-log.slurp.lines;
	ok $lines.elems > 0, 'write log';
	isnt $lines[0], $expected, 'rewrite log';
});

'05-do-not-test-without-exec'.&test(:1plan, {
	setup('lib', proc => my $proc = Fixture::fakeProc, :!exec);
	collect();
	nok $proc.c, 'do not test without exec';
});

'06-fail-collect'.&test(:1plan, {
	setup('lib', proc => Fixture::failProc);
	throws-like { collect() }, App::Racoco::X::NonZeroExitCode,
		'no zero exitcode';
});

'07-pass-default-out-to-proc'.&test(:2plan, {
	setup('lib', :outloud, proc => my $proc = Fixture::fakeProc);
	collect();
	ok $proc.c, 'proc is run';
	is $proc.c.hash<out>, '-', 'out passed';
});

'08-pass-true-out-to-proc'.&test(:2plan, {
	setup('lib', :!outloud, proc => my $proc = Fixture::fakeProc);
	collect();
	ok $proc.c, 'proc is run';
	is $proc.c.hash<out>, False, 'out passed';
});

'09-parse-log'.&test(:2plan, {
	setup('lib', proc => Fixture::fakeProc, :!exec);
	my $path = coverage-log-path(:$lib);
	$path.spurt: $path.slurp.subst('lib/', $lib ~ '/', :g);
	my %covered-lines = collect();
	ok %covered-lines<source-file1.rakumod> === bag(1, 2, 2, 1, 3, 5), 'parse 1 ok';
	ok %covered-lines<source-file2.rakumod> === bag(1, 1, 1, 1), 'parse 2 ok';
});

done-testing