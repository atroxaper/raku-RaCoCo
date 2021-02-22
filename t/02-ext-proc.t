use Test;
use lib 'lib';
use Racoco::UtilExtProc;
use Racoco::UtilTmpFile;

plan 2;

constant tmp-file = Racoco::UtilTmpFile;
LEAVE { tmp-file::clean-up }

my $test-dir = $*TMPDIR.add('ext-proc');
my $test-file = $test-dir.add('file');
tmp-file::create-dir($test-dir);

my $proc = RunProc.new;

$proc.run('echo', 'boom', out => $test-file.open(:w));
ok $test-file.e, 'run echo into file';
is $test-file.slurp.trim, 'boom', 'echo into file correct';

done-testing