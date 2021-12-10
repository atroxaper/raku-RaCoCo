use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::RunProc;
use App::Racoco::Fixture;
use TestResources;
use TestHelper;

plan 2;

my ($test-file, $*subtest, $*plan);
sub setup() {
	plan $*plan;
	TestResources::prepare($*subtest);
	my $sources = TestResources::exam-directory;
	$test-file = $sources.add('file');
}

'01-run-proc-with-vars-and-out'.&test(:3plan, {
	setup();
	my $out will leave { .close } = $test-file.open(:w);
	my %vars = V1 => 'v1', V2 => 'v2';
	my $result = RunProc.new
		.run(q/raku -e "say qq[vars: %*ENV{'V1'} %*ENV{'V2'}]"/, :$out, :%vars);
	ok $test-file.e, 'run say into file';
	is $test-file.slurp.trim, 'vars: v1 v2', 'say into file with vars correct';
	is $result.exitcode, 0, 'exitcode 0';
});

'02-run-without-vars-and-out'.&test(:3plan, {
	setup();
	my $result = RunProc.new
		.run(qq/raku -e "q[{$test-file}].IO.spurt(q[no vars and out])"/);
	ok $test-file.e, 'run spurt into file';
	is $test-file.slurp.trim, 'no vars and out',
		'say into file without any params';
	is $result.exitcode, 0, 'exitcode 0';
});

#{
#	my $out = $test-file.open(:w);
#	LEAVE { .close with $out }
#	my $result = RunProc.new
#			.run(qq/raku -e "q[{$test-file}].IO.spurt(q[no vars and out])"/);
#	ok $test-file.e, 'run spurt into file';
#	is $test-file.slurp.trim, 'no vars and out',
#			'say into file without any params';
#	is $result.exitcode, 0, 'exitcode 0';
#}
#
#{
#  my $actual;
#  Fixture::silently({ $actual = RunProc.new.run(q/not-exists/, :!err) });
#	nok $actual, 'run not-exists ok';
#}

done-testing