use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::UtilExtProc;
use Racoco::TmpDir;
use Racoco::Fixture;

plan 4;

my $sources = create-tmp-dir('racoco-tests');
my $test-file = $sources.add('file');

{
	my $result = RunProc.new.run('echo "boom"', out => $test-file.open(:w));
	ok $test-file.e, 'run echo into file';
	is $test-file.slurp.trim, 'boom', 'echo into file correct';
	is $result.exitcode, 0, 'exitcode 0';
}

{
	Fixture::suppressErr;
  LEAVE { Fixture::restoreErr }
	nok RunProc.new.run('not-exists', :!err), 'run not-exists ok';
}

done-testing