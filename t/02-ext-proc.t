use Test;
use lib 'lib';
use Racoco::UtilExtProc;
use Racoco::UtilTmpFile;

plan 4;

constant tmp-file = Racoco::UtilTmpFile;
LEAVE { tmp-file::clean-up }

my $test-dir = tmp-file::create-dir($*TMPDIR.add('ext-proc'));
my $test-file = $test-dir.add('file');

my $proc = RunProc.new;

my $result = $proc.run('echo "boom"', out => $test-file.open(:w));
ok $test-file.e, 'run echo into file';
is $test-file.slurp.trim, 'boom', 'echo into file correct';
is $result.exitcode, 0, 'exitcode 0';

nok $proc.run('not-exists', :!err), 'run not-exists ok';

done-testing